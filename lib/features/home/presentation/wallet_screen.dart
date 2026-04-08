import 'package:car_wash/core/router/app_navigation.dart';
import 'package:car_wash/core/theme/app_button_colors.dart';
import 'package:car_wash/features/home/booking/data/booking_orders_store.dart';
import 'package:car_wash/features/home/booking/model/booking_order_item.dart';
import 'package:car_wash/features/home/presentation/widgets/home_bottom_navigation_bar.dart';
import 'package:flutter/material.dart';

class WalletScreen extends StatefulWidget {
  const WalletScreen({super.key});

  @override
  State<WalletScreen> createState() => _WalletScreenState();
}

class _WalletScreenState extends State<WalletScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
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
                      key: const Key('wallet_back_button'),
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
                          'Wallet',
                          key: Key('wallet_screen_title'),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w500,
                            color: Colors.black,
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
              color: const Color(0xFFE9E6E3).withValues(alpha: 0.9),
            ),
            Expanded(
              child: AnimatedBuilder(
                animation: BookingOrdersStore.instance.listenable,
                builder: (context, _) {
                  final orders = BookingOrdersStore.instance.orders;
                  final paymentOrders = orders
                      .where((order) => order.showInWallet)
                      .toList(growable: false)
                    ..sort(
                      (first, second) =>
                          second.paymentDate.compareTo(first.paymentDate),
                    );

                  if (paymentOrders.isEmpty) {
                    return const _WalletEmptyState();
                  }

                  return ListView.separated(
                    padding: const EdgeInsets.fromLTRB(14, 18, 14, 16),
                    itemCount: paymentOrders.length,
                    separatorBuilder: (_, _) =>
                        const Divider(height: 1, color: Color(0xFFEAEAEA)),
                    itemBuilder: (context, index) {
                      return _WalletPaymentTile(order: paymentOrders[index]);
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: const HomeBottomNavigationBar(
        selectedTab: HomeBottomTab.wallet,
      ),
    );
  }
}

class _WalletPaymentTile extends StatelessWidget {
  const _WalletPaymentTile({
    required this.order,
  });

  final BookingOrderItem order;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: const Color(0xFFF3F3F3),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(
              Icons.arrow_downward_rounded,
              color: AppButtonColors.primaryBackground,
              size: 24,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _formatWalletTime(order.paymentDate),
                  style: const TextStyle(
                    fontSize: 14,
                    color: Color(0xFF8B8B8B),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  order.serviceProviderName,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF202020),
                  ),
                ),
              ],
            ),
          ),
          Text(
            order.totalPayment,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: AppButtonColors.primaryBackground,
            ),
          ),
        ],
      ),
    );
  }
}

class _WalletEmptyState extends StatelessWidget {
  const _WalletEmptyState();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 24),
        child: Text(
          'No payment history available right now.',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 13,
            color: Color(0xFF888888),
          ),
        ),
      ),
    );
  }
}

String _formatWalletTime(DateTime value) {
  final now = DateTime.now();
  final isToday = now.year == value.year &&
      now.month == value.month &&
      now.day == value.day;

  final hour = value.hour > 12 ? value.hour - 12 : (value.hour == 0 ? 12 : value.hour);
  final minute = value.minute.toString().padLeft(2, '0');

  if (isToday) {
    return 'Today $hour:$minute';
  }

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

  return '${value.day} ${monthNames[value.month - 1]} $hour:$minute';
}
