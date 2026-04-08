import 'package:car_wash/core/theme/app_button_colors.dart';
import 'package:car_wash/core/widgets/app_buttons.dart';
import 'package:car_wash/features/home/booking/model/booking_order_item.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class BookingTrackingScreen extends StatelessWidget {
  const BookingTrackingScreen({
    super.key,
    required this.order,
  });

  final BookingOrderItem order;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
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
                            fontWeight: FontWeight.w500,
                            color: Colors.black,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Divider(
              height: 1,
              thickness: 0.8,
              color: const Color(0xFFE9E6E3).withValues(alpha: 0.9),
            ),
            Expanded(
              child: Stack(
                children: [
                  Positioned.fill(
                    child: _TrackingMap(
                      providerName: order.serviceProviderName,
                    ),
                  ),
                  Positioned(
                    left: 14,
                    right: 14,
                    bottom: 16,
                    child: _TrackingBottomPanel(order: order),
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

class _TrackingMap extends StatelessWidget {
  const _TrackingMap({
    required this.providerName,
  });

  final String providerName;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: const Color(0xFFF4F4F2),
      child: Stack(
        children: [
          Positioned.fill(
            child: CustomPaint(
              painter: _MapBackgroundPainter(),
            ),
          ),
          Positioned.fill(
            child: CustomPaint(
              painter: _TrackingRoutePainter(),
            ),
          ),
          Positioned(
            left: 26,
            top: 108,
            child: Transform.rotate(
              angle: -0.18,
              child: Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: const Color(0xFFE8EDE8).withValues(alpha: 0.9),
                  shape: BoxShape.circle,
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x18000000),
                      blurRadius: 12,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                alignment: Alignment.center,
                child: Container(
                  width: 38,
                  height: 22,
                  decoration: BoxDecoration(
                    color: const Color(0xFF474747),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: const Icon(
                    Icons.directions_car_filled_rounded,
                    size: 18,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            right: 42,
            top: 126,
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFD8E8D9).withValues(alpha: 0.9),
                    shape: BoxShape.circle,
                  ),
                  child: Text(
                    providerName,
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF5C755D),
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                const Icon(
                  Icons.location_pin,
                  size: 34,
                  color: AppButtonColors.primaryBackground,
                ),
              ],
            ),
          ),
          const Positioned(
            left: 18,
            top: 150,
            child: RotatedBox(
              quarterTurns: 3,
              child: Text(
                'Cleveland Street',
                style: TextStyle(
                  fontSize: 10.5,
                  color: Color(0xFF8D8D8D),
                ),
              ),
            ),
          ),
          const Positioned(
            left: 74,
            top: 72,
            child: RotatedBox(
              quarterTurns: 3,
              child: Text(
                '93rd St.',
                style: TextStyle(
                  fontSize: 10.5,
                  color: Color(0xFF8D8D8D),
                ),
              ),
            ),
          ),
          const Positioned(
            left: 96,
            top: 188,
            child: RotatedBox(
              quarterTurns: 3,
              child: Text(
                'Balasubramanyam St.',
                style: TextStyle(
                  fontSize: 10.5,
                  color: Color(0xFF8D8D8D),
                ),
              ),
            ),
          ),
          const Positioned(
            right: 38,
            top: 94,
            child: Text(
              '86th Street',
              style: TextStyle(
                fontSize: 10.5,
                color: Color(0xFF8D8D8D),
              ),
            ),
          ),
          const Positioned(
            right: 30,
            bottom: 240,
            child: RotatedBox(
              quarterTurns: 1,
              child: Text(
                '18th Avenue',
                style: TextStyle(
                  fontSize: 10.5,
                  color: Color(0xFF8D8D8D),
                ),
              ),
            ),
          ),
          const Positioned(
            left: 152,
            top: 150,
            child: RotatedBox(
              quarterTurns: 3,
              child: Text(
                '88 Street',
                style: TextStyle(
                  fontSize: 10.5,
                  color: Color(0xFF8D8D8D),
                ),
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
  });

  final BookingOrderItem order;

  static const _labels = [
    'Order Placed',
    'Ready to pick',
    'Washed',
    'Delivered',
  ];

  @override
  Widget build(BuildContext context) {
    final activeStepCount = order.trackingStepCount;

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 18, 16, 18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: const [
          BoxShadow(
            color: Color(0x14000000),
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
                        : const Color(0xFFD8D8D8),
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
                      : const Color(0xFFD8D8D8),
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
                        color: Color(0xFF666666),
                      ),
                    ),
                  ),
                )
                .toList(growable: false),
          ),
          const SizedBox(height: 26),
          AppPrimaryButton(
            key: const Key('booking_tracking_done_button'),
            label: 'Done',
            onPressed: () => context.pop(),
            height: 46,
            borderRadius: 6,
            textStyle: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _MapBackgroundPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final backgroundPaint = Paint()
      ..color = const Color(0xFFEBEBE8)
      ..style = PaintingStyle.fill;
    final roadPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.88)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 27
      ..strokeCap = StrokeCap.round;
    final lanePaint = Paint()
      ..color = const Color(0xFFE2E2DE)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.3;

    canvas.drawRect(Offset.zero & size, backgroundPaint);

    final streetPaths = <Path>[
      Path()
        ..moveTo(size.width * 0.03, size.height * 0.10)
        ..lineTo(size.width * 0.35, size.height * 0.10)
        ..lineTo(size.width * 0.64, size.height * 0.12)
        ..lineTo(size.width * 0.97, size.height * 0.12),
      Path()
        ..moveTo(size.width * 0.08, size.height * 0.28)
        ..lineTo(size.width * 0.82, size.height * 0.28),
      Path()
        ..moveTo(size.width * 0.05, size.height * 0.47)
        ..lineTo(size.width * 0.78, size.height * 0.47),
      Path()
        ..moveTo(size.width * 0.12, size.height * 0.68)
        ..lineTo(size.width * 0.90, size.height * 0.68),
      Path()
        ..moveTo(size.width * 0.10, size.height * 0.88)
        ..lineTo(size.width * 0.94, size.height * 0.94),
      Path()
        ..moveTo(size.width * 0.18, size.height * 0.04)
        ..lineTo(size.width * 0.04, size.height * 0.22)
        ..lineTo(size.width * 0.20, size.height * 0.40)
        ..lineTo(size.width * 0.08, size.height * 0.76),
      Path()
        ..moveTo(size.width * 0.32, size.height * 0.04)
        ..lineTo(size.width * 0.26, size.height * 0.42)
        ..lineTo(size.width * 0.18, size.height * 0.86),
      Path()
        ..moveTo(size.width * 0.56, size.height * 0.0)
        ..lineTo(size.width * 0.50, size.height * 0.60)
        ..lineTo(size.width * 0.56, size.height * 0.82),
      Path()
        ..moveTo(size.width * 0.77, size.height * 0.06)
        ..lineTo(size.width * 0.75, size.height * 0.52)
        ..lineTo(size.width * 0.90, size.height * 0.78),
    ];

    for (final path in streetPaths) {
      canvas.drawPath(path, roadPaint);
      canvas.drawPath(path, lanePaint);
    }

    final blockPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.38)
      ..style = PaintingStyle.fill;

    final blocks = [
      Rect.fromLTWH(size.width * 0.58, size.height * 0.18, 76, 54),
      Rect.fromLTWH(size.width * 0.22, size.height * 0.54, 62, 48),
      Rect.fromLTWH(size.width * 0.63, size.height * 0.62, 80, 50),
      Rect.fromLTWH(size.width * 0.10, size.height * 0.30, 54, 64),
    ];

    for (final block in blocks) {
      canvas.drawRRect(
        RRect.fromRectAndRadius(block, const Radius.circular(4)),
        blockPaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _TrackingRoutePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final routeShadowPaint = Paint()
      ..color = const Color(0x330F7D32)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 6
      ..strokeCap = StrokeCap.round;
    final routePaint = Paint()
      ..color = AppButtonColors.primaryBackground
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round;

    final path = Path()
      ..moveTo(size.width * 0.18, size.height * 0.34)
      ..cubicTo(
        size.width * 0.29,
        size.height * 0.34,
        size.width * 0.39,
        size.height * 0.35,
        size.width * 0.38,
        size.height * 0.41,
      )
      ..cubicTo(
        size.width * 0.37,
        size.height * 0.46,
        size.width * 0.49,
        size.height * 0.44,
        size.width * 0.59,
        size.height * 0.44,
      )
      ..cubicTo(
        size.width * 0.67,
        size.height * 0.44,
        size.width * 0.68,
        size.height * 0.32,
        size.width * 0.79,
        size.height * 0.31,
      );

    canvas.drawPath(path, routeShadowPaint);
    canvas.drawPath(path, routePaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
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
      case BookingOrderStatus.completed:
        return 4;
      case BookingOrderStatus.cancelled:
        return 0;
    }
  }
}
