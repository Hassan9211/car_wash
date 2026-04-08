import 'package:car_wash/core/router/app_navigation.dart';
import 'package:car_wash/core/widgets/app_buttons.dart';
import 'package:car_wash/features/home/model/service_provider_profile.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

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
      1 => _GalleryTab(provider: provider),
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
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFEAF7EC),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  provider.categoryLabel,
                                  style: const TextStyle(
                                    fontSize: 12.5,
                                    fontWeight: FontWeight.w500,
                                    color: Color(0xFF238A42),
                                  ),
                                ),
                              ),
                              const Spacer(),
                              const _RatingStars(),
                              const SizedBox(width: 8),
                              Text(
                                provider.reviews,
                                style: const TextStyle(
                                  fontSize: 15,
                                  color: Color(0xFF1E1E1E),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: Text(
                                  provider.name,
                                  key: const Key('service_detail_provider_name'),
                                  style: const TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.black,
                                  ),
                                ),
                              ),
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
                            children: [
                              const Icon(
                                Icons.location_on_rounded,
                                size: 18,
                                color: Colors.red,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                provider.location,
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: Color(0xFF555555),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              const Icon(
                                Icons.access_time_filled_rounded,
                                size: 16,
                                color: Color(0xFF0F7D32),
                              ),
                              const SizedBox(width: 6),
                              Text(
                                provider.availability,
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: Color(0xFF222222),
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
                onPressed: () => context.pushToBooking(provider),
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
                const Spacer(),
                Row(
                  children: [
                    for (var i = 0; i < thumbnails.length; i++) ...[
                      Expanded(
                        child: Padding(
                          padding: EdgeInsets.only(
                            right: i == thumbnails.length - 1 ? 0 : 4,
                          ),
                          child: _GalleryThumb(
                            imageUrl: thumbnails[i],
                            fallbackAssetPath: provider.imagePath,
                          ),
                        ),
                      ),
                    ],
                    const SizedBox(width: 4),
                    const Expanded(
                      child: _GalleryCountThumb(
                        countLabel: '+10',
                      ),
                    ),
                  ],
                ),
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
  const _RatingStars();

  @override
  Widget build(BuildContext context) {
    return const Row(
      children: [
        Icon(Icons.star_rounded, size: 14, color: Color(0xFF0F7D32)),
        Icon(Icons.star_rounded, size: 14, color: Color(0xFF0F7D32)),
        Icon(Icons.star_rounded, size: 14, color: Color(0xFF0F7D32)),
        Icon(Icons.star_half_rounded, size: 14, color: Color(0xFF0F7D32)),
        Icon(Icons.star_outline_rounded, size: 14, color: Color(0xFF0F7D32)),
      ],
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
    const labels = ['Details', 'Gallery', 'Reviews'];

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
            fontSize: 13,
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
          child: const _MockMapCard(),
        ),
      ],
    );
  }
}

class _GalleryTab extends StatelessWidget {
  const _GalleryTab({
    required this.provider,
  });

  final ServiceProviderProfile provider;

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: provider.galleryImageUrls.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
        childAspectRatio: 1,
      ),
      itemBuilder: (context, index) {
        return ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: _NetworkCarImage(
            imageUrl: provider.galleryImageUrls[index],
            fallbackAssetPath: provider.imagePath,
          ),
        );
      },
    );
  }
}

class _ReviewsTab extends StatelessWidget {
  const _ReviewsTab({
    required this.provider,
  });

  final ServiceProviderProfile provider;

  @override
  Widget build(BuildContext context) {
    const reviews = [
      ('Ali', 'Very professional wash and the car looked brand new.'),
      ('Sara', 'On-time arrival and the detailing quality was excellent.'),
      ('John', 'Good value for money and the interior was super clean.'),
    ];

    return Column(
      children: reviews.map((review) {
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
                  review.$1.substring(0, 1),
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
                      review.$1,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(height: 4),
                    const _RatingStars(),
                    const SizedBox(height: 6),
                    Text(
                      review.$2,
                      style: const TextStyle(
                        fontSize: 12.5,
                        height: 1.4,
                        color: Color(0xFF6E6E6E),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      }).toList(growable: false),
    );
  }
}

class _MockMapCard extends StatelessWidget {
  const _MockMapCard();

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        CustomPaint(
          painter: _MapPainter(),
        ),
        const Positioned(
          left: 98,
          top: 78,
          child: Icon(
            Icons.location_on_rounded,
            size: 26,
            color: Color(0xFFF05A45),
          ),
        ),
        const Positioned(
          left: 124,
          top: 42,
          child: Text(
            'Nirmala\nHSS',
            style: TextStyle(
              fontSize: 8,
              color: Color(0xFF8F8F8F),
            ),
          ),
        ),
        const Positioned(
          left: 16,
          top: 104,
          child: RotatedBox(
            quarterTurns: 3,
            child: Text(
              'Vepernandi S...',
              style: TextStyle(fontSize: 8, color: Color(0xFF9A9A9A)),
            ),
          ),
        ),
        const Positioned(
          left: 46,
          top: 90,
          child: RotatedBox(
            quarterTurns: 3,
            child: Text(
              '8th St.',
              style: TextStyle(fontSize: 8, color: Color(0xFF9A9A9A)),
            ),
          ),
        ),
        const Positioned(
          left: 78,
          top: 78,
          child: RotatedBox(
            quarterTurns: 3,
            child: Text(
              'Babusak Junathamman Salai',
              style: TextStyle(fontSize: 7.5, color: Color(0xFF9A9A9A)),
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
      ..strokeWidth = 16
      ..color = Colors.white;

    final roadEdgePaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 1
      ..color = const Color(0xFFE2E2E2);

    final paths = <Path>[
      Path()
        ..moveTo(10, 20)
        ..quadraticBezierTo(60, 80, 90, 210),
      Path()
        ..moveTo(56, 10)
        ..quadraticBezierTo(120, 70, 110, 220),
      Path()
        ..moveTo(150, 0)
        ..quadraticBezierTo(130, 80, 155, 220),
      Path()
        ..moveTo(205, 10)
        ..quadraticBezierTo(185, 90, 205, 220),
      Path()
        ..moveTo(0, 72)
        ..quadraticBezierTo(110, 90, 245, 82),
      Path()
        ..moveTo(0, 138)
        ..quadraticBezierTo(120, 120, 245, 146),
    ];

    for (final path in paths) {
      canvas.drawPath(path, roadPaint);
      canvas.drawPath(path, roadEdgePaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
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
    return Image.network(
      imageUrl,
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) {
        return Image.asset(
          fallbackAssetPath,
          fit: BoxFit.cover,
        );
      },
      loadingBuilder: (context, child, loadingProgress) {
        if (loadingProgress == null) {
          return child;
        }

        return Image.asset(
          fallbackAssetPath,
          fit: BoxFit.cover,
        );
      },
    );
  }
}
