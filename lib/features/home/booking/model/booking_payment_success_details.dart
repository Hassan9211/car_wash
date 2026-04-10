class BookingPaymentSuccessDetails {
  const BookingPaymentSuccessDetails({
    required this.paymentDate,
    required this.promoCode,
    required this.expectedDeliveryTime,
    required this.amount,
    required this.tipAmount,
    required this.deliveryCharge,
    required this.tax,
    required this.discount,
    required this.totalAmount,
  });

  final DateTime paymentDate;
  final String promoCode;
  final String expectedDeliveryTime;
  final double amount;
  final double tipAmount;
  final double deliveryCharge;
  final double tax;
  final double discount;
  final double totalAmount;

  static final fallback = BookingPaymentSuccessDetails(
    paymentDate: DateTime(2023, 9, 18, 10),
    promoCode: 'FR2412357435WER',
    expectedDeliveryTime: '12:00 pm',
    amount: 150,
    tipAmount: 10,
    deliveryCharge: 0,
    tax: 0,
    discount: 35,
    totalAmount: 125,
  );
}
