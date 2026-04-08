import 'package:car_wash/core/theme/app_button_colors.dart';
import 'package:car_wash/core/widgets/app_buttons.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class BookingLocationScreen extends StatefulWidget {
  const BookingLocationScreen({super.key, this.initialLocation});

  final String? initialLocation;

  @override
  State<BookingLocationScreen> createState() => _BookingLocationScreenState();
}

class _BookingLocationScreenState extends State<BookingLocationScreen> {
  static const _fullAddress = 'Ranya, Mousel, Street 423, Rd 1158B';

  late String _selectedLocation;

  @override
  void initState() {
    super.initState();
    _selectedLocation = widget.initialLocation?.trim().isNotEmpty == true
        ? widget.initialLocation!
        : _fullAddress;
  }

  void _saveSelection() {
    context.pop<String>(_selectedLocation);
  }

  @override
  Widget build(BuildContext context) {
    final isDefaultLocation = _selectedLocation == _fullAddress;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            const _BookingLocationAppBar(),
            const Divider(height: 1, thickness: 1, color: Color(0xFFE5E5E5)),
            Expanded(
              child: Stack(
                children: [
                  const Positioned.fill(child: _BookingMapSection()),
                  Align(
                    alignment: Alignment.bottomCenter,
                    child: _BookingLocationSheet(
                      isSelected: isDefaultLocation,
                      onTap: () {
                        setState(() {
                          _selectedLocation = _fullAddress;
                        });
                      },
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
                color: Colors.black,
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
                    fontWeight: FontWeight.w500,
                    color: Colors.black,
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

class _BookingMapSection extends StatelessWidget {
  const _BookingMapSection();

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned.fill(
          child: ColoredBox(
            color: const Color(0xFFF5F3EF),
            child: CustomPaint(
              painter: _BookingMapPainter(),
            ),
          ),
        ),
        const Positioned(
          left: 18,
          top: 122,
          child: _MapStreetLabel(
            label: '83rd St.',
            angle: -1.42,
          ),
        ),
        const Positioned(
          left: 106,
          top: 258,
          child: _MapStreetLabel(
            label: 'Kamrajar Sala',
            angle: -1.57,
          ),
        ),
        const Positioned(
          left: 158,
          top: 170,
          child: _MapStreetLabel(
            label: '88th Street',
            angle: -1.57,
          ),
        ),
        const Positioned(
          right: 24,
          top: 82,
          child: Text(
            '86th Street',
            style: TextStyle(
              fontSize: 12,
              color: Color(0xFF959595),
            ),
          ),
        ),
        const Positioned(
          right: 34,
          top: 136,
          child: Text(
            'Nirmala\nGirls HSS',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 12,
              height: 1.25,
              color: Color(0xFFB0AAA3),
            ),
          ),
        ),
        Positioned.fill(
          child: Center(
            child: Transform.translate(
              offset: const Offset(8, 12),
              child: const _MapPin(),
            ),
          ),
        ),
      ],
    );
  }
}

class _BookingLocationSheet extends StatelessWidget {
  const _BookingLocationSheet({
    required this.isSelected,
    required this.onTap,
    required this.onDone,
  });

  final bool isSelected;
  final VoidCallback onTap;
  final VoidCallback onDone;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(26)),
        boxShadow: [
          BoxShadow(
            color: Color(0x16000000),
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
              'Address',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 12),
            const Divider(height: 1, thickness: 1, color: Color(0xFFF0EFEC)),
            const SizedBox(height: 14),
            Material(
              color: isSelected
                  ? const Color(0xFFF7FCF8)
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(12),
              child: InkWell(
                key: const Key('booking_location_address_tile'),
                onTap: onTap,
                borderRadius: BorderRadius.circular(12),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 4,
                    vertical: 6,
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 24,
                        height: 24,
                        margin: const EdgeInsets.only(top: 2),
                        decoration: BoxDecoration(
                          color: const Color(0xFFE7F7EC),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.location_on_rounded,
                          size: 16,
                          color: AppButtonColors.primaryBackground,
                        ),
                      ),
                      const SizedBox(width: 10),
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Ranya, Mousel',
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF202020),
                              ),
                            ),
                            SizedBox(height: 4),
                            Text(
                              'Street 423, Rd 1158B',
                              style: TextStyle(
                                fontSize: 13,
                                color: Color(0xFF9B9B9B),
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (isSelected)
                        const Padding(
                          padding: EdgeInsets.only(top: 3),
                          child: Icon(
                            Icons.check_circle_rounded,
                            size: 18,
                            color: AppButtonColors.primaryBackground,
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 22),
            AppPrimaryButton(
              key: const Key('booking_location_done_button'),
              label: 'Done',
              onPressed: onDone,
              height: 48,
              borderRadius: 8,
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

class _MapStreetLabel extends StatelessWidget {
  const _MapStreetLabel({
    required this.label,
    required this.angle,
  });

  final String label;
  final double angle;

  @override
  Widget build(BuildContext context) {
    return Transform.rotate(
      angle: angle,
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 11,
          color: Color(0xFFAAA59E),
        ),
      ),
    );
  }
}

class _MapPin extends StatelessWidget {
  const _MapPin();

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        Container(
          width: 34,
          height: 34,
          decoration: BoxDecoration(
            color: Colors.black.withValues(alpha: 0.08),
            shape: BoxShape.circle,
          ),
        ),
        const Icon(
          Icons.location_on_rounded,
          size: 42,
          color: Color(0xFFF07B56),
        ),
        const Positioned(
          top: 10,
          child: CircleAvatar(
            radius: 5.5,
            backgroundColor: Colors.white,
          ),
        ),
      ],
    );
  }
}

class _BookingMapPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final blockPaint = Paint()..color = const Color(0xFFF0EDE7);
    final roadPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 12
      ..color = Colors.white.withValues(alpha: 0.92);

    final thinRoadPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 8
      ..color = Colors.white;

    final blocks = <RRect>[
      RRect.fromRectAndRadius(
        Rect.fromLTWH(14, 10, size.width * 0.34, 92),
        const Radius.circular(14),
      ),
      RRect.fromRectAndRadius(
        Rect.fromLTWH(size.width * 0.41, 10, size.width * 0.47, 76),
        const Radius.circular(12),
      ),
      RRect.fromRectAndRadius(
        Rect.fromLTWH(20, 126, size.width * 0.28, 74),
        const Radius.circular(12),
      ),
      RRect.fromRectAndRadius(
        Rect.fromLTWH(size.width * 0.35, 122, size.width * 0.23, 84),
        const Radius.circular(12),
      ),
      RRect.fromRectAndRadius(
        Rect.fromLTWH(size.width * 0.64, 104, size.width * 0.24, 120),
        const Radius.circular(14),
      ),
      RRect.fromRectAndRadius(
        Rect.fromLTWH(8, 246, size.width * 0.23, 76),
        const Radius.circular(12),
      ),
      RRect.fromRectAndRadius(
        Rect.fromLTWH(size.width * 0.29, 248, size.width * 0.18, 98),
        const Radius.circular(12),
      ),
      RRect.fromRectAndRadius(
        Rect.fromLTWH(size.width * 0.54, 246, size.width * 0.25, 78),
        const Radius.circular(12),
      ),
      RRect.fromRectAndRadius(
        Rect.fromLTWH(size.width * 0.82, 252, size.width * 0.18, 126),
        const Radius.circular(12),
      ),
    ];

    for (final block in blocks) {
      canvas.drawRRect(block, blockPaint);
    }

    final mainRoads = <Path>[
      Path()
        ..moveTo(0, 100)
        ..quadraticBezierTo(size.width * 0.18, 114, size.width * 0.26, 86)
        ..quadraticBezierTo(size.width * 0.4, 44, size.width * 0.58, 72)
        ..quadraticBezierTo(size.width * 0.8, 104, size.width, 92),
      Path()
        ..moveTo(size.width * 0.48, 0)
        ..quadraticBezierTo(size.width * 0.52, 120, size.width * 0.5, 220)
        ..quadraticBezierTo(size.width * 0.48, 320, size.width * 0.52, size.height),
      Path()
        ..moveTo(size.width * 0.2, 0)
        ..quadraticBezierTo(size.width * 0.22, 140, size.width * 0.32, 220)
        ..quadraticBezierTo(size.width * 0.42, 310, size.width * 0.4, size.height),
      Path()
        ..moveTo(size.width * 0.72, 80)
        ..quadraticBezierTo(size.width * 0.74, 210, size.width * 0.78, size.height),
      Path()
        ..moveTo(0, 228)
        ..quadraticBezierTo(size.width * 0.22, 214, size.width * 0.34, 234)
        ..quadraticBezierTo(size.width * 0.54, 266, size.width, 252),
    ];

    final sideRoads = <Path>[
      Path()
        ..moveTo(0, 160)
        ..quadraticBezierTo(size.width * 0.16, 182, size.width * 0.28, 172),
      Path()
        ..moveTo(size.width * 0.56, 118)
        ..quadraticBezierTo(size.width * 0.7, 118, size.width * 0.84, 104),
      Path()
        ..moveTo(size.width * 0.58, 178)
        ..quadraticBezierTo(size.width * 0.68, 178, size.width * 0.84, 166),
      Path()
        ..moveTo(size.width * 0.64, 324)
        ..quadraticBezierTo(size.width * 0.7, 298, size.width * 0.84, 302),
      Path()
        ..moveTo(size.width * 0.38, 284)
        ..quadraticBezierTo(size.width * 0.46, 304, size.width * 0.62, 298),
    ];

    for (final road in mainRoads) {
      canvas.drawPath(road, roadPaint);
    }

    for (final road in sideRoads) {
      canvas.drawPath(road, thinRoadPaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
