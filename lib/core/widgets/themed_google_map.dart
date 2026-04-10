import 'package:car_wash/core/services/app_maps_config_service.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class ThemedGoogleMap extends StatefulWidget {
  const ThemedGoogleMap({
    super.key,
    required this.initialCameraPosition,
    this.markers = const <Marker>{},
    this.polylines = const <Polyline>{},
    this.circles = const <Circle>{},
    this.myLocationEnabled = false,
    this.myLocationButtonEnabled = false,
    this.zoomControlsEnabled = false,
    this.mapToolbarEnabled = false,
    this.compassEnabled = false,
    this.scrollGesturesEnabled = true,
    this.zoomGesturesEnabled = true,
    this.rotateGesturesEnabled = true,
    this.tiltGesturesEnabled = true,
    this.style = _premiumDarkMapStyle,
    this.padding = EdgeInsets.zero,
    this.onMapCreated,
    this.onTap,
    this.onCameraMove,
    this.onCameraIdle,
  });

  final CameraPosition initialCameraPosition;
  final Set<Marker> markers;
  final Set<Polyline> polylines;
  final Set<Circle> circles;
  final bool myLocationEnabled;
  final bool myLocationButtonEnabled;
  final bool zoomControlsEnabled;
  final bool mapToolbarEnabled;
  final bool compassEnabled;
  final bool scrollGesturesEnabled;
  final bool zoomGesturesEnabled;
  final bool rotateGesturesEnabled;
  final bool tiltGesturesEnabled;
  final String? style;
  final EdgeInsets padding;
  final ValueChanged<GoogleMapController>? onMapCreated;
  final ValueChanged<LatLng>? onTap;
  final ValueChanged<CameraPosition>? onCameraMove;
  final VoidCallback? onCameraIdle;

  @override
  State<ThemedGoogleMap> createState() => _ThemedGoogleMapState();
}

class _ThemedGoogleMapState extends State<ThemedGoogleMap> {
  bool? _hasUsableApiKey;

  @override
  void initState() {
    super.initState();
    _loadMapsConfig();
  }

  Future<void> _loadMapsConfig() async {
    final hasUsableApiKey =
        await AppMapsConfigService.hasUsableGoogleMapsApiKey();
    if (!mounted) {
      return;
    }

    setState(() {
      _hasUsableApiKey = hasUsableApiKey;
    });
  }

  void _handleMapCreated(GoogleMapController controller) {
    widget.onMapCreated?.call(controller);
  }

  @override
  Widget build(BuildContext context) {
    if (_hasUsableApiKey == null) {
      return const ColoredBox(
        color: Color(0xFF0B1411),
        child: Center(
          child: SizedBox(
            width: 24,
            height: 24,
            child: CircularProgressIndicator(strokeWidth: 2.2),
          ),
        ),
      );
    }

    if (_hasUsableApiKey == false) {
      return const _GoogleMapsUnavailableState();
    }

    return GoogleMap(
      initialCameraPosition: widget.initialCameraPosition,
      markers: widget.markers,
      polylines: widget.polylines,
      circles: widget.circles,
      padding: widget.padding,
      myLocationEnabled: widget.myLocationEnabled,
      myLocationButtonEnabled: widget.myLocationButtonEnabled,
      zoomControlsEnabled: widget.zoomControlsEnabled,
      mapToolbarEnabled: widget.mapToolbarEnabled,
      compassEnabled: widget.compassEnabled,
      scrollGesturesEnabled: widget.scrollGesturesEnabled,
      zoomGesturesEnabled: widget.zoomGesturesEnabled,
      rotateGesturesEnabled: widget.rotateGesturesEnabled,
      tiltGesturesEnabled: widget.tiltGesturesEnabled,
      style: widget.style,
      onMapCreated: _handleMapCreated,
      onTap: widget.onTap,
      onCameraMove: widget.onCameraMove,
      onCameraIdle: widget.onCameraIdle,
    );
  }
}

class _GoogleMapsUnavailableState extends StatelessWidget {
  const _GoogleMapsUnavailableState();

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: const Color(0xFF0B1411),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 320),
          child: Container(
            margin: const EdgeInsets.all(20),
            padding: const EdgeInsets.fromLTRB(18, 18, 18, 18),
            decoration: BoxDecoration(
              color: const Color(0xFF12201B),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: const Color(0xFF274238)),
            ),
            child: const Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.map_outlined,
                  size: 34,
                  color: Color(0xFF8FD3AF),
                ),
                SizedBox(height: 12),
                Text(
                  'Google Map is not configured yet',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  'Add GOOGLE_MAPS_API_KEY to android/local.properties, then fully restart the app.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 12.8,
                    height: 1.45,
                    color: Color(0xFFC1D5CA),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

const String _premiumDarkMapStyle = '''
[
  {
    "elementType": "geometry",
    "stylers": [
      { "color": "#0f1815" }
    ]
  },
  {
    "elementType": "labels.icon",
    "stylers": [
      { "visibility": "off" }
    ]
  },
  {
    "elementType": "labels.text.fill",
    "stylers": [
      { "color": "#97b6a6" }
    ]
  },
  {
    "elementType": "labels.text.stroke",
    "stylers": [
      { "color": "#0f1815" }
    ]
  },
  {
    "featureType": "administrative",
    "elementType": "geometry.stroke",
    "stylers": [
      { "color": "#31483f" }
    ]
  },
  {
    "featureType": "landscape.man_made",
    "elementType": "geometry",
    "stylers": [
      { "color": "#15211d" }
    ]
  },
  {
    "featureType": "landscape.natural",
    "elementType": "geometry",
    "stylers": [
      { "color": "#13211c" }
    ]
  },
  {
    "featureType": "poi",
    "elementType": "geometry",
    "stylers": [
      { "color": "#162520" }
    ]
  },
  {
    "featureType": "poi.park",
    "elementType": "geometry",
    "stylers": [
      { "color": "#123223" }
    ]
  },
  {
    "featureType": "road",
    "elementType": "geometry",
    "stylers": [
      { "color": "#22362e" }
    ]
  },
  {
    "featureType": "road.arterial",
    "elementType": "geometry",
    "stylers": [
      { "color": "#294137" }
    ]
  },
  {
    "featureType": "road.highway",
    "elementType": "geometry",
    "stylers": [
      { "color": "#31714a" }
    ]
  },
  {
    "featureType": "road.highway",
    "elementType": "geometry.stroke",
    "stylers": [
      { "color": "#1c3f2c" }
    ]
  },
  {
    "featureType": "transit",
    "elementType": "geometry",
    "stylers": [
      { "color": "#1b2c26" }
    ]
  },
  {
    "featureType": "water",
    "elementType": "geometry",
    "stylers": [
      { "color": "#0e2d35" }
    ]
  }
]
''';
