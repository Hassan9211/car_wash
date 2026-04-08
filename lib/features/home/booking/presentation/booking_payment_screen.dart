import 'package:car_wash/core/router/app_navigation.dart';
import 'package:car_wash/core/theme/app_button_colors.dart';
import 'package:car_wash/core/widgets/app_buttons.dart';
import 'package:car_wash/features/authentication/data/auth_session.dart';
import 'package:car_wash/features/home/booking/model/booking_flow_details.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class BookingPaymentScreen extends StatelessWidget {
  const BookingPaymentScreen({
    super.key,
    required this.details,
  });

  final BookingFlowDetails details;

  Future<void> _openCheckout(BuildContext context) async {
    await context.pushToBookingCheckout(details);
  }

  @override
  Widget build(BuildContext context) {
    final customerName = details.customerName.trim().isNotEmpty
        ? details.customerName.trim()
        : 'JohnSmith';
    final serviceType = details.serviceType.trim().isNotEmpty
        ? details.serviceType.trim()
        : 'Basic Car Wash';
    final customerEmail = AuthSession.currentEmail ?? 'smith@gmail.com';
    final bookingDateTime = _formatBookingDateTime(
      details.bookingDate ?? DateTime(2021, 1, 18),
      details.bookingTime ?? '11:30 AM',
    );
    final totalAmount = details.provider.price;

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
                      key: const Key('booking_payment_back_button'),
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
                          'Payment',
                          key: Key('booking_payment_title'),
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
              child: Padding(
                padding: const EdgeInsets.fromLTRB(12, 14, 12, 16),
                child: Column(
                  children: [
                    const _PaymentProgressIndicator(),
                    const SizedBox(height: 16),
                    Expanded(
                      child: SingleChildScrollView(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.fromLTRB(8, 8, 8, 10),
                              decoration: BoxDecoration(
                                color: const Color(0xFFDCE7DC),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Booking details',
                                    style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w500,
                                      color: Colors.black,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  _PaymentDetailRow(
                                    icon: Icons.person_rounded,
                                    title: 'Name',
                                    value: customerName,
                                  ),
                                  const SizedBox(height: 8),
                                  _PaymentDetailRow(
                                    icon: Icons.email_outlined,
                                    title: 'Email',
                                    value: customerEmail,
                                  ),
                                  const SizedBox(height: 8),
                                  _PaymentDetailRow(
                                    icon: Icons.local_car_wash_rounded,
                                    title: 'Service Type',
                                    value: serviceType,
                                  ),
                                  const SizedBox(height: 8),
                                  _PaymentDetailRow(
                                    icon: Icons.person_pin_rounded,
                                    title: 'Service Provider',
                                    value: details.provider.name,
                                  ),
                                  const SizedBox(height: 8),
                                  _PaymentDetailRow(
                                    icon: Icons.calendar_month_rounded,
                                    title: bookingDateTime,
                                    value: '',
                                    compactValue: true,
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 10),
                            _PaymentAmountRow(
                              label: 'Total Bill',
                              amount: totalAmount,
                              isBold: false,
                            ),
                            const SizedBox(height: 10),
                            const _PaymentAmountRow(
                              label: 'Tax + Delivery Charges',
                              amount: '\$0.00',
                              isBold: false,
                            ),
                            const SizedBox(height: 10),
                            _PaymentAmountRow(
                              label: 'Total Amount',
                              amount: totalAmount,
                              isBold: true,
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),
                    AppPrimaryButton(
                      key: const Key('booking_payment_checkout_button'),
                      label: 'Checkout',
                      onPressed: () => _openCheckout(context),
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

  String _formatBookingDateTime(DateTime date, String time) {
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

    return '${date.day} ${monthNames[date.month - 1]} ${date.year} - ${time.replaceAll(':', '.')}';
  }
}

class _PaymentProgressIndicator extends StatelessWidget {
  const _PaymentProgressIndicator();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 40),
      child: Row(
        children: const [
          _ProgressDone(),
          _ProgressLine(),
          _ProgressPending(),
          _ProgressLine(),
          _ProgressPending(),
        ],
      ),
    );
  }
}

class _ProgressDone extends StatelessWidget {
  const _ProgressDone();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 16,
      height: 16,
      decoration: const BoxDecoration(
        color: AppButtonColors.primaryBackground,
        shape: BoxShape.circle,
      ),
      child: const Icon(Icons.check_rounded, size: 12, color: Colors.white),
    );
  }
}

class _ProgressPending extends StatelessWidget {
  const _ProgressPending();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 8,
      height: 8,
      decoration: const BoxDecoration(
        color: Color(0xFFD8D8D8),
        shape: BoxShape.circle,
      ),
    );
  }
}

class _ProgressLine extends StatelessWidget {
  const _ProgressLine();

  @override
  Widget build(BuildContext context) {
    return const Expanded(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 10),
        child: Divider(
          height: 1,
          thickness: 1.5,
          color: Color(0xFFE1E1E1),
        ),
      ),
    );
  }
}

class _PaymentDetailRow extends StatelessWidget {
  const _PaymentDetailRow({
    required this.icon,
    required this.title,
    required this.value,
    this.compactValue = false,
  });

  final IconData icon;
  final String title;
  final String value;
  final bool compactValue;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 24,
          height: 24,
          decoration: BoxDecoration(
            color: AppButtonColors.primaryBackground,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, size: 15, color: Colors.white),
        ),
        const SizedBox(width: 6),
        Expanded(
          child: compactValue
              ? Padding(
                  padding: const EdgeInsets.only(top: 3),
                  child: Text(
                    title,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF1E1E1E),
                    ),
                  ),
                )
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF1E1E1E),
                      ),
                    ),
                    const SizedBox(height: 1),
                    Text(
                      value,
                      style: const TextStyle(
                        fontSize: 9.5,
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

class _PaymentAmountRow extends StatelessWidget {
  const _PaymentAmountRow({
    required this.label,
    required this.amount,
    required this.isBold,
  });

  final String label;
  final String amount;
  final bool isBold;

  @override
  Widget build(BuildContext context) {
    final textStyle = TextStyle(
      fontSize: 13,
      fontWeight: isBold ? FontWeight.w600 : FontWeight.w400,
      color: const Color(0xFF2A2A2A),
    );

    return Row(
      children: [
        Text(label, style: textStyle),
        const Spacer(),
        Text(amount, style: textStyle),
      ],
    );
  }
}
