import 'dart:async';

import 'package:car_wash/core/theme/app_button_colors.dart';
import 'package:car_wash/core/theme/app_colors.dart';
import 'package:car_wash/core/widgets/app_buttons.dart';
import 'package:car_wash/core/widgets/themed_google_map.dart';
import 'package:car_wash/features/authentication/data/auth_session.dart';
import 'package:car_wash/features/authentication/model/app_user_role.dart';
import 'package:car_wash/features/home/booking/data/booking_orders_store.dart';
import 'package:car_wash/features/home/booking/model/booking_order_item.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:go_router/go_router.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class BookingTrackingScreen extends StatefulWidget {
  const BookingTrackingScreen({super.key, required this.order});

  final BookingOrderItem order;

  @override
  State<BookingTrackingScreen> createState() => _BookingTrackingScreenState();
}

class _BookingTrackingScreenState extends State<BookingTrackingScreen> {
  static const LatLng _fallbackLatLng = LatLng(40.7581, -73.9856);

  GoogleMapController? _mapController;
  StreamSubscription<Position>? _positionSubscription;
  LatLng? _liveDeviceLocation;

  @override
  void initState() {
    super.initState();
    _startLiveLocationTracking();
  }

  @override
  void dispose() {
    _positionSubscription?.cancel();
    super.dispose();
  }

  Future<void> _startLiveLocationTracking() async {
    try {
      final isEnabled = await Geolocator.isLocationServiceEnabled();
      if (!isEnabled) {
        return;
      }

      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        return;
      }

      final sessionLocation = AuthSession.currentLocationDetails;
      if (sessionLocation != null) {
        _liveDeviceLocation = LatLng(
          sessionLocation.latitude,
          sessionLocation.longitude,
        );
      }

      _positionSubscription =
          Geolocator.getPositionStream(
            locationSettings: const LocationSettings(
              accuracy: LocationAccuracy.high,
              distanceFilter: 10,
            ),
          ).listen((position) {
            if (!mounted) {
              return;
            }

            setState(() {
              _liveDeviceLocation = LatLng(
                position.latitude,
                position.longitude,
              );
            });
          });
    } catch (_) {
      // Keep the screen usable even if live location is unavailable.
    }
  }

  LatLng get _providerPosition {
    if (AuthSession.effectiveRole == AppUserRole.serviceProvider &&
        _liveDeviceLocation != null) {
      return _liveDeviceLocation!;
    }

    if (widget.order.hasProviderCoordinates) {
      return LatLng(
        widget.order.providerLatitude!,
        widget.order.providerLongitude!,
      );
    }

    return _fallbackLatLng;
  }

  LatLng get _customerPosition {
    if (widget.order.hasCustomerCoordinates) {
      return LatLng(
        widget.order.customerLatitude!,
        widget.order.customerLongitude!,
      );
    }

    final sessionLocation = AuthSession.currentLocationDetails;
    if (sessionLocation != null) {
      return LatLng(sessionLocation.latitude, sessionLocation.longitude);
    }

    return _fallbackLatLng;
  }

  String get _bookedLocationLabel {
    final savedAddress = widget.order.address.trim();
    if (savedAddress.isNotEmpty) {
      return savedAddress;
    }

    if (widget.order.hasCustomerCoordinates) {
      return 'Booked service location';
    }

    final sessionAddress = AuthSession.displayLocationLabel.trim();
    if (sessionAddress.isNotEmpty) {
      return sessionAddress;
    }

    return 'Booked service location';
  }

  Set<Marker> _buildMarkers() {
    return {
      Marker(
        markerId: const MarkerId('provider_marker'),
        position: _providerPosition,
        infoWindow: InfoWindow(
          title: widget.order.serviceProviderName,
          snippet: 'Service provider location',
        ),
      ),
      Marker(
        markerId: const MarkerId('customer_marker'),
        position: _customerPosition,
        infoWindow: InfoWindow(
          title: widget.order.customerName,
          snippet: _bookedLocationLabel,
        ),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure),
      ),
    };
  }

  Set<Polyline> _buildPolylines() {
    return {
      Polyline(
        polylineId: const PolylineId('booking_route'),
        points: [_providerPosition, _customerPosition],
        color: AppButtonColors.primaryBackground,
        width: 5,
        startCap: Cap.roundCap,
        endCap: Cap.roundCap,
      ),
    };
  }

  Future<void> _fitRouteBounds() async {
    final controller = _mapController;
    if (controller == null) {
      return;
    }

    final southWest = LatLng(
      _providerPosition.latitude < _customerPosition.latitude
          ? _providerPosition.latitude
          : _customerPosition.latitude,
      _providerPosition.longitude < _customerPosition.longitude
          ? _providerPosition.longitude
          : _customerPosition.longitude,
    );
    final northEast = LatLng(
      _providerPosition.latitude > _customerPosition.latitude
          ? _providerPosition.latitude
          : _customerPosition.latitude,
      _providerPosition.longitude > _customerPosition.longitude
          ? _providerPosition.longitude
          : _customerPosition.longitude,
    );

    await controller.animateCamera(
      CameraUpdate.newLatLngBounds(
        LatLngBounds(southwest: southWest, northeast: northEast),
        64,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final initialCameraTarget = LatLng(
      (_providerPosition.latitude + _customerPosition.latitude) / 2,
      (_providerPosition.longitude + _customerPosition.longitude) / 2,
    );

    return Scaffold(
      backgroundColor: AppColors.appBackground,
      body: SafeArea(
        child: Column(
          children: [
            SizedBox(
              height: 54,
              child: Stack(
                children: [
                  Positioned(
                    left: 8,
                    top: 0,
                    bottom: 0,
                    child: IconButton(
                      key: const Key('booking_tracking_back_button'),
                      onPressed: () => context.pop(),
                      icon: const Icon(
                        Icons.arrow_back_ios_new_rounded,
                        color: AppButtonColors.actionForeground,
                        size: 18,
                      ),
                    ),
                  ),
                  const Positioned.fill(
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 56),
                      child: Align(
                        alignment: Alignment.center,
                        child: Text(
                          'Tracking',
                          key: Key('booking_tracking_title'),
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
            ),
            Divider(height: 1, thickness: 0.8, color: AppColors.border),
            Expanded(
              child: Stack(
                children: [
                  Positioned.fill(
                    child: ThemedGoogleMap(
                      initialCameraPosition: CameraPosition(
                        target: initialCameraTarget,
                        zoom: 13.8,
                      ),
                      myLocationEnabled: true,
                      myLocationButtonEnabled: false,
                      markers: _buildMarkers(),
                      polylines: _buildPolylines(),
                      onMapCreated: (controller) {
                        _mapController = controller;
                        unawaited(_fitRouteBounds());
                      },
                    ),
                  ),
                  Positioned(
                    top: 14,
                    left: 14,
                    right: 14,
                    child: Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        _TopInfoChip(
                          icon: Icons.local_shipping_outlined,
                          label: widget.order.serviceProviderName,
                        ),
                        _TopInfoChip(
                          icon: Icons.location_on_outlined,
                          label: _bookedLocationLabel,
                        ),
                      ],
                    ),
                  ),
                  Positioned(
                    right: 14,
                    bottom: 238,
                    child: FloatingActionButton.small(
                      heroTag: 'tracking_recenter_button',
                      backgroundColor: AppColors.surfaceElevated,
                      foregroundColor: AppColors.textPrimary,
                      onPressed: _fitRouteBounds,
                      child: const Icon(Icons.my_location_rounded, size: 20),
                    ),
                  ),
                  Positioned(
                    left: 14,
                    right: 14,
                    bottom: 16,
                    child: ValueListenableBuilder<List<BookingOrderItem>>(
                      valueListenable: BookingOrdersStore.instance.listenable,
                      builder: (context, orders, _) {
                        final currentOrder = orders.firstWhere(
                          (o) => o.id == widget.order.id,
                          orElse: () => widget.order,
                        );
                        return _TrackingBottomPanel(
                          order: currentOrder,
                          bookedLocationLabel: _bookedLocationLabel,
                          liveDeviceLocation: _liveDeviceLocation,
                        );
                      },
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
}

class _TopInfoChip extends StatelessWidget {
  const _TopInfoChip({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(maxWidth: 250),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.surfaceElevated.withValues(alpha: 0.92),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.borderSoft),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: AppColors.brandGreen),
          const SizedBox(width: 8),
          Flexible(
            child: Text(
              label,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 12.2,
                fontWeight: FontWeight.w500,
                color: AppColors.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TrackingBottomPanel extends StatelessWidget {
  const _TrackingBottomPanel({
    required this.order,
    required this.bookedLocationLabel,
    this.liveDeviceLocation,
  });

  final BookingOrderItem order;
  final String bookedLocationLabel;
  final LatLng? liveDeviceLocation;

  static const _labels = [
    'Confirmed',
    'Arrived',
    'In Progress',
    'Completed',
  ];

  @override
  Widget build(BuildContext context) {
    final activeStepCount = order.trackingStepCount;

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 18, 16, 18),
      decoration: BoxDecoration(
        color: AppColors.surfaceElevated,
        borderRadius: BorderRadius.circular(24),
        boxShadow: const [
          BoxShadow(
            color: Color(0x18000000),
            blurRadius: 18,
            offset: Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: List.generate(_labels.length * 2 - 1, (index) {
              if (index.isOdd) {
                final lineIndex = index ~/ 2;
                final isActive = lineIndex < activeStepCount - 1;

                return Expanded(
                  child: Container(
                    height: 2.2,
                    margin: const EdgeInsets.symmetric(horizontal: 6),
                    color: isActive
                        ? AppButtonColors.primaryBackground
                        : const Color(0xFF496257),
                  ),
                );
              }

              final stepIndex = index ~/ 2;
              final isDone = stepIndex < activeStepCount;

              return Container(
                width: 18,
                height: 18,
                decoration: BoxDecoration(
                  color: isDone
                      ? AppButtonColors.primaryBackground
                      : const Color(0xFF496257),
                  shape: BoxShape.circle,
                ),
                child: isDone
                    ? const Icon(
                        Icons.check_rounded,
                        size: 13,
                        color: Colors.white,
                      )
                    : null,
              );
            }),
          ),
          const SizedBox(height: 12),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: _labels
                .map(
                  (label) => Expanded(
                    child: Text(
                      label,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 11,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ),
                )
                .toList(growable: false),
          ),
          const SizedBox(height: 14),
          if (bookedLocationLabel.trim().isNotEmpty)
            Text(
              bookedLocationLabel,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 12, color: AppColors.textMuted),
            ),
          const SizedBox(height: 20),
          _buildActionSection(context),
        ],
      ),
    );
  }

  Widget _buildActionSection(BuildContext context) {
    final role = AuthSession.effectiveRole;

    if (role == AppUserRole.serviceProvider) {
      if (order.status == BookingOrderStatus.accepted ||
          order.status == BookingOrderStatus.orderPlaced) {
        return AppPrimaryButton(
          label: 'Start Work',
          onPressed: () {
            BookingOrdersStore.instance.updateStatus(
              order.id,
              BookingOrderStatus.inProgress,
            );
          },
          height: 46,
          borderRadius: 6,
        );
      }

      if (order.status == BookingOrderStatus.inProgress) {
        return AppPrimaryButton(
          label: 'Finish Work (Upload Photo)',
          onPressed: () {
            _showProofUploadSheet(context);
          },
          height: 46,
          borderRadius: 6,
        );
      }

      if (order.status == BookingOrderStatus.awaitingApproval) {
        return Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: AppColors.surfaceHighlight,
            borderRadius: BorderRadius.circular(6),
          ),
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                width: 14,
                height: 14,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: AppColors.brandGreen,
                ),
              ),
              SizedBox(width: 12),
              Text(
                'Waiting for Customer Approval',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.brandGreen,
                ),
              ),
            ],
          ),
        );
      }
    } else {
      // Customer Role
      if (order.status == BookingOrderStatus.awaitingApproval) {
        return AppPrimaryButton(
          label: 'Review & Approve Work',
          backgroundColor: AppColors.brandGreen,
          onPressed: () {
            _showCustomerApprovalSheet(context);
          },
          height: 46,
          borderRadius: 6,
        );
      }
    }

    return AppPrimaryButton(
      key: const Key('booking_tracking_done_button'),
      label: 'Done',
      onPressed: () => context.pop(),
      height: 46,
      borderRadius: 6,
      textStyle: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w600,
      ),
    );
  }

  void _showProofUploadSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _ProviderProofUploadPanel(
        order: order,
        liveLocation: liveDeviceLocation,
      ),
    );
  }

  void _showCustomerApprovalSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _CustomerApprovalPanel(order: order),
    );
  }
}

class _ProviderProofUploadPanel extends StatefulWidget {
  const _ProviderProofUploadPanel({
    required this.order,
    this.liveLocation,
  });

  final BookingOrderItem order;
  final LatLng? liveLocation;

  @override
  State<_ProviderProofUploadPanel> createState() =>
      _ProviderProofUploadPanelState();
}

class _ProviderProofUploadPanelState extends State<_ProviderProofUploadPanel> {
  bool _isLocationVerified = false;
  final List<String> _selectedPhotos = [];
  bool _isSubmitting = false;

  Future<void> _verifyLocation() async {
    if (widget.liveLocation == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not detect your current location.')),
      );
      return;
    }

    final customerLat = widget.order.customerLatitude;
    final customerLng = widget.order.customerLongitude;

    if (customerLat == null || customerLng == null) {
      setState(() => _isLocationVerified = true);
      return;
    }

    final distance = Geolocator.distanceBetween(
      widget.liveLocation!.latitude,
      widget.liveLocation!.longitude,
      customerLat,
      customerLng,
    );

    if (distance <= 150) {
      setState(() => _isLocationVerified = true);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Location Verified! You are at the service site.'),
          backgroundColor: AppColors.brandGreen,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Location Error: You are ${distance.toInt()}m away. Please go to the customer address.',
          ),
          backgroundColor: AppColors.dangerSurface,
        ),
      );
    }
  }

  void _mockPickPhoto() {
    if (_selectedPhotos.length >= 3) return;
    setState(() {
      _selectedPhotos.add('https://images.unsplash.com/photo-1520340356584-f9917d1eea6f?w=400');
    });
  }

  Future<void> _submit() async {
    if (!_isLocationVerified) return;
    if (_selectedPhotos.isEmpty) return;

    setState(() => _isSubmitting = true);
    await BookingOrdersStore.instance.submitForApproval(
      widget.order.id,
      _selectedPhotos,
    );
    if (mounted) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Work submitted for customer approval.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.border,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'Complete Work',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Upload photos and verify your location to finish the booking.',
            style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
          ),
          const SizedBox(height: 24),
          const Text(
            'Proof of Work (Photos)',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              for (final photo in _selectedPhotos)
                Container(
                  width: 70,
                  height: 70,
                  margin: const EdgeInsets.only(right: 8),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    image: DecorationImage(
                      image: NetworkImage(photo),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              if (_selectedPhotos.length < 3)
                GestureDetector(
                  onTap: _mockPickPhoto,
                  child: Container(
                    width: 70,
                    height: 70,
                    decoration: BoxDecoration(
                      color: AppColors.surfaceElevated,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: const Icon(
                      Icons.add_a_photo_outlined,
                      color: AppColors.brandGreen,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 24),
          const Text(
            'Location Check',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          AppPrimaryButton(
            label: _isLocationVerified ? 'Location Verified ✓' : 'Verify My Location',
            backgroundColor: _isLocationVerified ? AppColors.successSurface : AppColors.surfaceHighlight,
            foregroundColor: _isLocationVerified ? AppColors.brandGreenLight : Colors.white,
            onPressed: _isLocationVerified ? null : _verifyLocation,
            height: 44,
          ),
          const SizedBox(height: 32),
          AppPrimaryButton(
            label: _isSubmitting ? 'Submitting...' : 'Done & Notify Customer',
            onPressed: (_isLocationVerified && _selectedPhotos.isNotEmpty && !_isSubmitting)
                ? _submit
                : null,
            height: 50,
          ),
        ],
      ),
    );
  }
}

class _CustomerApprovalPanel extends StatefulWidget {
  const _CustomerApprovalPanel({required this.order});

  final BookingOrderItem order;

  @override
  State<_CustomerApprovalPanel> createState() => _CustomerApprovalPanelState();
}

class _CustomerApprovalPanelState extends State<_CustomerApprovalPanel> {
  bool _isApproving = false;

  Future<void> _approve() async {
    setState(() => _isApproving = true);
    await BookingOrdersStore.instance.approveWork(widget.order.id);
    if (mounted) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Booking Completed! Payment released to provider.'),
          backgroundColor: AppColors.brandGreen,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.border,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'Review Proof of Work',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '${widget.order.serviceProviderName} has finished the work. Please check the photos below.',
            style: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
          ),
          const SizedBox(height: 24),
          if (widget.order.workPhotos.isNotEmpty)
            SizedBox(
              height: 120,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: widget.order.workPhotos.length,
                separatorBuilder: (_, __) => const SizedBox(width: 10),
                itemBuilder: (context, index) {
                  return Container(
                    width: 120,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      image: DecorationImage(
                        image: NetworkImage(widget.order.workPhotos[index]),
                        fit: BoxFit.cover,
                      ),
                    ),
                  );
                },
              ),
            )
          else
            const Text(
              'No photos available.',
              style: TextStyle(color: AppColors.textMuted),
            ),
          const SizedBox(height: 32),
          Row(
            children: [
              Expanded(
                child: AppPrimaryButton(
                  label: _isApproving ? 'Approving...' : 'Approve & Release Payment',
                  onPressed: _isApproving ? null : _approve,
                  height: 50,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Center(
            child: TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text(
                'I have an issue (Dispute)',
                style: TextStyle(color: AppColors.textMuted, fontSize: 13),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

extension on BookingOrderItem {
  int get trackingStepCount {
    switch (status) {
      case BookingOrderStatus.pending:
        return 1;
      case BookingOrderStatus.accepted:
      case BookingOrderStatus.orderPlaced:
        return 2;
      case BookingOrderStatus.inProgress:
        return 3;
      case BookingOrderStatus.awaitingApproval:
      case BookingOrderStatus.completed:
        return 4;
      case BookingOrderStatus.cancelled:
        return 0;
    }
  }
}
