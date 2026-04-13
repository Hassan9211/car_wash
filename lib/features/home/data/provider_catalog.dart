import 'dart:convert';

import 'package:car_wash/features/authentication/data/auth_session.dart';
import 'package:car_wash/core/scheduling/business_hours.dart';
import 'package:car_wash/features/home/model/service_provider_profile.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProviderCatalog {
  ProviderCatalog._();

  static const _prefsSavedProvidersKey = 'provider_catalog.saved_providers';

  static const fallbackProvider = ServiceProviderProfile(
    id: 'fallback_provider',
    name: 'Ahmed',
    price: '\$24',
    rating: '5',
    reviews: '13.7K',
    imagePath: 'assets/images/onboarding/pexels-bulat843-1243575272-28995187.jpg',
    mainImageUrl:
        'https://images.pexels.com/photos/6873132/pexels-photo-6873132.jpeg?auto=compress&cs=tinysrgb&w=1200',
    galleryImageUrls: [
      'https://images.pexels.com/photos/6873132/pexels-photo-6873132.jpeg?auto=compress&cs=tinysrgb&w=900',
    ],
    description:
        'Professional car wash service provider available near you.',
    searchTerms: ['ahmed', 'car wash'],
    location: 'Midtown, New York, USA',
    availability: BusinessHours.label,
    latitude: 40.7581,
    longitude: -73.9856,
  );

  static const _seedProviders = <ServiceProviderProfile>[
    ServiceProviderProfile(
      id: '1',
      name: 'Ahmed',
      price: '\$24',
      rating: '5',
      reviews: '13.7K',
      imagePath: 'assets/images/onboarding/pexels-bulat843-1243575272-28995187.jpg',
      mainImageUrl:
          'https://images.pexels.com/photos/6873132/pexels-photo-6873132.jpeg?auto=compress&cs=tinysrgb&w=1200',
      galleryImageUrls: [
        'https://images.pexels.com/photos/6873132/pexels-photo-6873132.jpeg?auto=compress&cs=tinysrgb&w=900',
        'https://images.pexels.com/photos/4870700/pexels-photo-4870700.jpeg?auto=compress&cs=tinysrgb&w=900',
        'https://images.pexels.com/photos/4876676/pexels-photo-4876676.jpeg?auto=compress&cs=tinysrgb&w=900',
        'https://images.pexels.com/photos/4870671/pexels-photo-4870671.jpeg?auto=compress&cs=tinysrgb&w=900',
        'https://images.pexels.com/photos/4870740/pexels-photo-4870740.jpeg?auto=compress&cs=tinysrgb&w=900',
        'https://images.pexels.com/photos/7530997/pexels-photo-7530997.jpeg?auto=compress&cs=tinysrgb&w=900',
      ],
      description:
          'Ahmed delivers a polished doorstep wash with rich foam coverage, wheel cleaning, and a smooth finishing shine that works great for daily cars and SUVs.',
      searchTerms: ['ahmed', 'foam', 'wash', 'car washer', 'detail'],
      location: 'Midtown, New York, USA',
      availability: BusinessHours.label,
      latitude: 40.7581,
      longitude: -73.9856,
    ),
    ServiceProviderProfile(
      id: '2',
      name: 'Youssef',
      price: '\$24',
      rating: '5',
      reviews: '13.7K',
      imagePath: 'assets/images/onboarding/pexels-bulat843-1243575272-31154194.jpg',
      mainImageUrl:
          'https://images.pexels.com/photos/7530997/pexels-photo-7530997.jpeg?auto=compress&cs=tinysrgb&w=1200',
      galleryImageUrls: [
        'https://images.pexels.com/photos/7530997/pexels-photo-7530997.jpeg?auto=compress&cs=tinysrgb&w=900',
        'https://images.pexels.com/photos/4870700/pexels-photo-4870700.jpeg?auto=compress&cs=tinysrgb&w=900',
        'https://images.pexels.com/photos/4876676/pexels-photo-4876676.jpeg?auto=compress&cs=tinysrgb&w=900',
        'https://images.pexels.com/photos/4870740/pexels-photo-4870740.jpeg?auto=compress&cs=tinysrgb&w=900',
        'https://images.pexels.com/photos/10804350/pexels-photo-10804350.jpeg?auto=compress&cs=tinysrgb&w=900',
        'https://images.pexels.com/photos/14231684/pexels-photo-14231684.jpeg?auto=compress&cs=tinysrgb&w=900',
      ],
      description:
          'Youssef focuses on exterior shine packages, tire dressing, and quick response bookings for customers who want a clean car without long waiting times.',
      searchTerms: ['youssef', 'exterior', 'shine', 'detail'],
      location: 'Williamsburg, Brooklyn, USA',
      availability: BusinessHours.label,
      latitude: 40.7178,
      longitude: -73.9560,
    ),
    ServiceProviderProfile(
      id: '3',
      name: 'Samir',
      price: '\$22',
      rating: '4.9',
      reviews: '10.2K',
      imagePath: 'assets/images/onboarding/pexels-karola-g-4870700.jpg',
      mainImageUrl:
          'https://images.pexels.com/photos/4870700/pexels-photo-4870700.jpeg?auto=compress&cs=tinysrgb&w=1200',
      galleryImageUrls: [
        'https://images.pexels.com/photos/4870700/pexels-photo-4870700.jpeg?auto=compress&cs=tinysrgb&w=900',
        'https://images.pexels.com/photos/4876676/pexels-photo-4876676.jpeg?auto=compress&cs=tinysrgb&w=900',
        'https://images.pexels.com/photos/10804350/pexels-photo-10804350.jpeg?auto=compress&cs=tinysrgb&w=900',
        'https://images.pexels.com/photos/14231684/pexels-photo-14231684.jpeg?auto=compress&cs=tinysrgb&w=900',
        'https://images.pexels.com/photos/4870671/pexels-photo-4870671.jpeg?auto=compress&cs=tinysrgb&w=900',
        'https://images.pexels.com/photos/6873132/pexels-photo-6873132.jpeg?auto=compress&cs=tinysrgb&w=900',
      ],
      description:
          'Samir is known for interior vacuuming, dashboard detailing, and tidy cabin finishing that leaves family cars feeling fresh, clean, and organized.',
      searchTerms: ['samir', 'interior', 'vacuum', 'detail'],
      location: 'Astoria, Queens, USA',
      availability: BusinessHours.label,
      latitude: 40.7644,
      longitude: -73.9235,
    ),
    ServiceProviderProfile(
      id: '4',
      name: 'Omar',
      price: '\$26',
      rating: '5',
      reviews: '12.1K',
      imagePath: 'assets/images/onboarding/pexels-bulat843-1243575272-28995187.jpg',
      mainImageUrl:
          'https://images.pexels.com/photos/10804350/pexels-photo-10804350.jpeg?auto=compress&cs=tinysrgb&w=1200',
      galleryImageUrls: [
        'https://images.pexels.com/photos/10804350/pexels-photo-10804350.jpeg?auto=compress&cs=tinysrgb&w=900',
        'https://images.pexels.com/photos/14231684/pexels-photo-14231684.jpeg?auto=compress&cs=tinysrgb&w=900',
        'https://images.pexels.com/photos/7530997/pexels-photo-7530997.jpeg?auto=compress&cs=tinysrgb&w=900',
        'https://images.pexels.com/photos/4870700/pexels-photo-4870700.jpeg?auto=compress&cs=tinysrgb&w=900',
        'https://images.pexels.com/photos/4870740/pexels-photo-4870740.jpeg?auto=compress&cs=tinysrgb&w=900',
        'https://images.pexels.com/photos/4876676/pexels-photo-4876676.jpeg?auto=compress&cs=tinysrgb&w=900',
      ],
      description:
          'Omar handles premium deep-clean sessions with wax polish, careful exterior treatment, and a strong finish for customers who want showroom-style results.',
      searchTerms: ['omar', 'engine', 'premium', 'detail'],
      location: 'Lower Manhattan, New York, USA',
      availability: BusinessHours.label,
      latitude: 40.7075,
      longitude: -74.0113,
    ),
  ];

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

    return providers.isNotEmpty ? providers.first : fallbackProvider;
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
        (provider) => provider.copyWith(availability: BusinessHours.label),
      ),
      ..._seedProviders
          .where(
            (seedProvider) =>
                _storedProviders.every(
                  (storedProvider) => storedProvider.id != seedProvider.id,
                ),
          )
          .map(
            (provider) => provider.copyWith(availability: BusinessHours.label),
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
}
