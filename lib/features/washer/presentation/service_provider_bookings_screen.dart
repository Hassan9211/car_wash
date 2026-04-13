import 'package:car_wash/core/router/app_navigation.dart';
import 'package:car_wash/core/theme/app_button_styles.dart';
import 'package:car_wash/core/theme/app_colors.dart';
import 'package:car_wash/features/authentication/data/auth_session.dart';
import 'package:car_wash/features/home/booking/data/booking_orders_store.dart';
import 'package:car_wash/features/home/booking/model/booking_order_item.dart';
import 'package:car_wash/features/washer/presentation/widgets/service_provider_bottom_navigation_bar.dart';
import 'package:flutter/material.dart';

class ServiceProviderBookingsScreen extends StatefulWidget {
  const ServiceProviderBookingsScreen({super.key});

  @override
  State<ServiceProviderBookingsScreen> createState() =>
      _ServiceProviderBookingsScreenState();
}

class _ServiceProviderBookingsScreenState
    extends State<ServiceProviderBookingsScreen> {
  _ProviderBookingsTab _selectedTab = _ProviderBookingsTab.pending;

  @override
  void initState() {
    super.initState();
    BookingOrdersStore.instance.fetchProviderOrders();
  }

  List<_ProviderPendingBooking> _buildPendingBookings(
    List<BookingOrderItem> orders,
  ) {
    final providerName = AuthSession.currentName?.trim().isNotEmpty == true
        ? AuthSession.displayName
        : 'Robert Fox';

    final pendingOrders = orders
        .where((order) => order.status == BookingOrderStatus.pending)
        .toList(growable: false)
      ..sort(
        (first, second) =>
            second.notificationTimestamp.compareTo(first.notificationTimestamp),
      );

    if (pendingOrders.isEmpty) {
      return const [];
    }

    return pendingOrders
        .map(
          (order) => _ProviderPendingBooking(
            orderId: order.id,
            customerName: order.customerName,
            email: order.customerEmail.isNotEmpty
                ? order.customerEmail
                : 'customer@example.com',
            serviceType: order.serviceType,
            providerName: providerName,
            scheduledAt: order.orderDate,
          ),
        )
        .toList(growable: false);
  }

  List<_ProviderBookingSummary> _buildAcceptedBookings(
    List<BookingOrderItem> orders,
  ) {
    final acceptedOrders = orders
        .where(
          (order) =>
              order.status == BookingOrderStatus.accepted ||
              order.status == BookingOrderStatus.orderPlaced ||
              order.status == BookingOrderStatus.inProgress,
        )
        .toList(growable: false)
      ..sort(
        (first, second) =>
            second.notificationTimestamp.compareTo(first.notificationTimestamp),
      );

    if (acceptedOrders.isEmpty) {
      return const [];
    }

    return acceptedOrders
        .map(
          (order) => _ProviderBookingSummary(
            order: order,
            customerName: order.customerName,
            orderDate: order.orderDate,
            totalPayment: order.totalPayment,
            status: _ProviderBookingStatus.accepted,
          ),
        )
        .toList(growable: false);
  }

  List<_ProviderBookingSummary> _buildCompletedBookings(
    List<BookingOrderItem> orders,
  ) {
    final completedOrders = orders
        .where((order) => order.status == BookingOrderStatus.completed)
        .toList(growable: false)
      ..sort(
        (first, second) =>
            second.notificationTimestamp.compareTo(first.notificationTimestamp),
      );

    if (completedOrders.isEmpty) {
      return const [];
    }

    return completedOrders
        .map(
          (order) => _ProviderBookingSummary(
            order: order,
            customerName: order.customerName,
            orderDate: order.orderDate,
            totalPayment: order.totalPayment,
            status: _ProviderBookingStatus.completed,
          ),
        )
        .toList(growable: false);
  }

  Future<void> _acceptPendingBooking(_ProviderPendingBooking booking) async {
    if (booking.email == AuthSession.displayEmail) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          const SnackBar(content: Text('You cannot accept your own booking!')),
        );
      return;
    }

    try {
      await BookingOrdersStore.instance.updateStatus(
        booking.orderId,
        BookingOrderStatus.accepted,
      );

      if (!mounted) {
        return;
      }

      setState(() {
        _selectedTab = _ProviderBookingsTab.accepted;
      });

      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            content: Text(
              '${booking.customerName} booking accepted. Customer notified.',
            ),
          ),
        );
    } catch (error) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(content: Text(error.toString())));
    }
  }

  Future<void> _declinePendingBooking(_ProviderPendingBooking booking) async {
    try {
      await BookingOrdersStore.instance.cancelOrder(booking.orderId);

      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(content: Text('${booking.customerName} booking declined')),
        );
    } catch (error) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(content: Text(error.toString())));
    }
  }

  Future<void> _openTracking(BookingOrderItem order) async {
    await context.pushToBookingTracking(order);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.appBackground,
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(
              height: 54,
              child: Center(
                child: Text(
                  'Bookings',
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
            ),
            Divider(
              height: 1,
              thickness: 0.8,
              color: AppColors.border,
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 12, 12, 0),
              child: _ProviderBookingsTabBar(
                selectedTab: _selectedTab,
                onChanged: (tab) {
                  setState(() {
                    _selectedTab = tab;
                  });
                },
              ),
            ),
            Expanded(
              child: ValueListenableBuilder<List<BookingOrderItem>>(
                valueListenable: BookingOrdersStore.instance.listenable,
                builder: (context, orders, _) {
                  final pendingBookings = _buildPendingBookings(orders);
                  final acceptedBookings = _buildAcceptedBookings(orders);
                  final completedBookings = _buildCompletedBookings(orders);

                  return switch (_selectedTab) {
                    _ProviderBookingsTab.accepted => _SummaryBookingsList(
                      items: acceptedBookings,
                      onTap: _openTracking,
                    ),
                    _ProviderBookingsTab.pending => _PendingBookingsList(
                      items: pendingBookings,
                      onAccept: (booking) {
                        _acceptPendingBooking(booking);
                      },
                      onDecline: (booking) {
                        _declinePendingBooking(booking);
                      },
                    ),
                    _ProviderBookingsTab.completed => _SummaryBookingsList(
                      items: completedBookings,
                    ),
                  };
                },
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: const ServiceProviderBottomNavigationBar(
        selectedTab: ServiceProviderBottomTab.bookings,
      ),
    );
  }
}

class _ProviderBookingsTabBar extends StatelessWidget {
  const _ProviderBookingsTabBar({
    required this.selectedTab,
    required this.onChanged,
  });

  final _ProviderBookingsTab selectedTab;
  final ValueChanged<_ProviderBookingsTab> onChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: _ProviderBookingsTab.values
          .map(
            (tab) => Expanded(
              child: _ProviderBookingsTabItem(
                label: tab.label,
                isSelected: selectedTab == tab,
                onTap: () => onChanged(tab),
              ),
            ),
          )
          .toList(growable: false),
    );
  }
}

class _ProviderBookingsTabItem extends StatelessWidget {
  const _ProviderBookingsTabItem({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w400,
                  color: isSelected
                      ? AppColors.brandGreen
                      : AppColors.textMuted,
                ),
              ),
            ),
            Container(
              height: 1.8,
              color: isSelected
                  ? AppColors.brandGreen
                  : AppColors.border,
            ),
          ],
        ),
      ),
    );
  }
}

class _SummaryBookingsList extends StatelessWidget {
  const _SummaryBookingsList({
    required this.items,
    this.onTap,
  });

  final List<_ProviderBookingSummary> items;
  final ValueChanged<BookingOrderItem>? onTap;

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return const _ProviderBookingsEmptyState(
        message: 'No bookings available right now.',
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(12, 14, 12, 18),
      itemCount: items.length,
      separatorBuilder: (_, _) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        return _ProviderSummaryBookingCard(
          item: items[index],
          onTap: onTap == null ? null : () => onTap!(items[index].order),
        );
      },
    );
  }
}

class _PendingBookingsList extends StatelessWidget {
  const _PendingBookingsList({
    required this.items,
    required this.onAccept,
    required this.onDecline,
  });

  final List<_ProviderPendingBooking> items;
  final ValueChanged<_ProviderPendingBooking> onAccept;
  final ValueChanged<_ProviderPendingBooking> onDecline;

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return const _ProviderBookingsEmptyState(
        message: 'No pending booking requests right now.',
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(12, 14, 12, 18),
      itemCount: items.length,
      separatorBuilder: (_, _) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final item = items[index];
        return _ProviderPendingBookingCard(
          item: item,
          onAccept: () => onAccept(item),
          onDecline: () => onDecline(item),
        );
      },
    );
  }
}

class _ProviderSummaryBookingCard extends StatelessWidget {
  const _ProviderSummaryBookingCard({
    required this.item,
    this.onTap,
  });

  final _ProviderBookingSummary item;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Ink(
          padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
          decoration: BoxDecoration(
            color: AppColors.surfaceElevated,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.border),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.14),
                blurRadius: 18,
                offset: Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  _ProviderStatusBadge(status: item.status),
                  const Spacer(),
                  if (onTap != null)
                    const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.route_rounded,
                          size: 14,
                          color: AppColors.brandGreen,
                        ),
                        SizedBox(width: 6),
                        Text(
                          'Track',
                          style: TextStyle(
                            fontSize: 11.5,
                            fontWeight: FontWeight.w600,
                            color: AppColors.brandGreen,
                          ),
                        ),
                      ],
                    ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _SummaryInfoColumn(
                      label: 'Name',
                      value: item.customerName,
                    ),
                  ),
                  Expanded(
                    child: _SummaryInfoColumn(
                      label: 'Order Date',
                      value: _formatShortDate(item.orderDate),
                    ),
                  ),
                  Expanded(
                    child: _SummaryInfoColumn(
                      label: 'Total Payment',
                      value: item.totalPayment,
                      alignment: CrossAxisAlignment.end,
                      textAlign: TextAlign.right,
                    ),
                  ),
                ],
              ),
              if (item.order.paymentStatus == BookingPaymentStatus.paid) ...[
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.successSurface,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.payments_rounded,
                        size: 15,
                        color: AppColors.brandGreenLight,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          '${item.customerName} has paid ${item.totalPayment}',
                          style: const TextStyle(
                            fontSize: 11.8,
                            fontWeight: FontWeight.w600,
                            color: AppColors.brandGreenLight,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _ProviderPendingBookingCard extends StatelessWidget {
  const _ProviderPendingBookingCard({
    required this.item,
    required this.onAccept,
    required this.onDecline,
  });

  final _ProviderPendingBooking item;
  final VoidCallback onAccept;
  final VoidCallback onDecline;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
      decoration: BoxDecoration(
        color: AppColors.surfaceElevated,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  children: [
                    _PendingInfoRow(
                      icon: Icons.person_rounded,
                      label: 'Name',
                      value: item.customerName,
                    ),
                    const SizedBox(height: 10),
                    _PendingInfoRow(
                      icon: Icons.email_outlined,
                      label: 'Email',
                      value: item.email,
                    ),
                    const SizedBox(height: 10),
                    _PendingInfoRow(
                      icon: Icons.directions_car_filled_rounded,
                      label: 'Service Type',
                      value: item.serviceType,
                    ),
                    const SizedBox(height: 10),
                    _PendingInfoRow(
                      icon: Icons.person_pin_circle_outlined,
                      label: 'Service Provider',
                      value: item.providerName,
                    ),
                    const SizedBox(height: 10),
                    _PendingInfoRow(
                      icon: Icons.calendar_month_rounded,
                      label: _formatPendingDate(item.scheduledAt),
                      value: '',
                      compact: true,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              CircleAvatar(
                radius: 22,
                backgroundColor: const Color(0xFFEAF7EE),
                child: Text(
                  _initials(item.customerName),
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: AppColors.brandGreen,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Divider(height: 1, color: AppColors.border),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: FilledButton(
                  onPressed: onAccept,
                  style: AppButtonStyles.filled(
                    backgroundColor: AppColors.surfaceHighlight,
                    foregroundColor: Colors.white,
                    side: const BorderSide(color: AppColors.brandGreen),
                    height: 44,
                  ),
                  child: const Text('Accept'),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: FilledButton(
                  onPressed: onDecline,
                  style: AppButtonStyles.filled(
                    backgroundColor: AppColors.surfaceMuted,
                    foregroundColor: AppColors.textSecondary,
                    side: const BorderSide(color: AppColors.border),
                    height: 44,
                  ),
                  child: const Text('Decline'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _PendingInfoRow extends StatelessWidget {
  const _PendingInfoRow({
    required this.icon,
    required this.label,
    required this.value,
    this.compact = false,
  });

  final IconData icon;
  final String label;
  final String value;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 24,
          height: 24,
          decoration: const BoxDecoration(
            color: AppColors.brandGreen,
            shape: BoxShape.circle,
          ),
          child: Icon(icon, size: 14, color: Colors.white),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: compact
              ? Padding(
                  padding: const EdgeInsets.only(top: 2),
                  child: Text(
                    label,
                    style: const TextStyle(
                      fontSize: 12.8,
                      color: AppColors.textPrimary,
                    ),
                  ),
                )
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 1),
                    Text(
                      value,
                      style: const TextStyle(
                        fontSize: 11.5,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
        ),
      ],
    );
  }
}

class _ProviderStatusBadge extends StatelessWidget {
  const _ProviderStatusBadge({required this.status});

  final _ProviderBookingStatus status;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
      decoration: BoxDecoration(
        color: status.backgroundColor,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        status.label,
        style: TextStyle(fontSize: 10.5, color: status.foregroundColor),
      ),
    );
  }
}

class _SummaryInfoColumn extends StatelessWidget {
  const _SummaryInfoColumn({
    required this.label,
    required this.value,
    this.alignment = CrossAxisAlignment.start,
    this.textAlign = TextAlign.left,
  });

  final String label;
  final String value;
  final CrossAxisAlignment alignment;
  final TextAlign textAlign;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: alignment,
      children: [
        Text(
          label,
          textAlign: textAlign,
          style: const TextStyle(fontSize: 10.8, color: AppColors.textMuted),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          textAlign: textAlign,
          style: const TextStyle(fontSize: 11.5, color: AppColors.textPrimary),
        ),
      ],
    );
  }
}

class _ProviderBookingsEmptyState extends StatelessWidget {
  const _ProviderBookingsEmptyState({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Text(
          message,
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
        ),
      ),
    );
  }
}

enum _ProviderBookingsTab {
  accepted('Accepted'),
  pending('Pending'),
  completed('Completed');

  const _ProviderBookingsTab(this.label);

  final String label;
}

enum _ProviderBookingStatus {
  accepted('Accepted', AppColors.successSurface, AppColors.brandGreenLight),
  completed('Completed', AppColors.infoSurface, Color(0xFF7DD0F3));

  const _ProviderBookingStatus(
    this.label,
    this.backgroundColor,
    this.foregroundColor,
  );

  final String label;
  final Color backgroundColor;
  final Color foregroundColor;
}

class _ProviderBookingSummary {
  const _ProviderBookingSummary({
    required this.order,
    required this.customerName,
    required this.orderDate,
    required this.totalPayment,
    required this.status,
  });

  final BookingOrderItem order;
  final String customerName;
  final DateTime orderDate;
  final String totalPayment;
  final _ProviderBookingStatus status;
}

class _ProviderPendingBooking {
  const _ProviderPendingBooking({
    required this.orderId,
    required this.customerName,
    required this.email,
    required this.serviceType,
    required this.providerName,
    required this.scheduledAt,
  });

  final String orderId;
  final String customerName;
  final String email;
  final String serviceType;
  final String providerName;
  final DateTime scheduledAt;
}

String _formatShortDate(DateTime value) {
  const monthNames = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sept',
    'Oct',
    'Nov',
    'Dec',
  ];

  return '${value.day}, ${monthNames[value.month - 1]}';
}

String _formatPendingDate(DateTime value) {
  const monthNames = [
    'January',
    'February',
    'March',
    'April',
    'May',
    'June',
    'July',
    'August',
    'September',
    'October',
    'November',
    'December',
  ];

  final hour = value.hour % 12 == 0 ? 12 : value.hour % 12;
  final minute = value.minute.toString().padLeft(2, '0');
  final period = value.hour >= 12 ? 'PM' : 'AM';
  return '${value.day} ${monthNames[value.month - 1]} ${value.year} - $hour:$minute $period';
}

String _initials(String name) {
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
