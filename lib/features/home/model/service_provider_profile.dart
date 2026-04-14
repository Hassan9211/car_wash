import 'package:car_wash/core/scheduling/business_hours.dart';

class ServiceProviderProfile {
  const ServiceProviderProfile({
    this.id = '',
    required this.name,
    required this.price,
    required this.rating,
    required this.reviews,
    required this.imagePath,
    required this.mainImageUrl,
    required this.galleryImageUrls,
    required this.description,
    required this.searchTerms,
    this.supportedServices = const [],
    required this.location,
    required this.availability,
    this.categoryLabel = 'Car Washer',
    this.latitude,
    this.longitude,
    this.isNewProvider = false,
    this.isVerified = false,
    this.joinedAt,
  });

  final String id;
  final String name;
  final String price;
  final String rating;
  final String reviews;
  final String imagePath;
  final String mainImageUrl;
  final List<String> galleryImageUrls;
  final String description;
  final List<String> searchTerms;
  final List<String> supportedServices;
  final String location;
  final String availability;
  final String categoryLabel;
  final double? latitude;
  final double? longitude;
  final bool isNewProvider;
  final bool isVerified;
  final DateTime? joinedAt;

  factory ServiceProviderProfile.fromJson(Map<String, dynamic> json) {
    final gallery = _readList(json, [
      'gallery_urls',
      'gallery',
      'images',
      'gallery_images',
    ]).map((item) => item.toString()).where((item) => item.isNotEmpty).toList(
      growable: false,
    );

    final fallbackImage = _readString(
      json,
      ['image', 'image_url', 'thumbnail', 'profile_image', 'main_image_url'],
      fallback: 'assets/images/onboarding/pexels-bulat843-1243575272-28995187.jpg',
    );

    final priceValue = _readString(
      json,
      ['price', 'hourly_rate', 'service_price'],
      fallback: '\$24',
    );

    final ratingValue = _readString(
      json,
      ['rating', 'avg_rating', 'average_rating'],
      fallback: '4.9',
    );

    final reviewsValue = _readString(
      json,
      ['reviews', 'reviews_count', 'total_reviews'],
      fallback: '0',
    );

    final description = _readString(
      json,
      ['description', 'bio', 'about'],
      fallback: 'Professional car wash service provider.',
    );
    final joinedAt = DateTime.tryParse(
      _readString(
        json,
        ['joined_at', 'created_at', 'registered_at'],
      ),
    );

    final searchTerms = _readList(json, ['search_terms', 'tags', 'keywords'])
        .map((item) => item.toString())
        .where((item) => item.isNotEmpty)
        .toList(growable: false);
    final supportedServices = _readList(json, [
      'supported_services',
      'services',
      'service_labels',
    ]).map((item) => item.toString()).where((item) => item.isNotEmpty).toList(
      growable: false,
    );

    return ServiceProviderProfile(
      id: _readString(json, ['id', 'provider_id', 'user_id']),
      name: _readString(json, ['name', 'full_name'], fallback: 'Provider'),
      price: priceValue.startsWith('\$') ? priceValue : '\$$priceValue',
      rating: ratingValue,
      reviews: reviewsValue,
      imagePath: fallbackImage.startsWith('http')
          ? 'assets/images/onboarding/pexels-bulat843-1243575272-28995187.jpg'
          : fallbackImage,
      mainImageUrl: _readString(
        json,
        ['main_image_url', 'image_url', 'image', 'profile_image'],
        fallback: gallery.isNotEmpty ? gallery.first : fallbackImage,
      ),
      galleryImageUrls: gallery.isNotEmpty ? gallery : [fallbackImage],
      description: description,
      searchTerms: searchTerms.isNotEmpty
          ? searchTerms
          : description
                .toLowerCase()
                .split(RegExp(r'[^a-z0-9]+'))
                .where((item) => item.isNotEmpty)
                .take(8)
                .toList(growable: false),
      supportedServices: supportedServices,
      location: _readString(
        json,
        ['location', 'address', 'city'],
        fallback: 'New York, USA',
      ),
      availability: _readString(
        json,
        ['availability', 'working_hours', 'availability_label'],
        fallback: BusinessHours.label,
      ),
      categoryLabel: _readString(
        json,
        ['category_label', 'service_type', 'category'],
        fallback: 'Car Washer',
      ),
      latitude: _readDouble(json, ['latitude', 'lat', 'provider_latitude']),
      longitude: _readDouble(
        json,
        ['longitude', 'lng', 'provider_longitude'],
      ),
      isNewProvider:
          _readBool(json, ['is_new_provider', 'is_new', 'new_provider']) ??
          false,
      isVerified: _readBool(json, ['is_verified', 'verified']) ?? false,
      joinedAt: joinedAt,
    );
  }

  bool matches(String query) {
    return searchTerms.any((term) => term.toLowerCase().contains(query));
  }

  ServiceProviderProfile copyWith({
    String? id,
    String? name,
    String? price,
    String? rating,
    String? reviews,
    String? imagePath,
    String? mainImageUrl,
    List<String>? galleryImageUrls,
    String? description,
    List<String>? searchTerms,
    List<String>? supportedServices,
    String? location,
    String? availability,
    String? categoryLabel,
    double? latitude,
    double? longitude,
    bool? isNewProvider,
    bool? isVerified,
    DateTime? joinedAt,
  }) {
    return ServiceProviderProfile(
      id: id ?? this.id,
      name: name ?? this.name,
      price: price ?? this.price,
      rating: rating ?? this.rating,
      reviews: reviews ?? this.reviews,
      imagePath: imagePath ?? this.imagePath,
      mainImageUrl: mainImageUrl ?? this.mainImageUrl,
      galleryImageUrls: galleryImageUrls ?? this.galleryImageUrls,
      description: description ?? this.description,
      searchTerms: searchTerms ?? this.searchTerms,
      supportedServices: supportedServices ?? this.supportedServices,
      location: location ?? this.location,
      availability: availability ?? this.availability,
      categoryLabel: categoryLabel ?? this.categoryLabel,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      isNewProvider: isNewProvider ?? this.isNewProvider,
      isVerified: isVerified ?? this.isVerified,
      joinedAt: joinedAt ?? this.joinedAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'price': price,
      'rating': rating,
      'reviews': reviews,
      'image_path': imagePath,
      'main_image_url': mainImageUrl,
      'gallery_urls': galleryImageUrls,
      'description': description,
      'search_terms': searchTerms,
      'supported_services': supportedServices,
      'location': location,
      'availability': availability,
      'category_label': categoryLabel,
      'latitude': latitude,
      'longitude': longitude,
      'is_new_provider': isNewProvider,
      'is_verified': isVerified,
      'joined_at': joinedAt?.toIso8601String(),
    };
  }

  String get detailsKeyName => (id.trim().isNotEmpty ? id : name)
      .toLowerCase()
      .replaceAll(' ', '_');

  bool get hasCoordinates => latitude != null && longitude != null;

  bool get showNewBadge {
    if (joinedAt != null) {
      return DateTime.now().difference(joinedAt!).inDays < 14;
    }

    return isNewProvider;
  }
}

String _readString(
  Map<String, dynamic> json,
  List<String> keys, {
  String fallback = '',
}) {
  for (final key in keys) {
    final value = json[key];
    if (value == null) {
      continue;
    }

    final asString = value.toString().trim();
    if (asString.isNotEmpty) {
      return asString;
    }
  }

  return fallback;
}

List<dynamic> _readList(Map<String, dynamic> json, List<String> keys) {
  for (final key in keys) {
    final value = json[key];
    if (value is List) {
      return value;
    }
  }

  return const [];
}

double? _readDouble(Map<String, dynamic> json, List<String> keys) {
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

bool? _readBool(Map<String, dynamic> json, List<String> keys) {
  for (final key in keys) {
    final value = json[key];
    if (value == null) {
      continue;
    }

    if (value is bool) {
      return value;
    }

    final normalized = value.toString().trim().toLowerCase();
    if (normalized == 'true' || normalized == '1') {
      return true;
    }
    if (normalized == 'false' || normalized == '0') {
      return false;
    }
  }

  return null;
}
