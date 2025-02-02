import 'dart:convert';
import 'dart:developer' as dev;

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../core/di/injection_container.dart';
import '../../../../core/services/platform_service.dart';
import '../../../../core/state/wallpaper_provider.dart';
import '../../../../core/util/app_constants.dart';
import '../../domain/entities/wallpaper.dart';

class SettingsProvider extends ChangeNotifier {
  final SharedPreferences _sharedPreferences = sl();
  final PlatformService _platformService = sl();
  late WallpaperProvider _wallpaperProvider;

  bool _isCarouselEnabled = false;
  bool _isRandom = true; // Default to random

  List<Wallpaper> _selectedLockScreenWallpapers = [];

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
    await _sharedPreferences.setBool(AppConstants.isRandomKey, _isRandom);

    await _sharedPreferences.setBool(
        AppConstants.lockScreenEnabledKey, _isCarouselEnabled);

    final pathsJson =
        jsonEncode(_selectedLockScreenWallpapers.map((e) => e.path).toList());
    await _sharedPreferences.setString(AppConstants.lockScreenWallpapersKey, pathsJson);

    dev.log('Settings Providers: Paths $pathsJson');
  }

  Future<void> _loadState() async {
    _isRandom = _sharedPreferences.getBool(AppConstants.isRandomKey) ?? true;

    final isEnabled = _sharedPreferences.getBool(AppConstants.lockScreenEnabledKey);
    if (isEnabled != null) {
      _isCarouselEnabled = isEnabled;
    }
    if (_isCarouselEnabled) {
      _selectedLockScreenWallpapers = sl<WallpaperProvider>().wallpapers;
      _startLockScreenWallpaperChange();
    } else {
      final data = _sharedPreferences.getString(AppConstants.lockScreenWallpapersKey);
      dev.log("$data ::  ${data.runtimeType}");
      final List imagesPaths = jsonDecode(data!);
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
