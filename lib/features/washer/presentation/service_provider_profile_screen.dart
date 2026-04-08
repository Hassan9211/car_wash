import 'package:car_wash/core/router/app_navigation.dart';
import 'package:car_wash/core/theme/app_colors.dart';
import 'package:car_wash/features/authentication/data/auth_session.dart';
import 'package:car_wash/features/home/booking/data/booking_orders_store.dart';
import 'package:car_wash/features/home/booking/model/booking_order_item.dart';
import 'package:car_wash/features/home/data/provider_catalog.dart';
import 'package:car_wash/features/washer/model/washer_profile.dart';
import 'package:car_wash/features/washer/presentation/widgets/service_provider_bottom_navigation_bar.dart';
import 'package:flutter/material.dart';

class ServiceProviderProfileScreen extends StatefulWidget {
  const ServiceProviderProfileScreen({super.key});

  @override
  State<ServiceProviderProfileScreen> createState() =>
      _ServiceProviderProfileScreenState();
}

class _ServiceProviderProfileScreenState
    extends State<ServiceProviderProfileScreen> {
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
    return ValueListenableBuilder<int>(
      valueListenable: AuthSession.listenable,
      builder: (context, _, child) {
        final profile = _buildCurrentProviderProfile();

        return DefaultTabController(
          length: 3,
          child: Scaffold(
            backgroundColor: Colors.white,
            body: SafeArea(
              bottom: false,
              child: Column(
                children: [
                  _ProfileHeader(profile: profile, onEditTap: _openEditProfile),
                  Expanded(
                    child: TabBarView(
                      children: [
                        _ProfileDetailsTab(profile: profile),
                        _ProfileGalleryTab(profile: profile),
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
      height: 332,
      child: Stack(
        children: [
          SizedBox(
            height: 220,
            width: double.infinity,
            child: Stack(
              fit: StackFit.expand,
              children: [
                _ProviderNetworkImage(
                  imageUrl: profile.mainImageUrl,
                  fallbackAssetPath: profile.imagePath,
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
                Padding(
                  padding: const EdgeInsets.fromLTRB(14, 12, 14, 0),
                  child: Row(
                    children: [
                      const SizedBox(width: 42),
                      const Expanded(
                        child: Text(
                          'Profile',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: onEditTap,
                          customBorder: const CircleBorder(),
                          child: const SizedBox(
                            width: 42,
                            height: 42,
                            child: Icon(
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
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
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
                            color: Color(0xFF1D1D1D),
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
                        color: Color(0xFF1A1A1A),
                      ),
                    ),
                  ),
                  const SizedBox(height: 18),
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
    return const TabBar(
      labelColor: AppColors.brandGreen,
      unselectedLabelColor: Color(0xFF9C9C9C),
      indicatorColor: AppColors.brandGreen,
      indicatorWeight: 1.6,
      indicatorSize: TabBarIndicatorSize.tab,
      labelStyle: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
      unselectedLabelStyle: TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w400,
      ),
      tabs: [
        Tab(text: 'Details'),
        Tab(text: 'Gallery'),
        Tab(text: 'Reviews'),
      ],
    );
  }
}

class _ProfileDetailsTab extends StatelessWidget {
  const _ProfileDetailsTab({required this.profile});

  final WasherProfile profile;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'About',
            style: TextStyle(
              fontSize: 15.5,
              fontWeight: FontWeight.w600,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            profile.description,
            style: const TextStyle(
              fontSize: 12.5,
              height: 1.6,
              color: Color(0xFF7B7B7B),
            ),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            runSpacing: 8,
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
                label: profile.isVerified ? 'Verified' : 'Pending Verification',
              ),
            ],
          ),
          const SizedBox(height: 18),
          const Text(
            'Location',
            style: TextStyle(
              fontSize: 15.5,
              fontWeight: FontWeight.w600,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            profile.location,
            style: const TextStyle(fontSize: 12.5, color: Color(0xFF6C6C6C)),
          ),
          const SizedBox(height: 12),
          Container(
            height: 246,
            clipBehavior: Clip.antiAlias,
            decoration: BoxDecoration(
              color: const Color(0xFFF7F7F7),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFE6E6E6)),
            ),
            child: const _MockMapCard(),
          ),
        ],
      ),
    );
  }
}

class _ProfileGalleryTab extends StatelessWidget {
  const _ProfileGalleryTab({required this.profile});

  final WasherProfile profile;

  @override
  Widget build(BuildContext context) {
    final galleryImages = _expandedGallery(profile.galleryImageUrls);

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(10, 14, 10, 22),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: galleryImages.length,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          crossAxisSpacing: 4,
          mainAxisSpacing: 4,
          childAspectRatio: 1,
        ),
        itemBuilder: (context, index) {
          return ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: _ProviderNetworkImage(
              imageUrl: galleryImages[index],
              fallbackAssetPath: profile.imagePath,
            ),
          );
        },
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
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 22),
          itemCount: reviews.length,
          separatorBuilder: (_, _) => const SizedBox(height: 14),
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
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFF4F7F4),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 15, color: AppColors.brandGreen),
          const SizedBox(width: 6),
          Text(
            label,
            style: const TextStyle(fontSize: 12, color: Color(0xFF4D4D4D)),
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
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CircleAvatar(
          radius: 14,
          backgroundColor: const Color(0xFFF3ECE7),
          child: Text(
            _initials(review.customerName),
            style: const TextStyle(
              fontSize: 10.5,
              fontWeight: FontWeight.w700,
              color: Color(0xFF7B5B42),
            ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: List.generate(5, (index) {
                  return Icon(
                    index < review.rating
                        ? Icons.star_rounded
                        : Icons.star_border_rounded,
                    size: 14,
                    color: const Color(0xFFFFB423),
                  );
                }),
              ),
              const SizedBox(height: 6),
              Text(
                review.message,
                style: const TextStyle(
                  fontSize: 12.5,
                  height: 1.52,
                  color: Color(0xFF656565),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                review.customerName,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF4A4A4A),
                ),
              ),
              const SizedBox(height: 2),
              Text(
                review.dateLabel,
                style: const TextStyle(
                  fontSize: 10.5,
                  color: Color(0xFF9C9C9C),
                ),
              ),
            ],
          ),
        ),
      ],
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
    return Image.network(
      imageUrl,
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) {
        return Image.asset(fallbackAssetPath, fit: BoxFit.cover);
      },
      loadingBuilder: (context, child, loadingProgress) {
        if (loadingProgress == null) {
          return child;
        }

        return Image.asset(fallbackAssetPath, fit: BoxFit.cover);
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

WasherProfile _buildCurrentProviderProfile() {
  final baseProfile = WasherProfile.fromServiceProvider(
    ProviderCatalog.providers.first,
    id: 'service_provider_profile',
    phoneNumber: AuthSession.displayPhoneNumber,
    email: AuthSession.displayEmail,
    supportedServices: const [
      'Exterior Wash',
      'Interior Cleaning',
      'Foam Wash',
      'Wax Polish',
    ],
    completedJobs: 248,
    pendingRequests: 4,
    activeOrders: 2,
    totalEarnings: '\$2,344.56',
    todayEarnings: '\$180',
    experienceLabel: '1-2 years',
    isOnline: true,
    isVerified: true,
  );

  final currentName = AuthSession.currentName?.trim();
  final hasCustomName = currentName != null && currentName.isNotEmpty;
  final currentLocation = AuthSession.currentLocationLabel?.trim();
  final hasCustomLocation =
      currentLocation != null && currentLocation.isNotEmpty;

  return baseProfile.copyWith(
    name: hasCustomName ? AuthSession.displayName : baseProfile.name,
    location: hasCustomLocation
        ? AuthSession.displayLocationLabel
        : baseProfile.location,
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
          'Lorem ipsum dolor sit amet consectetur. Lorem nibh in vitae cras. Rhoncus justo volutpat nisi sed. Interdum aenean lobortis ipsum bibendum.',
      dateLabel: 'March 14, 2021',
    ),
    _ProviderReview(
      customerName: 'Kristin Watson',
      rating: 4,
      message:
          'Lorem ipsum dolor sit amet consectetur. Lorem nibh in vitae cras. Rhoncus justo volutpat nisi sed. Interdum aenean lobortis ipsum bibendum.',
      dateLabel: 'March 14, 2021',
    ),
    _ProviderReview(
      customerName: 'Kristin Watson',
      rating: 4,
      message:
          'Lorem ipsum dolor sit amet consectetur. Lorem nibh in vitae cras. Rhoncus justo volutpat nisi sed. Interdum aenean lobortis ipsum bibendum.',
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

class _MockMapCard extends StatelessWidget {
  const _MockMapCard();

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        CustomPaint(painter: _MapPainter()),
        const Positioned(
          left: 104,
          top: 84,
          child: Icon(
            Icons.location_on_rounded,
            size: 28,
            color: Color(0xFFF05A45),
          ),
        ),
        const Positioned(
          left: 148,
          top: 52,
          child: Text(
            'Nirmala\nGirls HSS',
            style: TextStyle(fontSize: 8, color: Color(0xFF8F8F8F)),
          ),
        ),
        const Positioned(
          left: 22,
          top: 118,
          child: RotatedBox(
            quarterTurns: 3,
            child: Text(
              'Upperhandalva Salai',
              style: TextStyle(fontSize: 8, color: Color(0xFF9A9A9A)),
            ),
          ),
        ),
        const Positioned(
          left: 64,
          top: 108,
          child: RotatedBox(
            quarterTurns: 3,
            child: Text(
              '8th St.',
              style: TextStyle(fontSize: 8, color: Color(0xFF9A9A9A)),
            ),
          ),
        ),
        const Positioned(
          left: 102,
          top: 100,
          child: RotatedBox(
            quarterTurns: 3,
            child: Text(
              'Balaramapuram Main St.',
              style: TextStyle(fontSize: 7.5, color: Color(0xFF9A9A9A)),
            ),
          ),
        ),
        const Positioned(
          left: 188,
          top: 92,
          child: RotatedBox(
            quarterTurns: 3,
            child: Text(
              '8th Street',
              style: TextStyle(fontSize: 8, color: Color(0xFF9A9A9A)),
            ),
          ),
        ),
      ],
    );
  }
}

class _MapPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final backgroundPaint = Paint()..color = const Color(0xFFF5F5F5);
    canvas.drawRect(Offset.zero & size, backgroundPaint);

    final roadPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 17
      ..color = Colors.white;

    final roadEdgePaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 1
      ..color = const Color(0xFFE2E2E2);

    final paths = <Path>[
      Path()
        ..moveTo(12, 18)
        ..quadraticBezierTo(70, 98, 102, 242),
      Path()
        ..moveTo(60, 0)
        ..quadraticBezierTo(120, 88, 112, 248),
      Path()
        ..moveTo(154, 8)
        ..quadraticBezierTo(136, 102, 164, 248),
      Path()
        ..moveTo(228, 12)
        ..quadraticBezierTo(204, 104, 228, 248),
      Path()
        ..moveTo(0, 84)
        ..quadraticBezierTo(120, 102, 310, 88),
      Path()
        ..moveTo(0, 148)
        ..quadraticBezierTo(150, 132, 310, 154),
      Path()
        ..moveTo(44, 210)
        ..quadraticBezierTo(136, 194, 310, 208),
    ];

    for (final path in paths) {
      canvas.drawPath(path, roadPaint);
      canvas.drawPath(path, roadEdgePaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
