import 'package:flutter/material.dart';

import 'animations/bounce_snackbar.dart';
import 'animations/confetti_animation.dart';
import 'animations/firework_animation.dart';
import 'animations/slide_snackbar.dart';
import 'animations/wave_animation.dart';

class AnimatedSnackBar {
  static void _showOverlayAnimation(
      BuildContext context, Widget animationWidget, Duration duration) {
    final overlay = Overlay.of(context);
    final overlayEntry = OverlayEntry(builder: (context) => animationWidget);

    overlay.insert(overlayEntry);
    Future.delayed(duration, () => overlayEntry.remove());
  }

  static void showConfetti(BuildContext context, String message,
      {Duration duration = const Duration(seconds: 3)}) {
    _showOverlayAnimation(
        context, ConfettiAnimation(message: message, duration: duration), duration);
  }

  static void showFireworks(BuildContext context, String message,
      {Duration duration = const Duration(seconds: 3)}) {
    _showOverlayAnimation(
        context, FireworkAnimation(message: message, duration: duration), duration);
  }

  static void showWave(BuildContext context, String message,
      {Duration duration = const Duration(seconds: 3)}) {
    _showOverlayAnimation(
        context, WaveAnimation(message: message, duration: duration), duration);
  }

  static void showSlideIn(BuildContext context, String message,
      {Duration duration = const Duration(seconds: 3)}) {
    _showOverlayAnimation(
        context, SlideSnackbar(message: message, duration: duration), duration);
  }

  static void showBounce(BuildContext context, String message,
      {Duration duration = const Duration(seconds: 3)}) {
    _showOverlayAnimation(
        context, BounceSnackbar(message: message, duration: duration), duration);
  }
}
