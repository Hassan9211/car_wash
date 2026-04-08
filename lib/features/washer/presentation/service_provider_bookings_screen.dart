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
  _ProviderBookingsTab _selectedTab = _ProviderBookingsTab.accepted;

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
        .toList(growable: false);

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
        .toList(growable: false);

    if (acceptedOrders.isEmpty) {
      return const [];
    }

    return acceptedOrders
        .map(
          (order) => _ProviderBookingSummary(
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
        .toList(growable: false);

    if (completedOrders.isEmpty) {
      return const [];
    }

    return completedOrders
        .map(
          (order) => _ProviderBookingSummary(
            customerName: order.customerName,
            orderDate: order.orderDate,
            totalPayment: order.totalPayment,
            status: _ProviderBookingStatus.completed,
          ),
        )
        .toList(growable: false);
  }

  Future<void> _acceptPendingBooking(_ProviderPendingBooking booking) async {
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
          SnackBar(content: Text('${booking.customerName} booking accepted')),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
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
                    color: Colors.black,
                  ),
                ),
              ),
            ),
            Divider(
              height: 1,
              thickness: 0.8,
              color: const Color(0xFFE9E6E3).withValues(alpha: 0.9),
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
                      : const Color(0xFF808080),
                ),
              ),
            ),
            Container(
              height: 1.8,
              color: isSelected
                  ? AppColors.brandGreen
                  : const Color(0xFFE2E2E2),
            ),
          ],
        ),
      ),
    );
  }
}

class _SummaryBookingsList extends StatelessWidget {
  const _SummaryBookingsList({required this.items});

  final List<_ProviderBookingSummary> items;

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
        return _ProviderSummaryBookingCard(item: items[index]);
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
  const _ProviderSummaryBookingCard({required this.item});

  final _ProviderBookingSummary item;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0A000000),
            blurRadius: 18,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _ProviderStatusBadge(status: item.status),
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
        ],
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
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE8ECE8)),
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
          const Divider(height: 1, color: Color(0xFFE9ECE9)),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: FilledButton(
                  onPressed: onAccept,
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.brandGreen,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text('Accept'),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: FilledButton(
                  onPressed: onDecline,
                  style: FilledButton.styleFrom(
                    backgroundColor: const Color(0xFFDDE9DF),
                    foregroundColor: const Color(0xFF45634D),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
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
                      color: Color(0xFF252525),
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
                        color: Color(0xFF1F251F),
                      ),
                    ),
                    const SizedBox(height: 1),
                    Text(
                      value,
                      style: const TextStyle(
                        fontSize: 11.5,
                        color: Color(0xFF8A8A8A),
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
          style: const TextStyle(fontSize: 10.8, color: Color(0xFFACACAC)),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          textAlign: textAlign,
          style: const TextStyle(fontSize: 11.5, color: Color(0xFF333333)),
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
          style: const TextStyle(fontSize: 13, color: Color(0xFF8A8A8A)),
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
  accepted('Accepted', Color(0xFFEAF7EE), Color(0xFF7EBF8C)),
  completed('Completed', Color(0xFFE8F6FD), Color(0xFF6BB6DF));

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
    required this.customerName,
    required this.orderDate,
    required this.totalPayment,
    required this.status,
  });

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
