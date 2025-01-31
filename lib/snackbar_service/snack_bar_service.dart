// library snackbar_animations;

import 'package:flutter/material.dart';

import 'animated_snackbar.dart';

class SnackBarService {
  static void showBasic(BuildContext context, String message, {Duration? duration}) {
    _showSnackBar(context, message,
        backgroundColor: Colors.grey[800], textColor: Colors.white, duration: duration);
  }

  static void showSuccess(BuildContext context, String message, {Duration? duration}) {
    _showSnackBar(context, message,
        icon: Icons.check_circle,
        backgroundColor: Colors.green,
        textColor: Colors.white,
        duration: duration);
  }

  static void showError(BuildContext context, String message, {Duration? duration}) {
    _showSnackBar(context, message,
        icon: Icons.error_outline,
        backgroundColor: Colors.red,
        textColor: Colors.white,
        duration: duration);
  }

  static void showInfo(BuildContext context, String message, {Duration? duration}) {
    _showSnackBar(context, message,
        backgroundColor: Colors.blue,
        textColor: Colors.white,
        icon: Icons.info_outline,
        duration: duration);
  }

  static void showWarning(BuildContext context, String message, {Duration? duration}) {
    _showSnackBar(context, message,
        backgroundColor: Colors.orange,
        textColor: Colors.black,
        icon: Icons.warning_amber_rounded,
        duration: duration);
  }

  static void showCelebration(BuildContext context, String message,
      {Duration? duration}) {
    AnimatedSnackBar.showConfetti(context, message,
        duration: duration ?? const Duration(seconds: 3));
  }

  static void showFireworks(BuildContext context, String message, {Duration? duration}) {
    AnimatedSnackBar.showFireworks(context, message,
        duration: duration ?? const Duration(seconds: 3));
  }

  static void showWave(BuildContext context, String message, {Duration? duration}) {
    AnimatedSnackBar.showWave(context, message,
        duration: duration ?? const Duration(seconds: 3));
  }

  static void showSlideIn(BuildContext context, String message, {Duration? duration}) {
    AnimatedSnackBar.showSlideIn(context, message,
        duration: duration ?? const Duration(seconds: 3));
  }

  static void showBounce(BuildContext context, String message, {Duration? duration}) {
    AnimatedSnackBar.showBounce(context, message,
        duration: duration ?? const Duration(seconds: 3));
  }

  static void _showSnackBar(BuildContext context, String message,
      {Color? backgroundColor, Color? textColor, IconData? icon, Duration? duration}) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    final snackBar = SnackBar(
      backgroundColor: backgroundColor,
      duration: duration ?? const Duration(seconds: 4),
      content: Row(
        children: [
          if (icon != null)
            Padding(
                padding: const EdgeInsets.only(right: 12),
                child: Icon(icon, color: textColor)),
          Expanded(
              child: Text(message,
                  style: TextStyle(color: textColor, fontWeight: FontWeight.w500))),
        ],
      ),
    );
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  static void dismissCurrent(BuildContext context) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
  }
}
