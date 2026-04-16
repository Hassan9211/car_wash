// ignore_for_file: unused_element

import 'dart:io';

import 'package:car_wash/core/router/app_navigation.dart';
import 'package:car_wash/core/theme/app_colors.dart';
import 'package:car_wash/core/widgets/themed_google_map.dart';
import 'package:car_wash/features/authentication/data/auth_session.dart';
import 'package:car_wash/features/home/booking/data/booking_orders_store.dart';
import 'package:car_wash/features/home/booking/model/booking_order_item.dart';
import 'package:car_wash/features/home/data/provider_catalog.dart';
import 'package:car_wash/features/services/data/service_catalog.dart';
import 'package:car_wash/features/services/model/service_item.dart';
import 'package:car_wash/features/washer/model/washer_profile.dart';
import 'package:car_wash/features/washer/presentation/widgets/service_provider_bottom_navigation_bar.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class ServiceProviderProfileScreen extends StatefulWidget {
  const ServiceProviderProfileScreen({super.key});

  @override
  State<ServiceProviderProfileScreen> createState() =>
      _ServiceProviderProfileScreenState();
}

class _ServiceProviderProfileScreenState
    extends State<ServiceProviderProfileScreen> {
  @override
  void initState() {
    super.initState();
    ProviderCatalog.fetchProviders();
  }

  Future<void> _openEditProfile() async {
    final didUpdate = await context.pushToProfileEdit();
    if (didUpdate == true && mounted) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          const SnackBar(content: Text('Profile updated successfully')),
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([
        AuthSession.listenable,
        ProviderCatalog.listenable,
        BookingOrdersStore.instance.listenable,
      ]),
      builder: (context, child) {
        final orders = BookingOrdersStore.instance.orders;
        final profile = _buildCurrentProviderProfile(orders);

        return DefaultTabController(
          length: 3,
          child: Scaffold(
            backgroundColor: AppColors.appBackground,
            body: SafeArea(
              bottom: false,
              child: Column(
                children: [
                  _ProfileHeader(profile: profile, onEditTap: _openEditProfile),
                  Expanded(
                    child: TabBarView(
                      children: [
                        _ProfileDetailsTab(profile: profile),
                        _ProfileServicesTab(profile: profile),
                        _ProfileReviewsTab(profile: profile),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            bottomNavigationBar: const ServiceProviderBottomNavigationBar(
              selectedTab: ServiceProviderBottomTab.profile,
            ),
          ),
        );
      },
    );
  }
}

class _ProfileHeader extends StatelessWidget {
  const _ProfileHeader({required this.profile, required this.onEditTap});

  final WasherProfile profile;
  final VoidCallback onEditTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 350,
      child: Stack(
        children: [
          SizedBox(
            height: 220,
            width: double.infinity,
            child: Stack(
              fit: StackFit.expand,
              children: [
                Image(
                  image: AuthSession.avatarImage,
                  fit: BoxFit.cover,
                  width: double.infinity,
                  height: double.infinity,
                ),
                DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.black.withValues(alpha: 0.35),
                        Colors.black.withValues(alpha: 0.12),
                        Colors.black.withValues(alpha: 0.24),
                      ],
                    ),
                  ),
                ),
                Positioned(
                  top: 0,
                  left: 14,
                  right: 14,
                  child: Row(
                    children: [
                      const SizedBox(width: 42),
                      const Expanded(
                        child: Text(
                          'Profile',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: onEditTap,
                          borderRadius: BorderRadius.circular(999),
                          child: Ink(
                            width: 42,
                            height: 42,
                            decoration: BoxDecoration(
                              color: Colors.black.withValues(alpha: 0.22),
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: Colors.white.withValues(alpha: 0.22),
                              ),
                            ),
                            child: const Icon(
                              Icons.edit_outlined,
                              size: 21,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            left: 0,
            right: 0,
            top: 188,
            bottom: 0,
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: AppColors.surfaceElevated,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(28),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.18),
                    blurRadius: 18,
                    offset: const Offset(0, -6),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(14, 12, 14, 0),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 11,
                            vertical: 5,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFEAF7EC),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            profile.categoryLabel,
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: AppColors.brandGreen,
                            ),
                          ),
                        ),
                        const Spacer(),
                        _ProfileRatingStars(
                          rating: double.tryParse(profile.rating) ?? 4.5,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          profile.reviews,
                          style: const TextStyle(
                            fontSize: 13,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(14, 10, 14, 0),
                    child: Text(
                      profile.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 10),
                    child: _ProfileTabBar(),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ProfileTabBar extends StatelessWidget {
  const _ProfileTabBar();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppColors.surfaceMuted,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderSoft),
      ),
      child: TabBar(
        labelPadding: EdgeInsets.zero,
        labelColor: AppColors.textPrimary,
        unselectedLabelColor: AppColors.textMuted,
        indicatorSize: TabBarIndicatorSize.tab,
        dividerColor: Colors.transparent,
        indicator: BoxDecoration(
          color: AppColors.surfaceHighlight,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.12),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        labelStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
        unselectedLabelStyle: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
        tabs: const [
          Tab(text: 'Details'),
          Tab(text: 'Services'),
          Tab(text: 'Reviews'),
        ],
      ),
    );
  }
}

class _ProfileDetailsTab extends StatelessWidget {
  const _ProfileDetailsTab({required this.profile});

  final WasherProfile profile;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 18, 16, 28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _ProfileSectionCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'About',
                  style: TextStyle(
                    fontSize: 15.5,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  profile.description,
                  style: const TextStyle(
                    fontSize: 13.4,
                    height: 1.7,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 16),
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: [
                    _InfoChip(
                      icon: Icons.work_outline_rounded,
                      label: profile.experienceLabel,
                    ),
                    _InfoChip(
                      icon: Icons.access_time_rounded,
                      label: profile.availability,
                    ),
                    _InfoChip(
                      icon: Icons.verified_rounded,
                      label: profile.isVerified
                          ? 'Verified'
                          : 'Pending Verification',
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          _ProfileSectionCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Location',
                  style: TextStyle(
                    fontSize: 15.5,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  profile.location,
                  style: const TextStyle(
                    fontSize: 12.5,
                    height: 1.5,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 14),
                Container(
                  height: 246,
                  clipBehavior: Clip.antiAlias,
                  decoration: BoxDecoration(
                    color: AppColors.surfaceMuted,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: _ProfileLocationMap(profile: profile),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ProfileServicesTab extends StatelessWidget {
  const _ProfileServicesTab({required this.profile});

  final WasherProfile profile;

  @override
  Widget build(BuildContext context) {
    if (profile.supportedServices.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(32),
          child: Text(
            'No services selected.',
            style: TextStyle(color: AppColors.textSecondary),
          ),
        ),
      );
    }

    final servicesList = ServiceCatalog.allServices
        .where((service) => profile.supportedServices.contains(service.label))
        .toList(growable: false);

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 18, 16, 24),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: servicesList.length,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          crossAxisSpacing: 14,
          mainAxisSpacing: 14,
          childAspectRatio: 1.0,
        ),
        itemBuilder: (context, index) {
          final service = servicesList[index];
          return _ProviderServiceChip(service: service);
        },
      ),
    );
  }
}

class _ProviderServiceChip extends StatelessWidget {
  const _ProviderServiceChip({required this.service});

  final ServiceItem service;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceElevated,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 10),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: AppColors.brandGreen,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(service.icon, color: Colors.white, size: 20),
          ),
          const SizedBox(height: 4),
          Expanded(
            child: Center(
              child: Text(
                service.label,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 11.5,
                  fontWeight: FontWeight.w600,
                  height: 1.15,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ProfileReviewsTab extends StatelessWidget {
  const _ProfileReviewsTab({required this.profile});

  final WasherProfile profile;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<List<BookingOrderItem>>(
      valueListenable: BookingOrdersStore.instance.listenable,
      builder: (context, orders, _) {
        final reviews = _buildReviews(orders, profile);

        return ListView.separated(
          padding: const EdgeInsets.fromLTRB(16, 18, 16, 24),
          itemCount: reviews.length,
          separatorBuilder: (_, _) => const SizedBox(height: 16),
          itemBuilder: (context, index) {
            return _ReviewCard(review: reviews[index]);
          },
        );
      },
    );
  }
}

class _InfoChip extends StatelessWidget {
  const _InfoChip({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.surfaceMuted,
        border: Border.all(color: AppColors.borderSoft),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: AppColors.brandGreen),
          const SizedBox(width: 7),
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

class _ReviewCard extends StatelessWidget {
  const _ReviewCard({required this.review});

  final _ProviderReview review;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceElevated,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 18,
            backgroundColor: AppColors.surfaceMuted,
            child: Text(
              _initials(review.customerName),
              style: const TextStyle(
                fontSize: 11.5,
                fontWeight: FontWeight.w700,
                color: AppColors.brandGreenLight,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        review.customerName,
                        style: const TextStyle(
                          fontSize: 13.2,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ),
                    Text(
                      review.dateLabel,
                      style: const TextStyle(
                        fontSize: 10.8,
                        color: AppColors.textMuted,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: List.generate(5, (index) {
                    return Icon(
                      index < review.rating
                          ? Icons.star_rounded
                          : Icons.star_border_rounded,
                      size: 15,
                      color: const Color(0xFFFFB423),
                    );
                  }),
                ),
                const SizedBox(height: 10),
                Text(
                  review.message,
                  style: const TextStyle(
                    fontSize: 13.2,
                    height: 1.6,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ProfileSectionCard extends StatelessWidget {
  const _ProfileSectionCard({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
      decoration: BoxDecoration(
        color: AppColors.surfaceElevated,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: child,
    );
  }
}

class _ProfileRatingStars extends StatelessWidget {
  const _ProfileRatingStars({required this.rating});

  final double rating;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (index) {
        final starNumber = index + 1;
        final icon = rating >= starNumber
            ? Icons.star_rounded
            : rating >= starNumber - 0.5
            ? Icons.star_half_rounded
            : Icons.star_outline_rounded;

        return Icon(icon, size: 13, color: AppColors.brandGreen);
      }),
    );
  }
}

class _ProviderNetworkImage extends StatelessWidget {
  const _ProviderNetworkImage({
    required this.imageUrl,
    required this.fallbackAssetPath,
  });

  final String imageUrl;
  final String fallbackAssetPath;

  @override
  Widget build(BuildContext context) {
    final normalizedImageUrl = imageUrl.trim();

    if (normalizedImageUrl.startsWith('http')) {
      return Image.network(
        normalizedImageUrl,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return _FlexibleProviderImage(path: fallbackAssetPath);
        },
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) {
            return child;
          }

          return _FlexibleProviderImage(path: fallbackAssetPath);
        },
      );
    }

    return _FlexibleProviderImage(
      path: normalizedImageUrl.isEmpty ? fallbackAssetPath : normalizedImageUrl,
    );
  }
}

class _FlexibleProviderImage extends StatelessWidget {
  const _FlexibleProviderImage({required this.path});

  final String path;

  @override
  Widget build(BuildContext context) {
    final normalizedPath = path.trim();
    if (normalizedPath.startsWith('assets/')) {
      return Image.asset(normalizedPath, fit: BoxFit.cover);
    }

    return Image.file(
      File(normalizedPath),
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) {
        return Image.asset(
          'assets/images/onboarding/pexels-bulat843-1243575272-28995187.jpg',
          fit: BoxFit.cover,
        );
      },
    );
  }
}

class _ProviderReview {
  const _ProviderReview({
    required this.customerName,
    required this.rating,
    required this.message,
    required this.dateLabel,
  });

  final String customerName;
  final int rating;
  final String message;
  final String dateLabel;
}

WasherProfile _buildCurrentProviderProfile(List<BookingOrderItem> orders) {
  final provider = ProviderCatalog.currentProviderProfile();

  // Count completed bookings
  final completedOrders = orders
      .where((o) => o.status == BookingOrderStatus.completed)
      .toList(growable: false);
  final completedCount = completedOrders.length;

  // Collect all orders that have a review rating
  final reviewedOrders = completedOrders
      .where((o) => o.reviewRating != null)
      .toList(growable: false);
  final reviewCount = reviewedOrders.length;

  // Rating starts at 1 star for new providers.
  // As reviews come in, it becomes the running average.
  final avgRating = reviewedOrders.isEmpty
      ? 1.0
      : reviewedOrders.map((o) => o.reviewRating!).reduce((a, b) => a + b) /
            reviewCount;

  // Verified only when 10+ completed jobs AND average rating >= 4.5
  final isVerified = completedCount >= 10 && avgRating >= 4.5;

  // Display label: "New" when no reviews yet, else actual count
  final reviewsLabel = reviewCount == 0 ? 'New' : '$reviewCount';

  final baseProfile = WasherProfile.fromServiceProvider(
    provider,
    id: 'service_provider_profile',
    phoneNumber: AuthSession.displayPhoneNumber,
    email: AuthSession.displayEmail,
    supportedServices: provider.supportedServices.isNotEmpty
        ? provider.supportedServices
        : const [
            'Exterior Wash',
            'Interior Cleaning',
            'Foam Wash',
            'Wax Polish',
          ],
    completedJobs: completedCount,
    pendingRequests: 4,
    activeOrders: 2,
    totalEarnings: '\$2,344.56',
    todayEarnings: '\$180',
    experienceLabel: '1-2 years',
    isOnline: true,
    isVerified: isVerified,
  );

  final currentName = AuthSession.currentName?.trim();
  final hasCustomName = currentName != null && currentName.isNotEmpty;
  final currentLocation = AuthSession.currentLocationLabel?.trim();
  final hasCustomLocation =
      currentLocation != null && currentLocation.isNotEmpty;

  // Update description to reflect current name in real-time
  final displayName = hasCustomName ? AuthSession.displayName : baseProfile.name;
  final updatedDescription = baseProfile.description.isEmpty
      ? '$displayName is a professional car wash service provider.'
      : baseProfile.description.replaceFirst(
          RegExp(r'^[\w\s]+?(?=\s+(is|delivers|focuses|handles|known))'),
          displayName,
        );

  return baseProfile.copyWith(
    name: hasCustomName ? AuthSession.displayName : baseProfile.name,
    description: updatedDescription,
    location: hasCustomLocation
        ? AuthSession.displayLocationLabel
        : baseProfile.location,
    latitude: AuthSession.currentLatitude ?? baseProfile.latitude,
    longitude: AuthSession.currentLongitude ?? baseProfile.longitude,
    rating: avgRating.toStringAsFixed(1),
    reviews: reviewsLabel,
  );
}

List<String> _expandedGallery(List<String> galleryImages) {
  if (galleryImages.length >= 9) {
    return galleryImages.take(9).toList(growable: false);
  }

  final expandedImages = <String>[...galleryImages];
  while (expandedImages.length < 9 && galleryImages.isNotEmpty) {
    expandedImages.add(
      galleryImages[expandedImages.length % galleryImages.length],
    );
  }

  return expandedImages;
}

List<_ProviderReview> _buildReviews(
  List<BookingOrderItem> orders,
  WasherProfile profile,
) {
  final providerName = profile.name.trim().toLowerCase();

  final matchingReviews = orders
      .where(
        (order) =>
            order.hasReview &&
            order.serviceProviderName.trim().toLowerCase() == providerName,
      )
      .toList(growable: false);

  final sourceReviews = matchingReviews.isNotEmpty
      ? matchingReviews
      : orders.where((order) => order.hasReview).toList(growable: false);

  if (sourceReviews.isNotEmpty) {
    final sortedReviews = [
      ...sourceReviews,
    ]..sort((first, second) => second.paymentDate.compareTo(first.paymentDate));

    return sortedReviews
        .take(6)
        .map((order) {
          final reviewRating =
              order.reviewRating ?? _fallbackRating(order.rating);
          final message = order.reviewText.trim().isNotEmpty
              ? order.reviewText.trim()
              : 'Professional service and clean finishing. Everything was handled smoothly and on time.';

          return _ProviderReview(
            customerName: order.customerName,
            rating: reviewRating.clamp(1, 5),
            message: message,
            dateLabel: _formatLongDate(order.paymentDate),
          );
        })
        .toList(growable: false);
  }

  return const [
    _ProviderReview(
      customerName: 'Kristin Watson',
      rating: 4,
      message:
          'The washer arrived on time, explained the service clearly, and left the car looking fresh inside and out. Very smooth experience overall.',
      dateLabel: 'March 14, 2021',
    ),
    _ProviderReview(
      customerName: 'Leslie Alexander',
      rating: 5,
      message:
          'Great attention to detail on the seats, dashboard, and wheel finish. The car looked much cleaner than I expected for a quick booking.',
      dateLabel: 'March 14, 2021',
    ),
    _ProviderReview(
      customerName: 'Devon Lane',
      rating: 5,
      message:
          'Professional behavior, fast setup, and a really nice final shine. I would happily book this provider again for my next wash.',
      dateLabel: 'March 14, 2021',
    ),
  ];
}

int _fallbackRating(String value) {
  final parsed = double.tryParse(value);
  if (parsed == null) {
    return 4;
  }

  return parsed.round().clamp(1, 5);
}

String _formatLongDate(DateTime value) {
  const monthNames = [
    'January',
    'February',
    'March',
    'April',
    'May',
    'June',
    'July',
    'August',
    'September',
    'October',
    'November',
    'December',
  ];

  return '${monthNames[value.month - 1]} ${value.day}, ${value.year}';
}

String _initials(String name) {
  final words = name
      .split(RegExp(r'\s+'))
      .where((word) => word.isNotEmpty)
      .toList(growable: false);

  if (words.isEmpty) {
    return 'CU';
  }

  if (words.length == 1) {
    final word = words.first;
    return word.length >= 2
        ? word.substring(0, 2).toUpperCase()
        : word.toUpperCase();
  }

  return '${words.first[0]}${words.last[0]}'.toUpperCase();
}

class _ProfileLocationMap extends StatelessWidget {
  const _ProfileLocationMap({required this.profile});

  final WasherProfile profile;

  @override
  Widget build(BuildContext context) {
    if (profile.latitude == null || profile.longitude == null) {
      return const ColoredBox(
        color: AppColors.surfaceMuted,
        child: Center(
          child: Text(
            'Location unavailable',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: AppColors.textSecondary,
            ),
          ),
        ),
      );
    }

    return Stack(
      fit: StackFit.expand,
      children: [
        ThemedGoogleMap(
          initialCameraPosition: CameraPosition(
            target: LatLng(profile.latitude!, profile.longitude!),
            zoom: 14.9,
          ),
          scrollGesturesEnabled: false,
          zoomGesturesEnabled: false,
          rotateGesturesEnabled: false,
          tiltGesturesEnabled: false,
          markers: {
            Marker(
              markerId: MarkerId(profile.profileKeyName),
              position: LatLng(profile.latitude!, profile.longitude!),
              infoWindow: InfoWindow(
                title: profile.name,
                snippet: profile.location,
              ),
            ),
          },
        ),
        Positioned(
          left: 12,
          right: 12,
          bottom: 12,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.62),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              profile.location,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 12,
                height: 1.3,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
