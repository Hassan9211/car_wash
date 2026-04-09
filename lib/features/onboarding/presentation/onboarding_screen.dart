import 'dart:math' as math;

import 'package:car_wash/core/router/app_navigation.dart';
import 'package:car_wash/core/widgets/app_buttons.dart';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  static const double _onboardingPlaybackSpeed = 0.72;
  late final List<VideoPlayerController> _videoControllers = _pages
      .map((page) => VideoPlayerController.asset(page.videoAssetPath))
      .toList(growable: false);

  static const List<_OnboardingPageData> _pages = [
    _OnboardingPageData(
      title: 'Welcome to LaveGo!',
      description: 'Book a car wash at your doorstep with just a few taps.',
      videoAssetPath: 'assets/videos/onboarding_welcome.mp4',
      imageAssetPath:
          'assets/images/onboarding/pexels-bulat843-1243575272-28995187.jpg',
      imageAlignment: Alignment.center,
      badgeLabel: 'CINEMATIC WELCOME',
      accentColor: Color(0xFF26C35B),
      secondaryAccentColor: Color(0xFFF4C14D),
    ),
    _OnboardingPageData(
      title: 'Book in Seconds',
      description:
          'Choose your service, time, and location. We\'ll handle the rest!',
      videoAssetPath: 'assets/videos/onboarding_booking.mp4',
      imageAssetPath: 'assets/images/onboarding/pexels-karola-g-4870700.jpg',
      imageAlignment: Alignment.centerLeft,
      badgeLabel: 'HYPER-FAST FLOW',
      accentColor: Color(0xFF68D6E8),
      secondaryAccentColor: Color(0xFFECC65C),
    ),
    _OnboardingPageData(
      title: 'Track Your Washer.',
      description:
          'Follow your washer in real-time and know exactly when they\'ll arrive.',
      videoAssetPath: 'assets/videos/onboarding_tracking.mp4',
      imageAssetPath:
          'assets/images/onboarding/pexels-bulat843-1243575272-31154194.jpg',
      imageAlignment: Alignment.center,
      badgeLabel: 'LIVE ARRIVAL DRAMA',
      accentColor: Color(0xFFFF8C5A),
      secondaryAccentColor: Color(0xFF3BC86C),
    ),
  ];

  int _currentIndex = 0;

  bool get _isLastPage => _currentIndex == _pages.length - 1;

  @override
  void initState() {
    super.initState();
    _initializeVideos();
  }

  Future<void> _initializeVideos() async {
    for (final controller in _videoControllers) {
      await controller.initialize();
      await controller.setLooping(true);
      await controller.setVolume(0);
      await controller.setPlaybackSpeed(_onboardingPlaybackSpeed);
    }

    if (!mounted) {
      return;
    }

    _syncVideoPlayback(resetActive: true);
    setState(() {});
  }

  void _handlePageChanged(int index) {
    setState(() {
      _currentIndex = index;
    });
    _syncVideoPlayback(resetActive: true);
  }

  void _syncVideoPlayback({bool resetActive = false}) {
    for (var index = 0; index < _videoControllers.length; index++) {
      final controller = _videoControllers[index];
      if (!controller.value.isInitialized) {
        continue;
      }

      if (index == _currentIndex) {
        if (resetActive) {
          controller.seekTo(Duration.zero);
        }
        controller.play();
      } else {
        controller.pause();
      }
    }
  }

  Future<void> _goNext() async {
    if (_isLastPage) {
      context.goToLanguage();
      return;
    }

    await _pageController.nextPage(
      duration: const Duration(milliseconds: 420),
      curve: Curves.easeOutCubic,
    );
  }

  Future<void> _goBack() async {
    if (_currentIndex == 0) {
      context.goToSplash();
      return;
    }

    await _pageController.previousPage(
      duration: const Duration(milliseconds: 420),
      curve: Curves.easeOutCubic,
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    for (final controller in _videoControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final page = _pages[_currentIndex];

    return Scaffold(
      backgroundColor: const Color(0xFF030806),
      body: Stack(
        fit: StackFit.expand,
        children: [
          PageView.builder(
            key: const Key('onboarding_page_view'),
            controller: _pageController,
            itemCount: _pages.length,
            onPageChanged: _handlePageChanged,
            itemBuilder: (context, index) {
              return _OnboardingBackground(
                page: _pages[index],
                pageController: _pageController,
                pageIndex: index,
                videoController: _videoControllers[index],
              );
            },
          ),
          const _OnboardingScrim(),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(0, 14, 0, 0),
              child: Align(
                alignment: Alignment.bottomCenter,
                child: _BottomControlPanel(
                  page: page,
                  currentIndex: _currentIndex,
                  itemCount: _pages.length,
                  onBack: _goBack,
                  onNext: _goNext,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _OnboardingBackground extends StatelessWidget {
  const _OnboardingBackground({
    required this.page,
    required this.pageController,
    required this.pageIndex,
    required this.videoController,
  });

  final _OnboardingPageData page;
  final PageController pageController;
  final int pageIndex;
  final VideoPlayerController videoController;

  @override
  Widget build(BuildContext context) {
    return _AnimatedOnboardingBackground(
      page: page,
      pageController: pageController,
      pageIndex: pageIndex,
      videoController: videoController,
    );
  }
}

class _AnimatedOnboardingBackground extends StatefulWidget {
  const _AnimatedOnboardingBackground({
    required this.page,
    required this.pageController,
    required this.pageIndex,
    required this.videoController,
  });

  final _OnboardingPageData page;
  final PageController pageController;
  final int pageIndex;
  final VideoPlayerController videoController;

  @override
  State<_AnimatedOnboardingBackground> createState() =>
      _AnimatedOnboardingBackgroundState();
}

class _AnimatedOnboardingBackgroundState
    extends State<_AnimatedOnboardingBackground>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 10),
  )..repeat();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  double _currentPageValue() {
    if (!widget.pageController.hasClients) {
      return widget.pageIndex.toDouble();
    }

    return widget.pageController.page ?? widget.pageIndex.toDouble();
  }

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: const Color(0xFF051009),
      child: AnimatedBuilder(
        animation: Listenable.merge([_controller, widget.pageController]),
        builder: (context, child) {
          final motion = Curves.easeInOut.transform(_controller.value);
          final sine = math.sin(motion * math.pi * 2);
          final cosine = math.cos(motion * math.pi * 2);
          final pageDelta =
              (_currentPageValue() - widget.pageIndex).clamp(-1.2, 1.2);
          final reveal = (1 - pageDelta.abs()).clamp(0.0, 1.0);

          return Stack(
            fit: StackFit.expand,
            children: [
              Opacity(
                opacity: 0.5 + (reveal * 0.5),
                child: Transform.translate(
                  offset: Offset(
                    (-pageDelta * 76) + (sine * 12),
                    -18 + (cosine * 12),
                  ),
                  child: Transform.scale(
                    scale: 1.16 + (reveal * 0.08) + (motion * 0.05),
                    child: _FullscreenOnboardingMedia(
                      page: widget.page,
                      videoController: widget.videoController,
                    ),
                  ),
                ),
              ),
              _BackgroundColorWash(
                accentColor: widget.page.accentColor,
                secondaryAccentColor: widget.page.secondaryAccentColor,
              ),
              Positioned(
                top: 46 + (cosine * 8),
                left: -38 + (pageDelta * 18),
                child: _AmbientGlow(
                  size: 220,
                  color: widget.page.accentColor.withValues(alpha: 0.26),
                ),
              ),
              Positioned(
                right: -46 - (pageDelta * 12),
                top: 186 + (sine * 10),
                child: _AmbientGlow(
                  size: 190,
                  color: widget.page.secondaryAccentColor.withValues(
                    alpha: 0.18,
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _OnboardingPageData {
  const _OnboardingPageData({
    required this.title,
    required this.description,
    required this.videoAssetPath,
    required this.imageAssetPath,
    required this.imageAlignment,
    required this.badgeLabel,
    required this.accentColor,
    required this.secondaryAccentColor,
  });

  final String title;
  final String description;
  final String videoAssetPath;
  final String imageAssetPath;
  final Alignment imageAlignment;
  final String badgeLabel;
  final Color accentColor;
  final Color secondaryAccentColor;
}

class _FullscreenOnboardingMedia extends StatelessWidget {
  const _FullscreenOnboardingMedia({
    required this.page,
    required this.videoController,
  });

  final _OnboardingPageData page;
  final VideoPlayerController videoController;

  @override
  Widget build(BuildContext context) {
    if (!videoController.value.isInitialized) {
      return Image.asset(
        page.imageAssetPath,
        fit: BoxFit.cover,
        alignment: page.imageAlignment,
      );
    }

    final size = videoController.value.size;
    final width = size.width == 0 ? 1080.0 : size.width;
    final height = size.height == 0 ? 1920.0 : size.height;

    return SizedBox.expand(
      child: FittedBox(
        fit: BoxFit.cover,
        child: SizedBox(
          width: width,
          height: height,
          child: VideoPlayer(videoController),
        ),
      ),
    );
  }
}

class _BottomControlPanel extends StatelessWidget {
  const _BottomControlPanel({
    required this.page,
    required this.currentIndex,
    required this.itemCount,
    required this.onBack,
    required this.onNext,
  });

  final _OnboardingPageData page;
  final int currentIndex;
  final int itemCount;
  final Future<void> Function() onBack;
  final Future<void> Function() onNext;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(22, 88, 22, 18),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.transparent,
            Colors.black.withValues(alpha: 0.08),
            Colors.black.withValues(alpha: 0.28),
            Colors.black.withValues(alpha: 0.72),
          ],
          stops: const [0, 0.18, 0.48, 1],
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 500),
            switchInCurve: Curves.easeOutCubic,
            switchOutCurve: Curves.easeInCubic,
            transitionBuilder: (child, animation) {
              final offsetAnimation = Tween<Offset>(
                begin: const Offset(0.14, 0.1),
                end: Offset.zero,
              ).animate(animation);

              return FadeTransition(
                opacity: animation,
                child: SlideTransition(
                  position: offsetAnimation,
                  child: child,
                ),
              );
            },
            child: Column(
              key: ValueKey(currentIndex),
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _BottomMetaPill(
                  label: page.badgeLabel,
                  accentColor: page.accentColor,
                ),
                const SizedBox(height: 14),
                Text(
                  page.title,
                  key: const Key('onboarding_title'),
                  style: const TextStyle(
                    fontSize: 28,
                    height: 1.05,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                    letterSpacing: -0.9,
                  ),
                ),
                const SizedBox(height: 10),
                ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 300),
                  child: Text(
                    page.description,
                    style: TextStyle(
                      fontSize: 15.3,
                      height: 1.45,
                      fontWeight: FontWeight.w400,
                      color: Colors.white.withValues(alpha: 0.9),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 22),
          Row(
            children: [
              AppCircularIconButton(
                key: const Key('onboarding_back_button'),
                backgroundColor: Colors.white.withValues(alpha: 0.08),
                iconColor: Colors.white,
                icon: Icons.arrow_back_rounded,
                showShadow: false,
                onTap: () {
                  onBack();
                },
              ),
              const Spacer(),
              _PageIndicator(
                currentIndex: currentIndex,
                itemCount: itemCount,
                activeColor: page.accentColor,
              ),
              const Spacer(),
              AppCircularIconButton(
                key: const Key('onboarding_next_button'),
                backgroundColor: page.accentColor,
                iconColor: const Color(0xFF041008),
                icon: Icons.arrow_forward_rounded,
                onTap: () {
                  onNext();
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _BackgroundColorWash extends StatelessWidget {
  const _BackgroundColorWash({
    required this.accentColor,
    required this.secondaryAccentColor,
  });

  final Color accentColor;
  final Color secondaryAccentColor;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            accentColor.withValues(alpha: 0.18),
            secondaryAccentColor.withValues(alpha: 0.12),
            Colors.transparent,
            Colors.black.withValues(alpha: 0.28),
          ],
        ),
      ),
    );
  }
}

class _AmbientGlow extends StatelessWidget {
  const _AmbientGlow({required this.size, required this.color});

  final double size;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(
            colors: [color, color.withValues(alpha: 0)],
          ),
        ),
      ),
    );
  }
}

class _BottomMetaPill extends StatelessWidget {
  const _BottomMetaPill({
    required this.label,
    required this.accentColor,
  });

  final String label;
  final Color accentColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(
        color: accentColor.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: accentColor.withValues(alpha: 0.36)),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 10.8,
          fontWeight: FontWeight.w800,
          color: accentColor,
          letterSpacing: 0.45,
        ),
      ),
    );
  }
}

class _OnboardingScrim extends StatelessWidget {
  const _OnboardingScrim();

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.black.withValues(alpha: 0.16),
            Colors.black.withValues(alpha: 0.06),
            Colors.black.withValues(alpha: 0.28),
            Colors.black.withValues(alpha: 0.66),
            Colors.black.withValues(alpha: 0.9),
          ],
          stops: const [0, 0.18, 0.42, 0.68, 1],
        ),
      ),
    );
  }
}

class _PageIndicator extends StatelessWidget {
  const _PageIndicator({
    required this.currentIndex,
    required this.itemCount,
    required this.activeColor,
  });

  final int currentIndex;
  final int itemCount;
  final Color activeColor;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(itemCount, (index) {
        final isActive = index == currentIndex;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 280),
          curve: Curves.easeOutCubic,
          width: isActive ? 26 : 7,
          height: 7,
          margin: EdgeInsets.only(right: index == itemCount - 1 ? 0 : 7),
          decoration: BoxDecoration(
            color: isActive
                ? activeColor
                : Colors.white.withValues(alpha: 0.72),
            borderRadius: BorderRadius.circular(999),
            boxShadow: isActive
                ? [
                    BoxShadow(
                      color: activeColor.withValues(alpha: 0.55),
                      blurRadius: 14,
                    ),
                  ]
                : null,
          ),
        );
      }),
    );
  }
}
