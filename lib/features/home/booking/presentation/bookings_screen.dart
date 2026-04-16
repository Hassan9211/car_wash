import 'dart:async';

import 'package:car_wash/core/router/app_navigation.dart';
import 'package:car_wash/core/scheduling/business_hours.dart';
import 'package:car_wash/core/services/app_notification_service.dart';
import 'package:car_wash/core/theme/app_button_colors.dart';
import 'package:car_wash/core/theme/app_button_styles.dart';
import 'package:car_wash/core/theme/app_colors.dart';
import 'package:car_wash/features/authentication/data/auth_session.dart';
import 'package:car_wash/features/home/booking/data/booking_orders_store.dart';
import 'package:car_wash/features/home/booking/model/booking_order_item.dart';
import 'package:car_wash/features/home/presentation/widgets/home_bottom_navigation_bar.dart';
import 'package:flutter/material.dart';

class BookingsScreen extends StatefulWidget {
  const BookingsScreen({super.key});

  @override
  State<BookingsScreen> createState() => _BookingsScreenState();
}

class _BookingsScreenState extends State<BookingsScreen> {
  _BookingsFilterTab _selectedTab = _BookingsFilterTab.active;

  @override
  void initState() {
    super.initState();
    BookingOrdersStore.instance.fetchCustomerOrders(
      customerEmail: AuthSession.displayEmail,
    );
  }

  Future<void> _cancelOrder(String orderId) async {
    try {
      await BookingOrdersStore.instance.cancelOrder(orderId);

      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          const SnackBar(content: Text('Booking cancelled successfully')),
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

  Future<void> _trackOrder(BookingOrderItem order) async {
    await context.pushToBookingTracking(order);
  }

  Future<void> _leaveReview(BookingOrderItem order) async {
    final didSubmit = await context.pushToBookingReview(order);

    if (!mounted || didSubmit != true) {
      return;
    }

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        const SnackBar(content: Text('Review submitted successfully')),
      );
  }

  Future<void> _rescheduleOrder(BookingOrderItem order) async {
    final now = DateTime.now();
    final initialDate = order.orderDate.isAfter(now) ? order.orderDate : now;

    final selectedDate = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(now.year, now.month, now.day),
      lastDate: DateTime(now.year + 1, 12, 31),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(context).colorScheme.copyWith(
              primary: AppButtonColors.primaryBackground,
            ),
          ),
          child: child!,
        );
      },
    );

    if (!mounted || selectedDate == null) {
      return;
    }

    final selectedTime = await showModalBottomSheet<String>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => _BusinessHoursSheet(
        selectedTime: BusinessHours.normalizeBookingTimeLabel(order.bookingTime),
      ),
    );

    if (!mounted || selectedTime == null || selectedTime.isEmpty) {
      return;
    }

    await BookingOrdersStore.instance.rescheduleOrder(
      orderId: order.id,
      bookingDate: selectedDate,
      bookingTime: selectedTime,
    );

    if (!mounted) return;

    // Notify provider about reschedule
    unawaited(AppNotificationService.sendBookingNotification(
      providerEmail: order.customerEmail.isNotEmpty
          ? '${order.serviceProviderName.toLowerCase().replaceAll(' ', '')}@carwash.app'
          : '${order.serviceProviderName.toLowerCase().replaceAll(' ', '')}@carwash.app',
      providerName: order.serviceProviderName,
      customerName: AuthSession.displayName,
      serviceType: order.serviceType,
      bookingTime:
          '${_formatRescheduleDate(selectedDate)} at $selectedTime (Rescheduled)',
    ));

    setState(() {
      _selectedTab = _BookingsFilterTab.active;
    });

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(
            'Booking re-scheduled for ${_formatRescheduleDate(selectedDate)} at $selectedTime',
          ),
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.appBackground,
      body: SafeArea(
        child: Column(
          children: [
            SizedBox(
              height: 54,
              child: Stack(
                children: [
                  Positioned(
                    left: 8,
                    top: 0,
                    bottom: 0,
                    child: IconButton(
                      key: const Key('bookings_back_button'),
                      onPressed: context.goToHome,
                      icon: const Icon(
                        Icons.arrow_back_ios_new_rounded,
                        color: AppButtonColors.actionForeground,
                        size: 18,
                      ),
                    ),
                  ),
                  const Positioned.fill(
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 56),
                      child: Align(
                        alignment: Alignment.center,
                        child: Text(
                          'Bookings',
                          key: Key('bookings_screen_title'),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w500,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Divider(
              height: 1,
              thickness: 0.8,
              color: AppColors.border,
            ),
            Expanded(
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(12, 12, 12, 0),
                    child: _BookingsTabBar(
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
                        final filteredOrders = orders
                            .where((order) => order.matchesTab(_selectedTab))
                            .toList(growable: false);

                        if (filteredOrders.isEmpty) {
                          return _BookingsEmptyState(tab: _selectedTab);
                        }

                        return ListView.separated(
                          padding: const EdgeInsets.fromLTRB(12, 14, 12, 16),
                          itemCount: filteredOrders.length,
                          separatorBuilder: (_, _) =>
                              const SizedBox(height: 14),
                          itemBuilder: (context, index) {
                            final order = filteredOrders[index];
                            return _BookingCard(
                              order: order,
                              onSecondaryTap: switch (order.status) {
                                BookingOrderStatus.pending ||
                                BookingOrderStatus.accepted ||
                                BookingOrderStatus.orderPlaced ||
                                BookingOrderStatus.inProgress ||
                                BookingOrderStatus.awaitingApproval =>
                                  () => _cancelOrder(order.id),
                                BookingOrderStatus.completed =>
                                  () => _leaveReview(order),
                                BookingOrderStatus.cancelled => null,
                              },
                              onPrimaryTap: switch (order.status) {
                                BookingOrderStatus.pending ||
                                BookingOrderStatus.accepted ||
                                BookingOrderStatus.orderPlaced ||
                                BookingOrderStatus.inProgress ||
                                BookingOrderStatus.awaitingApproval =>
                                  () => _trackOrder(order),
                                BookingOrderStatus.completed =>
                                  () => _rescheduleOrder(order),
                                BookingOrderStatus.cancelled => null,
                              },
                            );
                          },
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: const HomeBottomNavigationBar(
        selectedTab: HomeBottomTab.bookings,
      ),
    );
  }
}

String _formatRescheduleDate(DateTime value) {
  const monthNames = [
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

  return '${value.day} ${monthNames[value.month - 1]} ${value.year}';
}

class _BusinessHoursSheet extends StatefulWidget {
  const _BusinessHoursSheet({
    required this.selectedTime,
  });

  final String selectedTime;

  @override
  State<_BusinessHoursSheet> createState() => _BusinessHoursSheetState();
}

class _BusinessHoursSheetState extends State<_BusinessHoursSheet> {
  late String _selectedTime;

  @override
  void initState() {
    super.initState();
    // Always start with a valid time slot
    _selectedTime = BusinessHours.timeSlotLabels.contains(widget.selectedTime)
        ? widget.selectedTime
        : BusinessHours.timeSlotLabels.first;
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Padding(
        padding: EdgeInsets.only(
          left: 16,
          right: 16,
          bottom: 16 + MediaQuery.of(context).viewPadding.bottom,
        ),
        child: Container(
          padding: const EdgeInsets.fromLTRB(18, 14, 18, 18),
          decoration: BoxDecoration(
            color: AppColors.surfaceElevated,
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: AppColors.border),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.28),
                blurRadius: 24,
                offset: const Offset(0, 12),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
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
                'Select Time',
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 6),
              const Text(
                'Available booking hours are 9:00 AM to 5:00 PM.',
                style: TextStyle(
                  fontSize: 12,
                  height: 1.4,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 14),
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: BusinessHours.timeSlotLabels
                    .map(
                      (time) => _RescheduleTimeSlotButton(
                        label: time,
                        isSelected: _selectedTime == time,
                        onTap: () {
                          setState(() {
                            _selectedTime = time;
                          });
                        },
                      ),
                    )
                    .toList(growable: false),
              ),
              const SizedBox(height: 18),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: () => Navigator.of(context).pop(_selectedTime),
                  style: AppButtonStyles.filled(height: 44),
                  child: const Text('Confirm'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _RescheduleTimeSlotButton extends StatelessWidget {
  const _RescheduleTimeSlotButton({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 84,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(6),
        child: Ink(
          height: 30,
          decoration: BoxDecoration(
            color: isSelected
                ? AppButtonColors.primaryBackground
                : Colors.white,
            borderRadius: BorderRadius.circular(6),
            boxShadow: isSelected
                ? null
                : const [
                    BoxShadow(
                      color: Color(0x12000000),
                      blurRadius: 8,
                      offset: Offset(0, 2),
                    ),
                  ],
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 10.5,
                fontWeight: FontWeight.w600,
                color: isSelected ? Colors.white : AppColors.textSecondary,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _BookingsTabBar extends StatelessWidget {
  const _BookingsTabBar({
    required this.selectedTab,
    required this.onChanged,
  });

  final _BookingsFilterTab selectedTab;
  final ValueChanged<_BookingsFilterTab> onChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: _BookingsFilterTab.values
          .map(
            (tab) => Expanded(
              child: _BookingsTabItem(
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

class _BookingsTabItem extends StatelessWidget {
  const _BookingsTabItem({
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
                  fontSize: 15,
                  fontWeight: FontWeight.w400,
                  color: isSelected
                      ? AppButtonColors.primaryBackground
                      : AppColors.textMuted,
                ),
              ),
            ),
            Container(
              height: 1.8,
              color: isSelected
                  ? AppButtonColors.primaryBackground
                  : AppColors.border,
            ),
          ],
        ),
      ),
    );
  }
}

class _BookingCard extends StatelessWidget {
  const _BookingCard({
    required this.order,
    this.onSecondaryTap,
    this.onPrimaryTap,
  });

  final BookingOrderItem order;
  final VoidCallback? onSecondaryTap;
  final VoidCallback? onPrimaryTap;

  @override
  Widget build(BuildContext context) {
    return Container(
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
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _BookingStatusBadge(status: order.status),
          const SizedBox(height: 12),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: _BookingInfoColumn(
                  label: 'Order Date',
                  value: _formatOrderDate(order.orderDate),
                ),
              ),
              Expanded(
                child: _BookingRatingColumn(
                  rating: order.rating,
                  reviews: order.reviews,
                ),
              ),
              Expanded(
                child: _BookingInfoColumn(
                  label: 'Total Payment',
                  value: order.totalPayment,
                  alignment: CrossAxisAlignment.end,
                  textAlign: TextAlign.right,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: _BookingActionButton(
                  label: order.secondaryActionLabel,
                  isPrimary: false,
                  onTap: onSecondaryTap,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _BookingActionButton(
                  label: order.primaryActionLabel,
                  isPrimary: true,
                  onTap: onPrimaryTap,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _BookingStatusBadge extends StatelessWidget {
  const _BookingStatusBadge({
    required this.status,
  });

  final BookingOrderStatus status;

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
        style: TextStyle(
          fontSize: 10.5,
          fontWeight: FontWeight.w400,
          color: status.foregroundColor,
        ),
      ),
    );
  }
}

class _BookingInfoColumn extends StatelessWidget {
  const _BookingInfoColumn({
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
          style: const TextStyle(
            fontSize: 11,
            color: AppColors.textMuted,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          textAlign: textAlign,
          style: const TextStyle(
            fontSize: 11.5,
            color: AppColors.textPrimary,
          ),
        ),
      ],
    );
  }
}

class _BookingRatingColumn extends StatelessWidget {
  const _BookingRatingColumn({
    required this.rating,
    required this.reviews,
  });

  final String rating;
  final String reviews;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const Text(
          'Ratings',
          style: TextStyle(
            fontSize: 11,
            color: AppColors.textMuted,
          ),
        ),
        const SizedBox(height: 4),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            for (var index = 0; index < 4; index++) ...[
              const Icon(
                Icons.star_rounded,
                size: 12,
                color: AppButtonColors.primaryBackground,
              ),
              if (index != 3) const SizedBox(width: 1),
            ],
            const SizedBox(width: 3),
            Text(
              rating,
              style: const TextStyle(
                fontSize: 9.5,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(width: 4),
            Text(
              reviews,
              style: const TextStyle(
                fontSize: 9.5,
                color: AppColors.textPrimary,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _BookingActionButton extends StatelessWidget {
  const _BookingActionButton({
    required this.label,
    required this.isPrimary,
    this.onTap,
  });

  final String label;
  final bool isPrimary;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 42,
      child: isPrimary
          ? FilledButton(
              onPressed: onTap,
              style: AppButtonStyles.filled(
                backgroundColor: AppButtonColors.primaryBackground,
                foregroundColor: Colors.white,
                height: 42,
              ),
              child: Text(label),
            )
          : TextButton(
              onPressed: onTap,
              style: TextButton.styleFrom(
                foregroundColor: AppButtonColors.actionForeground,
                backgroundColor: AppColors.surfaceMuted,
                side: const BorderSide(color: AppColors.border),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text(label),
            ),
    );
  }
}

class _BookingsEmptyState extends StatelessWidget {
  const _BookingsEmptyState({
    required this.tab,
  });

  final _BookingsFilterTab tab;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Text(
          'No ${tab.label.toLowerCase()} bookings available right now.',
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 13,
            color: AppColors.textSecondary,
          ),
        ),
      ),
    );
  }
}

enum _BookingsFilterTab {
  active('Active'),
  completed('Completed'),
  cancelled('Cancelled');

  const _BookingsFilterTab(this.label);

  final String label;
}

String _formatOrderDate(DateTime value) {
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

extension on BookingOrderItem {
  String get primaryActionLabel {
    switch (status) {
      case BookingOrderStatus.pending:
        return 'Track';
      case BookingOrderStatus.accepted:
      case BookingOrderStatus.orderPlaced:
      case BookingOrderStatus.inProgress:
      case BookingOrderStatus.awaitingApproval:
        return 'Track';
      case BookingOrderStatus.completed:
        return 'Re-Schedule';
      case BookingOrderStatus.cancelled:
        return 'Closed';
    }
  }

  String get secondaryActionLabel {
    switch (status) {
      case BookingOrderStatus.pending:
      case BookingOrderStatus.accepted:
      case BookingOrderStatus.orderPlaced:
      case BookingOrderStatus.inProgress:
      case BookingOrderStatus.awaitingApproval:
        return 'Cancel';
      case BookingOrderStatus.completed:
        return 'Leave Review';
      case BookingOrderStatus.cancelled:
        return 'Cancelled';
    }
  }

  bool matchesTab(_BookingsFilterTab tab) {
    switch (tab) {
      case _BookingsFilterTab.active:
        return isActive;
      case _BookingsFilterTab.completed:
        return status == BookingOrderStatus.completed;
      case _BookingsFilterTab.cancelled:
        return status == BookingOrderStatus.cancelled;
    }
  }
}

extension on BookingOrderStatus {
  String get label {
    switch (this) {
      case BookingOrderStatus.pending:
        return 'Pending';
      case BookingOrderStatus.accepted:
        return 'Accepted';
      case BookingOrderStatus.orderPlaced:
        return 'Order Placed';
      case BookingOrderStatus.inProgress:
        return 'In Progress';
      case BookingOrderStatus.awaitingApproval:
        return 'Awaiting Approval';
      case BookingOrderStatus.completed:
        return 'Completed';
      case BookingOrderStatus.cancelled:
        return 'Cancelled';
    }
  }

  Color get backgroundColor {
    switch (this) {
      case BookingOrderStatus.pending:
        return const Color(0xFFFFF5E5);
      case BookingOrderStatus.accepted:
        return const Color(0xFFEAF7EE);
      case BookingOrderStatus.orderPlaced:
        return const Color(0xFFFEF5E6);
      case BookingOrderStatus.inProgress:
        return const Color(0xFFEAF1FF);
      case BookingOrderStatus.awaitingApproval:
        return const Color(0xFFFEF5E6);
      case BookingOrderStatus.completed:
        return const Color(0xFFE6FBF4);
      case BookingOrderStatus.cancelled:
        return const Color(0xFFFFEEEE);
    }
  }

  Color get foregroundColor {
    switch (this) {
      case BookingOrderStatus.pending:
        return const Color(0xFFE6A23C);
      case BookingOrderStatus.accepted:
        return const Color(0xFF5FA76D);
      case BookingOrderStatus.orderPlaced:
        return const Color(0xFFF3B65B);
      case BookingOrderStatus.inProgress:
        return const Color(0xFF79A7FF);
      case BookingOrderStatus.awaitingApproval:
        return const Color(0xFFF3B65B);
      case BookingOrderStatus.completed:
        return const Color(0xFF67C8AF);
      case BookingOrderStatus.cancelled:
        return const Color(0xFFD35B5B);
    }
  }
}
