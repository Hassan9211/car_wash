import 'dart:math' as math;
import 'dart:ui';

import 'package:car_wash/core/router/app_navigation.dart';
import 'package:car_wash/core/widgets/app_buttons.dart';
import 'package:flutter/material.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();

  static const List<_OnboardingPageData> _pages = [
    _OnboardingPageData(
      title: 'Welcome to LaveGo!',
      description: 'Book a car wash at your doorstep with just a few taps.',
      imageAssetPath:
          'assets/images/onboarding/pexels-bulat843-1243575272-28995187.jpg',
      imageAlignment: Alignment.center,
      demoAssetPaths: [
        'assets/images/onboarding/pexels-bulat843-1243575272-28995187.jpg',
        'assets/images/onboarding/pexels-karola-g-4870700.jpg',
        'assets/images/onboarding/pexels-bulat843-1243575272-31154194.jpg',
      ],
      badgeLabel: 'CINEMATIC WELCOME',
      reelTitle: 'Doorstep wash in motion',
      reelSubtitle: 'Luxe foam. Premium shine. Zero waiting.',
      metricValue: '24/7',
      metricLabel: 'Live booking energy',
      accentColor: Color(0xFF26C35B),
      secondaryAccentColor: Color(0xFFF4C14D),
    ),
    _OnboardingPageData(
      title: 'Book in Seconds',
      description:
          'Choose your service, time, and location. We\'ll handle the rest!',
      imageAssetPath: 'assets/images/onboarding/pexels-karola-g-4870700.jpg',
      imageAlignment: Alignment.centerLeft,
      demoAssetPaths: [
        'assets/images/onboarding/pexels-karola-g-4870700.jpg',
        'assets/images/onboarding/pexels-bulat843-1243575272-31154194.jpg',
        'assets/images/onboarding/pexels-bulat843-1243575272-28995187.jpg',
      ],
      badgeLabel: 'HYPER-FAST FLOW',
      reelTitle: 'Swipe. Pick. Confirm.',
      reelSubtitle: 'Three effortless steps feel like a polished product ad.',
      metricValue: '3 Taps',
      metricLabel: 'From browse to checkout',
      accentColor: Color(0xFF68D6E8),
      secondaryAccentColor: Color(0xFFECC65C),
    ),
    _OnboardingPageData(
      title: 'Track Your Washer.',
      description:
          'Follow your washer in real-time and know exactly when they\'ll arrive.',
      imageAssetPath:
          'assets/images/onboarding/pexels-bulat843-1243575272-31154194.jpg',
      imageAlignment: Alignment.center,
      demoAssetPaths: [
        'assets/images/onboarding/pexels-bulat843-1243575272-31154194.jpg',
        'assets/images/onboarding/pexels-bulat843-1243575272-28995187.jpg',
        'assets/images/onboarding/pexels-karola-g-4870700.jpg',
      ],
      badgeLabel: 'LIVE ARRIVAL DRAMA',
      reelTitle: 'Real-time washer tracking',
      reelSubtitle: 'A smooth arrival reel with every update in view.',
      metricValue: 'ETA',
      metricLabel: 'Story-like live status',
      accentColor: Color(0xFFFF8C5A),
      secondaryAccentColor: Color(0xFF3BC86C),
    ),
  ];

  int _currentIndex = 0;

  bool get _isLastPage => _currentIndex == _pages.length - 1;

  void _handlePageChanged(int index) {
    setState(() {
      _currentIndex = index;
    });
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
              );
            },
          ),
          const _OnboardingScrim(),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 18),
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
  });

  final _OnboardingPageData page;
  final PageController pageController;
  final int pageIndex;

  @override
  Widget build(BuildContext context) {
    return _AnimatedOnboardingBackground(
      page: page,
      pageController: pageController,
      pageIndex: pageIndex,
    );
  }
}

class _AnimatedOnboardingBackground extends StatefulWidget {
  const _AnimatedOnboardingBackground({
    required this.page,
    required this.pageController,
    required this.pageIndex,
  });

  final _OnboardingPageData page;
  final PageController pageController;
  final int pageIndex;

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
    final size = MediaQuery.sizeOf(context);

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
          final showcaseWidth = math.min(size.width * 0.78, 320.0);
          final showcaseHeight = showcaseWidth * 1.34;

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
                    child: Image.asset(
                      widget.page.imageAssetPath,
                      fit: BoxFit.cover,
                      alignment: widget.page.imageAlignment,
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
              Positioned.fill(
                child: Align(
                  alignment: const Alignment(0, -0.06),
                  child: Transform.translate(
                    offset: Offset(pageDelta * -34, cosine * 4),
                    child: Opacity(
                      opacity: 0.18 + (reveal * 0.42),
                      child: _ShowcaseDepthAura(
                        width: showcaseWidth,
                        height: showcaseHeight,
                        accentColor: widget.page.accentColor,
                        secondaryAccentColor: widget.page.secondaryAccentColor,
                        progress: motion,
                      ),
                    ),
                  ),
                ),
              ),
              Positioned.fill(
                child: Align(
                  alignment: const Alignment(0, -0.08),
                  child: Transform.translate(
                    offset: Offset(pageDelta * -54, sine * 6),
                    child: Transform.rotate(
                      angle: (-pageDelta * 0.055) + (cosine * 0.012),
                      child: _ShowcaseReel(
                        page: widget.page,
                        progress: motion,
                        reveal: reveal,
                        width: showcaseWidth,
                        height: showcaseHeight,
                      ),
                    ),
                  ),
                ),
              ),
              Positioned.fill(
                child: Align(
                  alignment: Alignment(
                    pageDelta * -0.03,
                    0.42 + (sine * 0.01),
                  ),
                  child: _GroundReflection(
                    width: showcaseWidth,
                    color: widget.page.accentColor,
                    secondaryColor: widget.page.secondaryAccentColor,
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
    required this.imageAssetPath,
    required this.imageAlignment,
    required this.demoAssetPaths,
    required this.badgeLabel,
    required this.reelTitle,
    required this.reelSubtitle,
    required this.metricValue,
    required this.metricLabel,
    required this.accentColor,
    required this.secondaryAccentColor,
  });

  final String title;
  final String description;
  final String imageAssetPath;
  final Alignment imageAlignment;
  final List<String> demoAssetPaths;
  final String badgeLabel;
  final String reelTitle;
  final String reelSubtitle;
  final String metricValue;
  final String metricLabel;
  final Color accentColor;
  final Color secondaryAccentColor;
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
    return ClipRRect(
      borderRadius: BorderRadius.circular(30),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 22, sigmaY: 22),
        child: Container(
          padding: const EdgeInsets.fromLTRB(18, 18, 18, 18),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(30),
            border: Border.all(color: Colors.white.withValues(alpha: 0.16)),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.white.withValues(alpha: 0.12),
                Colors.white.withValues(alpha: 0.04),
                Colors.black.withValues(alpha: 0.22),
              ],
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
                    backgroundColor: Colors.white.withValues(alpha: 0.14),
                    iconColor: Colors.white,
                    icon: Icons.arrow_back_rounded,
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
        ),
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

class _ShowcaseReel extends StatelessWidget {
  const _ShowcaseReel({
    required this.page,
    required this.progress,
    required this.reveal,
    required this.width,
    required this.height,
  });

  final _OnboardingPageData page;
  final double progress;
  final double reveal;
  final double width;
  final double height;

  @override
  Widget build(BuildContext context) {
    final frameProgress = progress * page.demoAssetPaths.length;
    final currentFrame = frameProgress.floor() % page.demoAssetPaths.length;
    final nextFrame = (currentFrame + 1) % page.demoAssetPaths.length;
    final frameT = frameProgress - frameProgress.floorToDouble();

    return Container(
      width: width,
      height: height,
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(34),
        border: Border.all(color: Colors.white.withValues(alpha: 0.18)),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white.withValues(alpha: 0.16),
            Colors.white.withValues(alpha: 0.05),
            Colors.black.withValues(alpha: 0.12),
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.28),
            blurRadius: 36,
            offset: const Offset(0, 24),
          ),
          BoxShadow(
            color: page.accentColor.withValues(alpha: 0.14),
            blurRadius: 44,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(26),
        child: Stack(
          fit: StackFit.expand,
          children: [
            for (var index = 0; index < page.demoAssetPaths.length; index++)
              _ShowcaseFrame(
                assetPath: page.demoAssetPaths[index],
                opacity: switch (index) {
                  final value when value == currentFrame => 1 - frameT,
                  final value when value == nextFrame => frameT,
                  _ => 0,
                },
                scale: index == nextFrame ? 1.1 : 1.04,
                horizontalShift: switch (index) {
                  final value when value == currentFrame => -10 * frameT,
                  final value when value == nextFrame => 10 * (1 - frameT),
                  _ => 0,
                },
                verticalShift: switch (index) {
                  final value when value == currentFrame => 8 * frameT,
                  final value when value == nextFrame => -8 * (1 - frameT),
                  _ => 0,
                },
              ),
            DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withValues(alpha: 0.04),
                    Colors.transparent,
                    Colors.black.withValues(alpha: 0.52),
                  ],
                ),
              ),
            ),
            Positioned.fill(
              child: IgnorePointer(
                child: Transform.translate(
                  offset: Offset((-width * 0.9) + (progress * width * 1.9), 0),
                  child: Transform.rotate(
                    angle: 0.22,
                    child: Container(
                      width: 70,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Colors.white.withValues(alpha: 0),
                            Colors.white.withValues(alpha: 0.2),
                            Colors.white.withValues(alpha: 0),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            Positioned(
              left: 14,
              top: 14,
              right: 14,
              child: Row(
                children: [
                  _GlassMicroPill(
                    label: page.badgeLabel,
                    accentColor: page.accentColor,
                  ),
                  const Spacer(),
                  Container(
                    width: 34,
                    height: 34,
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.28),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.18),
                      ),
                    ),
                    child: Icon(
                      Icons.play_arrow_rounded,
                      color: page.secondaryAccentColor,
                      size: 20,
                    ),
                  ),
                ],
              ),
            ),
            Positioned(
              left: 16,
              right: 16,
              bottom: 16,
              child: _ShowcaseFooter(
                page: page,
                progress: progress,
                reveal: reveal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ShowcaseFrame extends StatelessWidget {
  const _ShowcaseFrame({
    required this.assetPath,
    required this.opacity,
    required this.scale,
    required this.horizontalShift,
    required this.verticalShift,
  });

  final String assetPath;
  final double opacity;
  final double scale;
  final double horizontalShift;
  final double verticalShift;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Opacity(
        opacity: opacity.clamp(0.0, 1.0),
        child: Transform.translate(
          offset: Offset(horizontalShift, verticalShift),
          child: Transform.scale(
            scale: scale,
            child: Image.asset(assetPath, fit: BoxFit.cover),
          ),
        ),
      ),
    );
  }
}

class _ShowcaseFooter extends StatelessWidget {
  const _ShowcaseFooter({
    required this.page,
    required this.progress,
    required this.reveal,
  });

  final _OnboardingPageData page;
  final double progress;
  final double reveal;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(22),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
        child: Container(
          padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
          decoration: BoxDecoration(
            color: Colors.black.withValues(alpha: 0.34),
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: Colors.white.withValues(alpha: 0.14)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                page.reelTitle,
                style: const TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                  letterSpacing: -0.4,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                page.reelSubtitle,
                style: TextStyle(
                  fontSize: 12.6,
                  height: 1.4,
                  color: Colors.white.withValues(alpha: 0.84),
                ),
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: page.accentColor,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: page.accentColor.withValues(alpha: 0.42),
                          blurRadius: 10,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    page.metricValue,
                    style: TextStyle(
                      fontSize: 12.4,
                      fontWeight: FontWeight.w800,
                      color: page.secondaryAccentColor,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      page.metricLabel,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 11.4,
                        color: Colors.white.withValues(alpha: 0.72),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _PlaybackTimeline(
                      progress: progress,
                      accentColor: page.accentColor,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    '${(92 + (reveal * 7)).round()}%',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: page.secondaryAccentColor,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PlaybackTimeline extends StatelessWidget {
  const _PlaybackTimeline({
    required this.progress,
    required this.accentColor,
  });

  final double progress;
  final Color accentColor;

  @override
  Widget build(BuildContext context) {
    final sectionProgress = progress * 3;

    return Row(
      children: List.generate(3, (index) {
        final localProgress = (sectionProgress - index).clamp(0.0, 1.0);

        return Expanded(
          child: Container(
            height: 4,
            margin: EdgeInsets.only(right: index == 2 ? 0 : 6),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.16),
              borderRadius: BorderRadius.circular(999),
            ),
            child: Align(
              alignment: Alignment.centerLeft,
              child: FractionallySizedBox(
                widthFactor: localProgress,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: accentColor,
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: const SizedBox.expand(),
                ),
              ),
            ),
          ),
        );
      }),
    );
  }
}

class _ShowcaseDepthAura extends StatelessWidget {
  const _ShowcaseDepthAura({
    required this.width,
    required this.height,
    required this.accentColor,
    required this.secondaryAccentColor,
    required this.progress,
  });

  final double width;
  final double height;
  final Color accentColor;
  final Color secondaryAccentColor;
  final double progress;

  @override
  Widget build(BuildContext context) {
    final sweep = math.sin(progress * math.pi * 2);

    return IgnorePointer(
      child: SizedBox(
        width: width,
        height: height,
        child: Stack(
          alignment: Alignment.center,
          children: [
            Transform.translate(
              offset: Offset(-22 + (sweep * 6), 14),
              child: Transform.rotate(
                angle: -0.065,
                child: _GhostPane(
                  width: width * 0.96,
                  height: height * 0.92,
                  startColor: accentColor.withValues(alpha: 0.2),
                  endColor: Colors.white.withValues(alpha: 0.02),
                ),
              ),
            ),
            Transform.translate(
              offset: Offset(20 - (sweep * 5), -8),
              child: Transform.rotate(
                angle: 0.055,
                child: _GhostPane(
                  width: width * 0.92,
                  height: height * 0.88,
                  startColor: secondaryAccentColor.withValues(alpha: 0.18),
                  endColor: Colors.white.withValues(alpha: 0.01),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _GhostPane extends StatelessWidget {
  const _GhostPane({
    required this.width,
    required this.height,
    required this.startColor,
    required this.endColor,
  });

  final double width;
  final double height;
  final Color startColor;
  final Color endColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(32),
        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [startColor, endColor, Colors.black.withValues(alpha: 0.04)],
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.16),
            blurRadius: 36,
            offset: const Offset(0, 20),
          ),
        ],
      ),
    );
  }
}

class _GroundReflection extends StatelessWidget {
  const _GroundReflection({
    required this.width,
    required this.color,
    required this.secondaryColor,
  });

  final double width;
  final Color color;
  final Color secondaryColor;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Container(
        width: width * 0.82,
        height: width * 0.19,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(999),
          gradient: LinearGradient(
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
            colors: [
              color.withValues(alpha: 0),
              color.withValues(alpha: 0.18),
              secondaryColor.withValues(alpha: 0.16),
              secondaryColor.withValues(alpha: 0),
            ],
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.34),
              blurRadius: 42,
              spreadRadius: 2,
            ),
          ],
        ),
      ),
    );
  }
}

class _GlassMicroPill extends StatelessWidget {
  const _GlassMicroPill({
    required this.label,
    required this.accentColor,
  });

  final String label;
  final Color accentColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: Colors.white.withValues(alpha: 0.16)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              color: accentColor,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 6),
          Text(
            label,
            style: const TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
        ],
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
