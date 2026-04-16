import 'dart:async';

import 'package:car_wash/features/home/booking/model/booking_order_item.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

class BookingOrdersStore {
  BookingOrdersStore._()
      : _ordersNotifier = ValueNotifier<List<BookingOrderItem>>([]);

  static final BookingOrdersStore instance = BookingOrdersStore._();

  static const _collection = 'bookings';

  final ValueNotifier<List<BookingOrderItem>> _ordersNotifier;
  final ValueNotifier<bool> _loadingNotifier = ValueNotifier<bool>(false);
  final ValueNotifier<String?> _errorNotifier = ValueNotifier<String?>(null);

  StreamSubscription<QuerySnapshot>? _subscription;

  ValueListenable<List<BookingOrderItem>> get listenable => _ordersNotifier;
  ValueListenable<bool> get loadingListenable => _loadingNotifier;
  ValueListenable<String?> get errorListenable => _errorNotifier;

  List<BookingOrderItem> get orders =>
      List.unmodifiable(_ordersNotifier.value);

  // ── Fetch / Listen ──────────────────────────────────────────────────────────

  /// Listens to all bookings where customerEmail matches.
  Future<void> fetchCustomerOrders({required String customerEmail}) async {
    _cancelSubscription();
    _loadingNotifier.value = true;

    _subscription = FirebaseFirestore.instance
        .collection(_collection)
        .where('customer_email', isEqualTo: customerEmail.trim().toLowerCase())
        .orderBy('created_at', descending: true)
        .snapshots()
        .listen(
          (snapshot) {
            _ordersNotifier.value = snapshot.docs
                .map((doc) => BookingOrderItem.fromJson(
                    doc.data()..['id'] = doc.id))
                .toList(growable: false);
            _loadingNotifier.value = false;
          },
          onError: (_) => _loadingNotifier.value = false,
        );
  }

  /// Listens to all bookings where providerId matches.
  Future<void> fetchProviderOrders({required String providerId}) async {
    _cancelSubscription();
    _loadingNotifier.value = true;

    _subscription = FirebaseFirestore.instance
        .collection(_collection)
        .where('provider_id', isEqualTo: providerId.trim())
        .orderBy('created_at', descending: true)
        .snapshots()
        .listen(
          (snapshot) {
            _ordersNotifier.value = snapshot.docs
                .map((doc) => BookingOrderItem.fromJson(
                    doc.data()..['id'] = doc.id))
                .toList(growable: false);
            _loadingNotifier.value = false;
          },
          onError: (_) => _loadingNotifier.value = false,
        );
  }

  void _cancelSubscription() {
    _subscription?.cancel();
    _subscription = null;
  }

  // ── Write ────────────────────────────────────────────────────────────────────

  /// Saves a new order to Firestore and updates local state.
  Future<void> addOrUpdate(BookingOrderItem order) async {
    try {
      final data = _toFirestore(order);
      if (order.id.isEmpty) {
        final ref = await FirebaseFirestore.instance
            .collection(_collection)
            .add(data);
        _upsertLocal(BookingOrderItem(
          id: ref.id,
          providerId: order.providerId,
          status: order.status,
          orderDate: order.orderDate,
          paymentDate: order.paymentDate,
          statusUpdatedAt: order.statusUpdatedAt,
          rating: order.rating,
          reviews: order.reviews,
          totalPayment: order.totalPayment,
          serviceProviderName: order.serviceProviderName,
          serviceType: order.serviceType,
          customerName: order.customerName,
          customerEmail: order.customerEmail,
          address: order.address,
          customerLatitude: order.customerLatitude,
          customerLongitude: order.customerLongitude,
          providerLatitude: order.providerLatitude,
          providerLongitude: order.providerLongitude,
          paymentStatus: order.paymentStatus,
          paymentMethod: order.paymentMethod,
          bookingTime: order.bookingTime,
          reviewRating: order.reviewRating,
          reviewText: order.reviewText,
          showInWallet: order.showInWallet,
          workPhotos: order.workPhotos,
        ));
      } else {
        await FirebaseFirestore.instance
            .collection(_collection)
            .doc(order.id)
            .set(data, SetOptions(merge: true));
        _upsertLocal(order);
      }
    } catch (_) {
      // Fallback: update local only
      _upsertLocal(order);
    }
  }

  Future<void> updateStatus(String orderId, BookingOrderStatus status) async {
    await _updateFirestore(orderId, {
      'status': status.apiValue,
      'status_updated_at': DateTime.now().toIso8601String(),
    });
    _updateLocal(orderId, (o) => o.copyWith(
          status: status,
          statusUpdatedAt: DateTime.now(),
        ));
  }

  Future<void> submitForApproval(String orderId, List<String> photos) async {
    await _updateFirestore(orderId, {
      'status': BookingOrderStatus.awaitingApproval.apiValue,
      'work_photos': photos,
      'status_updated_at': DateTime.now().toIso8601String(),
    });
    _updateLocal(orderId, (o) => o.copyWith(
          status: BookingOrderStatus.awaitingApproval,
          workPhotos: photos,
          statusUpdatedAt: DateTime.now(),
        ));
  }

  Future<void> approveWork(String orderId) async {
    await _updateFirestore(orderId, {
      'status': BookingOrderStatus.completed.apiValue,
      'payment_status': 'paid',
      'status_updated_at': DateTime.now().toIso8601String(),
    });
    _updateLocal(orderId, (o) => o.copyWith(
          status: BookingOrderStatus.completed,
          paymentStatus: BookingPaymentStatus.paid,
          statusUpdatedAt: DateTime.now(),
        ));
  }

  Future<void> updateReview(
    String orderId, {
    required int reviewRating,
    required String reviewText,
  }) async {
    await _updateFirestore(orderId, {
      'review': {'rating': reviewRating, 'review_text': reviewText},
    });
    _updateLocal(orderId, (o) => o.copyWith(
          reviewRating: reviewRating,
          reviewText: reviewText,
        ));
  }

  /// Called when customer pays for a rescheduled order — sets payment to held.
  Future<void> markReschedulePaymentHeld(String orderId) async {
    await _updateFirestore(orderId, {
      'payment_status': 'held',
      'payment_date': DateTime.now().toIso8601String(),
    });
    _updateLocal(orderId, (o) => o.copyWith(
          paymentStatus: BookingPaymentStatus.held,
          paymentDate: DateTime.now(),
        ));
  }

  Future<void> cancelOrder(String orderId) async {
    await _updateFirestore(orderId, {
      'status': BookingOrderStatus.cancelled.apiValue,
      'status_updated_at': DateTime.now().toIso8601String(),
    });
    _updateLocal(orderId, (o) => o.copyWith(
          status: BookingOrderStatus.cancelled,
          statusUpdatedAt: DateTime.now(),
        ));
  }

  Future<void> rescheduleOrder({
    required String orderId,
    required DateTime bookingDate,
    required String bookingTime,
  }) async {
    await _updateFirestore(orderId, {
      'status': BookingOrderStatus.pending.apiValue,
      'payment_status': 'pending',
      'booking_date': bookingDate.toIso8601String(),
      'booking_time': bookingTime,
      'status_updated_at': DateTime.now().toIso8601String(),
    });
    _updateLocal(orderId, (o) => o.copyWith(
          status: BookingOrderStatus.pending,
          paymentStatus: BookingPaymentStatus.pending,
          orderDate: bookingDate,
          bookingTime: bookingTime,
          statusUpdatedAt: DateTime.now(),
        ));
  }

  Future<BookingOrderItem> fetchBooking(String orderId) async {
    try {
      final doc = await FirebaseFirestore.instance
          .collection(_collection)
          .doc(orderId)
          .get();
      if (doc.exists) {
        return BookingOrderItem.fromJson(doc.data()!..['id'] = doc.id);
      }
    } catch (_) {}
    return _ordersNotifier.value.firstWhere(
      (o) => o.id == orderId,
      orElse: () => BookingOrderItem(
        id: orderId,
        status: BookingOrderStatus.pending,
        orderDate: DateTime.now(),
        paymentDate: DateTime.now(),
        rating: '0',
        reviews: '0',
        totalPayment: '\$0',
        serviceProviderName: '',
        serviceType: '',
        customerName: '',
      ),
    );
  }

  void deleteOrdersByProvider(String providerId) {
    _ordersNotifier.value = _ordersNotifier.value
        .where((o) => o.providerId != providerId)
        .toList(growable: false);
  }

  void deleteOrdersByCustomerEmail(String email) {
    final normalized = email.trim().toLowerCase();
    _ordersNotifier.value = _ordersNotifier.value
        .where((o) => o.customerEmail.trim().toLowerCase() != normalized)
        .toList(growable: false);
  }

  // ── Helpers ──────────────────────────────────────────────────────────────────

  void _upsertLocal(BookingOrderItem order) {
    final list = List<BookingOrderItem>.from(_ordersNotifier.value);
    final idx = list.indexWhere((o) => o.id == order.id);
    if (idx == -1) {
      list.insert(0, order);
    } else {
      list[idx] = order;
    }
    _ordersNotifier.value = list;
  }

  void _updateLocal(
    String orderId,
    BookingOrderItem Function(BookingOrderItem) transform,
  ) {
    final list = List<BookingOrderItem>.from(_ordersNotifier.value);
    final idx = list.indexWhere((o) => o.id == orderId);
    if (idx == -1) return;
    list[idx] = transform(list[idx]);
    _ordersNotifier.value = list;
  }

  Future<void> _updateFirestore(
      String orderId, Map<String, dynamic> data) async {
    try {
      await FirebaseFirestore.instance
          .collection(_collection)
          .doc(orderId)
          .update(data);
    } catch (_) {}
  }

  Map<String, dynamic> _toFirestore(BookingOrderItem o) {
    return {
      'provider_id': o.providerId,
      'status': o.status.apiValue,
      'booking_date': o.orderDate.toIso8601String(),
      'created_at': o.paymentDate.toIso8601String(),
      'updated_at': (o.statusUpdatedAt ?? o.paymentDate).toIso8601String(),
      'status_updated_at':
          (o.statusUpdatedAt ?? o.paymentDate).toIso8601String(),
      'total_payment': o.totalPayment,
      'service_provider_name': o.serviceProviderName,
      'service_type': o.serviceType,
      'customer_name': o.customerName,
      'customer_email': o.customerEmail.trim().toLowerCase(),
      'address': o.address,
      'customer_latitude': o.customerLatitude,
      'customer_longitude': o.customerLongitude,
      'provider_latitude': o.providerLatitude,
      'provider_longitude': o.providerLongitude,
      'payment_status': switch (o.paymentStatus) {
        BookingPaymentStatus.paid => 'paid',
        BookingPaymentStatus.held => 'held',
        BookingPaymentStatus.pending => 'pending',
      },
      'payment_method': o.paymentMethod,
      'booking_time': o.bookingTime ?? '',
      'show_in_wallet': o.showInWallet,
      'work_photos': o.workPhotos,
      if (o.reviewRating != null)
        'review': {
          'rating': o.reviewRating,
          'review_text': o.reviewText,
        },
    };
  }
}
