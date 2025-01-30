import 'package:flutter/material.dart';
import 'dart:math'as math;
class SparkyWidget extends StatefulWidget {
  final Offset start;
  final Offset end;
  final double size;
  final VoidCallback onComplete;

  const SparkyWidget({required this.start, required this.end, required this.size, required this.onComplete ,super.key});

  @override
  State<SparkyWidget> createState() => _SparkyWidgetState();
}

class _SparkyWidgetState extends State<SparkyWidget> with SingleTickerProviderStateMixin{
  late AnimationController controller;
  late Animation<double> rotationAnimation;
  late Animation<Offset> positionAnimation;

  @override
  void initState() {
    controller = AnimationController(duration: const Duration(seconds: 1), vsync: this);
    rotationAnimation = Tween<double>(begin: 0, end: 2 * math.pi).animate(controller);
    positionAnimation = Tween<Offset>(begin: widget.start, end: widget.end).animate(CurvedAnimation(
        parent: controller,
        curve: Curves.easeInOut
    ) );
    controller.forward();
    controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        widget.onComplete();
      }
    });
    super.initState();
  }
  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    return AnimatedPositioned(
        top: positionAnimation.value.dy ,
        left: positionAnimation.value.dx ,
        duration: const Duration(seconds: 1),
        child:  RotationTransition(
            turns: rotationAnimation,
            child: Icon(Icons.star, color: Colors.white.withOpacity(0.7), size: widget.size,))
    );
  }
}

