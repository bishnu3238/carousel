import 'package:flutter/cupertino.dart';
import 'dart:math'as math;

class SparklePainter extends CustomPainter {
  final double animationValue;
  final double iconSize;
  final Icon sparkleIcon;

  SparklePainter(
      {required this.animationValue, required this.iconSize, required this.sparkleIcon});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final maxRadius = size.width / 2 * 1.2; // Adjust the max radius as needed.

    const numberOfSparks = 8;

    for (int i = 0; i < numberOfSparks; i++) {
      final angle = (2 * math.pi / numberOfSparks) * i;
      final currentRadius = maxRadius * animationValue;
      final sparkOffset = center +
          Offset(currentRadius * math.cos(angle), currentRadius * math.sin(angle));

      final iconPainter = TextPainter(textDirection: TextDirection.ltr);
      iconPainter.text = TextSpan(
          text: String.fromCharCode(sparkleIcon.icon!.codePoint),
          style: TextStyle(
              fontSize: sparkleIcon.size!,
              fontFamily: sparkleIcon.icon!.fontFamily,
              color: sparkleIcon.color));
      iconPainter.layout();

      final textOffset = Offset(
        sparkOffset.dx - (iconPainter.width / 2),
        sparkOffset.dy - (iconPainter.height / 2),
      );
      iconPainter.paint(canvas, textOffset);
      // canvas.drawCircle(sparkOffset, sparkSize * (1.2 - animationValue) , paint);
    }
  }

  @override
  bool shouldRepaint(covariant SparklePainter oldDelegate) {
    return oldDelegate.animationValue != animationValue;
  }
}





class SparklePainterRotation extends CustomPainter {
  final double animationValue;
  final double iconSize;
  final List<Icon> sparkleIcons; // List of star icons

  SparklePainterRotation({
    required this.animationValue,
    required this.iconSize,
    required this.sparkleIcons,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final maxRadius = size.width / 2 * 1.2; // Adjust the max radius as needed.
    final numberOfSparks = sparkleIcons.length;
    for (int i = 0; i < numberOfSparks; i++) {
      final angle = (2 * math.pi / numberOfSparks) * i;
      final currentRadius = maxRadius * animationValue;

      // Offset starts at bottom, moves upward
      final startY = size.height ; // Start from the bottom edge of cart icon
      const endY = 0; // Move to the top
      final animatedY =
          startY + (endY - startY) * animationValue; // Interpolate Y position

      final sparkOffset =
          center +
              Offset(
                  currentRadius * math.cos(angle), animatedY - size.height/2 );

      final iconPainter = TextPainter(textDirection: TextDirection.ltr);
      iconPainter.text = TextSpan(
          text: String.fromCharCode(sparkleIcons[i].icon!.codePoint),
          style: TextStyle(
              fontSize: sparkleIcons[i].size!,
              fontFamily: sparkleIcons[i].icon!.fontFamily,
              color: sparkleIcons[i].color));
      iconPainter.layout();


      final textOffset = Offset(
        sparkOffset.dx - (iconPainter.width / 2),
        sparkOffset.dy - (iconPainter.height / 2),
      );

      canvas.save(); // save the current canvas state before applying any transforms
      canvas.translate(sparkOffset.dx, sparkOffset.dy); // translate the canvas to current offset of star

      // rotation angle based on animation value
      double rotation = math.pi*2 * animationValue ; // full 360 degree rotation

      canvas.rotate(rotation); // rotate the canvas

      canvas.translate(-sparkOffset.dx, -sparkOffset.dy); // translate it to it's previous offset position before rotation

      iconPainter.paint(canvas, textOffset);

      canvas.restore(); // restore the canvas state so other stars are not affected with rotation.
    }
  }

  @override
  bool shouldRepaint(covariant SparklePainterRotation oldDelegate) {
    return oldDelegate.animationValue != animationValue;
  }
}