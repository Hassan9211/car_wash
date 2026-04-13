import 'package:car_wash/features/home/model/service_provider_profile.dart';

class WasherProfile {
  const WasherProfile({
    required this.id,
    required this.name,
    required this.price,
    required this.rating,
    required this.reviews,
    required this.imagePath,
    required this.mainImageUrl,
    required this.galleryImageUrls,
    required this.description,
    required this.location,
    required this.availability,
    this.phoneNumber = '',
    this.email = '',
    this.searchTerms = const [],
    this.categoryLabel = 'Car Washer',
    this.supportedServices = const [],
    this.completedJobs = 0,
    this.pendingRequests = 0,
    this.activeOrders = 0,
    this.totalEarnings = '\$0',
    this.todayEarnings = '\$0',
    this.experienceLabel = '',
    this.isOnline = false,
    this.isVerified = false,
    this.latitude,
    this.longitude,
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
  final String location;
  final String availability;
  final String phoneNumber;
  final String email;
  final List<String> searchTerms;
  final String categoryLabel;
  final List<String> supportedServices;
  final int completedJobs;
  final int pendingRequests;
  final int activeOrders;
  final String totalEarnings;
  final String todayEarnings;
  final String experienceLabel;
  final bool isOnline;
  final bool isVerified;
  final double? latitude;
  final double? longitude;

  factory WasherProfile.fromServiceProvider(
    ServiceProviderProfile provider, {
    String? id,
    String phoneNumber = '',
    String email = '',
    List<String> supportedServices = const [],
    int completedJobs = 0,
    int pendingRequests = 0,
    int activeOrders = 0,
    String totalEarnings = '\$0',
    String todayEarnings = '\$0',
    String experienceLabel = '',
    bool isOnline = false,
    bool isVerified = false,
  }) {
    return WasherProfile(
      id: id ?? provider.detailsKeyName,
      name: provider.name,
      price: provider.price,
      rating: provider.rating,
      reviews: provider.reviews,
      imagePath: provider.imagePath,
      mainImageUrl: provider.mainImageUrl,
      galleryImageUrls: provider.galleryImageUrls,
      description: provider.description,
      location: provider.location,
      availability: provider.availability,
      phoneNumber: phoneNumber,
      email: email,
      searchTerms: provider.searchTerms,
      categoryLabel: provider.categoryLabel,
      supportedServices: supportedServices.isNotEmpty
          ? supportedServices
          : provider.supportedServices,
      completedJobs: completedJobs,
      pendingRequests: pendingRequests,
      activeOrders: activeOrders,
      totalEarnings: totalEarnings,
      todayEarnings: todayEarnings,
      experienceLabel: experienceLabel,
      isOnline: isOnline,
      isVerified: isVerified,
      latitude: provider.latitude,
      longitude: provider.longitude,
    );
  }

  WasherProfile copyWith({
    String? id,
    String? name,
    String? price,
    String? rating,
    String? reviews,
    String? imagePath,
    String? mainImageUrl,
    List<String>? galleryImageUrls,
    String? description,
    String? location,
    String? availability,
    String? phoneNumber,
    String? email,
    List<String>? searchTerms,
    String? categoryLabel,
    List<String>? supportedServices,
    int? completedJobs,
    int? pendingRequests,
    int? activeOrders,
    String? totalEarnings,
    String? todayEarnings,
    String? experienceLabel,
    bool? isOnline,
    bool? isVerified,
    double? latitude,
    double? longitude,
  }) {
    return WasherProfile(
      id: id ?? this.id,
      name: name ?? this.name,
      price: price ?? this.price,
      rating: rating ?? this.rating,
      reviews: reviews ?? this.reviews,
      imagePath: imagePath ?? this.imagePath,
      mainImageUrl: mainImageUrl ?? this.mainImageUrl,
      galleryImageUrls: galleryImageUrls ?? this.galleryImageUrls,
      description: description ?? this.description,
      location: location ?? this.location,
      availability: availability ?? this.availability,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      email: email ?? this.email,
      searchTerms: searchTerms ?? this.searchTerms,
      categoryLabel: categoryLabel ?? this.categoryLabel,
      supportedServices: supportedServices ?? this.supportedServices,
      completedJobs: completedJobs ?? this.completedJobs,
      pendingRequests: pendingRequests ?? this.pendingRequests,
      activeOrders: activeOrders ?? this.activeOrders,
      totalEarnings: totalEarnings ?? this.totalEarnings,
      todayEarnings: todayEarnings ?? this.todayEarnings,
      experienceLabel: experienceLabel ?? this.experienceLabel,
      isOnline: isOnline ?? this.isOnline,
      isVerified: isVerified ?? this.isVerified,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
    );
  }

  bool matches(String query) {
    final normalizedQuery = query.trim().toLowerCase();
    if (normalizedQuery.isEmpty) {
      return true;
    }

    return name.toLowerCase().contains(normalizedQuery) ||
        location.toLowerCase().contains(normalizedQuery) ||
        categoryLabel.toLowerCase().contains(normalizedQuery) ||
        searchTerms.any(
          (term) => term.toLowerCase().contains(normalizedQuery),
        ) ||
        supportedServices.any(
          (service) => service.toLowerCase().contains(normalizedQuery),
        );
  }

  String get profileKeyName => id.trim().isNotEmpty
      ? id.toLowerCase().replaceAll(' ', '_')
      : name.toLowerCase().replaceAll(' ', '_');

  String get statusLabel => isOnline ? 'Online' : 'Offline';
}
