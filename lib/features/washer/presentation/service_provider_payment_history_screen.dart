import 'package:car_wash/core/theme/app_colors.dart';
import 'package:car_wash/features/home/booking/data/booking_orders_store.dart';
import 'package:car_wash/features/home/booking/model/booking_order_item.dart';
import 'package:car_wash/features/washer/presentation/widgets/service_provider_bottom_navigation_bar.dart';
import 'package:flutter/material.dart';

class ServiceProviderPaymentHistoryScreen extends StatefulWidget {
  const ServiceProviderPaymentHistoryScreen({super.key});

  @override
  State<ServiceProviderPaymentHistoryScreen> createState() =>
      _ServiceProviderPaymentHistoryScreenState();
}

class _ServiceProviderPaymentHistoryScreenState
    extends State<ServiceProviderPaymentHistoryScreen> {
  @override
  void initState() {
    super.initState();
    BookingOrdersStore.instance.fetchProviderOrders();
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
                  'Payment History',
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
            Expanded(
              child: AnimatedBuilder(
                animation: BookingOrdersStore.instance.listenable,
                builder: (context, _) {
                  final orders = BookingOrdersStore.instance.orders;
                  final paymentOrders =
                      orders
                          .where(
                            (order) =>
                                order.showInWallet ||
                                order.status == BookingOrderStatus.completed,
                          )
                          .toList(growable: false)
                        ..sort(
                          (first, second) =>
                              second.paymentDate.compareTo(first.paymentDate),
                        );

                  if (paymentOrders.isEmpty) {
                    return const _PaymentHistoryEmptyState();
                  }

                  return ListView.separated(
                    padding: const EdgeInsets.fromLTRB(12, 14, 12, 18),
                    itemCount: paymentOrders.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      return _PaymentHistoryCard(order: paymentOrders[index]);
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: const ServiceProviderBottomNavigationBar(
        selectedTab: ServiceProviderBottomTab.earnings,
      ),
    );
  }
}

class _PaymentHistoryCard extends StatelessWidget {
  const _PaymentHistoryCard({required this.order});

  final BookingOrderItem order;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE7EBE8)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 22,
            backgroundColor: const Color(0xFFEAF7EE),
            child: Text(
              _initials(order.customerName),
              style: const TextStyle(
                fontSize: 13.5,
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
                          color: Color(0xFF202020),
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
                  'Booking on ${_formatPaymentDate(order.paymentDate)}',
                  style: const TextStyle(
                    fontSize: 10.8,
                    color: Color(0xFF8C8C8C),
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  'Car Wash ${_capitalizeWords(order.serviceType)}',
                  style: const TextStyle(
                    fontSize: 11.2,
                    color: Color(0xFF6D6D6D),
                  ),
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    ...List.generate(4, (index) {
                      return const Padding(
                        padding: EdgeInsets.only(right: 1),
                        child: Icon(
                          Icons.star_rounded,
                          size: 12,
                          color: AppColors.brandGreen,
                        ),
                      );
                    }),
                    const SizedBox(width: 4),
                    Text(
                      '${_ratingLabel(order)}/5',
                      style: const TextStyle(
                        fontSize: 11,
                        color: Color(0xFF5C5C5C),
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

  String _ratingLabel(BookingOrderItem order) {
    if (order.reviewRating != null) {
      return order.reviewRating.toString();
    }

    final parsed = double.tryParse(order.rating);
    if (parsed == null) {
      return '4';
    }

    return parsed.round().clamp(1, 5).toString();
  }
}

class _PaymentHistoryEmptyState extends StatelessWidget {
  const _PaymentHistoryEmptyState();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 24),
        child: Text(
          'No customer payments available right now.',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 13, color: Color(0xFF8A8A8A)),
        ),
      ),
    );
  }
}

String _formatPaymentDate(DateTime value) {
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

  final hour = value.hour % 12 == 0 ? 12 : value.hour % 12;
  final minute = value.minute.toString().padLeft(2, '0');
  return '${value.day} ${monthNames[value.month - 1]}, $hour:$minute';
}

String _capitalizeWords(String value) {
  return value
      .split(RegExp(r'\s+'))
      .where((word) => word.isNotEmpty)
      .map(
        (word) => '${word[0].toUpperCase()}${word.substring(1).toLowerCase()}',
      )
      .join(' ');
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
