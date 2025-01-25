import 'package:flutter/material.dart';

class WavePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint1 = Paint()
      ..color = Colors.blueAccent
      ..style = PaintingStyle.fill;

    final paint2 = Paint()
      ..color = Colors.lightBlueAccent
      ..style = PaintingStyle.fill;

    final paint3 = Paint()
      ..color = Colors.blue.withValues(alpha: 0.5)
      ..style = PaintingStyle.fill;

    final path1 = Path()
      ..moveTo(0, size.height * 0.8)
      ..quadraticBezierTo(
          size.width * 0.25, size.height * 0.6, size.width * 0.5, size.height * 0.8)
      ..quadraticBezierTo(size.width * 0.75, size.height, size.width, size.height * 0.8)
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();

    final path2 = Path()
      ..moveTo(0, size.height * 0.6)
      ..quadraticBezierTo(
          size.width * 0.25, size.height * 0.4, size.width * 0.5, size.height * 0.6)
      ..quadraticBezierTo(
          size.width * 0.75, size.height * 0.8, size.width, size.height * 0.6)
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();

    final path3 = Path()
      ..moveTo(0, size.height * 0.4)
      ..quadraticBezierTo(
          size.width * 0.25, size.height * 0.2, size.width * 0.5, size.height * 0.4)
      ..quadraticBezierTo(
          size.width * 0.75, size.height * 0.6, size.width, size.height * 0.4)
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();

    canvas.drawPath(path1, paint1);
    canvas.drawPath(path2, paint2);
    canvas.drawPath(path3, paint3);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}
