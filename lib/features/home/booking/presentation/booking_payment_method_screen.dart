import 'package:car_wash/core/router/app_navigation.dart';
import 'package:car_wash/core/theme/app_button_colors.dart';
import 'package:car_wash/core/widgets/app_buttons.dart';
import 'package:car_wash/features/home/booking/model/booking_payment_method.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class BookingPaymentMethodScreen extends StatefulWidget {
  const BookingPaymentMethodScreen({
    super.key,
    required this.selectedMethod,
  });

  final BookingPaymentMethod selectedMethod;

  @override
  State<BookingPaymentMethodScreen> createState() =>
      _BookingPaymentMethodScreenState();
}

class _BookingPaymentMethodScreenState extends State<BookingPaymentMethodScreen> {
  late BookingPaymentMethod _selectedMethod;

  @override
  void initState() {
    super.initState();
    _selectedMethod = widget.selectedMethod;
  }

  void _submitSelection() {
    context.pop<BookingPaymentMethod>(_selectedMethod);
  }

  Future<void> _openCardDetails() async {
    final selectedMethod = await context.pushToBookingCardDetails(
      _selectedMethod,
    );

    if (!mounted || selectedMethod == null) {
      return;
    }

    setState(() {
      _selectedMethod = selectedMethod;
    });

    _submitSelection();
  }

  BookingPaymentMethod _displayMethod(BookingPaymentMethod method) {
    if (method.id != _selectedMethod.id) {
      return method;
    }

    return _selectedMethod;
  }

  bool get _needsCardDetails {
    return _selectedMethod.isCard;
  }

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
                      key: const Key('booking_payment_method_back_button'),
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
                          'Payment Method',
                          key: Key('booking_payment_method_title'),
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
                padding: const EdgeInsets.fromLTRB(12, 18, 12, 16),
                child: Column(
                  children: [
                    Expanded(
                      child: ListView.separated(
                        itemCount: BookingPaymentMethod.all.length,
                        separatorBuilder: (_, _) => const SizedBox(height: 10),
                        itemBuilder: (context, index) {
                          final method = _displayMethod(
                            BookingPaymentMethod.all[index],
                          );
                          return _PaymentMethodOptionTile(
                            method: method,
                            isSelected: method == _selectedMethod,
                            onTap: () {
                              setState(() {
                                _selectedMethod = method;
                              });
                            },
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 16),
                    AppPrimaryButton(
                      key: const Key('booking_payment_method_add_card_button'),
                      label: _needsCardDetails
                          ? 'Add card details'
                          : 'Continue',
                      onPressed: _needsCardDetails
                          ? _openCardDetails
                          : _submitSelection,
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

class _PaymentMethodOptionTile extends StatelessWidget {
  const _PaymentMethodOptionTile({
    required this.method,
    required this.isSelected,
    required this.onTap,
  });

  final BookingPaymentMethod method;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Ink(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: const Color(0xFFE6E6E6)),
          ),
          child: Row(
            children: [
              _PaymentMethodLeadingIcon(kind: method.kind),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      method.title,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF202020),
                      ),
                    ),
                    if (method.displaySubtitle.isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Text(
                        method.displaySubtitle,
                        style: const TextStyle(
                          fontSize: 10.5,
                          color: Color(0xFF8D8D8D),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              _SelectionIndicator(isSelected: isSelected),
            ],
          ),
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

class _SelectionIndicator extends StatelessWidget {
  const _SelectionIndicator({
    required this.isSelected,
  });

  final bool isSelected;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 14,
      height: 14,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: isSelected
              ? AppButtonColors.primaryBackground
              : const Color(0xFFD9D9D9),
        ),
      ),
      child: Center(
        child: Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            color: isSelected
                ? AppButtonColors.primaryBackground
                : Colors.transparent,
            shape: BoxShape.circle,
          ),
        ),
      ),
    );
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
