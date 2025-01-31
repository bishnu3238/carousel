import 'dart:developer' as dev;

import 'package:flutter/services.dart';

class PlatformService {
  PlatformService() {
    dev.log('Platform Service Initialized');
    requestBatteryOptimizationExemption();
  }

  static const platform = MethodChannel('com.example.carousel/wallpaper');

  Future<void> startLockScreenWallpaperChange(bool isRandom) async {
    dev.log('Starting Lock Screen Wallpaper Changes');
    try {
      await platform
          .invokeMethod('startLockScreenWallpaperChange', {'isRandom': isRandom});
    } catch (e) {
      dev.log('ERROR --> Start Lock Screen Wallpaper Changes: $e');
    }
  }

  Future<void> stopLockScreenWallpaperChange() async {
    dev.log('Stopping Lock Screen Wallpaper Changes');
    try {
      await platform.invokeMethod('stopLockScreenWallpaperChange');
    } catch (e) {
      dev.log('ERROR -->Stop Lock Screen Wallpaper Changes: $e');
    }
  }

  static Future<dynamic> requestBatteryOptimizationExemption() async {
    dev.log('Requesting Battery Optimization Exemption');
    try {
      final result = await platform.invokeMethod('requestBatteryOptimizationExemption');
      dev.log('Result: $result');
      return result;
    } on PlatformException catch (e) {
      dev.log('Error requesting exemption: ${e.message}');
    }
  }
}
