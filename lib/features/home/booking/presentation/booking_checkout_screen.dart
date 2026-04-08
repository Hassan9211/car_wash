import 'package:car_wash/core/router/app_navigation.dart';
import 'package:car_wash/core/theme/app_button_colors.dart';
import 'package:car_wash/core/widgets/app_buttons.dart';
import 'package:car_wash/features/authentication/data/auth_session.dart';
import 'package:car_wash/features/home/booking/data/booking_orders_store.dart';
import 'package:car_wash/features/home/booking/model/booking_flow_details.dart';
import 'package:car_wash/features/home/booking/model/booking_order_item.dart';
import 'package:car_wash/features/home/booking/model/booking_payment_method.dart';
import 'package:car_wash/features/home/booking/model/booking_payment_success_details.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class BookingCheckoutScreen extends StatefulWidget {
  const BookingCheckoutScreen({
    super.key,
    required this.details,
  });

  final BookingFlowDetails details;

  @override
  State<BookingCheckoutScreen> createState() => _BookingCheckoutScreenState();
}

class _BookingCheckoutScreenState extends State<BookingCheckoutScreen> {
  static const _tipOptions = [0, 5, 10, 15, 20];

  int _selectedTip = 10;
  BookingPaymentMethod _selectedPaymentMethod =
      BookingPaymentMethod.creditCard;
  bool _isSubmitting = false;

  Future<void> _changePaymentMethod() async {
    final selectedMethod = await context.pushToBookingPaymentMethod(
      _selectedPaymentMethod,
    );

    if (!mounted || selectedMethod == null) {
      return;
    }

    setState(() {
      _selectedPaymentMethod = selectedMethod;
    });
  }

  Future<bool> _ensurePaymentMethodReady() async {
    if (!_selectedPaymentMethod.isCard || _selectedPaymentMethod.hasCardDetails) {
      return true;
    }

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        const SnackBar(
          content: Text('Please add your card details before payment'),
        ),
      );

    final selectedMethod = await context.pushToBookingCardDetails(
      _selectedPaymentMethod,
    );

    if (!mounted || selectedMethod == null) {
      return false;
    }

    setState(() {
      _selectedPaymentMethod = selectedMethod;
    });

    return _selectedPaymentMethod.hasCardDetails;
  }

  Future<void> _openPaymentSuccess() async {
    final isPaymentMethodReady = await _ensurePaymentMethodReady();
    if (!mounted || !isPaymentMethodReady) {
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      final amount = _parseAmount(widget.details.provider.price);
      final totalAmount = amount + _selectedTip;
      final bookingDate = widget.details.bookingDate ?? DateTime.now();
      final bookingTime = widget.details.bookingTime ?? '11:30 AM';
      final customerName = widget.details.customerName.trim().isNotEmpty
          ? widget.details.customerName.trim()
          : AuthSession.displayName;
      final serviceType = widget.details.serviceType.trim().isNotEmpty
          ? widget.details.serviceType.trim()
          : 'Car Wash';

      final paidOrder = BookingOrderItem(
        id: 'order_${DateTime.now().microsecondsSinceEpoch}',
        providerId: widget.details.provider.id.trim().isNotEmpty
            ? widget.details.provider.id
            : widget.details.provider.detailsKeyName,
        status: BookingOrderStatus.pending,
        orderDate: bookingDate,
        paymentDate: DateTime.now(),
        rating: widget.details.provider.rating,
        reviews: widget.details.provider.reviews,
        totalPayment: _formatCurrencyLabel(totalAmount),
        serviceProviderName: widget.details.provider.name,
        serviceType: serviceType,
        customerName: customerName,
        customerEmail: AuthSession.displayEmail,
        address: AuthSession.displayLocationLabel,
        paymentStatus: BookingPaymentStatus.paid,
        paymentMethod: _selectedPaymentMethod.id,
        bookingTime: bookingTime,
        showInWallet: true,
      );
      BookingOrdersStore.instance.addOrUpdate(paidOrder);

      if (!mounted) {
        return;
      }

      await context.pushToBookingPaymentSuccess(
        BookingPaymentSuccessDetails(
          paymentDate: DateTime.now(),
          promoCode: 'FR2412357435WER',
          expectedDeliveryTime: bookingTime,
          amount: amount,
          deliveryCharge: 5,
          tax: 0,
          discount: 0,
          totalAmount: totalAmount,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final details = widget.details;
    final customerName = details.customerName.trim().isNotEmpty
        ? details.customerName.trim()
        : 'JohnSmith';
    final customerEmail = AuthSession.currentEmail ?? 'smith@gmail.com';
    final serviceType = details.serviceType.trim().isNotEmpty
        ? details.serviceType.trim()
        : 'Basic Car Wash';
    final bookingDateTime = _formatBookingDateTime(
      details.bookingDate ?? DateTime(2021, 1, 18),
      details.bookingTime ?? '11:30 AM',
    );
    final baseAmount = _parseAmount(details.provider.price);
    final totalAmount = baseAmount + _selectedTip;
    final baseAmountLabel = _formatCurrency(baseAmount);
    final totalAmountLabel = _formatCurrency(totalAmount);
    final paymentMethodSubtitle = _selectedPaymentMethod.displaySubtitle;

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
                      key: const Key('booking_checkout_back_button'),
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
                          'Checkout',
                          key: Key('booking_checkout_title'),
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
                padding: const EdgeInsets.fromLTRB(12, 10, 12, 16),
                child: Column(
                  children: [
                    const _CheckoutProgressIndicator(),
                    const SizedBox(height: 18),
                    Expanded(
                      child: SingleChildScrollView(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const Text(
                                  'Payment method',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.black,
                                  ),
                                ),
                                const Spacer(),
                                TextButton(
                                  onPressed: _changePaymentMethod,
                                  style: TextButton.styleFrom(
                                    foregroundColor:
                                        AppButtonColors.primaryBackground,
                                    padding: EdgeInsets.zero,
                                    minimumSize: Size.zero,
                                    tapTargetSize:
                                        MaterialTapTargetSize.shrinkWrap,
                                  ),
                                  child: const Text(
                                    'Change',
                                    style: TextStyle(fontSize: 13),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 14,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(color: const Color(0xFFE6E6E6)),
                              ),
                              child: Row(
                                children: [
                                  _PaymentMethodLeadingIcon(
                                    kind: _selectedPaymentMethod.kind,
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          _selectedPaymentMethod.title,
                                          style: TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w500,
                                            color: Color(0xFF222222),
                                          ),
                                        ),
                                        if (paymentMethodSubtitle.isNotEmpty) ...[
                                          const SizedBox(height: 2),
                                          Text(
                                            paymentMethodSubtitle,
                                            style: const TextStyle(
                                              fontSize: 11,
                                              color: Color(0xFF8C8C8C),
                                            ),
                                          ),
                                        ],
                                      ],
                                    ),
                                  ),
                                  Text(
                                    totalAmountLabel,
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w500,
                                      color: Colors.black,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 14),
                            const Text(
                              'Tip your Service Provider',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: Colors.black,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF9F9F9),
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(color: const Color(0xFFEAEAEA)),
                              ),
                              child: SingleChildScrollView(
                                scrollDirection: Axis.horizontal,
                                child: Row(
                                  children: _tipOptions
                                      .map(
                                        (tip) => Padding(
                                          padding: EdgeInsets.only(
                                            right: tip == _tipOptions.last
                                                ? 0
                                                : 8,
                                          ),
                                          child: _TipOptionChip(
                                            label: tip == 0
                                                ? 'Not now'
                                                : '\$${tip.toString()}',
                                            isSelected: _selectedTip == tip,
                                            onTap: () {
                                              setState(() {
                                                _selectedTip = tip;
                                              });
                                            },
                                          ),
                                        ),
                                      )
                                      .toList(growable: false),
                                ),
                              ),
                            ),
                            const SizedBox(height: 14),
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
                                  _CheckoutDetailRow(
                                    icon: Icons.person_rounded,
                                    title: 'Name',
                                    value: customerName,
                                  ),
                                  const SizedBox(height: 8),
                                  _CheckoutDetailRow(
                                    icon: Icons.email_outlined,
                                    title: 'Email',
                                    value: customerEmail,
                                  ),
                                  const SizedBox(height: 8),
                                  _CheckoutDetailRow(
                                    icon: Icons.local_car_wash_rounded,
                                    title: 'Service Type',
                                    value: serviceType,
                                  ),
                                  const SizedBox(height: 8),
                                  _CheckoutDetailRow(
                                    icon: Icons.person_pin_rounded,
                                    title: 'Service Provider',
                                    value: details.provider.name,
                                  ),
                                  const SizedBox(height: 8),
                                  _CheckoutDetailRow(
                                    icon: Icons.calendar_month_rounded,
                                    title: bookingDateTime,
                                    value: '',
                                    compactValue: true,
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 10),
                            _CheckoutAmountRow(
                              label: 'Total Bill',
                              amount: baseAmountLabel,
                              isBold: false,
                            ),
                            const SizedBox(height: 10),
                            _CheckoutAmountRow(
                              label: 'Tax + Delivery Charges',
                              amount: '\$0.00',
                              isBold: false,
                            ),
                            const SizedBox(height: 10),
                            _CheckoutAmountRow(
                              label: 'Total Amount',
                              amount: totalAmountLabel,
                              isBold: true,
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),
                    AppPrimaryButton(
                      key: const Key('booking_checkout_done_button'),
                      label: _isSubmitting ? 'Processing...' : 'Done',
                      onPressed: _isSubmitting ? null : _openPaymentSuccess,
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

  double _parseAmount(String amount) {
    final normalized = amount.replaceAll(RegExp(r'[^0-9.]'), '');
    return double.tryParse(normalized) ?? 0;
  }

  String _formatCurrency(double amount) {
    return '\$${amount.toStringAsFixed(0)}';
  }

  String _formatCurrencyLabel(double amount) {
    return '\$${amount.toStringAsFixed(2)}';
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

class _CheckoutProgressIndicator extends StatelessWidget {
  const _CheckoutProgressIndicator();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 38),
      child: Row(
        children: const [
          _CheckoutProgressDone(),
          _CheckoutProgressLine(isActive: true),
          _CheckoutProgressDone(),
          _CheckoutProgressLine(),
          _CheckoutProgressPending(),
        ],
      ),
    );
  }
}

class _CheckoutProgressDone extends StatelessWidget {
  const _CheckoutProgressDone();

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

class _CheckoutProgressPending extends StatelessWidget {
  const _CheckoutProgressPending();

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

class _CheckoutProgressLine extends StatelessWidget {
  const _CheckoutProgressLine({this.isActive = false});

  final bool isActive;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10),
        child: Divider(
          height: 1,
          thickness: 1.5,
          color: isActive
              ? AppButtonColors.primaryBackground
              : const Color(0xFFE1E1E1),
        ),
      ),
    );
  }
}

class _PaymentMethodLeadingIcon extends StatelessWidget {
  const _PaymentMethodLeadingIcon({
    required this.kind,
  });

  final BookingPaymentMethodKind kind;

  @override
  Widget build(BuildContext context) {
    switch (kind) {
      case BookingPaymentMethodKind.mastercard:
        return const _MasterCardBadge();
      case BookingPaymentMethodKind.cash:
        return const _CashBadge();
      case BookingPaymentMethodKind.visa:
        return const _VisaBadge();
      case BookingPaymentMethodKind.paypal:
        return const _PayPalBadge();
    }
  }
}

class _MasterCardBadge extends StatelessWidget {
  const _MasterCardBadge();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 26,
      height: 18,
      decoration: BoxDecoration(
        color: const Color(0xFF111111),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Positioned(
            left: 6,
            child: Container(
              width: 9,
              height: 9,
              decoration: const BoxDecoration(
                color: Color(0xFFF44336),
                shape: BoxShape.circle,
              ),
            ),
          ),
          Positioned(
            right: 6,
            child: Container(
              width: 9,
              height: 9,
              decoration: const BoxDecoration(
                color: Color(0xFFFFC107),
                shape: BoxShape.circle,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CashBadge extends StatelessWidget {
  const _CashBadge();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 26,
      height: 18,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: const Color(0xFFBDBDBD)),
      ),
      alignment: Alignment.center,
      child: const Icon(
        Icons.payments_outlined,
        size: 13,
        color: Color(0xFF565656),
      ),
    );
  }
}

class _VisaBadge extends StatelessWidget {
  const _VisaBadge();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 26,
      height: 18,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: const Color(0xFFE0E0E0)),
      ),
      alignment: Alignment.center,
      child: const Text(
        'VISA',
        style: TextStyle(
          fontSize: 8.5,
          fontWeight: FontWeight.w700,
          color: Color(0xFF1A4BA0),
        ),
      ),
    );
  }
}

class _PayPalBadge extends StatelessWidget {
  const _PayPalBadge();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 26,
      height: 18,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: const Color(0xFFE0E0E0)),
      ),
      alignment: Alignment.center,
      child: const Text(
        'PP',
        style: TextStyle(
          fontSize: 9,
          fontWeight: FontWeight.w800,
          color: Color(0xFF005EA6),
        ),
      ),
    );
  }
}

class _TipOptionChip extends StatelessWidget {
  const _TipOptionChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Ink(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected
              ? AppButtonColors.primaryBackground
              : Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected
                ? AppButtonColors.primaryBackground
                : const Color(0xFFE2E2E2),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: isSelected ? Colors.white : Colors.black,
          ),
        ),
      ),
    );
  }
}

class _CheckoutDetailRow extends StatelessWidget {
  const _CheckoutDetailRow({
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

class _CheckoutAmountRow extends StatelessWidget {
  const _CheckoutAmountRow({
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
