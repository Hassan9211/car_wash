import 'package:car_wash/features/authentication/data/auth_session.dart';
import 'package:car_wash/core/scheduling/business_hours.dart';
import 'package:car_wash/core/services/firebase_storage_service.dart';
import 'package:car_wash/features/home/booking/data/booking_orders_store.dart';
import 'package:car_wash/features/home/booking/model/booking_order_item.dart';
import 'package:car_wash/features/home/model/service_provider_profile.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

class ProviderCatalog {
  ProviderCatalog._();

  static const _collection = 'providers';

  static const fallbackProvider = ServiceProviderProfile(
    id: 'fallback_provider',
    name: 'Provider',
    price: '\$0',
    rating: '0',
    reviews: '0',
    imagePath:
        'assets/images/onboarding/pexels-bulat843-1243575272-28995187.jpg',
    mainImageUrl: '',
    galleryImageUrls: [],
    description: 'Car wash service provider.',
    searchTerms: ['car wash'],
    location: '',
    availability: BusinessHours.label,
    latitude: 0,
    longitude: 0,
  );

  static List<ServiceProviderProfile> _storedProviders = const [];
  static bool _hasRestored = false;

  static final ValueNotifier<List<ServiceProviderProfile>> _providersNotifier =
      ValueNotifier<List<ServiceProviderProfile>>(const []);
  static final ValueNotifier<bool> _loadingNotifier =
      ValueNotifier<bool>(false);
  static final ValueNotifier<String?> _errorNotifier =
      ValueNotifier<String?>(null);

  static ValueListenable<List<ServiceProviderProfile>> get listenable =>
      _providersNotifier;
  static ValueListenable<bool> get loadingListenable => _loadingNotifier;
  static ValueListenable<String?> get errorListenable => _errorNotifier;

  static List<ServiceProviderProfile> get providers =>
      List.unmodifiable(_providersNotifier.value);

  // ── Fetch ────────────────────────────────────────────────────────────────────

  static Future<void> fetchProviders({
    String search = '',
    String serviceType = '',
  }) async {
    _loadingNotifier.value = true;
    _errorNotifier.value = null;
    await _restoreIfNeeded();

    final normalizedSearch = search.trim().toLowerCase();
    final normalizedServiceType = serviceType.trim().toLowerCase();

    _providersNotifier.value = _allProviders.where((provider) {
      final matchesSearch = normalizedSearch.isEmpty
          ? true
          : provider.matches(normalizedSearch) ||
              provider.name.toLowerCase().contains(normalizedSearch) ||
              provider.location.toLowerCase().contains(normalizedSearch);
      final matchesServiceType = normalizedServiceType.isEmpty
          ? true
          : provider.searchTerms
                  .any((t) => t.toLowerCase().contains(normalizedServiceType)) ||
              provider.categoryLabel
                  .toLowerCase()
                  .contains(normalizedServiceType);
      return matchesSearch && matchesServiceType;
    }).toList(growable: false);

    _loadingNotifier.value = false;
  }

  static Future<ServiceProviderProfile> fetchProviderById(String id) async {
    await _restoreIfNeeded();
    return providers.firstWhere((p) => p.id == id, orElse: () => fallbackProvider);
  }

  // ── Current provider ID ───────────────────────────────────────────────────

  static String get currentSessionProviderId {
    // Prefer Firebase UID as the stable ID
    final uid = AuthSession.currentUserId?.trim();
    if (uid != null && uid.isNotEmpty) return uid;

    final email = AuthSession.currentEmail?.trim();
    if (email != null && email.isNotEmpty) {
      return email.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]+'), '_');
    }

    final name = AuthSession.displayName.trim();
    return name.isEmpty
        ? 'provider_current'
        : 'provider_${name.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]+'), '_')}';
  }

  static ServiceProviderProfile currentProviderProfile() {
    final id = currentSessionProviderId;

    try {
      return _storedProviders.firstWhere((p) => p.id == id);
    } catch (_) {}

    final name = AuthSession.displayName.trim().toLowerCase();
    try {
      return _storedProviders
          .firstWhere((p) => p.name.trim().toLowerCase() == name);
    } catch (_) {}

    return _storedProviders.isNotEmpty
        ? _enrichProvider(_storedProviders.first)
        : fallbackProvider;
  }

  // ── Save / Update ─────────────────────────────────────────────────────────

  static Future<void> saveOrUpdateProvider(
      ServiceProviderProfile provider) async {
    await _restoreIfNeeded();

    // Upload avatar to Firebase Storage if it's a local file
    String imagePath = provider.imagePath;
    final uid = AuthSession.currentUserId;
    if (uid != null &&
        imagePath.isNotEmpty &&
        !imagePath.startsWith('http') &&
        !imagePath.startsWith('assets/')) {
      try {
        final url = await FirebaseStorageService.uploadAvatar(uid, imagePath);
        if (url != null) imagePath = url;
      } catch (_) {}
    }

    final updatedProvider = provider.copyWith(imagePath: imagePath);

    // Update local list
    final list = List<ServiceProviderProfile>.from(_storedProviders);
    final idx = list.indexWhere((p) => p.id == updatedProvider.id);
    if (idx == -1) {
      list.insert(0, updatedProvider);
    } else {
      list[idx] = updatedProvider.copyWith(
          joinedAt: updatedProvider.joinedAt ?? list[idx].joinedAt);
    }
    _storedProviders = List.unmodifiable(list);
    _providersNotifier.value = _allProviders;

    // Persist to Firestore
    try {
      await FirebaseFirestore.instance
          .collection(_collection)
          .doc(updatedProvider.id)
          .set(_toFirestore(updatedProvider), SetOptions(merge: true));
    } catch (_) {}
  }

  // ── Delete ────────────────────────────────────────────────────────────────

  static Future<void> deleteProviderData(String providerId) async {
    _storedProviders = List.unmodifiable(
      _storedProviders.where((p) => p.id != providerId).toList(),
    );
    _providersNotifier.value = _allProviders;

    try {
      await FirebaseFirestore.instance
          .collection(_collection)
          .doc(providerId)
          .delete();
    } catch (_) {}

    BookingOrdersStore.instance.deleteOrdersByProvider(providerId);
  }

  // ── Initialize ────────────────────────────────────────────────────────────

  static void initialize() {
    BookingOrdersStore.instance.listenable.addListener(() {
      _providersNotifier.value = _allProviders;
    });
    AuthSession.listenable.addListener(() {
      _providersNotifier.value = _allProviders;
    });
  }

  // ── Internal ──────────────────────────────────────────────────────────────

  static Future<void> _restoreIfNeeded() async {
    if (_hasRestored) return;
    _hasRestored = true;

    try {
      final snapshot = await FirebaseFirestore.instance
          .collection(_collection)
          .orderBy('joined_at', descending: true)
          .get();

      _storedProviders = snapshot.docs
          .map((doc) => ServiceProviderProfile.fromJson(
              Map<String, dynamic>.from(doc.data())..['id'] = doc.id))
          .toList(growable: false);
    } catch (_) {
      _storedProviders = const [];
    }

    _providersNotifier.value = _allProviders;
  }

  static ServiceProviderProfile _enrichProvider(
      ServiceProviderProfile provider) {
    final orders = BookingOrdersStore.instance.orders;
    final providerName = provider.name.trim().toLowerCase();

    final completedOrders = orders
        .where((o) =>
            o.serviceProviderName.trim().toLowerCase() == providerName &&
            o.status == BookingOrderStatus.completed)
        .toList(growable: false);

    final reviewedOrders =
        completedOrders.where((o) => o.reviewRating != null).toList();
    final reviewCount = reviewedOrders.length;

    final avgRating = reviewedOrders.isEmpty
        ? 1.0
        : reviewedOrders.map((o) => o.reviewRating!).reduce((a, b) => a + b) /
            reviewCount;

    final isVerified = completedOrders.length >= 10 && avgRating >= 4.5;

    final isCurrentUser = provider.id == currentSessionProviderId ||
        AuthSession.displayName.trim().toLowerCase() == providerName;

    return provider.copyWith(
      name: isCurrentUser ? AuthSession.displayName : provider.name,
      rating: avgRating.toStringAsFixed(1),
      reviews: reviewCount == 0 ? 'New' : '$reviewCount',
      isVerified: isVerified,
      imagePath: isCurrentUser
          ? AuthSession.currentAvatarImagePath ?? provider.imagePath
          : provider.imagePath,
      location: isCurrentUser && AuthSession.displayLocationLabel.isNotEmpty
          ? AuthSession.displayLocationLabel
          : provider.location,
    );
  }

  static List<ServiceProviderProfile> get _allProviders {
    final list = _storedProviders
        .map((p) => _enrichProvider(p.copyWith(availability: BusinessHours.label)))
        .toList();

    list.sort((a, b) {
      if (a.showNewBadge != b.showNewBadge) return a.showNewBadge ? -1 : 1;
      final bj = b.joinedAt;
      final aj = a.joinedAt;
      if (bj != null && aj != null) return bj.compareTo(aj);
      if (bj != null) return 1;
      if (aj != null) return -1;
      return 0;
    });

    return List.unmodifiable(list);
  }

  static Map<String, dynamic> _toFirestore(ServiceProviderProfile p) {
    return {
      'name': p.name,
      'price': p.price,
      'rating': p.rating,
      'reviews': p.reviews,
      'image_path': p.imagePath,
      'main_image_url': p.mainImageUrl,
      'gallery_image_urls': p.galleryImageUrls,
      'description': p.description,
      'search_terms': p.searchTerms,
      'supported_services': p.supportedServices,
      'location': p.location,
      'availability': p.availability,
      'category_label': p.categoryLabel,
      'latitude': p.latitude,
      'longitude': p.longitude,
      'is_verified': p.isVerified,
      'joined_at': p.joinedAt?.toIso8601String() ??
          DateTime.now().toIso8601String(),
    };
  }
}
