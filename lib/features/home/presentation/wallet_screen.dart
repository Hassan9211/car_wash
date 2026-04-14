import 'package:car_wash/core/router/app_navigation.dart';
import 'package:car_wash/core/theme/app_button_colors.dart';
import 'package:car_wash/core/theme/app_colors.dart';
import 'package:car_wash/features/home/booking/data/booking_orders_store.dart';
import 'package:car_wash/features/home/booking/model/booking_order_item.dart';
import 'package:car_wash/features/home/presentation/widgets/home_bottom_navigation_bar.dart';
import 'package:car_wash/features/home/service/pdf_service.dart';
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
                        const Divider(height: 1, color: AppColors.border),
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
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.surfaceElevated,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: AppColors.surfaceMuted,
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
                      color: AppColors.textMuted,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    order.serviceProviderName,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  order.totalPayment,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: AppButtonColors.primaryBackground,
                  ),
                ),
                const SizedBox(height: 6),
                GestureDetector(
                  onTap: () => PdfService.generateAndDownloadReceipt(order),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.brandGreen.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(
                        color: AppColors.brandGreen.withValues(alpha: 0.2),
                      ),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.picture_as_pdf_rounded,
                          size: 12,
                          color: AppColors.brandGreen,
                        ),
                        SizedBox(width: 4),
                        Text(
                          'PDF',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: AppColors.brandGreen,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
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
            color: AppColors.textSecondary,
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
