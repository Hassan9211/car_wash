import 'package:car_wash/core/router/app_navigation.dart';
import 'package:car_wash/core/theme/app_colors.dart';
import 'package:car_wash/features/authentication/data/auth_session.dart';
import 'package:car_wash/features/home/booking/data/booking_orders_store.dart';
import 'package:car_wash/features/home/booking/model/booking_order_item.dart';
import 'package:car_wash/features/washer/presentation/widgets/service_provider_bottom_navigation_bar.dart';
import 'package:flutter/material.dart';

class ServiceProviderHomeScreen extends StatefulWidget {
  const ServiceProviderHomeScreen({super.key});

  @override
  State<ServiceProviderHomeScreen> createState() =>
      _ServiceProviderHomeScreenState();
}

class _ServiceProviderHomeScreenState extends State<ServiceProviderHomeScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';



  @override
  void initState() {
    super.initState();
    BookingOrdersStore.instance.fetchProviderOrders();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<BookingOrderItem> _filteredOrders(List<BookingOrderItem> orders) {
    if (_searchQuery.isEmpty) {
      return orders.take(4).toList(growable: false);
    }

    return orders
        .where(
          (order) =>
              order.customerName.toLowerCase().contains(_searchQuery) ||
              order.serviceType.toLowerCase().contains(_searchQuery),
        )
        .take(4)
        .toList(growable: false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.appBackground,
      body: Column(
        children: [
          _ProviderHomeHeader(
            searchController: _searchController,
            onSearchChanged: (value) {
              setState(() {
                _searchQuery = value.trim().toLowerCase();
              });
            },
            onNotificationTap: context.pushToNotifications,
            onSettingsTap: context.pushToServiceProviderSettings,
          ),
          Expanded(
            child: AnimatedBuilder(
              animation: BookingOrdersStore.instance.listenable,
              builder: (context, _) {
                final orders = BookingOrdersStore.instance.orders;
                final providerName = AuthSession.displayName.trim().toLowerCase();
                final currentUserEmail = AuthSession.displayEmail.trim().toLowerCase();

                // Filter all orders for this provider, excluding bookings they created themselves as customers
                final providerOrders = orders.where((o) {
                  final isServiceProvider = o.serviceProviderName.trim().toLowerCase() == providerName;
                  final isOwnBooking = o.customerName.trim().toLowerCase() == providerName || 
                                     o.customerEmail.trim().toLowerCase() == currentUserEmail;
                  return isServiceProvider && !isOwnBooking;
                }).toList(growable: false);

                final recentOrders = _filteredOrders(providerOrders);
                final ordersCount = providerOrders.length;

                // Revenue this week (last 7 days, paid status)
                final now = DateTime.now();
                final sevenDaysAgo = now.subtract(const Duration(days: 7));
                final weeklyOrders = providerOrders.where((o) =>
                  o.orderDate.isAfter(sevenDaysAgo)
                ).toList(growable: false);

                final revenueThisWeek = weeklyOrders
                    .where((o) => o.status == BookingOrderStatus.completed)
                    .fold<double>(0, (sum, o) => sum + _parsePaymentAmount(o.totalPayment));

                final weeklyRevenueData = _buildWeeklyChartData(providerOrders);

                final monthlyRevenueHistory = _buildMonthlyRevenueHistory(
                  providerOrders,
                );

                final ordersTrend = providerOrders.isEmpty
                    ? 'No orders yet'
                    : 'Live provider stats';
                final revenueTrend = weeklyOrders.isEmpty
                    ? 'No weekly activity'
                    : 'Last 7 days revenue';

                return SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(16, 18, 16, 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      IntrinsicHeight(
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Expanded(
                              child: _MetricCard(
                                title: 'Number of orders',
                                value: ordersCount.toString(),
                                trendLabel: ordersTrend,
                                icon: Icons.receipt_long_rounded,
                                iconBackground: Color(0xFFFFF6DE),
                                iconColor: Color(0xFFE1A900),
                              ),
                            ),
                            SizedBox(width: 10),
                            Expanded(
                              child: _MetricCard(
                                title: 'Revenue this week',
                                value: _formatCurrency(revenueThisWeek),
                                trendLabel: revenueTrend,
                                icon: Icons.monetization_on_outlined,
                                iconBackground: Color(0xFFF0ECFF),
                                iconColor: Color(0xFF7A5AF8),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 14),
                      _OrdersOverviewCard(
                        revenueLabel: _formatCurrency(revenueThisWeek),
                        ordersLabel: ordersCount.toString(),
                        weeklyChartData: weeklyRevenueData,
                        onRevenueHistoryTap: () =>
                            _showRevenueHistorySheet(monthlyRevenueHistory),
                      ),
                      const SizedBox(height: 18),
                      const _RecentOrdersHeader(),
                      const SizedBox(height: 12),
                      if (recentOrders.isEmpty)
                        const _ProviderEmptyState()
                      else
                        for (
                          var index = 0;
                          index < recentOrders.length;
                          index++
                        ) ...[
                          _RecentOrderCard(order: recentOrders[index]),
                          if (index != recentOrders.length - 1)
                            const SizedBox(height: 12),
                        ],
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
      bottomNavigationBar: const ServiceProviderBottomNavigationBar(
        selectedTab: ServiceProviderBottomTab.home,
      ),
    );
  }

  double _calculateRevenue(List<BookingOrderItem> orders) {
    return orders.fold<double>(0, (sum, order) {
      return sum + _parsePaymentAmount(order.totalPayment);
    });
  }

  String _formatCurrency(double value) {
    return '\$${value.toStringAsFixed(2)}';
  }

  double _parsePaymentAmount(String rawAmount) {
    final parsed = double.tryParse(
      rawAmount.replaceAll(RegExp(r'[^0-9.]'), ''),
    );
    return parsed ?? 0;
  }

  List<_WeeklyOrderBar> _buildWeeklyChartData(List<BookingOrderItem> orders) {
    final now = DateTime.now();
    final data = <_WeeklyOrderBar>[];

    // Last 7 days including today
    for (var i = 6; i >= 0; i--) {
      final date = now.subtract(Duration(days: i));
      final dayLabel = _dayOfWeekLabel(date.weekday);

      final dayTotal = orders
          .where((o) =>
              o.status == BookingOrderStatus.completed &&
              o.orderDate.year == date.year &&
              o.orderDate.month == date.month &&
              o.orderDate.day == date.day)
          .fold<double>(0, (sum, o) => sum + _parsePaymentAmount(o.totalPayment));

      data.add(_WeeklyOrderBar(
        label: dayLabel,
        value: dayTotal,
        isHighlighted: i == 0,
      ));
    }

    return data;
  }

  String _dayOfWeekLabel(int weekday) {
    const days = <String>['MON', 'TUE', 'WED', 'THU', 'FRI', 'SAT', 'SUN'];
    return days[weekday - 1];
  }

  List<_MonthlyRevenuePoint> _buildMonthlyRevenueHistory(
    List<BookingOrderItem> orders,
  ) {
    final referenceDate = _resolveRevenueReferenceDate(orders);
    final monthlyTotals = <String, double>{};

    for (final order in orders) {
      final amount = _parsePaymentAmount(order.totalPayment);
      if (amount <= 0) {
        continue;
      }

      final monthDate = DateTime(
        order.paymentDate.year,
        order.paymentDate.month,
      );
      final key = _monthKey(monthDate);
      monthlyTotals[key] = (monthlyTotals[key] ?? 0) + amount;
    }

    final history = <_MonthlyRevenuePoint>[
      for (var offset = 5; offset >= 0; offset--)
        _MonthlyRevenuePoint(
          label: _monthLabel(
            DateTime(referenceDate.year, referenceDate.month - offset),
          ),
          amount:
              monthlyTotals[_monthKey(
                DateTime(referenceDate.year, referenceDate.month - offset),
              )] ??
              0,
          isHighlighted: offset == 0,
        ),
    ];

    final populatedMonths = history.where((point) => point.amount > 0).length;
    if (populatedMonths >= 2) {
      return history;
    }

    final fallbackAmounts = _buildFallbackRevenueHistory(
      seedRevenue: history.last.amount > 0
          ? history.last.amount
          : _calculateRevenue(orders),
    );

    return [
      for (var index = 0; index < history.length; index++)
        _MonthlyRevenuePoint(
          label: history[index].label,
          amount: history[index].amount > 0
              ? history[index].amount
              : fallbackAmounts[index],
          isHighlighted: history[index].isHighlighted,
        ),
    ];
  }

  DateTime _resolveRevenueReferenceDate(List<BookingOrderItem> orders) {
    if (orders.isEmpty) {
      return DateTime.now();
    }

    return orders
        .map((order) => order.paymentDate)
        .reduce(
          (latest, current) => current.isAfter(latest) ? current : latest,
        );
  }

  List<double> _buildFallbackRevenueHistory({required double seedRevenue}) {
    final safeRevenue = seedRevenue <= 0 ? 240 : seedRevenue;
    const ratios = <double>[0.44, 0.56, 0.63, 0.74, 0.86, 1];

    return [
      for (final ratio in ratios)
        double.parse((safeRevenue * ratio).toStringAsFixed(2)),
    ];
  }

  String _monthKey(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}';
  }

  String _monthLabel(DateTime date) {
    const months = <String>[
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];

    return months[date.month - 1];
  }

  Future<void> _showRevenueHistorySheet(
    List<_MonthlyRevenuePoint> revenueHistory,
  ) async {
    if (!mounted || revenueHistory.isEmpty) {
      return;
    }

    final totalRevenue = revenueHistory.fold<double>(
      0,
      (sum, point) => sum + point.amount,
    );
    final averageRevenue = totalRevenue / revenueHistory.length;
    final bestMonth = revenueHistory.reduce(
      (best, point) => point.amount > best.amount ? point : best,
    );
    final latestRevenue = revenueHistory.last.amount;
    final previousRevenue = revenueHistory.length > 1
        ? revenueHistory[revenueHistory.length - 2].amount
        : 0.0;
    final monthlyChange = previousRevenue <= 0
        ? null
        : ((latestRevenue - previousRevenue) / previousRevenue) * 100;

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (bottomSheetContext) {
        final sheetHeight =
            MediaQuery.of(bottomSheetContext).size.height * 0.82;

        return SafeArea(
          top: false,
          child: Container(
            height: sheetHeight,
            padding: const EdgeInsets.fromLTRB(18, 12, 18, 20),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(28),
              ),
              border: Border.all(color: AppColors.border),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 42,
                    height: 4,
                    decoration: BoxDecoration(
                      color: AppColors.border,
                      borderRadius: BorderRadius.circular(999),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  '6-Month Revenue',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Last 6 months ka revenue chart. Is mein recent payment activity ka view dikh raha hai.',
                  style: const TextStyle(
                    fontSize: 12.5,
                    height: 1.45,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 18),
                Row(
                  children: [
                    Expanded(
                      child: _RevenueSummaryCard(
                        title: 'Total revenue',
                        value: _formatCurrency(totalRevenue),
                        subtitle: '6 months total',
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _RevenueSummaryCard(
                        title: 'Average / month',
                        value: _formatCurrency(averageRevenue),
                        subtitle: bestMonth.label == revenueHistory.last.label
                            ? 'Best month is current'
                            : 'Best month: ${bestMonth.label}',
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                Container(
                  width: double.infinity,
                  height: 308,
                  padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceElevated,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Expanded(
                            child: Text(
                              'Revenue performance',
                              style: TextStyle(
                                fontSize: 14.5,
                                fontWeight: FontWeight.w700,
                                color: AppColors.textPrimary,
                              ),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: monthlyChange == null
                                  ? AppColors.surfaceMuted
                                  : monthlyChange >= 0
                                  ? AppColors.successSurface
                                  : AppColors.dangerSurface,
                              borderRadius: BorderRadius.circular(999),
                            ),
                            child: Text(
                              monthlyChange == null
                                  ? 'No comparison'
                                  : '${monthlyChange >= 0 ? '+' : ''}${monthlyChange.toStringAsFixed(0)}%',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: monthlyChange == null
                                    ? AppColors.textSecondary
                                    : monthlyChange >= 0
                                    ? AppColors.brandGreenLight
                                    : const Color(0xFFFF9E9E),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Expanded(
                        child: _MonthlyRevenueChart(data: revenueHistory),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),
                Expanded(
                  child: ListView.separated(
                    itemCount: revenueHistory.length,
                    separatorBuilder: (context, index) =>
                        const SizedBox(height: 8),
                    itemBuilder: (context, index) {
                      final point = revenueHistory[index];

                      return Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 12,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.surfaceElevated,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: point.isHighlighted
                                ? AppColors.brandGreen.withValues(alpha: 0.34)
                                : AppColors.border,
                          ),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(
                                point.label,
                                style: TextStyle(
                                  fontSize: 13.5,
                                  fontWeight: point.isHighlighted
                                      ? FontWeight.w700
                                      : FontWeight.w600,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                            ),
                            Text(
                              _formatCurrency(point.amount),
                              style: TextStyle(
                                fontSize: 13.2,
                                fontWeight: FontWeight.w700,
                                color: point.isHighlighted
                                    ? AppColors.brandGreen
                                    : AppColors.textPrimary,
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _ProviderHomeHeader extends StatelessWidget {
  const _ProviderHomeHeader({
    required this.searchController,
    required this.onSearchChanged,
    required this.onNotificationTap,
    required this.onSettingsTap,
  });

  final TextEditingController searchController;
  final ValueChanged<String> onSearchChanged;
  final VoidCallback onNotificationTap;
  final VoidCallback onSettingsTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF0F6430), AppColors.brandGreen, AppColors.deepInk],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(26)),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ValueListenableBuilder<int>(
                valueListenable: AuthSession.listenable,
                builder: (context, _, __) {
                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // Avatar – tapping goes to SP profile
                      GestureDetector(
                        onTap: context.goToServiceProviderProfile,
                        child: Container(
                          width: 46,
                          height: 46,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: Colors.white.withValues(alpha: 0.7),
                              width: 2,
                            ),
                          ),
                          child: ClipOval(
                            child: Image(
                              image: AuthSession.avatarImage,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => Container(
                                color: Colors.white.withValues(alpha: 0.18),
                                child: Center(
                                  child: Text(
                                    AuthSession.initials,
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w700,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      // Name + location
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Hi, ${AuthSession.displayName.split(' ').first} 👋',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                const Icon(
                                  Icons.location_on_rounded,
                                  color: Color(0xFFFF3B30),
                                  size: 14,
                                ),
                                const SizedBox(width: 4),
                                Expanded(
                                  child: Text(
                                    AuthSession.displayLocationLabel,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: Colors.white70,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      // Action buttons
                      _HeaderIconButton(
                        icon: Icons.notifications_active_outlined,
                        onTap: onNotificationTap,
                      ),
                      const SizedBox(width: 8),
                      _HeaderIconButton(
                        icon: Icons.settings_outlined,
                        onTap: onSettingsTap,
                      ),
                    ],
                  );
                },
              ),
              const SizedBox(height: 18),
              Container(
                height: 44,
                decoration: BoxDecoration(
                  color: AppColors.surfaceElevated,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: AppColors.border),
                ),
                child: TextField(
                  controller: searchController,
                  onChanged: onSearchChanged,
                  cursorColor: AppColors.brandGreen,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 13.5,
                  ),
                  decoration: const InputDecoration(
                    hintText: 'Search',
                    hintStyle: TextStyle(
                      fontSize: 13.5,
                      color: AppColors.textMuted,
                    ),
                    prefixIcon: Icon(
                      Icons.search_rounded,
                      color: AppColors.brandGreenLight,
                      size: 22,
                    ),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 12,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _HeaderIconButton extends StatelessWidget {
  const _HeaderIconButton({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        customBorder: const CircleBorder(),
        child: Ink(
          width: 38,
          height: 38,
          decoration: const BoxDecoration(
            color: AppColors.surface,
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: AppColors.textPrimary, size: 20),
        ),
      ),
    );
  }
}

class _MetricCard extends StatelessWidget {
  const _MetricCard({
    required this.title,
    required this.value,
    required this.trendLabel,
    required this.icon,
    required this.iconBackground,
    required this.iconColor,
  });

  final String title;
  final String value;
  final String trendLabel;
  final IconData icon;
  final Color iconBackground;
  final Color iconColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minHeight: 118),
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
      decoration: BoxDecoration(
        color: AppColors.surfaceElevated,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.14),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 10.5,
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
              Container(
                width: 18,
                height: 18,
                decoration: BoxDecoration(
                  color: iconBackground,
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, size: 11, color: iconColor),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w700,
              color: AppColors.brandGreen,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(
                Icons.trending_up_rounded,
                size: 14,
                color: AppColors.brandGreen,
              ),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  trendLabel,
                  style: const TextStyle(
                    fontSize: 10.5,
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _OrdersOverviewCard extends StatelessWidget {
  const _OrdersOverviewCard({
    required this.revenueLabel,
    required this.ordersLabel,
    required this.weeklyChartData,
    required this.onRevenueHistoryTap,
  });

  final String revenueLabel;
  final String ordersLabel;
  final List<_WeeklyOrderBar> weeklyChartData;
  final VoidCallback onRevenueHistoryTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
      decoration: BoxDecoration(
        color: AppColors.surfaceElevated,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Orders',
                      style: TextStyle(
                        fontSize: 13.5,
                        fontWeight: FontWeight.w600,
                        color: AppColors.brandGreen,
                      ),
                    ),
                    SizedBox(height: 6),
                    Text(
                      revenueLabel,
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w700,
                        color: AppColors.brandGreen,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      '$ordersLabel total orders',
                      style: TextStyle(
                        fontSize: 10.5,
                        color: AppColors.textMuted,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(
                width: 168,
                child: IntrinsicHeight(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Expanded(
                        child: _ChangeChip(
                          label: '42%',
                          caption: 'Than last week',
                          backgroundColor: AppColors.dangerSurface,
                          foregroundColor: Color(0xFFFF9E9E),
                          icon: Icons.arrow_downward_rounded,
                        ),
                      ),
                      SizedBox(width: 8),
                      Expanded(
                        child: _ChangeChip(
                          label: '12%',
                          caption: 'Order',
                          backgroundColor: AppColors.successSurface,
                          foregroundColor: AppColors.brandGreenLight,
                          icon: Icons.arrow_upward_rounded,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: onRevenueHistoryTap,
              borderRadius: BorderRadius.circular(16),
              child: Ink(
                padding: const EdgeInsets.fromLTRB(12, 12, 12, 10),
                decoration: BoxDecoration(
                  color: AppColors.surfaceMuted,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.border),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Expanded(
                          child: Text(
                            'Weekly activity',
                            style: TextStyle(
                              fontSize: 13.5,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ),
                        Icon(
                          Icons.show_chart_rounded,
                          size: 18,
                          color: AppColors.brandGreen,
                        ),
                      ],
                    ),
                    SizedBox(height: 14),
                    _WeeklyOrdersChart(data: weeklyChartData),
                    SizedBox(height: 10),
                    Row(
                      children: [
                        Icon(
                          Icons.touch_app_rounded,
                          size: 14,
                          color: AppColors.brandGreen,
                        ),
                        SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            'Tap chart to view last 6 months revenue',
                            style: TextStyle(
                              fontSize: 10.8,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ),
                        Icon(
                          Icons.arrow_forward_ios_rounded,
                          size: 12,
                          color: AppColors.textMuted,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 14),
          Center(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.surfaceMuted,
                borderRadius: BorderRadius.circular(999),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.refresh_rounded,
                    size: 14,
                    color: AppColors.brandGreen,
                  ),
                  SizedBox(width: 4),
                  Text(
                    'Just updated',
                    style: TextStyle(
                      fontSize: 10.5,
                      color: AppColors.textMuted,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ChangeChip extends StatelessWidget {
  const _ChangeChip({
    required this.label,
    required this.caption,
    required this.backgroundColor,
    required this.foregroundColor,
    required this.icon,
  });

  final String label;
  final String caption;
  final Color backgroundColor;
  final Color foregroundColor;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minHeight: 56),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 11, color: foregroundColor),
              const SizedBox(width: 2),
              Text(
                label,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: foregroundColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 2),
          Text(
            caption,
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 8.5,
              color: foregroundColor.withValues(alpha: 0.88),
            ),
          ),
        ],
      ),
    );
  }
}

class _WeeklyOrdersChart extends StatelessWidget {
  const _WeeklyOrdersChart({required this.data});

  final List<_WeeklyOrderBar> data;

  @override
  Widget build(BuildContext context) {
    final maxValue = data.fold<double>(
      10.0, // Base max to avoid empty chart looking weird
      (highest, bar) => bar.value > highest ? bar.value : highest,
    );

    return SizedBox(
      height: 180,
      child: Column(
        children: [
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                for (var index = 0; index < data.length; index++) ...[
                  Expanded(
                    child: _ChartBar(data: data[index], maxValue: maxValue),
                  ),
                  if (index != data.length - 1) const SizedBox(width: 10),
                ],
              ],
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              for (var index = 0; index < data.length; index++) ...[
                Expanded(
                  child: Text(
                    data[index].label,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 10,
                      color: AppColors.textMuted,
                    ),
                  ),
                ),
                if (index != data.length - 1) const SizedBox(width: 10),
              ],
            ],
          ),
        ],
      ),
    );
  }
}

class _ChartBar extends StatelessWidget {
  const _ChartBar({required this.data, required this.maxValue});

  final _WeeklyOrderBar data;
  final double maxValue;

  @override
  Widget build(BuildContext context) {
    final normalizedHeight = (data.value / maxValue).clamp(0.0, 1.0);

    return Align(
      alignment: Alignment.bottomCenter,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Container(
            width: 14,
            height: 112 * normalizedHeight,
            decoration: BoxDecoration(
              color: data.isHighlighted
                  ? const Color(0xFF095F21)
                  : AppColors.brandGreen.withValues(alpha: 0.82),
              borderRadius: BorderRadius.circular(6),
            ),
          ),
        ],
      ),
    );
  }
}

class _RecentOrdersHeader extends StatelessWidget {
  const _RecentOrdersHeader();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: const [
        SizedBox(
          width: 4,
          height: 24,
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: AppColors.brandGreen,
              borderRadius: BorderRadius.all(Radius.circular(999)),
            ),
          ),
        ),
        SizedBox(width: 8),
        Text(
          'Recent Orders',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w700,
            color: AppColors.brandGreen,
          ),
        ),
      ],
    );
  }
}

class _RecentOrderCard extends StatelessWidget {
  const _RecentOrderCard({required this.order});

  final BookingOrderItem order;

  @override
  Widget build(BuildContext context) {
    final initials = _initialsFromName(order.customerName);

    return Container(
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
      decoration: BoxDecoration(
        color: AppColors.surfaceElevated,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 22,
            backgroundColor: const Color(0xFFEAF7EE),
            child: Text(
              initials,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: AppColors.brandGreen,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        order.customerName,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ),
                    Text(
                      order.totalPayment,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: AppColors.brandGreen,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  'Booking on ${_formatOrderDate(order.paymentDate)}',
                  style: const TextStyle(
                    fontSize: 11.5,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Car Wash: ${_capitalizeWords(order.serviceType)}',
                  style: const TextStyle(
                    fontSize: 11.8,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    for (var index = 0; index < 3; index++) ...[
                      const Icon(
                        Icons.star_rounded,
                        size: 14,
                        color: AppColors.brandGreen,
                      ),
                      if (index != 2) const SizedBox(width: 2),
                    ],
                    const SizedBox(width: 8),
                    Text(
                      '${_ratingLabel(order)}/5',
                      style: const TextStyle(
                        fontSize: 11.5,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _initialsFromName(String name) {
    final words = name
        .split(RegExp(r'\s+'))
        .where((word) => word.isNotEmpty)
        .toList(growable: false);

    if (words.isEmpty) {
      return 'CU';
    }

    if (words.length == 1) {
      final word = words.first;
      return word.length >= 2
          ? word.substring(0, 2).toUpperCase()
          : word.toUpperCase();
    }

    return '${words.first[0]}${words.last[0]}'.toUpperCase();
  }

  String _formatOrderDate(DateTime value) {
    const months = <String>[
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];

    final hour = value.hour % 12 == 0 ? 12 : value.hour % 12;
    final minute = value.minute.toString().padLeft(2, '0');
    return '${value.day} ${months[value.month - 1]}, $hour:$minute';
  }

  String _capitalizeWords(String value) {
    return value
        .split(RegExp(r'\s+'))
        .where((word) => word.isNotEmpty)
        .map(
          (word) =>
              '${word[0].toUpperCase()}${word.substring(1).toLowerCase()}',
        )
        .join(' ');
  }

  String _ratingLabel(BookingOrderItem order) {
    if (order.reviewRating != null) {
      return order.reviewRating.toString();
    }

    final parsedRating = double.tryParse(order.rating);
    if (parsedRating == null) {
      return '4';
    }

    return parsedRating.round().clamp(1, 5).toString();
  }
}

class _ProviderEmptyState extends StatelessWidget {
  const _ProviderEmptyState();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 24),
      decoration: BoxDecoration(
        color: AppColors.surfaceElevated,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: const Column(
        children: [
          Icon(
            Icons.receipt_long_outlined,
            size: 38,
            color: AppColors.textMuted,
          ),
          SizedBox(height: 10),
          Text(
            'No recent orders found',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          SizedBox(height: 6),
          Text(
            'Search for another customer or wait for new booking activity.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 12.5,
              height: 1.45,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

class _WeeklyOrderBar {
  const _WeeklyOrderBar({
    required this.label,
    required this.value,
    this.isHighlighted = false,
  });

  final String label;
  final double value;
  final bool isHighlighted;
}

class _MonthlyRevenuePoint {
  const _MonthlyRevenuePoint({
    required this.label,
    required this.amount,
    this.isHighlighted = false,
  });

  final String label;
  final double amount;
  final bool isHighlighted;
}

class _RevenueSummaryCard extends StatelessWidget {
  const _RevenueSummaryCard({
    required this.title,
    required this.value,
    required this.subtitle,
  });

  final String title;
  final String value;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
      decoration: BoxDecoration(
        color: AppColors.surfaceElevated,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 11.5,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: AppColors.brandGreen,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            subtitle,
            style: const TextStyle(fontSize: 10.5, color: AppColors.textMuted),
          ),
        ],
      ),
    );
  }
}

class _MonthlyRevenueChart extends StatelessWidget {
  const _MonthlyRevenueChart({required this.data});

  final List<_MonthlyRevenuePoint> data;

  @override
  Widget build(BuildContext context) {
    final maxRevenue = data.fold<double>(
      0,
      (highest, point) => point.amount > highest ? point.amount : highest,
    );
    final safeMaxRevenue = maxRevenue <= 0 ? 1.0 : maxRevenue;

    return SizedBox(
      height: 220,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          for (var index = 0; index < data.length; index++) ...[
            Expanded(
              child: _MonthlyRevenueBar(
                point: data[index],
                maxRevenue: safeMaxRevenue,
              ),
            ),
            if (index != data.length - 1) const SizedBox(width: 10),
          ],
        ],
      ),
    );
  }
}

class _MonthlyRevenueBar extends StatelessWidget {
  const _MonthlyRevenueBar({required this.point, required this.maxRevenue});

  final _MonthlyRevenuePoint point;
  final double maxRevenue;

  @override
  Widget build(BuildContext context) {
    final normalizedHeight = (point.amount / maxRevenue).clamp(0.0, 1.0);

    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Text(
          _compactCurrencyLabel(point.amount),
          style: TextStyle(
            fontSize: 9.5,
            fontWeight: FontWeight.w600,
            color: point.isHighlighted
                ? AppColors.brandGreenLight
                : AppColors.textMuted,
          ),
        ),
        const SizedBox(height: 8),
        Expanded(
          child: Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              width: 20,
              height: 130 * normalizedHeight + 14,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: point.isHighlighted
                      ? const [Color(0xFFE8C968), AppColors.brandGreen]
                      : [
                          AppColors.brandGreenLight.withValues(alpha: 0.88),
                          AppColors.brandGreen.withValues(alpha: 0.76),
                        ],
                ),
                borderRadius: BorderRadius.circular(999),
              ),
            ),
          ),
        ),
        const SizedBox(height: 10),
        Text(
          point.label,
          style: TextStyle(
            fontSize: 10.5,
            fontWeight: point.isHighlighted ? FontWeight.w700 : FontWeight.w600,
            color: point.isHighlighted
                ? AppColors.textPrimary
                : AppColors.textMuted,
          ),
        ),
      ],
    );
  }
}

String _compactCurrencyLabel(double amount) {
  if (amount >= 1000) {
    return '\$${(amount / 1000).toStringAsFixed(1)}k';
  }

  return '\$${amount.toStringAsFixed(0)}';
}
