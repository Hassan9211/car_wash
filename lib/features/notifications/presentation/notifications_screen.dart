import 'package:car_wash/core/router/app_navigation.dart';
import 'package:car_wash/core/theme/app_button_colors.dart';
import 'package:car_wash/core/theme/app_colors.dart';
import 'package:car_wash/features/home/booking/data/booking_orders_store.dart';
import 'package:car_wash/features/home/booking/model/booking_order_item.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  @override
  void initState() {
    super.initState();
    BookingOrdersStore.instance.fetchCustomerOrders();
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
                      key: const Key('notifications_back_button'),
                      onPressed: () => context.pop(),
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
                          'Notifications',
                          key: Key('notifications_screen_title'),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w600,
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
              child: ValueListenableBuilder<List<BookingOrderItem>>(
                valueListenable: BookingOrdersStore.instance.listenable,
                builder: (context, orders, _) {
                  final notifications = _buildNotifications(orders);
                  final sections = _buildSections(notifications);
                  final unreadCount = notifications
                      .where((item) => item.isUnread)
                      .length;
                  final activeBookings = orders
                      .where((order) => order.isActive)
                      .length;
                  final paymentUpdates = notifications
                      .where(
                        (item) =>
                            item.category == _NotificationCategory.payment ||
                            item.category == _NotificationCategory.security,
                      )
                      .length;

                  return ListView(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
                    children: [
                      _NotificationSummaryCard(
                        unreadCount: unreadCount,
                        activeBookings: activeBookings,
                        paymentUpdates: paymentUpdates,
                      ),
                      const SizedBox(height: 18),
                      if (sections.isEmpty)
                        const _EmptyNotificationState()
                      else
                        for (
                          var index = 0;
                          index < sections.length;
                          index++
                        ) ...[
                          _NotificationSection(
                            heading: sections[index].heading,
                            items: sections[index].items,
                            onTap: (item) {
                              _handleNotificationTap(context, item);
                            },
                          ),
                          if (index != sections.length - 1)
                            const SizedBox(height: 18),
                        ],
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<_NotificationItem> _buildNotifications(List<BookingOrderItem> orders) {
    final now = DateTime.now();
    final sortedOrders = List<BookingOrderItem>.from(orders)
      ..sort(
        (first, second) =>
            second.notificationTimestamp.compareTo(first.notificationTimestamp),
      );
    final notifications = <_NotificationItem>[
      for (final order in sortedOrders)
        _buildOrderNotification(
          order: order,
          timestamp: order.notificationTimestamp,
          isUnread: order.hasUnreadNotification,
        ),
      _NotificationItem(
        id: 'payment_security',
        title: 'Payment method secured',
        message:
            'Your saved card is protected with encrypted checkout for faster future bookings.',
        tag: 'Security',
        timestamp: now.subtract(const Duration(days: 1, hours: 5)),
        icon: Icons.lock_outline_rounded,
        iconColor: AppColors.brandGreen,
        iconBackground: const Color(0xFFEAF7EE),
        category: _NotificationCategory.security,
        actionLabel: 'Open',
        destination: _NotificationDestination.helpCenter,
      ),
      _NotificationItem(
        id: 'help_center',
        title: 'Need help with a recent booking?',
        message:
            'Visit Help Center for booking issues, refund timelines, or account support.',
        tag: 'Support',
        timestamp: now.subtract(const Duration(days: 2, hours: 1)),
        icon: Icons.support_agent_rounded,
        iconColor: const Color(0xFF176B87),
        iconBackground: const Color(0xFFE8F5FA),
        category: _NotificationCategory.support,
        actionLabel: 'Help',
        destination: _NotificationDestination.helpCenter,
      ),
      _NotificationItem(
        id: 'privacy_update',
        title: 'Privacy policy updated',
        message:
            'We clarified how profile details, booking history, and location permissions are used.',
        tag: 'Policy',
        timestamp: now.subtract(const Duration(days: 4, hours: 3)),
        icon: Icons.privacy_tip_outlined,
        iconColor: const Color(0xFF8A5D0A),
        iconBackground: const Color(0xFFFFF6DE),
        category: _NotificationCategory.support,
        actionLabel: 'Read',
        destination: _NotificationDestination.privacyPolicy,
      ),
    ];

    notifications.sort(
      (first, second) => second.timestamp.compareTo(first.timestamp),
    );

    return notifications;
  }

  _NotificationItem _buildOrderNotification({
    required BookingOrderItem order,
    required DateTime timestamp,
    required bool isUnread,
  }) {
    switch (order.status) {
      case BookingOrderStatus.pending:
        return _NotificationItem(
          id: '${order.id}_pending',
          title: 'Booking request received',
          message:
              'Your ${order.serviceType.toLowerCase()} booking with ${order.serviceProviderName} is waiting for provider approval.',
          tag: 'Pending',
          timestamp: timestamp,
          icon: Icons.hourglass_top_rounded,
          iconColor: const Color(0xFFE6A23C),
          iconBackground: const Color(0xFFFFF5E5),
          category: _NotificationCategory.booking,
          isUnread: isUnread,
          actionLabel: 'Track',
          destination: _NotificationDestination.tracking,
          order: order,
        );
      case BookingOrderStatus.accepted:
        return _NotificationItem(
          id: '${order.id}_accepted',
          title: 'Booking accepted',
          message:
              '${order.serviceProviderName} accepted your ${order.serviceType.toLowerCase()} booking. Washer is on the way for ${_scheduleLabel(order)}.',
          tag: 'Accepted',
          timestamp: timestamp,
          icon: Icons.check_circle_outline_rounded,
          iconColor: AppColors.brandGreen,
          iconBackground: const Color(0xFFEAF7EE),
          category: _NotificationCategory.booking,
          isUnread: isUnread,
          actionLabel: 'Track',
          destination: _NotificationDestination.tracking,
          order: order,
        );
      case BookingOrderStatus.orderPlaced:
        return _NotificationItem(
          id: '${order.id}_confirmed',
          title: 'Booking confirmed',
          message:
              'Your ${order.serviceType.toLowerCase()} with ${order.serviceProviderName} is scheduled for ${_scheduleLabel(order)}.',
          tag: 'Booking',
          timestamp: timestamp,
          icon: Icons.calendar_month_rounded,
          iconColor: AppColors.brandGreen,
          iconBackground: const Color(0xFFEAF7EE),
          category: _NotificationCategory.booking,
          isUnread: isUnread,
          actionLabel: 'Track',
          destination: _NotificationDestination.tracking,
          order: order,
        );
      case BookingOrderStatus.inProgress:
        return _NotificationItem(
          id: '${order.id}_live',
          title: 'Washer is on the way',
          message:
              '${order.serviceProviderName} has started your ${order.serviceType.toLowerCase()}. Track the service progress live.',
          tag: 'Live',
          timestamp: timestamp,
          icon: Icons.local_shipping_outlined,
          iconColor: const Color(0xFF176B87),
          iconBackground: const Color(0xFFE8F5FA),
          category: _NotificationCategory.booking,
          isUnread: isUnread,
          actionLabel: 'Track',
          destination: _NotificationDestination.tracking,
          order: order,
        );
      case BookingOrderStatus.awaitingApproval:
        return _NotificationItem(
          id: '${order.id}_awaiting',
          title: 'Work Finished - Review Proof',
          message:
              '${order.serviceProviderName} has finished the work. Please review the proof photos and approve to release payment.',
          tag: 'Approval',
          timestamp: timestamp,
          icon: Icons.rate_review_outlined,
          iconColor: AppColors.brandGreen,
          iconBackground: const Color(0xFFEAF7EE),
          category: _NotificationCategory.booking,
          isUnread: isUnread,
          actionLabel: 'Review',
          destination: _NotificationDestination.tracking,
          order: order,
        );
      case BookingOrderStatus.completed:
        return _NotificationItem(
          id: '${order.id}_payment',
          title: 'Payment successful',
          message:
              '${order.totalPayment} was received for your ${order.serviceType.toLowerCase()} with ${order.serviceProviderName}.',
          tag: 'Payment',
          timestamp: timestamp,
          icon: Icons.check_circle_outline_rounded,
          iconColor: const Color(0xFF0B8F5A),
          iconBackground: const Color(0xFFE8F8F0),
          category: _NotificationCategory.payment,
          isUnread: isUnread,
          actionLabel: 'Review',
          destination: _NotificationDestination.review,
          order: order,
        );
      case BookingOrderStatus.cancelled:
        return _NotificationItem(
          id: '${order.id}_cancelled',
          title: 'Booking cancelled',
          message:
              '${order.serviceType} with ${order.serviceProviderName} was cancelled. If charged, refunds appear in 3-5 business days.',
          tag: 'Refund',
          timestamp: timestamp,
          icon: Icons.receipt_long_rounded,
          iconColor: const Color(0xFFB26A00),
          iconBackground: const Color(0xFFFFF3E2),
          category: _NotificationCategory.payment,
          actionLabel: 'Help',
          destination: _NotificationDestination.helpCenter,
          order: order,
        );
    }
  }

  List<_NotificationSectionData> _buildSections(
    List<_NotificationItem> notifications,
  ) {
    final sections = <String, List<_NotificationItem>>{};
    final now = DateTime.now();

    for (final item in notifications) {
      final heading = _sectionHeading(item.timestamp, now);
      sections.putIfAbsent(heading, () => <_NotificationItem>[]).add(item);
    }

    return sections.entries
        .map(
          (entry) =>
              _NotificationSectionData(heading: entry.key, items: entry.value),
        )
        .toList(growable: false);
  }

  String _sectionHeading(DateTime timestamp, DateTime now) {
    final today = DateUtils.dateOnly(now);
    final notificationDay = DateUtils.dateOnly(timestamp);
    final difference = today.difference(notificationDay).inDays;

    if (difference <= 0) {
      return 'TODAY';
    }
    if (difference == 1) {
      return 'YESTERDAY';
    }
    return 'EARLIER';
  }

  void _handleNotificationTap(BuildContext context, _NotificationItem item) {
    switch (item.destination) {
      case _NotificationDestination.tracking:
        final order = item.order;
        if (order != null) {
          context.pushToBookingTracking(order);
        }
        return;
      case _NotificationDestination.review:
        final order = item.order;
        if (order != null) {
          context.pushToBookingReview(order);
        }
        return;
      case _NotificationDestination.helpCenter:
        context.pushToHelpCenter();
        return;
      case _NotificationDestination.privacyPolicy:
        context.pushToPrivacyPolicy();
        return;
      case _NotificationDestination.termsConditions:
        context.pushToTermsConditions();
        return;
      case null:
        return;
    }
  }

  static String _scheduleLabel(BookingOrderItem order) {
    final dateLabel = _dateLabel(order.orderDate);
    final timeLabel = order.bookingTime ?? 'your selected time';
    return '$dateLabel at $timeLabel';
  }

  static String _dateLabel(DateTime date) {
    final today = DateUtils.dateOnly(DateTime.now());
    final target = DateUtils.dateOnly(date);
    final difference = target.difference(today).inDays;

    if (difference == 0) {
      return 'today';
    }
    if (difference == 1) {
      return 'tomorrow';
    }
    if (difference == -1) {
      return 'yesterday';
    }
    return '${_monthLabel(date.month)} ${date.day}';
  }

  static String _timeAgo(DateTime timestamp) {
    final difference = DateTime.now().difference(timestamp);

    if (difference.inMinutes <= 0) {
      return 'Just now';
    }
    if (difference.inHours < 1) {
      return '${difference.inMinutes} min ago';
    }
    if (difference.inDays < 1) {
      return '${difference.inHours}h ago';
    }
    if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    }
    return '${_monthLabel(timestamp.month)} ${timestamp.day}';
  }

  static String _monthLabel(int month) {
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

    return months[month - 1];
  }
}

class _NotificationSummaryCard extends StatelessWidget {
  const _NotificationSummaryCard({
    required this.unreadCount,
    required this.activeBookings,
    required this.paymentUpdates,
  });

  final int unreadCount;
  final int activeBookings;
  final int paymentUpdates;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(18, 18, 18, 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: const LinearGradient(
          colors: [AppColors.surfaceHighlight, AppColors.surface],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.16),
            blurRadius: 16,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: AppColors.brandGreen,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(
                  Icons.notifications_active_outlined,
                  color: Colors.white,
                  size: 22,
                ),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Text(
                  'Stay on top of bookings and payments',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            unreadCount == 0
                ? 'You are all caught up for now.'
                : 'You have $unreadCount unread updates waiting for your attention.',
            style: const TextStyle(
              fontSize: 13,
              height: 1.45,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 14),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _SummaryChip(
                label: '$unreadCount unread',
                color: AppColors.surfaceMuted,
                textColor: AppColors.textSecondary,
              ),
              _SummaryChip(
                label: '$activeBookings active bookings',
                color: AppColors.successSurface,
                textColor: AppColors.brandGreenLight,
              ),
              _SummaryChip(
                label: '$paymentUpdates payment updates',
                color: AppColors.warningSurface,
                textColor: const Color(0xFFF3C96A),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SummaryChip extends StatelessWidget {
  const _SummaryChip({
    required this.label,
    required this.color,
    required this.textColor,
  });

  final String label;
  final Color color;
  final Color textColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: textColor,
        ),
      ),
    );
  }
}

class _NotificationSection extends StatelessWidget {
  const _NotificationSection({
    required this.heading,
    required this.items,
    required this.onTap,
  });

  final String heading;
  final List<_NotificationItem> items;
  final ValueChanged<_NotificationItem> onTap;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          heading,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.6,
            color: AppColors.textMuted,
          ),
        ),
        const SizedBox(height: 10),
        for (var index = 0; index < items.length; index++) ...[
          _NotificationTile(
            item: items[index],
            onTap: () => onTap(items[index]),
          ),
          if (index != items.length - 1) const SizedBox(height: 10),
        ],
      ],
    );
  }
}

class _NotificationTile extends StatelessWidget {
  const _NotificationTile({required this.item, required this.onTap});

  final _NotificationItem item;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surfaceElevated,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        onTap: item.destination == null ? null : onTap,
        borderRadius: BorderRadius.circular(18),
        child: Ink(
          padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: AppColors.border),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.16),
                blurRadius: 14,
                offset: Offset(0, 6),
              ),
            ],
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: item.iconBackground,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(item.icon, color: item.iconColor, size: 22),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(
                            item.title,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          _NotificationsScreenState._timeAgo(item.timestamp),
                          style: const TextStyle(
                            fontSize: 11.5,
                            fontWeight: FontWeight.w500,
                            color: AppColors.textMuted,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      item.message,
                      style: const TextStyle(
                        fontSize: 12.5,
                        height: 1.45,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 5,
                          ),
                          decoration: BoxDecoration(
                            color: item.iconBackground,
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child: Text(
                            item.tag,
                            style: TextStyle(
                              fontSize: 11.5,
                              fontWeight: FontWeight.w600,
                              color: item.iconColor,
                            ),
                          ),
                        ),
                        const Spacer(),
                        if (item.actionLabel != null)
                          Text(
                            item.actionLabel!,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: item.iconColor,
                            ),
                          ),
                        if (item.destination != null) ...[
                          const SizedBox(width: 4),
                          Icon(
                            Icons.chevron_right_rounded,
                            size: 18,
                            color: item.iconColor,
                          ),
                        ],
                        if (item.isUnread) ...[
                          const SizedBox(width: 8),
                          Container(
                            width: 8,
                            height: 8,
                            decoration: const BoxDecoration(
                              color: AppColors.brandGreen,
                              shape: BoxShape.circle,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _EmptyNotificationState extends StatelessWidget {
  const _EmptyNotificationState();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 26),
      decoration: BoxDecoration(
        color: AppColors.surfaceElevated,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border),
      ),
      child: const Column(
        children: [
          Icon(
            Icons.notifications_none_rounded,
            size: 42,
            color: AppColors.textMuted,
          ),
          SizedBox(height: 12),
          Text(
            'No notifications yet',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          SizedBox(height: 6),
          Text(
            'Booking updates, payment confirmations, and support alerts will appear here.',
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

class _NotificationSectionData {
  const _NotificationSectionData({required this.heading, required this.items});

  final String heading;
  final List<_NotificationItem> items;
}

class _NotificationItem {
  const _NotificationItem({
    required this.id,
    required this.title,
    required this.message,
    required this.tag,
    required this.timestamp,
    required this.icon,
    required this.iconColor,
    required this.iconBackground,
    required this.category,
    this.isUnread = false,
    this.actionLabel,
    this.destination,
    this.order,
  });

  final String id;
  final String title;
  final String message;
  final String tag;
  final DateTime timestamp;
  final IconData icon;
  final Color iconColor;
  final Color iconBackground;
  final _NotificationCategory category;
  final bool isUnread;
  final String? actionLabel;
  final _NotificationDestination? destination;
  final BookingOrderItem? order;
}

enum _NotificationCategory { booking, payment, support, security }

enum _NotificationDestination {
  tracking,
  review,
  helpCenter,
  privacyPolicy,
  termsConditions,
}
