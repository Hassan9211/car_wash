import 'package:car_wash/core/location/app_location_details.dart';
import 'package:car_wash/core/services/app_location_service.dart';
import 'package:car_wash/core/theme/app_button_colors.dart';
import 'package:car_wash/core/theme/app_colors.dart';
import 'package:car_wash/core/widgets/app_buttons.dart';
import 'package:car_wash/core/widgets/themed_google_map.dart';
import 'package:car_wash/features/authentication/data/auth_session.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:go_router/go_router.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class BookingLocationScreen extends StatefulWidget {
  const BookingLocationScreen({super.key, this.initialLocation});

  final AppLocationDetails? initialLocation;

  @override
  State<BookingLocationScreen> createState() => _BookingLocationScreenState();
}

class _BookingLocationScreenState extends State<BookingLocationScreen> {
  static const AppLocationDetails _fallbackLocation = AppLocationDetails(
    latitude: 40.7581,
    longitude: -73.9856,
    label: 'Midtown, New York, USA',
  );

  GoogleMapController? _mapController;
  late AppLocationDetails _selectedLocation;
  bool _isResolvingAddress = false;
  bool _isRefreshingLocation = false;

  @override
  void initState() {
    super.initState();
    _selectedLocation =
        widget.initialLocation ??
        AuthSession.currentLocationDetails ??
        _fallbackLocation;
    _resolveInitialAddress();
  }

  Future<void> _resolveInitialAddress() async {
    if (_selectedLocation.trimmedLabel.isNotEmpty &&
        !_selectedLocation.trimmedLabel.startsWith('Lat ')) {
      return;
    }

    await _updateSelection(
      latitude: _selectedLocation.latitude,
      longitude: _selectedLocation.longitude,
      animateCamera: false,
    );
  }

  Future<void> _updateSelection({
    required double latitude,
    required double longitude,
    bool animateCamera = true,
  }) async {
    setState(() {
      _selectedLocation = _selectedLocation.copyWith(
        latitude: latitude,
        longitude: longitude,
      );
      _isResolvingAddress = true;
    });

    final resolvedLocation = await AppLocationService.buildLocationDetails(
      latitude: latitude,
      longitude: longitude,
      fallbackLabel: _selectedLocation.displayLabel,
    );

    if (!mounted) {
      return;
    }

    setState(() {
      _selectedLocation = resolvedLocation;
      _isResolvingAddress = false;
    });

    if (animateCamera) {
      await _mapController?.animateCamera(
        CameraUpdate.newLatLng(_toLatLng(resolvedLocation)),
      );
    }
  }

  Future<void> _useCurrentLocation() async {
    if (_isRefreshingLocation) {
      return;
    }

    setState(() {
      _isRefreshingLocation = true;
    });

    try {
      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: Duration(seconds: 15),
        ),
      );

      final resolvedLocation = await AppLocationService.buildLocationDetails(
        latitude: position.latitude,
        longitude: position.longitude,
        fallbackLabel: AuthSession.displayLocationLabel,
      );

      AuthSession.setCurrentLocationDetails(resolvedLocation);

      if (!mounted) {
        return;
      }

      setState(() {
        _selectedLocation = resolvedLocation;
      });

      await _mapController?.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(target: _toLatLng(resolvedLocation), zoom: 16),
        ),
      );
    } catch (_) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          const SnackBar(
            content: Text('Current location refresh nahi ho saki.'),
          ),
        );
    } finally {
      if (mounted) {
        setState(() {
          _isRefreshingLocation = false;
        });
      }
    }
  }

  void _saveSelection() {
    context.pop<AppLocationDetails>(_selectedLocation);
  }

  @override
  Widget build(BuildContext context) {
    final markerPosition = _toLatLng(_selectedLocation);

    return Scaffold(
      backgroundColor: AppColors.appBackground,
      body: SafeArea(
        child: Column(
          children: [
            const _BookingLocationAppBar(),
            Divider(height: 1, thickness: 1, color: AppColors.border),
            Expanded(
              child: Stack(
                children: [
                  Positioned.fill(
                    child: ThemedGoogleMap(
                      initialCameraPosition: CameraPosition(
                        target: markerPosition,
                        zoom: 15.5,
                      ),
                      myLocationEnabled: true,
                      myLocationButtonEnabled: false,
                      compassEnabled: false,
                      markers: {
                        Marker(
                          markerId: const MarkerId('booking_location'),
                          position: markerPosition,
                          infoWindow: InfoWindow(
                            title: 'Service location',
                            snippet: _selectedLocation.displayLabel,
                          ),
                        ),
                      },
                      circles: {
                        Circle(
                          circleId: const CircleId('booking_location_radius'),
                          center: markerPosition,
                          radius: 40,
                          fillColor: AppColors.brandGreen.withValues(
                            alpha: 0.18,
                          ),
                          strokeColor: AppColors.brandGreen,
                          strokeWidth: 1,
                        ),
                      },
                      onMapCreated: (controller) {
                        _mapController = controller;
                      },
                      onTap: (position) {
                        _updateSelection(
                          latitude: position.latitude,
                          longitude: position.longitude,
                        );
                      },
                    ),
                  ),
                  Positioned(
                    top: 14,
                    left: 14,
                    right: 14,
                    child: Row(
                      children: [
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 12,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.surfaceElevated.withValues(
                                alpha: 0.92,
                              ),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: AppColors.borderSoft),
                            ),
                            child: const Text(
                              'Tap on the map to set the exact service location',
                              style: TextStyle(
                                fontSize: 12.6,
                                fontWeight: FontWeight.w500,
                                color: AppColors.textPrimary,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        _CircleActionButton(
                          icon: Icons.my_location_rounded,
                          isLoading: _isRefreshingLocation,
                          onTap: _useCurrentLocation,
                        ),
                      ],
                    ),
                  ),
                  Align(
                    alignment: Alignment.bottomCenter,
                    child: _BookingLocationSheet(
                      selectedLocation: _selectedLocation,
                      isResolvingAddress: _isResolvingAddress,
                      onDone: _saveSelection,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  LatLng _toLatLng(AppLocationDetails location) {
    return LatLng(location.latitude, location.longitude);
  }
}

class _BookingLocationAppBar extends StatelessWidget {
  const _BookingLocationAppBar();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 56,
      child: Stack(
        children: [
          Positioned(
            left: 8,
            top: 0,
            bottom: 0,
            child: IconButton(
              key: const Key('booking_location_back_button'),
              onPressed: () => context.pop(),
              icon: const Icon(
                Icons.arrow_back_ios_new_rounded,
                size: 18,
                color: AppButtonColors.actionForeground,
              ),
            ),
          ),
          const Positioned.fill(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 56),
              child: Align(
                alignment: Alignment.center,
                child: Text(
                  'Location',
                  key: Key('booking_location_title'),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _BookingLocationSheet extends StatelessWidget {
  const _BookingLocationSheet({
    required this.selectedLocation,
    required this.isResolvingAddress,
    required this.onDone,
  });

  final AppLocationDetails selectedLocation;
  final bool isResolvingAddress;
  final VoidCallback onDone;

  @override
  Widget build(BuildContext context) {
    final addressParts = selectedLocation.displayLabel
        .split(',')
        .map((item) => item.trim())
        .where((item) => item.isNotEmpty)
        .toList(growable: false);
    final title = addressParts.isEmpty
        ? 'Selected location'
        : addressParts.first;
    final subtitle = addressParts.length > 1
        ? addressParts.skip(1).join(', ')
        : 'Lat ${selectedLocation.latitude.toStringAsFixed(4)}, Lng ${selectedLocation.longitude.toStringAsFixed(4)}';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
      decoration: const BoxDecoration(
        color: AppColors.surfaceElevated,
        borderRadius: BorderRadius.vertical(top: Radius.circular(26)),
        boxShadow: [
          BoxShadow(
            color: Color(0x28000000),
            blurRadius: 22,
            offset: Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Exact Address',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 12),
            Divider(height: 1, thickness: 1, color: AppColors.borderSoft),
            const SizedBox(height: 14),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.surfaceMuted,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.border),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      color: AppColors.brandGreen.withValues(alpha: 0.18),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Icon(
                      Icons.location_on_rounded,
                      size: 18,
                      color: AppColors.brandGreen,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 5),
                        Text(
                          subtitle,
                          style: const TextStyle(
                            fontSize: 13,
                            height: 1.35,
                            color: AppColors.textSecondary,
                          ),
                        ),
                        if (isResolvingAddress) ...[
                          const SizedBox(height: 8),
                          const Row(
                            children: [
                              SizedBox(
                                width: 14,
                                height: 14,
                                child: CircularProgressIndicator(
                                  strokeWidth: 1.8,
                                  color: AppColors.brandGreen,
                                ),
                              ),
                              SizedBox(width: 8),
                              Text(
                                'Resolving address...',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: AppColors.textMuted,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 22),
            AppPrimaryButton(
              key: const Key('booking_location_done_button'),
              label: 'Done',
              onPressed: onDone,
              height: 48,
              borderRadius: 10,
              textStyle: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CircleActionButton extends StatelessWidget {
  const _CircleActionButton({
    required this.icon,
    required this.isLoading,
    required this.onTap,
  });

  final IconData icon;
  final bool isLoading;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surfaceElevated.withValues(alpha: 0.94),
      shape: const CircleBorder(),
      child: InkWell(
        onTap: isLoading ? null : onTap,
        customBorder: const CircleBorder(),
        child: SizedBox(
          width: 48,
          height: 48,
          child: Center(
            child: isLoading
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: AppColors.brandGreen,
                    ),
                  )
                : Icon(icon, size: 20, color: AppColors.textPrimary),
          ),
        ),
      ),
    );
  }
}
