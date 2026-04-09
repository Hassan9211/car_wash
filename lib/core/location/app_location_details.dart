class AppLocationDetails {
  const AppLocationDetails({
    required this.latitude,
    required this.longitude,
    required this.label,
  });

  final double latitude;
  final double longitude;
  final String label;

  AppLocationDetails copyWith({
    double? latitude,
    double? longitude,
    String? label,
  }) {
    return AppLocationDetails(
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      label: label ?? this.label,
    );
  }

  String get trimmedLabel => label.trim();

  String get fallbackLabel =>
      'Lat ${latitude.toStringAsFixed(4)}, Lng ${longitude.toStringAsFixed(4)}';

  String get displayLabel =>
      trimmedLabel.isEmpty ? fallbackLabel : trimmedLabel;
}
