import 'package:car_wash/core/theme/app_button_colors.dart';
import 'package:car_wash/core/theme/app_colors.dart';
import 'package:car_wash/core/widgets/app_buttons.dart';
import 'package:car_wash/features/home/booking/model/booking_payment_method.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

class BookingCardDetailsScreen extends StatefulWidget {
  const BookingCardDetailsScreen({
    super.key,
    required this.initialMethod,
  });

  final BookingPaymentMethod initialMethod;

  @override
  State<BookingCardDetailsScreen> createState() =>
      _BookingCardDetailsScreenState();
}

class _BookingCardDetailsScreenState extends State<BookingCardDetailsScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _cardNumberController = TextEditingController();
  final TextEditingController _expiryController = TextEditingController();
  final TextEditingController _cvvController = TextEditingController();

  bool _hasAttemptedSubmit = false;

  bool get _isCardMethod {
    return widget.initialMethod.kind == BookingPaymentMethodKind.mastercard ||
        widget.initialMethod.kind == BookingPaymentMethodKind.visa;
  }

  @override
  void initState() {
    super.initState();

    final digits = _extractDigits(widget.initialMethod.subtitle);
    if (_isCardMethod && widget.initialMethod.hasCardDetails) {
      _cardNumberController.text = _formatCardNumber(digits);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _cardNumberController.dispose();
    _expiryController.dispose();
    _cvvController.dispose();
    super.dispose();
  }

  void _submit() {
    FocusScope.of(context).unfocus();

    setState(() {
      _hasAttemptedSubmit = true;
    });

    final isValid = _formKey.currentState?.validate() ?? false;
    if (!isValid) {
      return;
    }

    context.pop<BookingPaymentMethod>(
      BookingPaymentMethod(
        id: widget.initialMethod.id,
        title: widget.initialMethod.title,
        subtitle: _cardNumberController.text.trim(),
        kind: _isCardMethod
            ? widget.initialMethod.kind
            : BookingPaymentMethodKind.mastercard,
      ),
    );
  }

  String _previewName() {
    final value = _nameController.text.trim();
    return value.isEmpty ? 'CARD HOLDER' : value.toUpperCase();
  }

  String _previewNumber() {
    final value = _cardNumberController.text.trim();
    return value.isEmpty ? '**** **** **** ****' : value;
  }

  String _previewExpiry() {
    final digits = _extractDigits(_expiryController.text);
    if (digits.length >= 4) {
      return '${digits.substring(0, 2)}/${digits.substring(digits.length - 2)}';
    }

    return 'MM/YY';
  }

  String? _validateName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Name on card is required';
    }

    return null;
  }

  String? _validateCardNumber(String? value) {
    final digits = _extractDigits(value);
    if (digits.length != 16) {
      return 'Enter a valid 16-digit card number';
    }

    return null;
  }

  String? _validateExpiry(String? value) {
    final digits = _extractDigits(value);
    if (digits.length != 6) {
      return 'Use MM / YYYY format';
    }

    final month = int.tryParse(digits.substring(0, 2));
    final year = int.tryParse(digits.substring(2));
    if (month == null || year == null || month < 1 || month > 12) {
      return 'Enter a valid expiry date';
    }

    return null;
  }

  String? _validateCvv(String? value) {
    final digits = _extractDigits(value);
    if (digits.length < 3) {
      return 'Enter a valid CVV';
    }

    return null;
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
                      key: const Key('booking_card_details_back_button'),
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
                          'Card Details',
                          key: Key('booking_card_details_title'),
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
                padding: const EdgeInsets.fromLTRB(12, 14, 12, 16),
                child: Column(
                  children: [
                    const _CardDetailsProgressIndicator(),
                    const SizedBox(height: 16),
                    Expanded(
                      child: SingleChildScrollView(
                        child: Form(
                          key: _formKey,
                          autovalidateMode: _hasAttemptedSubmit
                              ? AutovalidateMode.always
                              : AutovalidateMode.disabled,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _CardPreview(
                                name: _previewName(),
                                cardNumber: _previewNumber(),
                                expiry: _previewExpiry(),
                                kind: _isCardMethod
                                    ? widget.initialMethod.kind
                                    : BookingPaymentMethodKind.mastercard,
                              ),
                              const SizedBox(height: 16),
                              Container(
                                width: double.infinity,
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: AppColors.surfaceElevated,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: AppColors.border,
                                  ),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const _CardDetailsHeader(),
                                    const SizedBox(height: 12),
                                    const Divider(
                                      height: 1,
                                      thickness: 1,
                                      color: AppColors.border,
                                    ),
                                    const SizedBox(height: 12),
                                    const _CardDetailsFieldLabel(
                                      'Name on card',
                                    ),
                                    const SizedBox(height: 6),
                                    _CardDetailsTextField(
                                      key: const Key(
                                        'booking_card_details_name_field',
                                      ),
                                      controller: _nameController,
                                      hintText: 'Olivia Rhye',
                                      validator: _validateName,
                                      textInputAction: TextInputAction.next,
                                      onChanged: (_) => setState(() {}),
                                    ),
                                    const SizedBox(height: 12),
                                    const _CardDetailsFieldLabel(
                                      'Card number',
                                    ),
                                    const SizedBox(height: 6),
                                    _CardDetailsTextField(
                                      key: const Key(
                                        'booking_card_details_number_field',
                                      ),
                                      controller: _cardNumberController,
                                      hintText: '1234 1234 1234 1234',
                                      validator: _validateCardNumber,
                                      keyboardType: TextInputType.number,
                                      textInputAction: TextInputAction.next,
                                      inputFormatters: [
                                        FilteringTextInputFormatter.digitsOnly,
                                        LengthLimitingTextInputFormatter(16),
                                        _CardNumberFormatter(),
                                      ],
                                      prefix: _FieldCardBadge(
                                        kind: _isCardMethod
                                            ? widget.initialMethod.kind
                                            : BookingPaymentMethodKind
                                                  .mastercard,
                                      ),
                                      onChanged: (_) => setState(() {}),
                                    ),
                                    const SizedBox(height: 12),
                                    Row(
                                      children: [
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              const _CardDetailsFieldLabel(
                                                'Expiry',
                                              ),
                                              const SizedBox(height: 6),
                                              _CardDetailsTextField(
                                                key: const Key(
                                                  'booking_card_details_expiry_field',
                                                ),
                                                controller: _expiryController,
                                                hintText: '06 / 2024',
                                                validator: _validateExpiry,
                                                keyboardType:
                                                    TextInputType.number,
                                                textInputAction:
                                                    TextInputAction.next,
                                                inputFormatters: [
                                                  FilteringTextInputFormatter
                                                      .digitsOnly,
                                                  LengthLimitingTextInputFormatter(
                                                    6,
                                                  ),
                                                  _ExpiryDateFormatter(),
                                                ],
                                                onChanged: (_) =>
                                                    setState(() {}),
                                              ),
                                            ],
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              const _CardDetailsFieldLabel(
                                                'CVV',
                                              ),
                                              const SizedBox(height: 6),
                                              _CardDetailsTextField(
                                                key: const Key(
                                                  'booking_card_details_cvv_field',
                                                ),
                                                controller: _cvvController,
                                                hintText: '123',
                                                validator: _validateCvv,
                                                keyboardType:
                                                    TextInputType.number,
                                                textInputAction:
                                                    TextInputAction.done,
                                                obscureText: true,
                                                inputFormatters: [
                                                  FilteringTextInputFormatter
                                                      .digitsOnly,
                                                  LengthLimitingTextInputFormatter(
                                                    4,
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 10, 14, 22),
              child: AppPrimaryButton(
                key: const Key('booking_card_details_submit_button'),
                label: 'Proceed to payment',
                onPressed: _submit,
                height: 46,
                borderRadius: 6,
                textStyle: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CardDetailsProgressIndicator extends StatelessWidget {
  const _CardDetailsProgressIndicator();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(horizontal: 38),
      child: Row(
        children: [
          _CompletedProgressNode(),
          _CompletedProgressLine(),
          _CompletedProgressNode(),
          _CompletedProgressLine(),
          _CompletedProgressNode(),
        ],
      ),
    );
  }
}

class _CompletedProgressNode extends StatelessWidget {
  const _CompletedProgressNode();

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

class _CompletedProgressLine extends StatelessWidget {
  const _CompletedProgressLine();

  @override
  Widget build(BuildContext context) {
    return const Expanded(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 10),
        child: Divider(
          height: 1,
          thickness: 1.5,
          color: AppButtonColors.primaryBackground,
        ),
      ),
    );
  }
}

class _CardPreview extends StatelessWidget {
  const _CardPreview({
    required this.name,
    required this.cardNumber,
    required this.expiry,
    required this.kind,
  });

  final String name;
  final String cardNumber;
  final String expiry;
  final BookingPaymentMethodKind kind;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFFD7E8DD),
            Color(0xFFDBE4DA),
            Color(0xFFF2EFE7),
          ],
        ),
      ),
      child: SizedBox(
        height: 116,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Text(
                  'Untitled.',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF2E4563),
                  ),
                ),
                const Spacer(),
                Icon(
                  Icons.contactless_rounded,
                  size: 18,
                  color: Colors.white.withValues(alpha: 0.82),
                ),
              ],
            ),
            const Spacer(),
            Row(
              children: [
                Expanded(
                  child: Text(
                    name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 10.5,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF5B666E),
                      letterSpacing: 0.6,
                    ),
                  ),
                ),
                Text(
                  expiry,
                  style: const TextStyle(
                    fontSize: 10.5,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF5B666E),
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Expanded(
                  child: Text(
                    cardNumber,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF33414A),
                      letterSpacing: 1.1,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                _FieldCardBadge(kind: kind, useFilledBackground: true),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _CardDetailsHeader extends StatelessWidget {
  const _CardDetailsHeader();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            color: const Color(0xFFE8F4EA),
            borderRadius: BorderRadius.circular(19),
          ),
          alignment: Alignment.center,
          child: Container(
            width: 22,
            height: 16,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(4),
              border: Border.all(color: AppButtonColors.primaryBackground),
            ),
            child: const Icon(
              Icons.credit_card_rounded,
              size: 15,
              color: AppButtonColors.primaryBackground,
            ),
          ),
        ),
        const SizedBox(width: 10),
        const Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Add your Card details',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textPrimary,
                ),
              ),
              SizedBox(height: 2),
              Text(
                'Update your card details.',
                style: TextStyle(
                  fontSize: 11,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _CardDetailsFieldLabel extends StatelessWidget {
  const _CardDetailsFieldLabel(this.label);

  final String label;

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: const TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w500,
        color: AppColors.textPrimary,
      ),
    );
  }
}

class _CardDetailsTextField extends StatelessWidget {
  const _CardDetailsTextField({
    super.key,
    required this.controller,
    required this.hintText,
    this.validator,
    this.keyboardType,
    this.textInputAction,
    this.inputFormatters,
    this.prefix,
    this.obscureText = false,
    this.onChanged,
  });

  final TextEditingController controller;
  final String hintText;
  final String? Function(String?)? validator;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final List<TextInputFormatter>? inputFormatters;
  final Widget? prefix;
  final bool obscureText;
  final ValueChanged<String>? onChanged;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      cursorColor: AppButtonColors.primaryBackground,
      style: const TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: AppColors.textPrimary,
      ),
      validator: validator,
      keyboardType: keyboardType,
      textInputAction: textInputAction,
      inputFormatters: inputFormatters,
      obscureText: obscureText,
      obscuringCharacter: '*',
      onChanged: onChanged,
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: const TextStyle(
          fontSize: 14,
          color: AppColors.textMuted,
        ),
        contentPadding: EdgeInsets.symmetric(
          horizontal: prefix == null ? 12 : 10,
          vertical: 13,
        ),
        filled: true,
        fillColor: AppColors.inputFill,
        prefixIcon: prefix == null
            ? null
            : Padding(
                padding: const EdgeInsets.only(left: 10, right: 8),
                child: prefix,
              ),
        prefixIconConstraints: const BoxConstraints(
          minWidth: 0,
          minHeight: 0,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(
            color: AppButtonColors.primaryBackground,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Color(0xFFE53935)),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Color(0xFFE53935)),
        ),
        errorStyle: const TextStyle(fontSize: 12),
      ),
    );
  }
}

class _FieldCardBadge extends StatelessWidget {
  const _FieldCardBadge({
    required this.kind,
    this.useFilledBackground = false,
  });

  final BookingPaymentMethodKind kind;
  final bool useFilledBackground;

  @override
  Widget build(BuildContext context) {
    switch (kind) {
      case BookingPaymentMethodKind.mastercard:
        return _MasterCardBadge(useFilledBackground: useFilledBackground);
      case BookingPaymentMethodKind.visa:
        return const _VisaBadge();
      case BookingPaymentMethodKind.cash:
      case BookingPaymentMethodKind.paypal:
        return _MasterCardBadge(useFilledBackground: useFilledBackground);
    }
  }
}

class _MasterCardBadge extends StatelessWidget {
  const _MasterCardBadge({
    this.useFilledBackground = false,
  });

  final bool useFilledBackground;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 34,
      height: 26,
      decoration: BoxDecoration(
        color: useFilledBackground ? Colors.white : const Color(0xFF111111),
        borderRadius: BorderRadius.circular(6),
        border: useFilledBackground
            ? null
            : Border.all(color: const Color(0xFF111111)),
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Positioned(
            left: 7,
            child: Container(
              width: 12,
              height: 12,
              decoration: const BoxDecoration(
                color: Color(0xFFF44336),
                shape: BoxShape.circle,
              ),
            ),
          ),
          Positioned(
            right: 7,
            child: Container(
              width: 12,
              height: 12,
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

class _VisaBadge extends StatelessWidget {
  const _VisaBadge();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 34,
      height: 26,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: const Color(0xFFE0E0E0)),
      ),
      alignment: Alignment.center,
      child: const Text(
        'VISA',
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w700,
          color: Color(0xFF1A4BA0),
        ),
      ),
    );
  }
}

class _CardNumberFormatter extends TextInputFormatter {
  const _CardNumberFormatter();

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final digits = _extractDigits(newValue.text);
    final formatted = _formatCardNumber(digits);

    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}

class _ExpiryDateFormatter extends TextInputFormatter {
  const _ExpiryDateFormatter();

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final digits = _extractDigits(newValue.text);
    final buffer = StringBuffer();

    for (var index = 0; index < digits.length && index < 6; index++) {
      if (index == 2) {
        buffer.write(' / ');
      }
      buffer.write(digits[index]);
    }

    final formatted = buffer.toString();
    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}

String _extractDigits(String? value) {
  return (value ?? '').replaceAll(RegExp(r'[^0-9]'), '');
}

String _formatCardNumber(String digits) {
  final buffer = StringBuffer();

  for (var index = 0; index < digits.length && index < 16; index++) {
    if (index > 0 && index % 4 == 0) {
      buffer.write(' ');
    }
    buffer.write(digits[index]);
  }

  return buffer.toString();
}
