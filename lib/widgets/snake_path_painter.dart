import 'package:flutter/material.dart';

class SnakePathPainter extends CustomPainter {
  final List<Offset> points; // index 0 is Day 30 (top), index 29 is Day 1 (bottom)
  final int completedIndex; // number of completed days

  SnakePathPainter({
    required this.points,
    required this.completedIndex,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (points.length < 2) return;

    final glowPaint = Paint()
      ..color = Colors.amber.withValues(alpha: 0.35)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 10
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);

    final pathPaint = Paint()
      ..color = const Color(0xFFD4AF37) // Dorado elegante
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.round;

    final lockedPathPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.15)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round;

    final int totalPoints = points.length;

    for (int i = 0; i < totalPoints - 1; i++) {
      final p1 = points[i];
      final p2 = points[i + 1];

      // i = 0 corresponds to segment between Day 30 and Day 29.
      // Day 1 is at index totalPoints - 1 (index 29).
      // Segment at index `i` connects Day (totalPoints - i) and Day (totalPoints - i - 1).
      final int dayNumberAtBottom = totalPoints - (i + 1);

      final controlPoint1 = Offset(p1.dx, p1.dy + (p2.dy - p1.dy) / 2);
      final controlPoint2 = Offset(p2.dx, p1.dy + (p2.dy - p1.dy) / 2);

      final segmentPath = Path();
      segmentPath.moveTo(p1.dx, p1.dy);
      segmentPath.cubicTo(
        controlPoint1.dx,
        controlPoint1.dy,
        controlPoint2.dx,
        controlPoint2.dy,
        p2.dx,
        p2.dy,
      );

      final bool isSegmentCompleted = dayNumberAtBottom < completedIndex;

      if (isSegmentCompleted) {
        canvas.drawPath(segmentPath, glowPaint);
        canvas.drawPath(segmentPath, pathPaint);
      } else {
        canvas.drawPath(segmentPath, lockedPathPaint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant SnakePathPainter oldDelegate) {
    return oldDelegate.points != points || oldDelegate.completedIndex != completedIndex;
  }
}
