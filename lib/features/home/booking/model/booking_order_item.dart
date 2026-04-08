class BookingOrderItem {
  const BookingOrderItem({
    required this.id,
    this.providerId = '',
    required this.status,
    required this.orderDate,
    required this.paymentDate,
    required this.rating,
    required this.reviews,
    required this.totalPayment,
    required this.serviceProviderName,
    required this.serviceType,
    required this.customerName,
    this.customerEmail = '',
    this.address = '',
    this.paymentStatus = BookingPaymentStatus.pending,
    this.paymentMethod = '',
    this.bookingTime,
    this.reviewRating,
    this.reviewText = '',
    this.showInWallet = false,
  });

  final String id;
  final String providerId;
  final BookingOrderStatus status;
  final DateTime orderDate;
  final DateTime paymentDate;
  final String rating;
  final String reviews;
  final String totalPayment;
  final String serviceProviderName;
  final String serviceType;
  final String customerName;
  final String customerEmail;
  final String address;
  final BookingPaymentStatus paymentStatus;
  final String paymentMethod;
  final String? bookingTime;
  final int? reviewRating;
  final String reviewText;
  final bool showInWallet;

  bool get isActive {
    return status == BookingOrderStatus.pending ||
        status == BookingOrderStatus.accepted ||
        status == BookingOrderStatus.orderPlaced ||
        status == BookingOrderStatus.inProgress;
  }

  bool get hasReview {
    return reviewRating != null || reviewText.trim().isNotEmpty;
  }

  BookingOrderItem copyWith({
    BookingOrderStatus? status,
    DateTime? orderDate,
    DateTime? paymentDate,
    String? providerId,
    String? rating,
    String? reviews,
    String? totalPayment,
    String? serviceProviderName,
    String? serviceType,
    String? customerName,
    String? customerEmail,
    String? address,
    BookingPaymentStatus? paymentStatus,
    String? paymentMethod,
    String? bookingTime,
    int? reviewRating,
    String? reviewText,
    bool? showInWallet,
  }) {
    return BookingOrderItem(
      id: id,
      providerId: providerId ?? this.providerId,
      status: status ?? this.status,
      orderDate: orderDate ?? this.orderDate,
      paymentDate: paymentDate ?? this.paymentDate,
      rating: rating ?? this.rating,
      reviews: reviews ?? this.reviews,
      totalPayment: totalPayment ?? this.totalPayment,
      serviceProviderName: serviceProviderName ?? this.serviceProviderName,
      serviceType: serviceType ?? this.serviceType,
      customerName: customerName ?? this.customerName,
      customerEmail: customerEmail ?? this.customerEmail,
      address: address ?? this.address,
      paymentStatus: paymentStatus ?? this.paymentStatus,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      bookingTime: bookingTime ?? this.bookingTime,
      reviewRating: reviewRating ?? this.reviewRating,
      reviewText: reviewText ?? this.reviewText,
      showInWallet: showInWallet ?? this.showInWallet,
    );
  }

  factory BookingOrderItem.fromJson(Map<String, dynamic> json) {
    final booking = json['booking'] is Map<String, dynamic>
        ? json['booking'] as Map<String, dynamic>
        : json;
    final provider = booking['provider'] is Map<String, dynamic>
        ? booking['provider'] as Map<String, dynamic>
        : booking['service_provider'] is Map<String, dynamic>
        ? booking['service_provider'] as Map<String, dynamic>
        : const <String, dynamic>{};
    final customer = booking['customer'] is Map<String, dynamic>
        ? booking['customer'] as Map<String, dynamic>
        : const <String, dynamic>{};
    final review = booking['review'] is Map<String, dynamic>
        ? booking['review'] as Map<String, dynamic>
        : const <String, dynamic>{};

    final orderDate = DateTime.tryParse(
      (booking['booking_date'] ?? booking['order_date'] ?? '').toString(),
    );
    final createdAt = DateTime.tryParse(
      (booking['created_at'] ?? booking['payment_date'] ?? '').toString(),
    );

    final paymentValue =
        booking['total_payment'] ??
        booking['amount'] ??
        booking['total_amount'] ??
        booking['price'] ??
        0;

    return BookingOrderItem(
      id: (booking['id'] ?? '').toString(),
      providerId: (booking['provider_id'] ??
              provider['id'] ??
              booking['service_provider_id'] ??
              '')
          .toString(),
      status: BookingOrderStatusX.fromApi(
        (booking['status'] ?? 'pending').toString(),
      ),
      orderDate: orderDate ?? createdAt ?? DateTime.now(),
      paymentDate: createdAt ?? orderDate ?? DateTime.now(),
      rating: (provider['rating'] ??
              booking['provider_rating'] ??
              booking['rating'] ??
              '4.9')
          .toString(),
      reviews: (provider['reviews_count'] ??
              provider['reviews'] ??
              booking['reviews'] ??
              '0')
          .toString(),
      totalPayment: _formatCurrencyLabel(paymentValue),
      serviceProviderName: (provider['name'] ??
              booking['service_provider_name'] ??
              booking['provider_name'] ??
              'Provider')
          .toString(),
      serviceType:
          (booking['service_type'] ?? booking['service'] ?? 'Car Wash')
              .toString(),
      customerName:
          (customer['name'] ?? booking['customer_name'] ?? 'Customer')
              .toString(),
      customerEmail:
          (customer['email'] ?? booking['customer_email'] ?? '').toString(),
      address: (booking['address'] ?? '').toString(),
      paymentStatus: BookingPaymentStatusX.fromApi(
        (booking['payment_status'] ?? 'pending').toString(),
      ),
      paymentMethod: (booking['payment_method'] ?? '').toString(),
      bookingTime: (booking['booking_time'] ?? '').toString().trim().isEmpty
          ? null
          : booking['booking_time'].toString(),
      reviewRating: review['rating'] == null
          ? null
          : int.tryParse(review['rating'].toString()),
      reviewText: (review['review_text'] ?? review['text'] ?? '').toString(),
      showInWallet: (booking['payment_status'] ?? '').toString() == 'paid',
    );
  }

  static String _formatCurrencyLabel(dynamic amount) {
    final numeric = switch (amount) {
      num value => value.toDouble(),
      String value => double.tryParse(
            value.replaceAll(RegExp(r'[^0-9.]'), ''),
          ) ??
          0,
      _ => 0.0,
    };

    return '\$${numeric.toStringAsFixed(2)}';
  }
}

enum BookingOrderStatus {
  pending,
  accepted,
  orderPlaced,
  inProgress,
  completed,
  cancelled,
}

enum BookingPaymentStatus {
  pending,
  paid,
}

extension BookingOrderStatusX on BookingOrderStatus {
  static BookingOrderStatus fromApi(String value) {
    switch (value.trim().toLowerCase()) {
      case 'pending':
        return BookingOrderStatus.pending;
      case 'accepted':
        return BookingOrderStatus.accepted;
      case 'order_placed':
        return BookingOrderStatus.orderPlaced;
      case 'in_progress':
        return BookingOrderStatus.inProgress;
      case 'completed':
        return BookingOrderStatus.completed;
      case 'cancelled':
        return BookingOrderStatus.cancelled;
      default:
        return BookingOrderStatus.pending;
    }
  }

  String get apiValue {
    switch (this) {
      case BookingOrderStatus.pending:
        return 'pending';
      case BookingOrderStatus.accepted:
        return 'accepted';
      case BookingOrderStatus.orderPlaced:
        return 'order_placed';
      case BookingOrderStatus.inProgress:
        return 'in_progress';
      case BookingOrderStatus.completed:
        return 'completed';
      case BookingOrderStatus.cancelled:
        return 'cancelled';
    }
  }
}

extension BookingPaymentStatusX on BookingPaymentStatus {
  static BookingPaymentStatus fromApi(String value) {
    switch (value.trim().toLowerCase()) {
      case 'paid':
        return BookingPaymentStatus.paid;
      case 'pending':
      default:
        return BookingPaymentStatus.pending;
    }
  }
}
