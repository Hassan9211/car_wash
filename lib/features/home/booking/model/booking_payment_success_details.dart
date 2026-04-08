class BookingPaymentSuccessDetails {
  const BookingPaymentSuccessDetails({
    required this.paymentDate,
    required this.promoCode,
    required this.expectedDeliveryTime,
    required this.amount,
    required this.deliveryCharge,
    required this.tax,
    required this.discount,
    required this.totalAmount,
  });

  final DateTime paymentDate;
  final String promoCode;
  final String expectedDeliveryTime;
  final double amount;
  final double deliveryCharge;
  final double tax;
  final double discount;
  final double totalAmount;

  static final fallback = BookingPaymentSuccessDetails(
    paymentDate: DateTime(2023, 9, 18, 10),
    promoCode: 'FR2412357435WER',
    expectedDeliveryTime: '12:00 pm',
    amount: 150,
    deliveryCharge: 5,
    tax: 0,
    discount: 35,
    totalAmount: 190,
  );
}
