import 'dart:async';

import 'package:car_wash/core/router/app_navigation.dart';
import 'package:car_wash/core/theme/app_colors.dart';
import 'package:car_wash/features/authentication/data/auth_session.dart';
import 'package:flutter/material.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  Timer? _navigationTimer;

  @override
  void initState() {
    super.initState();
    _navigationTimer = Timer(const Duration(milliseconds: 2200), _goToHome);
  }

  void _goToHome() {
    if (!mounted) {
      return;
    }

    if (AuthSession.isAuthenticated) {
      context.goToHome();
      return;
    }

    context.goToOnboarding();
  }

  @override
  void dispose() {
    _navigationTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: TweenAnimationBuilder<double>(
            tween: Tween(begin: 0, end: 1),
            duration: const Duration(milliseconds: 1800),
            curve: Curves.easeOutCubic,
            builder: (context, value, child) {
              return Opacity(
                opacity: value.clamp(0.0, 1.0).toDouble(),
                child: Transform.scale(
                  scale: 0.94 + (value * 0.06),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const _LogoHalo(),
                      const SizedBox(height: 18),
                      const _LoadingBar(),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

class _LogoHalo extends StatelessWidget {
  const _LogoHalo();

  @override
  Widget build(BuildContext context) {
    return Container(
      key: const Key('splash_logo_badge'),
      width: 128,
      height: 128,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: const RadialGradient(
          colors: [Colors.white, AppColors.haloColor],
          radius: 0.9,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 24,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      alignment: Alignment.center,
      child: const Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _BrandMark(),
          SizedBox(height: 6),
          Text(
            'Lavego',
            style: TextStyle(
              fontSize: 20,
              height: 1,
              fontWeight: FontWeight.w700,
              color: AppColors.deepInk,
              letterSpacing: -0.4,
            ),
          ),
        ],
      ),
    );
  }
}

class _BrandMark extends StatelessWidget {
  const _BrandMark();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 80,
      height: 44,
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.center,
        children: const [
          Positioned(
            top: 0,
            left: 18,
            child: _LeafIcon(
              size: 18,
              rotation: -0.85,
              color: AppColors.brandGreen,
            ),
          ),
          Positioned(
            top: 2,
            left: 30,
            child: _LeafIcon(
              size: 20,
              rotation: -0.35,
              color: AppColors.brandGreenLight,
            ),
          ),
          Positioned(
            top: 4,
            left: 44,
            child: _LeafIcon(
              size: 18,
              rotation: 0.18,
              color: AppColors.brandGreen,
            ),
          ),
          Positioned(
            top: 12,
            left: 24,
            child: _LeafIcon(
              size: 16,
              rotation: -0.65,
              color: AppColors.brandGreenLight,
            ),
          ),
          Positioned(
            top: 13,
            left: 40,
            child: _LeafIcon(
              size: 16,
              rotation: -0.05,
              color: AppColors.brandGreen,
            ),
          ),
          Positioned(
            bottom: 0,
            child: Icon(
              Icons.directions_car_filled_rounded,
              size: 31,
              color: AppColors.deepInk,
            ),
          ),
          Positioned(right: 3, bottom: 9, child: _BubbleDots()),
        ],
      ),
    );
  }
}

class _LeafIcon extends StatelessWidget {
  const _LeafIcon({
    required this.size,
    required this.rotation,
    required this.color,
  });

  final double size;
  final double rotation;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Transform.rotate(
      angle: rotation,
      child: Icon(Icons.spa_rounded, size: size, color: color),
    );
  }
}

class _BubbleDots extends StatelessWidget {
  const _BubbleDots();

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: const [
        _BubbleDot(size: 4),
        SizedBox(width: 3),
        _BubbleDot(size: 6),
        SizedBox(width: 3),
        _BubbleDot(size: 4),
      ],
    );
  }
}

class _BubbleDot extends StatelessWidget {
  const _BubbleDot({required this.size});

  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: const BoxDecoration(
        color: AppColors.brandGreen,
        shape: BoxShape.circle,
      ),
    );
  }
}

class _LoadingBar extends StatefulWidget {
  const _LoadingBar();

  @override
  State<_LoadingBar> createState() => _LoadingBarState();
}

class _LoadingBarState extends State<_LoadingBar>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1100),
  )..repeat();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      key: const Key('splash_progress'),
      width: 92,
      height: 4,
      decoration: BoxDecoration(
        color: AppColors.trackColor,
        borderRadius: BorderRadius.circular(999),
      ),
      clipBehavior: Clip.antiAlias,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final segmentWidth = constraints.maxWidth * 0.48;
          final travelDistance = constraints.maxWidth + segmentWidth;

          return AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              final leftOffset =
                  (_controller.value * travelDistance) - segmentWidth;

              return Stack(
                children: [
                  Positioned(
                    left: leftOffset,
                    top: 0,
                    bottom: 0,
                    child: Container(
                      width: segmentWidth,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [
                            AppColors.brandGreen,
                            AppColors.brandGreenLight,
                          ],
                        ),
                        borderRadius: BorderRadius.circular(999),
                      ),
                    ),
                  ),
                ],
              );
            },
          );
        },
      ),
    );
  }
}
