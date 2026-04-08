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
    required this.location,
    required this.availability,
    this.categoryLabel = 'Car Washer',
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
  final String location;
  final String availability;
  final String categoryLabel;

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

    final searchTerms = _readList(json, ['search_terms', 'tags', 'keywords'])
        .map((item) => item.toString())
        .where((item) => item.isNotEmpty)
        .toList(growable: false);

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
      location: _readString(
        json,
        ['location', 'address', 'city'],
        fallback: 'New York, USA',
      ),
      availability: _readString(
        json,
        ['availability', 'working_hours', 'availability_label'],
        fallback: '9:00 AM - 6:00 PM',
      ),
      categoryLabel: _readString(
        json,
        ['category_label', 'service_type', 'category'],
        fallback: 'Car Washer',
      ),
    );
  }

  bool matches(String query) {
    return searchTerms.any((term) => term.toLowerCase().contains(query));
  }

  String get detailsKeyName => (id.trim().isNotEmpty ? id : name)
      .toLowerCase()
      .replaceAll(' ', '_');
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
