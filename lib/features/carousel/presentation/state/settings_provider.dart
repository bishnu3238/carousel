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
  List<Wallpaper> _selectedLockScreenWallpapers = [];

  static const String _lockScreenEnabledKey = 'lock_screen_enabled';
  static const String _lockScreenWallpapersKey = 'lock_screen_wallpapers';


  SettingsProvider() {
    _wallpaperProvider = sl<WallpaperProvider>();
    _loadState();
  }

  bool get isCarouselEnabled => _isCarouselEnabled;
  List<Wallpaper> get selectedLockScreenWallpapers => _selectedLockScreenWallpapers;
  void setCarouselEnabled(bool value){
    _isCarouselEnabled = value;
    if(value){
      _selectedLockScreenWallpapers = _wallpaperProvider.wallpapers;
      _startLockScreenWallpaperChange();
    } else {
      _stopLockScreenWallpaperChange();
    }
    _saveState();
    notifyListeners();
  }
  void setSelectedLockScreenWallpapers(List<Wallpaper> wallpapers){
    _selectedLockScreenWallpapers = wallpapers;
    _saveState();
    notifyListeners();
  }
  Future<void> _saveState() async {
    await _sharedPreferences.setBool(_lockScreenEnabledKey, _isCarouselEnabled);
    final paths =  _selectedLockScreenWallpapers.map((e) => e.path).toList();
    dev.log('Settings Providers: Paths  $paths');
    await _sharedPreferences.setStringList(_lockScreenWallpapersKey, paths);


  }
  Future<void> _loadState() async {
    final isEnabled = _sharedPreferences.getBool(_lockScreenEnabledKey);
    if(isEnabled != null) {
      _isCarouselEnabled = isEnabled;
    }
    if(_isCarouselEnabled){
      _selectedLockScreenWallpapers = sl<WallpaperProvider>().wallpapers;
      _startLockScreenWallpaperChange();
    }else {
      final imagesPaths = _sharedPreferences.getStringList(_lockScreenWallpapersKey);
      if(imagesPaths != null){
        _selectedLockScreenWallpapers = imagesPaths.map((e) =>  Wallpaper(path: e)).toList();
      } else {
        _selectedLockScreenWallpapers = [];
      }
      _stopLockScreenWallpaperChange();

    }


  }

  Future<void> _startLockScreenWallpaperChange() async {
    try {
      await _platformService.startLockScreenWallpaperChange();
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