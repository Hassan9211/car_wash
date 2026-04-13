import 'package:car_wash/features/home/booking/model/booking_order_item.dart';
import 'package:flutter/foundation.dart';

class BookingOrdersStore {
  BookingOrdersStore._()
    : _ordersNotifier = ValueNotifier<List<BookingOrderItem>>(
        List<BookingOrderItem>.from(_seedOrders),
      );

  static final BookingOrdersStore instance = BookingOrdersStore._();

  static final _seedOrders = [
    BookingOrderItem(
      id: 'seed_order_1',
      status: BookingOrderStatus.accepted,
      orderDate: DateTime(2026, 4, 10),
      paymentDate: DateTime(2026, 4, 7, 15, 20),
      rating: '4.9',
      reviews: '13.7K',
      totalPayment: '\$45.00',
      serviceProviderName: 'Ahmed',
      serviceType: 'Basic wash',
      customerName: 'Olivia Rhye',
      customerEmail: 'olivia@example.com',
      address: '145 W 46th St, New York, USA',
      customerLatitude: 40.7589,
      customerLongitude: -73.9844,
      providerLatitude: 40.7581,
      providerLongitude: -73.9856,
      paymentStatus: BookingPaymentStatus.paid,
      bookingTime: '09:00 AM',
      showInWallet: true,
    ),
    BookingOrderItem(
      id: 'seed_order_2',
      status: BookingOrderStatus.pending,
      orderDate: DateTime(2026, 4, 10),
      paymentDate: DateTime(2026, 4, 7, 14, 50),
      rating: '4.9',
      reviews: '13.7K',
      totalPayment: '\$45.00',
      serviceProviderName: 'Youssef',
      serviceType: 'Foam wash',
      customerName: 'Olivia Rhye',
      customerEmail: 'olivia@example.com',
      address: '277 Bedford Ave, Brooklyn, USA',
      customerLatitude: 40.7171,
      customerLongitude: -73.9580,
      providerLatitude: 40.7178,
      providerLongitude: -73.9560,
      paymentStatus: BookingPaymentStatus.paid,
      bookingTime: '10:00 AM',
      showInWallet: true,
    ),
    BookingOrderItem(
      id: 'seed_order_3',
      status: BookingOrderStatus.completed,
      orderDate: DateTime(2026, 4, 10),
      paymentDate: DateTime(2026, 4, 7, 13, 40),
      rating: '4.9',
      reviews: '13.7K',
      totalPayment: '\$45.00',
      serviceProviderName: 'Samir',
      serviceType: 'Interior',
      customerName: 'Olivia Rhye',
      customerEmail: 'olivia@example.com',
      address: '31-57 Steinway St, Queens, USA',
      customerLatitude: 40.7618,
      customerLongitude: -73.9174,
      providerLatitude: 40.7644,
      providerLongitude: -73.9235,
      paymentStatus: BookingPaymentStatus.paid,
      bookingTime: '11:00 AM',
      showInWallet: true,
    ),
    BookingOrderItem(
      id: 'seed_order_4',
      status: BookingOrderStatus.completed,
      orderDate: DateTime(2026, 4, 10),
      paymentDate: DateTime(2026, 4, 7, 12, 25),
      rating: '4.9',
      reviews: '13.7K',
      totalPayment: '\$45.00',
      serviceProviderName: 'Omar',
      serviceType: 'Wax',
      customerName: 'Olivia Rhye',
      customerEmail: 'olivia@example.com',
      address: '80 John St, New York, USA',
      customerLatitude: 40.7078,
      customerLongitude: -74.0054,
      providerLatitude: 40.7075,
      providerLongitude: -74.0113,
      paymentStatus: BookingPaymentStatus.paid,
      bookingTime: '05:00 PM',
      showInWallet: true,
    ),
    BookingOrderItem(
      id: 'seed_order_5',
      status: BookingOrderStatus.completed,
      orderDate: DateTime(2026, 4, 8),
      paymentDate: DateTime(2026, 4, 6, 17, 10),
      rating: '5.0',
      reviews: '11.2K',
      totalPayment: '\$52.00',
      serviceProviderName: 'Ahmed',
      serviceType: 'Premium wash',
      customerName: 'Olivia Rhye',
      customerEmail: 'olivia@example.com',
      address: '510 W 42nd St, New York, USA',
      customerLatitude: 40.7602,
      customerLongitude: -73.9961,
      providerLatitude: 40.7581,
      providerLongitude: -73.9856,
      paymentStatus: BookingPaymentStatus.paid,
      bookingTime: '04:00 PM',
      showInWallet: true,
    ),
    BookingOrderItem(
      id: 'seed_order_6',
      status: BookingOrderStatus.cancelled,
      orderDate: DateTime(2026, 4, 5),
      paymentDate: DateTime(2026, 4, 5, 11, 30),
      rating: '4.8',
      reviews: '9.4K',
      totalPayment: '\$40.00',
      serviceProviderName: 'Samir',
      serviceType: 'Basic wash',
      customerName: 'Olivia Rhye',
      customerEmail: 'olivia@example.com',
      address: '25-35 36th Ave, Queens, USA',
      customerLatitude: 40.7582,
      customerLongitude: -73.9334,
      providerLatitude: 40.7644,
      providerLongitude: -73.9235,
      bookingTime: '03:00 PM',
    ),
  ];

  final ValueNotifier<List<BookingOrderItem>> _ordersNotifier;
  final ValueNotifier<bool> _loadingNotifier = ValueNotifier<bool>(false);
  final ValueNotifier<String?> _errorNotifier = ValueNotifier<String?>(null);

  ValueListenable<List<BookingOrderItem>> get listenable => _ordersNotifier;
  ValueListenable<bool> get loadingListenable => _loadingNotifier;
  ValueListenable<String?> get errorListenable => _errorNotifier;

  List<BookingOrderItem> get orders => List.unmodifiable(_ordersNotifier.value);

  Future<void> fetchCustomerOrders() async {
    await _load(() async => orders);
  }

  Future<void> fetchProviderOrders() async {
    await _load(() async => orders);
  }

  Future<BookingOrderItem> fetchBooking(String orderId) async {
    final existingOrder = _ordersNotifier.value.firstWhere(
      (order) => order.id == orderId,
      orElse: () => _seedOrders.first,
    );
    return existingOrder;
  }

  void addOrUpdate(BookingOrderItem order) {
    final nextOrders = List<BookingOrderItem>.from(_ordersNotifier.value);
    final existingIndex = nextOrders.indexWhere(
      (existingOrder) => existingOrder.id == order.id,
    );

    if (existingIndex == -1) {
      nextOrders.insert(0, order);
    } else {
      nextOrders[existingIndex] = order;
    }

    _ordersNotifier.value = nextOrders;
  }

  Future<void> updateStatus(String orderId, BookingOrderStatus status) async {
    _updateOrder(
      orderId,
      (order) => order.copyWith(
        status: status,
        statusUpdatedAt: DateTime.now(),
      ),
    );
  }

  Future<void> updateReview(
    String orderId, {
    required int reviewRating,
    required String reviewText,
  }) async {
    _updateOrder(
      orderId,
      (order) => order.copyWith(
        reviewRating: reviewRating,
        reviewText: reviewText,
      ),
    );
  }

  Future<void> cancelOrder(String orderId) async {
    _updateOrder(
      orderId,
      (order) => order.copyWith(
        status: BookingOrderStatus.cancelled,
        statusUpdatedAt: DateTime.now(),
      ),
    );
  }

  Future<void> rescheduleOrder({
    required String orderId,
    required DateTime bookingDate,
    required String bookingTime,
  }) async {
    _updateOrder(
      orderId,
      (order) => order.copyWith(
        status: BookingOrderStatus.pending,
        orderDate: bookingDate,
        bookingTime: bookingTime,
        statusUpdatedAt: DateTime.now(),
      ),
    );
  }

  Future<void> _load(
    Future<List<BookingOrderItem>> Function() request,
  ) async {
    _loadingNotifier.value = true;
    _errorNotifier.value = null;

    try {
      final nextOrders = await request();
      _ordersNotifier.value = nextOrders.isEmpty
          ? List<BookingOrderItem>.from(_seedOrders)
          : List<BookingOrderItem>.from(nextOrders);
    } finally {
      _loadingNotifier.value = false;
    }
  }

  void _updateOrder(
    String orderId,
    BookingOrderItem Function(BookingOrderItem order) transform,
  ) {
    final nextOrders = List<BookingOrderItem>.from(_ordersNotifier.value);
    final existingIndex = nextOrders.indexWhere((order) => order.id == orderId);
    if (existingIndex == -1) {
      return;
    }

    nextOrders[existingIndex] = transform(nextOrders[existingIndex]);
    _ordersNotifier.value = nextOrders;
  }
}
