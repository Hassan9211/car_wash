import 'package:car_wash/features/home/booking/model/booking_order_item.dart';
import 'package:flutter/foundation.dart';

class BookingOrdersStore {
  BookingOrdersStore._()
    : _ordersNotifier = ValueNotifier<List<BookingOrderItem>>(
        List<BookingOrderItem>.from(_seedOrders),
      );

  static final BookingOrdersStore instance = BookingOrdersStore._();

  static final _seedOrders = <BookingOrderItem>[];

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

  Future<void> submitForApproval(String orderId, List<String> photos) async {
    _updateOrder(
      orderId,
      (order) => order.copyWith(
        status: BookingOrderStatus.awaitingApproval,
        workPhotos: photos,
        statusUpdatedAt: DateTime.now(),
      ),
    );
  }

  Future<void> approveWork(String orderId) async {
    _updateOrder(
      orderId,
      (order) => order.copyWith(
        status: BookingOrderStatus.completed,
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

  /// Deletes all orders belonging to [providerId].
  void deleteOrdersByProvider(String providerId) {
    _ordersNotifier.value = _ordersNotifier.value
        .where((order) => order.providerId != providerId)
        .toList(growable: false);
  }

  /// Deletes all orders belonging to the current customer email.
  void deleteOrdersByCustomerEmail(String email) {
    final normalizedEmail = email.trim().toLowerCase();
    _ordersNotifier.value = _ordersNotifier.value
        .where((order) =>
            order.customerEmail.trim().toLowerCase() != normalizedEmail)
        .toList(growable: false);
  }
}
