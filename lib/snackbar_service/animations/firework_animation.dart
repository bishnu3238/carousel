import 'package:flutter/material.dart';

class FireworkAnimation extends StatelessWidget {
  final String message;
  final Duration duration;

  const FireworkAnimation({required this.message, required this.duration, Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: Align(
        alignment: Alignment.bottomCenter,
        child: Text(
          "🎆 $message 🎆",
          style: const TextStyle(
              fontSize: 24, fontWeight: FontWeight.bold, color: Colors.red),
        ),
      ),
    );
  }
}
