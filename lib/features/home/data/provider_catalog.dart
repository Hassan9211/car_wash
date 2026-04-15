import 'dart:convert';

import 'package:car_wash/features/authentication/data/auth_session.dart';
import 'package:car_wash/core/scheduling/business_hours.dart';
import 'package:car_wash/features/home/booking/data/booking_orders_store.dart';
import 'package:car_wash/features/home/booking/model/booking_order_item.dart';
import 'package:car_wash/features/home/model/service_provider_profile.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProviderCatalog {
  ProviderCatalog._();

  static const _prefsSavedProvidersKey = 'provider_catalog.saved_providers';

  static const fallbackProvider = ServiceProviderProfile(
    id: 'fallback_provider',
    name: 'Provider',
    price: '\$0',
    rating: '0',
    reviews: '0',
    imagePath: 'assets/images/onboarding/pexels-bulat843-1243575272-28995187.jpg',
    mainImageUrl: '',
    galleryImageUrls: [],
    description: 'Car wash service provider.',
    searchTerms: ['car wash'],
    location: '',
    availability: BusinessHours.label,
    latitude: 0,
    longitude: 0,
  );

  static const _seedProviders = <ServiceProviderProfile>[];

  static List<ServiceProviderProfile> _storedProviders = const [];
  static bool _hasRestored = false;

  static final ValueNotifier<List<ServiceProviderProfile>> _providersNotifier =
      ValueNotifier<List<ServiceProviderProfile>>(
        List<ServiceProviderProfile>.from(_seedProviders),
      );
  static final ValueNotifier<bool> _loadingNotifier =
      ValueNotifier<bool>(false);
  static final ValueNotifier<String?> _errorNotifier =
      ValueNotifier<String?>(null);

  static ValueListenable<List<ServiceProviderProfile>> get listenable =>
      _providersNotifier;
  static ValueListenable<bool> get loadingListenable => _loadingNotifier;
  static ValueListenable<String?> get errorListenable => _errorNotifier;

  static List<ServiceProviderProfile> get providers {
    return List.unmodifiable(_providersNotifier.value);
  }

  static Future<void> fetchProviders({
    String search = '',
    String serviceType = '',
  }) async {
    _loadingNotifier.value = true;
    _errorNotifier.value = null;
    await _restoreSavedProvidersIfNeeded();

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
          : provider.searchTerms.any(
              (term) => term.toLowerCase().contains(normalizedServiceType),
            ) ||
              provider.categoryLabel.toLowerCase().contains(
                normalizedServiceType,
              );
      return matchesSearch && matchesServiceType;
    }).toList(growable: false);

    _loadingNotifier.value = false;
  }

  static Future<ServiceProviderProfile> fetchProviderById(String id) async {
    await _restoreSavedProvidersIfNeeded();

    return providers.firstWhere(
      (item) => item.id == id,
      orElse: () => fallbackProvider,
    );
  }

  static String get currentSessionProviderId {
    final rawValue =
        AuthSession.currentUserId?.trim() ??
        AuthSession.currentEmail?.trim() ??
        AuthSession.currentName?.trim() ??
        AuthSession.displayName;
    final normalized = rawValue
        .toLowerCase()
        .replaceAll(RegExp(r'[^a-z0-9]+'), '_')
        .replaceAll(RegExp(r'_+'), '_')
        .replaceAll(RegExp(r'^_|_$'), '');

    return normalized.isEmpty ? 'provider_current' : 'provider_$normalized';
  }

  static ServiceProviderProfile currentProviderProfile() {
    final providerId = currentSessionProviderId;
    final match = providers.where((provider) => provider.id == providerId);
    if (match.isNotEmpty) {
      return match.first;
    }

    final currentName = AuthSession.displayName.trim().toLowerCase();
    final byName = providers.where(
      (provider) => provider.name.trim().toLowerCase() == currentName,
    );
    if (byName.isNotEmpty) {
      return byName.first;
    }

    return providers.isNotEmpty
        ? _enrichProvider(providers.first)
        : fallbackProvider;
  }

  static void initialize() {
    // Refresh providers whenever bookings or session updates
    BookingOrdersStore.instance.listenable.addListener(() {
      _providersNotifier.value = _allProviders;
    });
    AuthSession.listenable.addListener(() {
      _providersNotifier.value = _allProviders;
    });
  }

  static ServiceProviderProfile _enrichProvider(
    ServiceProviderProfile provider,
  ) {
    final orders = BookingOrdersStore.instance.orders;
    final providerName = provider.name.trim().toLowerCase();

    final completedOrders =
        orders
            .where(
              (o) =>
                  o.serviceProviderName.trim().toLowerCase() == providerName &&
                  o.status == BookingOrderStatus.completed,
            )
            .toList(growable: false);

    final reviewedOrders =
        completedOrders
            .where((o) => o.reviewRating != null)
            .toList(growable: false);
    final reviewCount = reviewedOrders.length;

    // Rating grows from 1.0 (seed) up to real average.
    final avgRating =
        reviewedOrders.isEmpty
            ? 1.0
            : reviewedOrders
                    .map((o) => o.reviewRating!)
                    .reduce((a, b) => a + b) /
                reviewCount;

    // Verified: 10+ jobs AND 4.5+ average rating
    final isVerified = completedOrders.length >= 10 && avgRating >= 4.5;

    // Dynamic sync for current logged-in SP
    final isCurrentUser =
        AuthSession.displayName.trim().toLowerCase() == providerName;

    return provider.copyWith(
      rating: avgRating.toStringAsFixed(1),
      reviews: reviewCount == 0 ? 'New' : '$reviewCount',
      isVerified: isVerified,
      imagePath:
          isCurrentUser
              ? AuthSession.currentAvatarImagePath ?? provider.imagePath
              : provider.imagePath,
      location:
          isCurrentUser ? AuthSession.displayLocationLabel : provider.location,
    );
  }

  static Future<void> saveOrUpdateProvider(
    ServiceProviderProfile provider,
  ) async {
    await _restoreSavedProvidersIfNeeded();

    final nextProviders = List<ServiceProviderProfile>.from(_storedProviders);
    final existingIndex = nextProviders.indexWhere(
      (existingProvider) => existingProvider.id == provider.id,
    );

    if (existingIndex == -1) {
      nextProviders.insert(0, provider);
    } else {
      final existingProvider = nextProviders[existingIndex];
      nextProviders[existingIndex] = provider.copyWith(
        joinedAt: provider.joinedAt ?? existingProvider.joinedAt,
      );
    }

    _storedProviders = List<ServiceProviderProfile>.unmodifiable(nextProviders);
    _providersNotifier.value = _allProviders;
    await _persistSavedProviders();
  }

  static List<ServiceProviderProfile> get _allProviders {
    final mergedProviders = <ServiceProviderProfile>[
      ..._storedProviders.map(
        (provider) =>
            _enrichProvider(provider.copyWith(availability: BusinessHours.label)),
      ),
      ..._seedProviders
          .where(
            (seedProvider) =>
                _storedProviders.every(
                  (storedProvider) => storedProvider.id != seedProvider.id,
                ),
          )
          .map(
            (provider) => _enrichProvider(
              provider.copyWith(availability: BusinessHours.label),
            ),
          ),
    ];

    mergedProviders.sort((first, second) {
      if (first.showNewBadge != second.showNewBadge) {
        return first.showNewBadge ? -1 : 1;
      }

      final secondJoinedAt = second.joinedAt;
      final firstJoinedAt = first.joinedAt;
      if (secondJoinedAt != null && firstJoinedAt != null) {
        return secondJoinedAt.compareTo(firstJoinedAt);
      }
      if (secondJoinedAt != null) {
        return 1;
      }
      if (firstJoinedAt != null) {
        return -1;
      }

      return 0;
    });

    return List<ServiceProviderProfile>.unmodifiable(mergedProviders);
  }

  static Future<void> _restoreSavedProvidersIfNeeded() async {
    if (_hasRestored) {
      return;
    }

    _hasRestored = true;

    try {
      final preferences = await SharedPreferences.getInstance();
      final savedProvidersJson = preferences.getString(_prefsSavedProvidersKey);
      if (savedProvidersJson == null || savedProvidersJson.trim().isEmpty) {
        _storedProviders = const [];
        _providersNotifier.value = _allProviders;
        return;
      }

      final decoded = jsonDecode(savedProvidersJson);
      if (decoded is! List) {
        _storedProviders = const [];
        _providersNotifier.value = _allProviders;
        return;
      }

      _storedProviders = decoded
          .whereType<Map<String, dynamic>>()
          .map(ServiceProviderProfile.fromJson)
          .toList(growable: false);
      _providersNotifier.value = _allProviders;
    } catch (_) {
      _storedProviders = const [];
      _providersNotifier.value = List<ServiceProviderProfile>.from(
        _seedProviders,
      );
    }
  }

  static Future<void> _persistSavedProviders() async {
    try {
      final preferences = await SharedPreferences.getInstance();
      final jsonString = jsonEncode(
        _storedProviders.map((provider) => provider.toJson()).toList(),
      );
      await preferences.setString(_prefsSavedProvidersKey, jsonString);
    } catch (_) {
      // Ignore local persistence failures and keep the in-memory provider list.
    }
  }

  /// Deletes the provider profile for [providerId] and clears all their data.
  static Future<void> deleteProviderData(String providerId) async {
    await _restoreSavedProvidersIfNeeded();

    _storedProviders = List<ServiceProviderProfile>.unmodifiable(
      _storedProviders.where((p) => p.id != providerId).toList(),
    );
    _providersNotifier.value = _allProviders;
    await _persistSavedProviders();

    // Also remove their orders from BookingOrdersStore
    BookingOrdersStore.instance.deleteOrdersByProvider(providerId);
  }
}
