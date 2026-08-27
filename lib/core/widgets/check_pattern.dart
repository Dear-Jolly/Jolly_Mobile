import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

class CheckPattern extends StatelessWidget {
  final Color lineColor;
  final double gridSpacing;
  final double strokeWidth;
  final int majorLineInterval;
  final double minorOpacity;

  const CheckPattern({
    super.key,
    this.lineColor = AppColors.paperLine,
    this.gridSpacing = 15.0,
    this.strokeWidth = 2.0,
    this.majorLineInterval = 4,
    this.minorOpacity = 0.5,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: IgnorePointer(
        child: CustomPaint(
          painter: _CheckPatternPainter(
            lineColor: lineColor,
            gridSpacing: gridSpacing,
            strokeWidth: strokeWidth,
            majorLineInterval: majorLineInterval,
            minorOpacity: minorOpacity,
          ),
        ),
      ),
    );
  }
}

class _CheckPatternPainter extends CustomPainter {
  final Color lineColor;
  final double gridSpacing;
  final double strokeWidth;
  final int majorLineInterval;
  final double minorOpacity;

  _CheckPatternPainter({
    required this.lineColor,
    required this.gridSpacing,
    required this.strokeWidth,
    required this.majorLineInterval,
    required this.minorOpacity,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final majorPaint = Paint()
      ..color = lineColor
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke;

    final minorPaint = Paint()
      ..color = lineColor.withValues(alpha: lineColor.a * minorOpacity)
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke;

    // Vertical lines
    final verticalCount = (size.width / gridSpacing).ceil() + 1;
    for (int i = 0; i < verticalCount; i++) {
      final x = i * gridSpacing;
      final paint = (i % majorLineInterval == 0) ? majorPaint : minorPaint;
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }

    // Horizontal lines
    final horizontalCount = (size.height / gridSpacing).ceil() + 1;
    for (int i = 0; i < horizontalCount; i++) {
      final y = i * gridSpacing;
      final paint = (i % majorLineInterval == 0) ? majorPaint : minorPaint;
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(_CheckPatternPainter oldDelegate) {
    return oldDelegate.lineColor != lineColor ||
        oldDelegate.gridSpacing != gridSpacing ||
        oldDelegate.strokeWidth != strokeWidth ||
        oldDelegate.majorLineInterval != majorLineInterval ||
        oldDelegate.minorOpacity != minorOpacity;
  }
}
