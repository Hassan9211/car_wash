import 'package:car_wash/core/location/app_location_details.dart';
import 'package:geocoding/geocoding.dart';

class AppLocationService {
  AppLocationService._();

  static Future<AppLocationDetails> buildLocationDetails({
    required double latitude,
    required double longitude,
    String? fallbackLabel,
  }) async {
    final label = await reverseGeocodeLabel(
      latitude,
      longitude,
      fallbackLabel: fallbackLabel,
    );

    return AppLocationDetails(
      latitude: latitude,
      longitude: longitude,
      label: label,
    );
  }

  static Future<String> reverseGeocodeLabel(
    double latitude,
    double longitude, {
    String? fallbackLabel,
  }) async {
    try {
      final placemarks = await placemarkFromCoordinates(latitude, longitude);

      if (placemarks.isEmpty) {
        return _fallbackLabel(latitude, longitude, fallbackLabel);
      }

      return formatPlacemark(
        placemarks.first,
        latitude: latitude,
        longitude: longitude,
        fallbackLabel: fallbackLabel,
      );
    } catch (_) {
      return _fallbackLabel(latitude, longitude, fallbackLabel);
    }
  }

  static String formatPlacemark(
    Placemark placemark, {
    required double latitude,
    required double longitude,
    String? fallbackLabel,
  }) {
    final parts = <String?>[
      placemark.street,
      placemark.subLocality,
      placemark.locality,
      placemark.administrativeArea,
      placemark.country,
    ]
        .map((item) => item?.trim())
        .whereType<String>()
        .where((item) => item.isNotEmpty)
        .toList(growable: false);

    if (parts.isEmpty) {
      return _fallbackLabel(latitude, longitude, fallbackLabel);
    }

    return parts.join(', ');
  }

  static String _fallbackLabel(
    double latitude,
    double longitude,
    String? fallbackLabel,
  ) {
    final trimmedFallback = fallbackLabel?.trim();
    if (trimmedFallback != null && trimmedFallback.isNotEmpty) {
      return trimmedFallback;
    }

    return 'Lat ${latitude.toStringAsFixed(4)}, Lng ${longitude.toStringAsFixed(4)}';
  }
}
