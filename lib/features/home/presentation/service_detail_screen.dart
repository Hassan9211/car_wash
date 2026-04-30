import 'dart:io';

import 'package:car_wash/core/router/app_navigation.dart';
import 'package:car_wash/core/theme/app_colors.dart';
import 'package:car_wash/core/widgets/themed_google_map.dart';
import 'package:car_wash/core/widgets/app_buttons.dart';
import 'package:car_wash/features/authentication/data/auth_session.dart';
import 'package:car_wash/features/home/booking/data/booking_orders_store.dart';
import 'package:car_wash/features/home/booking/model/booking_order_item.dart';
import 'package:car_wash/features/home/model/service_provider_profile.dart';
import 'package:car_wash/features/services/data/service_catalog.dart';
import 'package:car_wash/features/services/model/service_item.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class ServiceDetailScreen extends StatefulWidget {
  const ServiceDetailScreen({
    super.key,
    required this.provider,
  });

  final ServiceProviderProfile provider;

  @override
  State<ServiceDetailScreen> createState() => _ServiceDetailScreenState();
}

class _ServiceDetailScreenState extends State<ServiceDetailScreen> {
  int _selectedTabIndex = 0;

  @override
  Widget build(BuildContext context) {
    final provider = widget.provider;
    final tabContent = switch (_selectedTabIndex) {
      0 => _DetailsTab(provider: provider),
      1 => _ServicesTab(provider: provider),
      _ => _ReviewsTab(provider: provider),
    };

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Stack(
          children: [
            Positioned.fill(
              child: SingleChildScrollView(
                padding: const EdgeInsets.only(bottom: 96),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _DetailHero(provider: provider),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
                      child: LayoutBuilder(
                        builder: (context, constraints) {
                          final useStackedPriceLayout =
                              constraints.maxWidth < 365;

                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Wrap(
                                spacing: 8,
                                runSpacing: 10,
                                crossAxisAlignment: WrapCrossAlignment.center,
                                children: [
                                  _InfoBadge(
                                    label: provider.categoryLabel,
                                    backgroundColor: const Color(0xFFEAF7EC),
                                    textColor: const Color(0xFF238A42),
                                    borderRadius: 6,
                                  ),
                                  if (provider.showNewBadge)
                                    const _InfoBadge(
                                      label: 'New Provider',
                                      backgroundColor: Color(0xFF183222),
                                      textColor: Color(0xFF8BF0AE),
                                      borderRadius: 999,
                                      fontWeight: FontWeight.w700,
                                      horizontalPadding: 10,
                                    ),
                                  _RatingSummary(
                                    rating: provider.rating,
                                    reviews: provider.reviews,
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              if (useStackedPriceLayout) ...[
                                Row(
                                  children: [
                                    Text(
                                      provider.name,
                                      key: const Key('service_detail_provider_name'),
                                      style: const TextStyle(
                                        fontSize: 24,
                                        fontWeight: FontWeight.w500,
                                        color: Colors.black,
                                      ),
                                    ),
                                    if (provider.isVerified) ...[
                                      const SizedBox(width: 6),
                                      const Icon(
                                        Icons.verified_rounded,
                                        color: Color(0xFF1D9BF0),
                                        size: 22,
                                      ),
                                    ],
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  provider.price,
                                  style: const TextStyle(
                                    fontSize: 30,
                                    fontWeight: FontWeight.w700,
                                    color: Color(0xFF202020),
                                  ),
                                ),
                              ] else
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Expanded(
                                      child: Row(
                                        children: [
                                          Flexible(
                                            child: Text(
                                              provider.name,
                                              key: const Key(
                                                'service_detail_provider_name',
                                              ),
                                              style: const TextStyle(
                                                fontSize: 24,
                                                fontWeight: FontWeight.w500,
                                                color: Colors.black,
                                              ),
                                            ),
                                          ),
                                          if (provider.isVerified) ...[
                                            const SizedBox(width: 8),
                                            const Icon(
                                              Icons.verified_rounded,
                                              color: Color(0xFF1D9BF0),
                                              size: 24,
                                            ),
                                          ],
                                        ],
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Text(
                                      provider.price,
                                      style: const TextStyle(
                                        fontSize: 32,
                                        fontWeight: FontWeight.w700,
                                        color: Color(0xFF202020),
                                      ),
                                    ),
                                  ],
                                ),
                              const SizedBox(height: 8),
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Padding(
                                    padding: EdgeInsets.only(top: 1),
                                    child: Icon(
                                      Icons.location_on_rounded,
                                      size: 18,
                                      color: Colors.red,
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                  Expanded(
                                    child: Text(
                                      provider.location,
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                        fontSize: 14,
                                        height: 1.35,
                                        color: Color(0xFF555555),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Padding(
                                    padding: EdgeInsets.only(top: 1),
                                    child: Icon(
                                      Icons.access_time_filled_rounded,
                                      size: 16,
                                      color: Color(0xFF0F7D32),
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                  Expanded(
                                    child: Text(
                                      provider.availability,
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                        fontSize: 14,
                                        color: Color(0xFF222222),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                              _DetailTabs(
                                selectedIndex: _selectedTabIndex,
                                onSelected: (index) {
                                  setState(() {
                                    _selectedTabIndex = index;
                                  });
                                },
                              ),
                              const SizedBox(height: 16),
                              tabContent,
                            ],
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Positioned(
              left: 16,
              right: 16,
              bottom: 16,
              child: AppPrimaryButton(
                key: const Key('service_detail_book_button'),
                label: 'Book Service Provider',
                onPressed: () {
                  if (AuthSession.isGuest) {
                    ScaffoldMessenger.of(context)
                      ..hideCurrentSnackBar()
                      ..showSnackBar(
                        SnackBar(
                          content: const Text('Please sign in to book a service.'),
                          duration: const Duration(seconds: 1),
                          action: SnackBarAction(
                            label: 'Sign In',
                            textColor: AppColors.brandGreenLight,
                            onPressed: () => context.goToRoleSelection(),
                          ),
                          behavior: SnackBarBehavior.floating,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      );
                    return;
                  }
                  context.pushToBooking(provider);
                },
                height: 48,
                borderRadius: 6,
                textStyle: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DetailHero extends StatelessWidget {
  const _DetailHero({
    required this.provider,
  });

  final ServiceProviderProfile provider;

  @override
  Widget build(BuildContext context) {
    final thumbnails = provider.galleryImageUrls.take(5).toList(growable: false);

    return SizedBox(
      height: 260,
      child: Stack(
        fit: StackFit.expand,
        children: [
          _NetworkCarImage(
            imageUrl: provider.mainImageUrl,
            fallbackAssetPath: provider.imagePath,
          ),
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.black.withValues(alpha: 0.38),
                  Colors.black.withValues(alpha: 0.10),
                  Colors.black.withValues(alpha: 0.22),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(8, 8, 8, 12),
            child: Column(
              children: [
                Row(
                  children: [
                    IconButton(
                      key: const Key('service_detail_back_button'),
                      onPressed: () => context.pop(),
                      icon: const Icon(
                        Icons.arrow_back_ios_new_rounded,
                        color: Colors.white,
                        size: 18,
                      ),
                    ),
                    const Expanded(
                      child: Text(
                        'Service Detail',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    const SizedBox(width: 48),
                  ],
                ),
                if (provider.showNewBadge)
                  Align(
                    alignment: Alignment.topRight,
                    child: Container(
                      margin: const EdgeInsets.only(top: 54, right: 12),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.66),
                        borderRadius: BorderRadius.circular(999),
                        border: Border.all(
                          color: const Color(0xFF8BF0AE),
                        ),
                      ),
                      child: const Text(
                        'Just Joined',
                        style: TextStyle(
                          fontSize: 10.8,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF8BF0AE),
                        ),
                      ),
                    ),
                  ),
                const Spacer(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _GalleryThumb extends StatelessWidget {
  const _GalleryThumb({
    required this.imageUrl,
    required this.fallbackAssetPath,
  });

  final String imageUrl;
  final String fallbackAssetPath;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(6),
      child: Container(
        height: 34,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(6),
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.9),
            width: 1,
          ),
        ),
        child: _NetworkCarImage(
          imageUrl: imageUrl,
          fallbackAssetPath: fallbackAssetPath,
        ),
      ),
    );
  }
}

class _GalleryCountThumb extends StatelessWidget {
  const _GalleryCountThumb({
    required this.countLabel,
  });

  final String countLabel;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 34,
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.58),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.9),
        ),
      ),
      child: Center(
        child: Text(
          countLabel,
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w500,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}

class _RatingStars extends StatelessWidget {
  const _RatingStars({required this.rating});

  final String rating;

  @override
  Widget build(BuildContext context) {
    final ratingValue = double.tryParse(rating) ?? 0.0;
    return Row(
      children: List.generate(5, (index) {
        final starNumber = index + 1;
        final icon = ratingValue >= starNumber
            ? Icons.star_rounded
            : ratingValue >= starNumber - 0.5
                ? Icons.star_half_rounded
                : Icons.star_outline_rounded;

        return Icon(icon, size: 14, color: const Color(0xFF0F7D32));
      }),
    );
  }
}

class _RatingSummary extends StatelessWidget {
  const _RatingSummary({required this.rating, required this.reviews});

  final String rating;
  final String reviews;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _RatingStars(rating: rating),
        const SizedBox(width: 8),
        Text(
          reviews,
          style: const TextStyle(
            fontSize: 15,
            color: Color(0xFF1E1E1E),
          ),
        ),
      ],
    );
  }
}

class _InfoBadge extends StatelessWidget {
  const _InfoBadge({
    required this.label,
    required this.backgroundColor,
    required this.textColor,
    required this.borderRadius,
    this.fontWeight = FontWeight.w500,
    this.horizontalPadding = 12,
  });

  final String label;
  final Color backgroundColor;
  final Color textColor;
  final double borderRadius;
  final FontWeight fontWeight;
  final double horizontalPadding;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: horizontalPadding,
        vertical: 6,
      ),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(borderRadius),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 12.5,
          fontWeight: fontWeight,
          color: textColor,
        ),
      ),
    );
  }
}

class _DetailTabs extends StatelessWidget {
  const _DetailTabs({
    required this.selectedIndex,
    required this.onSelected,
  });

  final int selectedIndex;
  final ValueChanged<int> onSelected;

  @override
  Widget build(BuildContext context) {
    const labels = ['Details', 'Services', 'Reviews'];

    return Row(
      children: List.generate(labels.length, (index) {
        final isSelected = index == selectedIndex;
        return Expanded(
          child: GestureDetector(
            onTap: () => onSelected(index),
            child: Container(
              padding: const EdgeInsets.only(bottom: 10),
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                    color: isSelected
                        ? const Color(0xFF0F7D32)
                        : const Color(0xFFE5E5E5),
                    width: isSelected ? 2 : 1,
                  ),
                ),
              ),
              child: Text(
                labels[index],
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: isSelected ? FontWeight.w500 : FontWeight.w400,
                  color: isSelected
                      ? const Color(0xFF0F7D32)
                      : const Color(0xFF9B9B9B),
                ),
              ),
            ),
          ),
        );
      }),
    );
  }
}

class _DetailsTab extends StatelessWidget {
  const _DetailsTab({
    required this.provider,
  });

  final ServiceProviderProfile provider;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'About',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: Colors.black,
          ),
        ),
        const SizedBox(height: 10),
        Text(
          provider.description,
          style: const TextStyle(
            fontSize: 13.8,
            height: 1.55,
            color: Color(0xFF8A8A8A),
          ),
        ),
        const SizedBox(height: 18),
        const Text(
          'Location',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: Colors.black,
          ),
        ),
        const SizedBox(height: 10),
        Container(
          height: 214,
          decoration: BoxDecoration(
            color: const Color(0xFFF6F6F6),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: const Color(0xFFE2E2E2),
            ),
          ),
          clipBehavior: Clip.antiAlias,
          child: _ProviderLocationMap(provider: provider),
        ),
      ],
    );
  }
}

class _ServicesTab extends StatelessWidget {
  const _ServicesTab({
    required this.provider,
  });

  final ServiceProviderProfile provider;

  @override
  Widget build(BuildContext context) {
    final serviceNames = provider.supportedServices.isNotEmpty
        ? provider.supportedServices
        : [
            'Basic wash',
            'Foam wash',
            'Interior',
            'Wax',
            'Engine',
            'Vacuum',
          ];

    final servicesList = ServiceCatalog.allServices
        .where((service) => serviceNames.any((name) => 
            name.toLowerCase().contains(service.label.toLowerCase()) ||
            service.label.toLowerCase().contains(name.toLowerCase())))
        .toList(growable: false);

    // Fallback if mapping fails
    final displayList = servicesList.isNotEmpty 
        ? servicesList 
        : ServiceCatalog.featuredServices;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Offered Services',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.black,
          ),
        ),
        const SizedBox(height: 16),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: displayList.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            crossAxisSpacing: 14,
            mainAxisSpacing: 14,
            childAspectRatio: 1.0,
          ),
          itemBuilder: (context, index) {
            final service = displayList[index];
            return _ProviderServiceChip(service: service);
          },
        ),
        const SizedBox(height: 24),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFF183222),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Row(
            children: [
              Icon(
                Icons.info_outline_rounded,
                color: Color(0xFF8BF0AE),
                size: 20,
              ),
              SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Professional equipment and premium quality soap used for all services.',
                  style: TextStyle(
                    fontSize: 12.5,
                    color: Colors.white,
                    height: 1.4,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
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
        color: const Color(0xFFF9F9F9),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFEEEEEE)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 10),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: const Color(0xFF0F7D32),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(service.icon, color: Colors.white, size: 20),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Text(
              service.label,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 11.5,
                fontWeight: FontWeight.w600,
                height: 1.15,
                color: Color(0xFF222222),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ReviewsTab extends StatelessWidget {
  const _ReviewsTab({required this.provider});

  final ServiceProviderProfile provider;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<List<BookingOrderItem>>(
      valueListenable: BookingOrdersStore.instance.listenable,
      builder: (context, orders, _) {
        final providerName = provider.name.trim().toLowerCase();
        final reviews = orders
            .where((o) =>
                o.serviceProviderName.trim().toLowerCase() == providerName &&
                o.hasReview)
            .toList(growable: false)
          ..sort((a, b) => b.paymentDate.compareTo(a.paymentDate));

        if (reviews.isEmpty) {
          return const Padding(
            padding: EdgeInsets.symmetric(vertical: 32),
            child: Center(
              child: Text(
                'No reviews yet.',
                style: TextStyle(
                  fontSize: 14,
                  color: AppColors.textSecondary,
                ),
              ),
            ),
          );
        }

        return Column(
          children: reviews.map((order) {
            final name = order.customerName.isNotEmpty
                ? order.customerName
                : 'Customer';
            final initial = name.substring(0, 1).toUpperCase();
            final rating = order.reviewRating ?? 0;
            final comment = order.reviewText;

            return Container(
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFF8F8F8),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CircleAvatar(
                    radius: 18,
                    backgroundColor: const Color(0xFFE5F2E8),
                    child: Text(
                      initial,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF0F7D32),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          name,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: Colors.black,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: List.generate(5, (i) => Icon(
                            i < rating.round()
                                ? Icons.star_rounded
                                : Icons.star_outline_rounded,
                            size: 14,
                            color: const Color(0xFF0F7D32),
                          )),
                        ),
                        if (comment.isNotEmpty) ...[
                          const SizedBox(height: 6),
                          Text(
                            comment,
                            style: const TextStyle(
                              fontSize: 12.5,
                              height: 1.4,
                              color: Color(0xFF6E6E6E),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            );
          }).toList(growable: false),
        );
      },
    );
  }
}

class _ProviderLocationMap extends StatelessWidget {
  const _ProviderLocationMap({required this.provider});

  final ServiceProviderProfile provider;

  @override
  Widget build(BuildContext context) {
    if (!provider.hasCoordinates) {
      return const ColoredBox(
        color: Color(0xFFF3F3F3),
        child: Center(
          child: Text(
            'Location unavailable',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: Color(0xFF6E6E6E),
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
            target: LatLng(provider.latitude!, provider.longitude!),
            zoom: 14.8,
          ),
          scrollGesturesEnabled: false,
          zoomGesturesEnabled: false,
          rotateGesturesEnabled: false,
          tiltGesturesEnabled: false,
          markers: {
            Marker(
              markerId: MarkerId(provider.detailsKeyName),
              position: LatLng(provider.latitude!, provider.longitude!),
              infoWindow: InfoWindow(
                title: provider.name,
                snippet: provider.location,
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
              provider.location,
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

class _NetworkCarImage extends StatelessWidget {
  const _NetworkCarImage({
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
          return _FallbackProviderImage(path: fallbackAssetPath);
        },
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) {
            return child;
          }

          return _FallbackProviderImage(path: fallbackAssetPath);
        },
      );
    }

    return _FallbackProviderImage(
      path: normalizedImageUrl.isEmpty ? fallbackAssetPath : normalizedImageUrl,
    );
  }
}

class _FallbackProviderImage extends StatelessWidget {
  const _FallbackProviderImage({required this.path});

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
