class BookingOrderItem {
  const BookingOrderItem({
    required this.id,
    this.providerId = '',
    required this.status,
    required this.orderDate,
    required this.paymentDate,
    this.statusUpdatedAt,
    required this.rating,
    required this.reviews,
    required this.totalPayment,
    required this.serviceProviderName,
    required this.serviceType,
    required this.customerName,
    this.customerEmail = '',
    this.address = '',
    this.customerLatitude,
    this.customerLongitude,
    this.providerLatitude,
    this.providerLongitude,
    this.paymentStatus = BookingPaymentStatus.pending,
    this.paymentMethod = '',
    this.bookingTime,
    this.reviewRating,
    this.reviewText = '',
    this.showInWallet = false,
    this.workPhotos = const [],
  });

  final String id;
  final String providerId;
  final BookingOrderStatus status;
  final DateTime orderDate;
  final DateTime paymentDate;
  final DateTime? statusUpdatedAt;
  final String rating;
  final String reviews;
  final String totalPayment;
  final String serviceProviderName;
  final String serviceType;
  final String customerName;
  final String customerEmail;
  final String address;
  final double? customerLatitude;
  final double? customerLongitude;
  final double? providerLatitude;
  final double? providerLongitude;
  final BookingPaymentStatus paymentStatus;
  final String paymentMethod;
  final String? bookingTime;
  final int? reviewRating;
  final String reviewText;
  final bool showInWallet;
  final List<String> workPhotos;

  bool get isActive {
    return status == BookingOrderStatus.pending ||
        status == BookingOrderStatus.accepted ||
        status == BookingOrderStatus.orderPlaced ||
        status == BookingOrderStatus.inProgress ||
        status == BookingOrderStatus.awaitingApproval;
  }

  bool get hasReview {
    return reviewRating != null || reviewText.trim().isNotEmpty;
  }

  bool get hasCustomerCoordinates =>
      customerLatitude != null && customerLongitude != null;

  bool get hasProviderCoordinates =>
      providerLatitude != null && providerLongitude != null;

  DateTime get notificationTimestamp => statusUpdatedAt ?? paymentDate;

  bool get hasUnreadNotification {
    final difference = DateTime.now().difference(notificationTimestamp);
    return difference.inMinutes < 180;
  }

  BookingOrderItem copyWith({
    BookingOrderStatus? status,
    DateTime? orderDate,
    DateTime? paymentDate,
    DateTime? statusUpdatedAt,
    String? providerId,
    String? rating,
    String? reviews,
    String? totalPayment,
    String? serviceProviderName,
    String? serviceType,
    String? customerName,
    String? customerEmail,
    String? address,
    double? customerLatitude,
    double? customerLongitude,
    double? providerLatitude,
    double? providerLongitude,
    BookingPaymentStatus? paymentStatus,
    String? paymentMethod,
    String? bookingTime,
    int? reviewRating,
    String? reviewText,
    bool? showInWallet,
    List<String>? workPhotos,
  }) {
    return BookingOrderItem(
      id: id,
      providerId: providerId ?? this.providerId,
      status: status ?? this.status,
      orderDate: orderDate ?? this.orderDate,
      paymentDate: paymentDate ?? this.paymentDate,
      statusUpdatedAt: statusUpdatedAt ?? this.statusUpdatedAt,
      rating: rating ?? this.rating,
      reviews: reviews ?? this.reviews,
      totalPayment: totalPayment ?? this.totalPayment,
      serviceProviderName: serviceProviderName ?? this.serviceProviderName,
      serviceType: serviceType ?? this.serviceType,
      customerName: customerName ?? this.customerName,
      customerEmail: customerEmail ?? this.customerEmail,
      address: address ?? this.address,
      customerLatitude: customerLatitude ?? this.customerLatitude,
      customerLongitude: customerLongitude ?? this.customerLongitude,
      providerLatitude: providerLatitude ?? this.providerLatitude,
      providerLongitude: providerLongitude ?? this.providerLongitude,
      paymentStatus: paymentStatus ?? this.paymentStatus,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      bookingTime: bookingTime ?? this.bookingTime,
      reviewRating: reviewRating ?? this.reviewRating,
      reviewText: reviewText ?? this.reviewText,
      showInWallet: showInWallet ?? this.showInWallet,
      workPhotos: workPhotos ?? this.workPhotos,
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
    final updatedAt = DateTime.tryParse(
      (booking['updated_at'] ??
              booking['status_updated_at'] ??
              booking['last_updated_at'] ??
              '')
          .toString(),
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
      statusUpdatedAt: updatedAt,
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
      customerLatitude: _readDouble(
        booking,
        ['customer_latitude', 'latitude', 'lat'],
      ),
      customerLongitude: _readDouble(
        booking,
        ['customer_longitude', 'longitude', 'lng'],
      ),
      providerLatitude: _readDouble(
        booking,
        ['provider_latitude', 'service_provider_latitude'],
      ),
      providerLongitude: _readDouble(
        booking,
        ['provider_longitude', 'service_provider_longitude'],
      ),
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
      workPhotos: (booking['work_photos'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          const [],
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

  static double? _readDouble(Map<String, dynamic> json, List<String> keys) {
    for (final key in keys) {
      final value = json[key];
      if (value == null) {
        continue;
      }

      if (value is num) {
        return value.toDouble();
      }

      final parsed = double.tryParse(value.toString());
      if (parsed != null) {
        return parsed;
      }
    }

    return null;
  }
}

enum BookingOrderStatus {
  pending,
  accepted,
  orderPlaced,
  inProgress,
  awaitingApproval,
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
      case 'awaiting_approval':
        return BookingOrderStatus.awaitingApproval;
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
      case BookingOrderStatus.awaitingApproval:
        return 'awaiting_approval';
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
