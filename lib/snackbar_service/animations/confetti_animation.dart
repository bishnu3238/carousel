import 'package:flutter/material.dart';

class ConfettiAnimation extends StatelessWidget {
  final String message;
  final Duration duration;

  const ConfettiAnimation({required this.message, required this.duration, Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: Align(
        alignment: Alignment.bottomCenter,
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
              color: Colors.purple, borderRadius: BorderRadius.circular(12)),
          child: Text(message, style: const TextStyle(color: Colors.white, fontSize: 16)),
        ),
      ),
    );
  }
}
