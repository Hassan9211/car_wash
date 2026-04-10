import 'package:car_wash/core/router/app_navigation.dart';
import 'package:car_wash/core/theme/app_button_colors.dart';
import 'package:car_wash/core/theme/app_colors.dart';
import 'package:car_wash/core/widgets/app_buttons.dart';
import 'package:car_wash/features/home/booking/model/booking_payment_success_details.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class BookingPaymentSuccessScreen extends StatelessWidget {
  const BookingPaymentSuccessScreen({
    super.key,
    required this.details,
  });

  final BookingPaymentSuccessDetails details;

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
                      key: const Key('booking_payment_success_back_button'),
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
                          'Payment Successful',
                          key: Key('booking_payment_success_title'),
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
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 18, 16, 16),
                child: Column(
                  children: [
                    Expanded(
                      child: SingleChildScrollView(
                        child: Column(
                          children: [
                            const _PaymentSuccessBadge(),
                            const SizedBox(height: 22),
                            const Text(
                              'Your Payment is\nsuccessfully done',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                                height: 1.45,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            const SizedBox(height: 26),
                            _PaymentSuccessRow(
                              label: 'Date',
                              value: _formatDateTime(details.paymentDate),
                            ),
                            const SizedBox(height: 12),
                            _PaymentSuccessRow(
                              label: 'Promo Code',
                              value: details.promoCode,
                            ),
                            const SizedBox(height: 12),
                            _PaymentSuccessRow(
                              label: 'Expected Delivery time',
                              value: details.expectedDeliveryTime,
                            ),
                            const SizedBox(height: 28),
                            _PaymentSuccessRow(
                              label: 'Amount',
                              value: _formatCurrency(details.amount),
                            ),
                            const SizedBox(height: 12),
                            _PaymentSuccessRow(
                              label: 'Tip for Service Provider',
                              value: _formatCurrency(details.tipAmount),
                              valueColor: details.tipAmount > 0
                                  ? AppButtonColors.primaryBackground
                                  : null,
                            ),
                            const SizedBox(height: 12),
                            _PaymentSuccessRow(
                              label: 'Delivery Charge',
                              value: _formatCurrency(details.deliveryCharge),
                            ),
                            const SizedBox(height: 12),
                            _PaymentSuccessRow(
                              label: 'Tax',
                              value: _formatCurrency(details.tax),
                            ),
                            const SizedBox(height: 12),
                            _PaymentSuccessRow(
                              label: 'Discount',
                              value: '-${_formatCurrency(details.discount)}',
                            ),
                            const SizedBox(height: 18),
                            Divider(
                              height: 1,
                              thickness: 1,
                              color: const Color(0xFFE9E9E9).withValues(
                                alpha: 0.95,
                              ),
                            ),
                            const SizedBox(height: 18),
                            _PaymentSuccessRow(
                              label: 'Total Amount',
                              value: _formatCurrency(details.totalAmount),
                              isTotal: true,
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),
                    AppPrimaryButton(
                      key: const Key('booking_payment_success_done_button'),
                      label: 'Done',
                      onPressed: context.goToHome,
                      height: 46,
                      borderRadius: 6,
                      textStyle: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PaymentSuccessBadge extends StatelessWidget {
  const _PaymentSuccessBadge();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 124,
      height: 124,
      child: Stack(
        alignment: Alignment.center,
        children: const [
          _BadgeDot(left: 58, top: 0, size: 4),
          _BadgeDot(left: 18, top: 18, size: 10),
          _BadgeDot(right: 14, top: 28, size: 10),
          _BadgeDot(left: 8, top: 68, size: 6),
          _BadgeDot(right: 16, top: 76, size: 4),
          _BadgeDot(left: 30, bottom: 14, size: 4),
          _BadgeDot(right: 34, bottom: 8, size: 4),
          _BadgeCenter(),
        ],
      ),
    );
  }
}

class _BadgeCenter extends StatelessWidget {
  const _BadgeCenter();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 74,
      height: 74,
      decoration: const BoxDecoration(
        color: AppButtonColors.primaryBackground,
        shape: BoxShape.circle,
      ),
      alignment: Alignment.center,
      child: Container(
        width: 34,
        height: 34,
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.96),
          shape: BoxShape.circle,
        ),
        child: const Icon(
          Icons.check_rounded,
          size: 24,
          color: AppButtonColors.primaryBackground,
        ),
      ),
    );
  }
}

class _BadgeDot extends StatelessWidget {
  const _BadgeDot({
    this.left,
    this.right,
    this.top,
    this.bottom,
    required this.size,
  });

  final double? left;
  final double? right;
  final double? top;
  final double? bottom;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: left,
      right: right,
      top: top,
      bottom: bottom,
      child: Container(
        width: size,
        height: size,
        decoration: const BoxDecoration(
          color: AppButtonColors.primaryBackground,
          shape: BoxShape.circle,
        ),
      ),
    );
  }
}

class _PaymentSuccessRow extends StatelessWidget {
  const _PaymentSuccessRow({
    required this.label,
    required this.value,
    this.isTotal = false,
    this.valueColor,
  });

  final String label;
  final String value;
  final bool isTotal;
  final Color? valueColor;

  @override
  Widget build(BuildContext context) {
    final labelStyle = TextStyle(
      fontSize: 12,
      fontWeight: isTotal ? FontWeight.w500 : FontWeight.w400,
      color: isTotal ? AppColors.textSecondary : AppColors.textMuted,
    );
    final valueStyle = TextStyle(
      fontSize: 12,
      fontWeight: isTotal ? FontWeight.w500 : FontWeight.w400,
      color: valueColor ??
          (isTotal ? AppColors.textPrimary : AppColors.textSecondary),
    );

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(child: Text(label, style: labelStyle)),
        const SizedBox(width: 12),
        Flexible(
          child: Text(
            value,
            textAlign: TextAlign.right,
            style: valueStyle,
          ),
        ),
      ],
    );
  }
}

String _formatCurrency(double amount) {
  return '\$${amount.toStringAsFixed(2)}';
}

String _formatDateTime(DateTime value) {
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

  final hour = value.hour == 0 ? 12 : (value.hour > 12 ? value.hour - 12 : value.hour);
  final suffix = value.hour >= 12 ? 'PM' : 'AM';
  final minute = value.minute.toString().padLeft(2, '0');

  return '${monthNames[value.month - 1]} ${value.day}, ${value.year} $hour:$minute $suffix';
}
