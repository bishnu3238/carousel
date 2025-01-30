import 'package:flutter/material.dart';

class OverlappingMirrorPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..style = PaintingStyle.fill
      ..isAntiAlias = true;

    // Gradient background for the canvas
    final Rect backgroundRect = Rect.fromLTWH(0, 0, size.width, size.height);
    paint.shader = const LinearGradient(
      colors: [
        Colors.blueAccent,
        Colors.lightBlue,
        Colors.blue,
      ],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ).createShader(backgroundRect);
    canvas.drawRect(backgroundRect, paint);

    final double rectWidth = size.width / 3; // Small individual mirror width
    final double rectHeight = size.height / 2; // Small individual mirror height
    final double overlapOffset = 12.0; // Overlap between mirrors

    final List<Color> colors = [
      Colors.cyanAccent.withOpacity(0.8),
      Colors.lightBlueAccent.withOpacity(0.6),
      Colors.blue.withOpacity(0.4),
    ];

    // Draw overlapping rectangles from right to left
    for (int i = 0; i < 3; i++) {
      final double xOffset = size.width - (i + 1) * (rectWidth - overlapOffset);
      final double yOffset = (size.height - rectHeight) / 2; // Center vertically

      final Rect rect = Rect.fromLTWH(
        xOffset,
        yOffset,
        rectWidth,
        rectHeight,
      );

      paint.shader = LinearGradient(
        colors: [
          colors[i],
          Colors.white.withOpacity(0.3),
        ],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ).createShader(rect);

      // Add shadow for each rectangle
      canvas.drawShadow(
        Path()..addRect(rect),
        Colors.black.withOpacity(0.3),
        4.0,
        true,
      );

      // Draw the rectangle
      canvas.drawRect(rect, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
