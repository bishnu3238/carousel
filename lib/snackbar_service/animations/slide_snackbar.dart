import 'package:flutter/material.dart';

class SlideSnackbar extends StatefulWidget {
  final String message;
  final Duration duration;

  const SlideSnackbar({required this.message, required this.duration, Key? key})
      : super(key: key);

  @override
  _SlideSnackbarState createState() => _SlideSnackbarState();
}

class _SlideSnackbarState extends State<SlideSnackbar>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _controller =
        AnimationController(vsync: this, duration: const Duration(milliseconds: 500))
          ..forward();
    _slideAnimation =
        Tween<Offset>(begin: const Offset(0, 1), end: Offset.zero).animate(_controller);
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      bottom: 20,
      left: 0,
      right: 0,
      child: SlideTransition(
        position: _slideAnimation,
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
              color: Colors.black87, borderRadius: BorderRadius.circular(12)),
          child: Text(widget.message,
              style: const TextStyle(color: Colors.white, fontSize: 16)),
        ),
      ),
    );
  }
}
