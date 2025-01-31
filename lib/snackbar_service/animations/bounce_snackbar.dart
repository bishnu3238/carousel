import 'package:flutter/material.dart';

class BounceSnackbar extends StatefulWidget {
  final String message;
  final Duration duration;

  const BounceSnackbar({required this.message, required this.duration, Key? key})
      : super(key: key);

  @override
  _BounceSnackbarState createState() => _BounceSnackbarState();
}

class _BounceSnackbarState extends State<BounceSnackbar>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _bounceAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    )..repeat(reverse: true);

    _bounceAnimation = Tween<double>(begin: 0, end: 10).animate(_controller);
  }

  @override
  void dispose() {
    _controller.stop(); // ✅ Stop the animation
    _controller.dispose(); // ✅ Dispose properly before super.dispose()
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      bottom: _bounceAnimation.value,
      left: 0,
      right: 0,
      child: Text(
        widget.message,
        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
      ),
    );
  }
}
