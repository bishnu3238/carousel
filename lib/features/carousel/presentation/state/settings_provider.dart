import 'dart:convert';

import 'package:carousel/core/di/injection_container.dart';
import 'package:carousel/core/services/platform_service.dart';
import 'package:carousel/features/carousel/domain/entities/wallpaper.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:developer' as dev;

import '../../../../core/state/wallpaper_provider.dart';

class SettingsProvider extends ChangeNotifier {
  final SharedPreferences _sharedPreferences = sl();
  final PlatformService _platformService = sl();
  late WallpaperProvider _wallpaperProvider;

  bool _isCarouselEnabled = false;
  bool _isRandom = true; // Default to random

  List<Wallpaper> _selectedLockScreenWallpapers = [];

  static const String _lockScreenEnabledKey = 'lock_screen_enabled';
  static const String _lockScreenWallpapersKey = 'lock_screen_wallpapers';
  static const String _isRandomKey = 'lock_screen_random';

  SettingsProvider() {
    _wallpaperProvider = sl<WallpaperProvider>();
    _loadState();
  }

  bool get isRandom => _isRandom;
  bool get isCarouselEnabled => _isCarouselEnabled;
  List<Wallpaper> get selectedLockScreenWallpapers => _selectedLockScreenWallpapers;

  void setCarouselEnabled(bool value) {
    _isCarouselEnabled = value;
    if (value) {
      _selectedLockScreenWallpapers = _wallpaperProvider.wallpapers;
      _startLockScreenWallpaperChange();
    } else {
      _stopLockScreenWallpaperChange();
    }
    _saveState();
    notifyListeners();
  }

  void setIsRandom(bool value) {
    _isRandom = value;
    _saveState();
    notifyListeners();
  }

  void setSelectedLockScreenWallpapers(List<Wallpaper> wallpapers) {
    _selectedLockScreenWallpapers = wallpapers;
    _saveState();
    notifyListeners();
  }

  Future<void> _saveState() async {
    await _sharedPreferences.setBool(_isRandomKey, _isRandom);

    await _sharedPreferences.setBool(_lockScreenEnabledKey, _isCarouselEnabled);

    final pathsJson =
        jsonEncode(_selectedLockScreenWallpapers.map((e) => e.path).toList());
    await _sharedPreferences.setString(_lockScreenWallpapersKey, pathsJson);

    dev.log('Settings Providers: Paths $pathsJson');
  }

  Future<void> _loadState() async {
    _isRandom = _sharedPreferences.getBool(_isRandomKey) ?? true;

    final isEnabled = _sharedPreferences.getBool(_lockScreenEnabledKey);
    if (isEnabled != null) {
      _isCarouselEnabled = isEnabled;
    }
    if (_isCarouselEnabled) {
      _selectedLockScreenWallpapers = sl<WallpaperProvider>().wallpapers;
      _startLockScreenWallpaperChange();
    } else {
      final data = _sharedPreferences.getString(_lockScreenWallpapersKey);
      dev.log("$data ::  ${data.runtimeType}");
      final List<String> imagesPaths = jsonDecode(data!) as List<String>;
      dev.log("$imagesPaths ::  ${imagesPaths.runtimeType}");
      _selectedLockScreenWallpapers = imagesPaths.map((e) => Wallpaper(path: e)).toList();
      _stopLockScreenWallpaperChange();
    }
  }

  Future<void> _startLockScreenWallpaperChange() async {
    try {
      final isRandom = _sharedPreferences.getBool('lock_screen_random') ?? true;

      await _platformService.startLockScreenWallpaperChange(isRandom);
    } on Exception catch (e) {
      print("Error while starting lock screen wallpaper service $e");
    }
  }

  Future<void> _stopLockScreenWallpaperChange() async {
    try {
      await _platformService.stopLockScreenWallpaperChange();
    } on Exception catch (e) {
      print("Error while stopping lock screen wallpaper service $e");
    }
  }
}
