import 'package:flutter/material.dart';

class PathPainter extends CustomPainter {
  final double startX;
  final double endX;
  final double height; // Distance to the next item center vertically
  final Color color;

  PathPainter({
    required this.startX,
    required this.endX,
    required this.height,
    required this.color,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 10.0
      ..strokeCap = StrokeCap.round;

    final path = Path();
    
    // We assume the painter is centered on the current item's center "visually" 
    // but the canvas size might be just the widget size.
    // Let's assume (0,0) is the center of the current button.
    
    path.moveTo(startX, 0);

    // Control points for a smooth S-curve
    // Vertical distance is 'height'.
    // We go from (startX, 0) to (endX, height).
    
    // Control point 1: go down 50% of height, keep x same as start
    final cp1 = Offset(startX, height * 0.5);
    // Control point 2: go down 50% of height, x is same as end
    final cp2 = Offset(endX, height * 0.5);
    // End point
    final end = Offset(endX, height);

    path.cubicTo(cp1.dx, cp1.dy, cp2.dx, cp2.dy, end.dx, end.dy);

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant PathPainter oldDelegate) {
    return oldDelegate.startX != startX ||
        oldDelegate.endX != endX ||
        oldDelegate.height != height ||
        oldDelegate.color != color;
  }
}
