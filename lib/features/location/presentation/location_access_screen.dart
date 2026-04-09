import 'dart:async';

import 'package:car_wash/core/services/app_permission_service.dart';
import 'package:car_wash/core/services/app_location_service.dart';
import 'package:car_wash/core/router/app_navigation.dart';
import 'package:car_wash/core/theme/app_colors.dart';
import 'package:car_wash/core/widgets/app_buttons.dart';
import 'package:car_wash/features/authentication/data/auth_session.dart';
import 'package:car_wash/features/authentication/model/app_user_role.dart';
import 'package:car_wash/features/authentication/presentation/widgets/auth_shared_widgets.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';

class LocationAccessScreen extends StatefulWidget {
  const LocationAccessScreen({super.key});

  @override
  State<LocationAccessScreen> createState() => _LocationAccessScreenState();
}

class _LocationAccessScreenState extends State<LocationAccessScreen> {
  bool _isRequestingLocation = false;

  static const _logTag = 'LocationAccessScreen';

  void _goBack(BuildContext context) {
    context.goToVerificationComplete();
  }

  Future<void> _allowLocationAccess() async {
    if (_isRequestingLocation) {
      return;
    }

    _log('Allow location flow started');

    setState(() {
      _isRequestingLocation = true;
    });

    try {
      if (defaultTargetPlatform == TargetPlatform.android) {
        final permissionStatus =
            await AppPermissionService.requestLocationPermission();
        _log('Native Android permission result: $permissionStatus');

        if (!mounted) {
          return;
        }

        if (permissionStatus == AppPermissionStatus.denied) {
          _showMessage(
            'Location permission allow karein taake app aapki location le sake.',
          );
          return;
        }

        if (permissionStatus == AppPermissionStatus.permanentlyDenied) {
          await AppPermissionService.openAppSettings();
          if (!mounted) {
            return;
          }
          _showMessage('Location permission settings mein allow karein.');
          return;
        }
      } else {
        var permission = await Geolocator.checkPermission();
        if (permission == LocationPermission.denied) {
          permission = await Geolocator.requestPermission();
        }

        if (permission == LocationPermission.denied) {
          if (!mounted) {
            return;
          }
          _showMessage('Location permission is required to continue.');
          return;
        }

        if (permission == LocationPermission.deniedForever) {
          await Geolocator.openAppSettings();
          if (!mounted) {
            return;
          }
          _showMessage(
            'Location permission is permanently denied. Please allow it in app settings.',
          );
          return;
        }
      }

      final isServiceEnabled = await Geolocator.isLocationServiceEnabled();
      _log('Location service enabled: $isServiceEnabled');
      if (!isServiceEnabled) {
        await Geolocator.openLocationSettings();
        if (!mounted) {
          return;
        }
        _showMessage(
          'Location service off hai. GPS on karke dubara try karein.',
        );
        return;
      }

      final position = await _resolvePosition();
      _log('Resolved position: $position');
      if (position == null) {
        if (!mounted) {
          return;
        }
        _showMessage('Location mil nahi rahi. GPS on karke dubara try karein.');
        return;
      }

      final resolvedLocation = await AppLocationService.buildLocationDetails(
        latitude: position.latitude,
        longitude: position.longitude,
      );
      AuthSession.setCurrentLocationDetails(resolvedLocation);

      if (!mounted) {
        return;
      }

      if (AuthSession.effectiveRole == AppUserRole.serviceProvider) {
        context.goToServiceProviderSetup();
        return;
      }

      AuthSession.setAuthenticated(true);
      context.goToHome();
    } on TimeoutException {
      _log('Location request timed out');
      if (!mounted) {
        return;
      }
      _showMessage('Location request timeout ho gaya. Dubara try karein.');
    } on ActivityMissingException {
      _log('Activity missing while requesting location permission');
      if (!mounted) {
        return;
      }
      _showMessage(
        'Location dialog open nahi ho saka. App dobara khol kar try karein.',
      );
    } on PermissionDefinitionsNotFoundException {
      _log('Permission definitions missing in platform config');
      if (!mounted) {
        return;
      }
      _showMessage(
        'Location permission app build mein apply nahi hui. App reinstall karke try karein.',
      );
    } on PositionUpdateException {
      _log('Position update exception thrown');
      if (!mounted) {
        return;
      }
      _showMessage(
        'Location provider response nahi de raha. GPS on karke dubara try karein.',
      );
    } catch (error, stackTrace) {
      _log('Unhandled location error: $error');
      debugPrintStack(label: '$_logTag stack', stackTrace: stackTrace);
      if (!mounted) {
        return;
      }
      _showMessage('Unable to access your current location right now.');
    } finally {
      if (mounted) {
        setState(() {
          _isRequestingLocation = false;
        });
      }
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  Future<Position?> _resolvePosition() async {
    try {
      _log('Trying fused/current provider');
      return await Geolocator.getCurrentPosition(
        locationSettings: _locationSettings(forceLocationManager: false),
      );
    } on TimeoutException {
      rethrow;
    } on LocationServiceDisabledException {
      _log('Location service disabled while resolving position');
      return null;
    } on PermissionDeniedException {
      _log('Permission denied while resolving position');
      return null;
    } catch (error) {
      _log('Primary provider failed: $error');
      if (defaultTargetPlatform == TargetPlatform.android) {
        try {
          _log('Trying Android location manager fallback');
          return await Geolocator.getCurrentPosition(
            locationSettings: _locationSettings(forceLocationManager: true),
          );
        } on TimeoutException {
          rethrow;
        } on LocationServiceDisabledException {
          _log('Location manager fallback saw disabled service');
          return null;
        } on PermissionDeniedException {
          _log('Location manager fallback saw denied permission');
          return null;
        } catch (fallbackError) {
          _log('Location manager fallback failed: $fallbackError');
          // Fall back to cached location below.
        }
      }

      try {
        _log('Trying last known position fallback');
        return await Geolocator.getLastKnownPosition(
          forceAndroidLocationManager:
              defaultTargetPlatform == TargetPlatform.android,
        );
      } catch (lastKnownError) {
        _log('Last known position fallback failed: $lastKnownError');
        return null;
      }
    }
  }

  LocationSettings _locationSettings({required bool forceLocationManager}) {
    if (defaultTargetPlatform == TargetPlatform.android) {
      return AndroidSettings(
        accuracy: LocationAccuracy.high,
        forceLocationManager: forceLocationManager,
        timeLimit: const Duration(seconds: 15),
      );
    }

    return const LocationSettings(
      accuracy: LocationAccuracy.high,
      timeLimit: Duration(seconds: 15),
    );
  }

  void _log(String message) {
    debugPrint('$_logTag: $message');
  }

  @override
  Widget build(BuildContext context) {
    return AuthScreenShell(
      title: 'Location Access',
      onBack: () => _goBack(context),
      child: Padding(
        padding: const EdgeInsets.only(top: 88),
        child: Column(
          children: [
            const _LocationAccessIllustration(),
            const SizedBox(height: 26),
            const Text(
              'Find and book the best car washes near you',
              key: Key('location_access_title'),
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 18,
                height: 1.2,
                fontWeight: FontWeight.w500,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 14),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 18),
              child: Text(
                'By allowing location access you can search for Car washers near you and receive more accurate results',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 12.5,
                  height: 1.15,
                  color: AppColors.textSecondary,
                ),
              ),
            ),
            const SizedBox(height: 170),
            AppPrimaryButton(
              key: const Key('location_access_allow_button'),
              label: 'Allow Location Access',
              onPressed: _isRequestingLocation ? null : _allowLocationAccess,
              textStyle: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            if (_isRequestingLocation) ...[
              const SizedBox(height: 16),
              const CircularProgressIndicator(
                strokeWidth: 2.4,
                color: Color(0xFF0F7D32),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _LocationAccessIllustration extends StatelessWidget {
  const _LocationAccessIllustration();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 170,
      height: 130,
      child: Stack(
        alignment: Alignment.center,
        clipBehavior: Clip.none,
        children: [
          Positioned(
            bottom: 8,
            child: Transform(
              alignment: Alignment.center,
              transform: Matrix4.identity()
                ..rotateX(0.9)
                ..rotateZ(-0.08),
              child: CustomPaint(
                size: const Size(112, 72),
                painter: _MapCardPainter(),
              ),
            ),
          ),
          const Positioned(
            top: 4,
            child: Icon(
              Icons.location_on_rounded,
              size: 88,
              color: Color(0xFFE91E3C),
            ),
          ),
          const Positioned(
            top: 25,
            child: CircleAvatar(
              radius: 13,
              backgroundColor: AppColors.surface,
            ),
          ),
        ],
      ),
    );
  }
}

class _MapCardPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final shadowPaint = Paint()
      ..color = Colors.black.withValues(alpha: 0.08)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);

    final cardRect = RRect.fromRectAndRadius(
      Offset.zero & size,
      const Radius.circular(4),
    );

    canvas.drawRRect(cardRect.shift(const Offset(0, 3)), shadowPaint);

    final cardPaint = Paint()..color = AppColors.surface;
    canvas.drawRRect(cardRect, cardPaint);

    final borderPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1
      ..color = AppColors.border;
    canvas.drawRRect(cardRect, borderPaint);

    final greenPaint = Paint()..color = const Color(0xFFA2D748);
    canvas.drawRect(Rect.fromLTWH(9, 11, 20, 15), greenPaint);
    canvas.drawRect(Rect.fromLTWH(83, 12, 18, 17), greenPaint);
    canvas.drawRect(Rect.fromLTWH(42, 43, 24, 13), greenPaint);
    canvas.drawRect(Rect.fromLTWH(77, 42, 22, 12), greenPaint);

    final bluePaint = Paint()..color = const Color(0xFF6CC8FF);
    final bluePath = Path()
      ..moveTo(6, 46)
      ..quadraticBezierTo(24, 38, 36, 44)
      ..quadraticBezierTo(47, 50, 62, 42)
      ..quadraticBezierTo(80, 32, 106, 45);
    canvas.drawPath(
      bluePath,
      bluePaint
        ..style = PaintingStyle.stroke
        ..strokeWidth = 5,
    );

    final roadPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round;

    roadPaint.color = const Color(0xFFD8D8D8);
    canvas.drawLine(const Offset(8, 20), const Offset(101, 58), roadPaint);
    canvas.drawLine(const Offset(19, 58), const Offset(83, 8), roadPaint);
    canvas.drawLine(const Offset(10, 34), const Offset(100, 27), roadPaint);

    roadPaint
      ..color = const Color(0xFFF2C94C)
      ..strokeWidth = 2.4;
    canvas.drawLine(const Offset(18, 53), const Offset(90, 19), roadPaint);
    canvas.drawLine(const Offset(22, 26), const Offset(70, 59), roadPaint);

    final foldPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1
      ..color = const Color(0xFFE7E7E7);
    canvas.drawLine(
      Offset(size.width / 3, 2),
      Offset(size.width / 3, size.height - 2),
      foldPaint,
    );
    canvas.drawLine(
      Offset((size.width / 3) * 2, 2),
      Offset((size.width / 3) * 2, size.height - 2),
      foldPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
