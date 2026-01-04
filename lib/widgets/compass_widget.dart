import 'dart:math';
import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

class CompassWidget extends StatelessWidget {
  final double? heading;
  final double size;

  const CompassWidget({
    super.key,
    this.heading,
    this.size = 250,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Outer ring with degree markings
          CustomPaint(
            size: Size(size, size),
            painter: CompassRingPainter(),
          ),

          // Rotating compass dial
          Transform.rotate(
            angle: -((heading ?? 0) * (pi / 180)),
            child: CustomPaint(
              size: Size(size * 0.85, size * 0.85),
              painter: CompassDialPainter(),
            ),
          ),

          // Center dot
          Container(
            width: 16,
            height: 16,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.accentOrange,
              boxShadow: [
                BoxShadow(
                  color: AppColors.accentOrange.withValues(alpha: 0.5),
                  blurRadius: 10,
                  spreadRadius: 2,
                ),
              ],
            ),
          ),

          // Fixed north indicator at top
          Positioned(
            top: 0,
            child: Container(
              width: 4,
              height: 20,
              decoration: BoxDecoration(
                color: AppColors.compassNorth,
                borderRadius: BorderRadius.circular(2),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.compassNorth.withValues(alpha: 0.5),
                    blurRadius: 8,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class CompassRingPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    // Outer ring
    final ringPaint = Paint()
      ..color = AppColors.compassRing.withValues(alpha: 0.3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    canvas.drawCircle(center, radius - 10, ringPaint);

    // Degree markings
    final tickPaint = Paint()
      ..color = AppColors.textSecondary.withValues(alpha: 0.5)
      ..strokeWidth = 1;

    final majorTickPaint = Paint()
      ..color = AppColors.textSecondary
      ..strokeWidth = 2;

    for (int i = 0; i < 360; i += 5) {
      final angle = i * (pi / 180) - pi / 2;
      final isMajor = i % 30 == 0;
      final tickLength = isMajor ? 15 : 8;

      final startRadius = radius - 10;
      final endRadius = startRadius - tickLength;

      final start = Offset(
        center.dx + startRadius * cos(angle),
        center.dy + startRadius * sin(angle),
      );

      final end = Offset(
        center.dx + endRadius * cos(angle),
        center.dy + endRadius * sin(angle),
      );

      canvas.drawLine(start, end, isMajor ? majorTickPaint : tickPaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class CompassDialPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    // Cardinal directions
    final textPainter = TextPainter(
      textDirection: TextDirection.ltr,
    );

    final directions = ['N', 'E', 'S', 'W'];
    final colors = [
      AppColors.compassNorth,
      AppColors.textSecondary,
      AppColors.compassSouth,
      AppColors.textSecondary,
    ];

    for (int i = 0; i < 4; i++) {
      final angle = i * (pi / 2) - pi / 2;
      final textRadius = radius - 35;

      final pos = Offset(
        center.dx + textRadius * cos(angle),
        center.dy + textRadius * sin(angle),
      );

      textPainter.text = TextSpan(
        text: directions[i],
        style: TextStyle(
          color: colors[i],
          fontSize: 24,
          fontWeight: FontWeight.bold,
        ),
      );

      textPainter.layout();
      textPainter.paint(
        canvas,
        Offset(
          pos.dx - textPainter.width / 2,
          pos.dy - textPainter.height / 2,
        ),
      );
    }

    // Compass needle
    final needlePath = Path();
    final needleLength = radius - 50;

    // North needle (orange)
    needlePath.moveTo(center.dx, center.dy - needleLength);
    needlePath.lineTo(center.dx - 8, center.dy);
    needlePath.lineTo(center.dx + 8, center.dy);
    needlePath.close();

    final northPaint = Paint()
      ..color = AppColors.compassNorth
      ..style = PaintingStyle.fill;

    canvas.drawPath(needlePath, northPaint);

    // South needle (grey)
    final southPath = Path();
    southPath.moveTo(center.dx, center.dy + needleLength);
    southPath.lineTo(center.dx - 8, center.dy);
    southPath.lineTo(center.dx + 8, center.dy);
    southPath.close();

    final southPaint = Paint()
      ..color = AppColors.compassSouth
      ..style = PaintingStyle.fill;

    canvas.drawPath(southPath, southPaint);

    // Needle border
    final borderPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    canvas.drawPath(needlePath, borderPaint);
    canvas.drawPath(southPath, borderPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
