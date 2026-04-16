import 'dart:async';

import 'package:car_wash/core/services/app_location_service.dart';
import 'package:car_wash/core/services/user_profile_service.dart';
import 'package:car_wash/features/authentication/data/auth_session.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';

/// Call this to fetch GPS location and update AuthSession.
/// Returns true on success, false on failure.
Future<bool> updateCurrentLocation(BuildContext context) async {
  try {
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    if (permission == LocationPermission.deniedForever ||
        permission == LocationPermission.denied) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Location permission denied.'),
            duration: Duration(seconds: 2),
          ),
        );
      }
      return false;
    }

    final position = await Geolocator.getCurrentPosition(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
      ),
    );

    final details = await AppLocationService.buildLocationDetails(
      latitude: position.latitude,
      longitude: position.longitude,
    );

    AuthSession.setCurrentLocationDetails(details);
    // Save updated location to Firestore
    unawaited(UserProfileService.saveProfile());
    return true;
  } catch (_) {
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Could not get location. Try again.'),
          duration: Duration(seconds: 2),
        ),
      );
    }
    return false;
  }
}
