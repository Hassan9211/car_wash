import 'dart:async';
import 'dart:math' as math;

import 'package:car_wash/core/router/app_navigation.dart';
import 'package:car_wash/core/theme/app_colors.dart';
import 'package:car_wash/features/authentication/data/auth_session.dart';
import 'package:car_wash/features/authentication/model/app_user_role.dart';
import 'package:flutter/material.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  Timer? _navigationTimer;
  late final AnimationController _ambienceController = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 6),
  )..repeat(reverse: true);

  @override
  void initState() {
    super.initState();
    _navigationTimer = Timer(const Duration(milliseconds: 2200), _goToHome);
  }

  void _goToHome() {
    if (!mounted) return;

    if (AuthSession.isAuthenticated) {
      // Service provider who hasn't completed setup
      if (AuthSession.effectiveRole == AppUserRole.serviceProvider &&
          !AuthSession.isProviderSetupCompleted) {
        context.goToServiceProviderSetup();
        return;
      }
      context.goToHome();
      return;
    }

    context.goToOnboarding();
  }

  @override
  void dispose() {
    _navigationTimer?.cancel();
    _ambienceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF031008),
      body: AnimatedBuilder(
        animation: _ambienceController,
        builder: (context, child) {
          final motion = Curves.easeInOut.transform(_ambienceController.value);
          final drift = math.sin(motion * math.pi * 2);
          final glide = math.cos(motion * math.pi * 2);

          return Stack(
            fit: StackFit.expand,
            children: [
              _SplashBackdrop(motion: motion, drift: drift, glide: glide),
              _SplashScrim(motion: motion),
              SafeArea(
                child: TweenAnimationBuilder<double>(
                  tween: Tween(begin: 0, end: 1),
                  duration: const Duration(milliseconds: 1800),
                  curve: Curves.easeOutCubic,
                  builder: (context, value, child) {
                    return Opacity(
                      opacity: value.clamp(0.0, 1.0),
                      child: Transform.translate(
                        offset: Offset(0, 24 * (1 - value)),
                        child: Transform.scale(
                          scale: 0.97 + (value * 0.03),
                          child: _SplashBrandPanel(
                            drift: drift,
                            glide: glide,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _SplashBackdrop extends StatelessWidget {
  const _SplashBackdrop({
    required this.motion,
    required this.drift,
    required this.glide,
  });

  final double motion;
  final double drift;
  final double glide;

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                const Color(0xFF07170D),
                const Color(0xFF041008),
                const Color(0xFF020905),
              ],
              stops: const [0, 0.48, 1],
            ),
          ),
        ),
        Positioned(
          left: -70 + (drift * 10),
          top: -40,
          child: _GlowOrb(
            size: 220,
            color: AppColors.brandGreenLight.withValues(alpha: 0.24),
          ),
        ),
        Positioned(
          right: -90 + (glide * 14),
          bottom: 80,
          child: _GlowOrb(
            size: 260,
            color: const Color(0xFFF3C95E).withValues(alpha: 0.18),
          ),
        ),
        Positioned(
          left: 24,
          right: 24,
          bottom: 120 + (drift * 10),
          child: _GroundGlow(
            color: AppColors.brandGreen.withValues(alpha: 0.22),
          ),
        ),
      ],
    );
  }
}

class _SplashScrim extends StatelessWidget {
  const _SplashScrim({required this.motion});

  final double motion;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.black.withValues(alpha: 0.26),
            Colors.black.withValues(alpha: 0.18),
            const Color(0xFF07120B).withValues(alpha: 0.44 + (motion * 0.08)),
            const Color(0xFF041008),
          ],
          stops: const [0, 0.26, 0.62, 1],
        ),
      ),
    );
  }
}

class _SplashBrandPanel extends StatelessWidget {
  const _SplashBrandPanel({
    required this.drift,
    required this.glide,
  });

  final double drift;
  final double glide;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.white.withValues(alpha: 0.03),
            Colors.transparent,
            Colors.black.withValues(alpha: 0.12),
          ],
        ),
      ),
      child: Column(
        children: [
          const Spacer(),
          Transform.translate(
            offset: Offset(drift * 2, glide * -2),
            child: const _LogoHalo(),
          ),
          const SizedBox(height: 22),
          const Text(
            'Lavego',
            style: TextStyle(
              fontSize: 38,
              fontWeight: FontWeight.w800,
              letterSpacing: -1.2,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            'Premium car wash experience, polished before the app even opens.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14.2,
              height: 1.5,
              color: Colors.white.withValues(alpha: 0.84),
            ),
          ),
          const Spacer(),
          const _LoadingBar(),
          const SizedBox(height: 12),
          Text(
            'Preparing your shine',
            style: TextStyle(
              fontSize: 11.8,
              fontWeight: FontWeight.w600,
              color: Colors.white.withValues(alpha: 0.68),
              letterSpacing: 0.2,
            ),
          ),
          const SizedBox(height: 85),
        ],
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
      width: 150,
      height: 150,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: const RadialGradient(
          colors: [Colors.white, AppColors.haloColor],
          radius: 0.92,
        ),
        border: Border.all(color: Colors.white.withValues(alpha: 0.7)),
        boxShadow: [
          BoxShadow(
            color: AppColors.brandGreen.withValues(alpha: 0.18),
            blurRadius: 30,
            spreadRadius: 3,
          ),
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 28,
            offset: const Offset(0, 14),
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
              fontSize: 22,
              height: 1,
              fontWeight: FontWeight.w800,
              color: AppColors.deepInk,
              letterSpacing: -0.5,
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
      width: 84,
      height: 48,
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
            left: 45,
            child: _LeafIcon(
              size: 18,
              rotation: 0.18,
              color: AppColors.brandGreen,
            ),
          ),
          Positioned(
            top: 13,
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
              size: 32,
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
    duration: const Duration(milliseconds: 1200),
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
      width: 280,
      height: 6,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.18),
        borderRadius: BorderRadius.circular(999),
      ),
      clipBehavior: Clip.antiAlias,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final segmentWidth = constraints.maxWidth * 0.42;
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
                            Color(0xFFE6D36C),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(999),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.brandGreenLight.withValues(
                              alpha: 0.34,
                            ),
                            blurRadius: 10,
                          ),
                        ],
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

class _GlowOrb extends StatelessWidget {
  const _GlowOrb({required this.size, required this.color});

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

class _GroundGlow extends StatelessWidget {
  const _GroundGlow({required this.color});

  final Color color;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Container(
        height: 44,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(999),
          gradient: LinearGradient(
            colors: [
              color.withValues(alpha: 0),
              color,
              color.withValues(alpha: 0),
            ],
          ),
        ),
      ),
    );
  }
}
