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

  static const _weeklyChart = <_WeeklyOrderBar>[
    _WeeklyOrderBar(label: 'SUN', value: 8),
    _WeeklyOrderBar(label: 'MON', value: 8),
    _WeeklyOrderBar(label: 'TUE', value: 8),
    _WeeklyOrderBar(label: 'WED', value: 8),
    _WeeklyOrderBar(label: 'THU', value: 10, isHighlighted: true),
    _WeeklyOrderBar(label: 'FRI', value: 8),
  ];

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
      backgroundColor: const Color(0xFFF5F6F4),
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
                final recentOrders = _filteredOrders(orders);
                final ordersCount = orders.length;
                final revenueThisWeek = _calculateRevenue(orders);
                final lastWeekRevenue = revenueThisWeek;
                final ordersTrend = 'Showing local demo orders';
                final revenueTrend = 'Showing local demo payments';

                return SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(16, 18, 16, 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
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
                      const SizedBox(height: 14),
                      _OrdersOverviewCard(
                        revenueLabel: _formatCurrency(lastWeekRevenue),
                        ordersLabel: ordersCount.toString(),
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
      final parsed = double.tryParse(
        order.totalPayment.replaceAll(RegExp(r'[^0-9.]'), ''),
      );
      return sum + (parsed ?? 0);
    });
  }

  String _formatCurrency(double value) {
    return '\$${value.toStringAsFixed(2)}';
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
        color: AppColors.brandGreen,
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(26)),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: ValueListenableBuilder<int>(
                      valueListenable: AuthSession.listenable,
                      builder: (context, _, child) {
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Location',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Row(
                              children: [
                                const Icon(
                                  Icons.location_on_rounded,
                                  color: Color(0xFFFF3B30),
                                  size: 18,
                                ),
                                const SizedBox(width: 6),
                                Expanded(
                                  child: Text(
                                    AuthSession.displayLocationLabel,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      fontSize: 13.5,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        );
                      },
                    ),
                  ),
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
              ),
              const SizedBox(height: 18),
              Container(
                height: 44,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: TextField(
                  controller: searchController,
                  onChanged: onSearchChanged,
                  cursorColor: AppColors.brandGreen,
                  decoration: const InputDecoration(
                    hintText: 'Search',
                    hintStyle: TextStyle(
                      fontSize: 13.5,
                      color: Color(0xFF9D9D9D),
                    ),
                    prefixIcon: Icon(
                      Icons.search_rounded,
                      color: Color(0xFF97A39A),
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
            color: Colors.white,
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: const Color(0xFF1E2B21), size: 20),
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
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE6E9E5)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0D000000),
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
                    color: Color(0xFF5C655E),
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
                    color: Color(0xFF4E8A5D),
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
  });

  final String revenueLabel;
  final String ordersLabel;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE6EAE7)),
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
                        color: Color(0xFF7A837D),
                      ),
                    ),
                  ],
                ),
              ),
              _ChangeChip(
                label: '42%',
                caption: 'Than last week',
                backgroundColor: Color(0xFFFFECEC),
                foregroundColor: Color(0xFFE06363),
                icon: Icons.arrow_downward_rounded,
              ),
              SizedBox(width: 8),
              _ChangeChip(
                label: '12%',
                caption: 'Order',
                backgroundColor: Color(0xFFE7F7EE),
                foregroundColor: AppColors.brandGreen,
                icon: Icons.arrow_upward_rounded,
              ),
            ],
          ),
          const SizedBox(height: 18),
          const _WeeklyOrdersChart(),
          const SizedBox(height: 14),
          Center(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: const Color(0xFFF2F5F1),
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
                    'updated 6 mins ago',
                    style: TextStyle(fontSize: 10.5, color: Color(0xFF6F7B72)),
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
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
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
  const _WeeklyOrdersChart();

  @override
  Widget build(BuildContext context) {
    const bars = _ServiceProviderHomeScreenState._weeklyChart;
    const maxValue = 10.0;

    return SizedBox(
      height: 180,
      child: Column(
        children: [
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                for (var index = 0; index < bars.length; index++) ...[
                  Expanded(
                    child: _ChartBar(data: bars[index], maxValue: maxValue),
                  ),
                  if (index != bars.length - 1) const SizedBox(width: 10),
                ],
              ],
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              for (var index = 0; index < bars.length; index++) ...[
                Expanded(
                  child: Text(
                    bars[index].label,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 10,
                      color: Color(0xFF7A837D),
                    ),
                  ),
                ),
                if (index != bars.length - 1) const SizedBox(width: 10),
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
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE6EAE7)),
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
                          color: Color(0xFF1C251F),
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
                    color: Color(0xFF7A837D),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Car Wash: ${_capitalizeWords(order.serviceType)}',
                  style: const TextStyle(
                    fontSize: 11.8,
                    color: Color(0xFF7A837D),
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
                        color: Color(0xFF66736A),
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
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE6EAE7)),
      ),
      child: const Column(
        children: [
          Icon(Icons.receipt_long_outlined, size: 38, color: Color(0xFF8C9990)),
          SizedBox(height: 10),
          Text(
            'No recent orders found',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: Color(0xFF223027),
            ),
          ),
          SizedBox(height: 6),
          Text(
            'Search for another customer or wait for new booking activity.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 12.5,
              height: 1.45,
              color: Color(0xFF6E7A72),
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
