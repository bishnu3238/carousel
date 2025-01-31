import 'package:flutter/material.dart';

class WaveAnimation extends StatelessWidget {
  final String message;
  final Duration duration;

  const WaveAnimation({required this.message, required this.duration, Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: Align(
        alignment: Alignment.bottomCenter,
        child: Text(
          "🌊 $message 🌊",
          style: const TextStyle(
              fontSize: 20, color: Colors.blue, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
