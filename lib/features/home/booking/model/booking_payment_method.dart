class BookingPaymentMethod {
  const BookingPaymentMethod({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.kind,
  });

  final String id;
  final String title;
  final String subtitle;
  final BookingPaymentMethodKind kind;

  static const creditCard = BookingPaymentMethod(
    id: 'credit_card',
    title: 'Credit card',
    subtitle: '',
    kind: BookingPaymentMethodKind.mastercard,
  );

  static const cash = BookingPaymentMethod(
    id: 'cash',
    title: 'Cash',
    subtitle: '',
    kind: BookingPaymentMethodKind.cash,
  );

  static const visa = BookingPaymentMethod(
    id: 'visa',
    title: 'Visa',
    subtitle: '',
    kind: BookingPaymentMethodKind.visa,
  );

  static const paypal = BookingPaymentMethod(
    id: 'paypal',
    title: 'PayPal',
    subtitle: '',
    kind: BookingPaymentMethodKind.paypal,
  );

  static const all = [
    creditCard,
    cash,
    visa,
    paypal,
  ];

  bool get isCard {
    return kind == BookingPaymentMethodKind.mastercard ||
        kind == BookingPaymentMethodKind.visa;
  }

  bool get hasCardDetails {
    final digits = subtitle.replaceAll(RegExp(r'[^0-9]'), '');
    return isCard && digits.length == 16;
  }

  String get displaySubtitle {
    if (subtitle.isNotEmpty) {
      return subtitle;
    }

    return isCard ? 'Card details required' : '';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }

    return other is BookingPaymentMethod && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}

enum BookingPaymentMethodKind {
  mastercard,
  cash,
  visa,
  paypal,
}
