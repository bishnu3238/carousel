import 'package:flutter/material.dart';

import '../di/injection_container.dart';
import '../domain/entities/wallpaper.dart';
import '../domain/usecases/get_wallpaper_usecase.dart';
import '../domain/usecases/wallpaper_usecase.dart';

class WallpaperProvider extends ChangeNotifier {
  final WallpaperUseCase wallpaperUseCase = sl();
  final GetWallpaperUseCase getWallpapersUseCase = sl();

  List<Wallpaper> _wallpapers = [];
  int _currentWallpaperIndex = 0;
  bool _isLoading = false;

  WallpaperProvider() {
    _loadWallpapers();
  }

  List<Wallpaper> get wallpapers => _wallpapers;

  int get currentWallpaperIndex => _currentWallpaperIndex;

  bool get isLoading => _isLoading;

  void setWallpapers(List<Wallpaper> wallpapers) {
    _wallpapers = wallpapers;
    notifyListeners();
  }

  void addWallpaper(Wallpaper wallpaper) {
    _wallpapers.add(wallpaper);
    notifyListeners();
  }

  void removeWallpaper(Wallpaper wallpaper) {
    _wallpapers.remove(wallpaper);
    notifyListeners();
  }

  void setCurrentWallpaperIndex(int index) {
    _currentWallpaperIndex = index;
    notifyListeners();
  }

  Future<void> _loadWallpapers() async {
    _isLoading = true;
    notifyListeners();

    final result = await getWallpapersUseCase.execute();
    // final result = await wallpapersUseCase.execute();
    result.fold((failure) {}, (wallpapers) {
      _wallpapers = wallpapers;
      notifyListeners();
    });
    _isLoading = false;
    notifyListeners();
  }

  Future<bool> deleteWallpaper(Wallpaper wallpaper) async {
    final result = await wallpaperUseCase.removeWallpaper(wallpaper);
    return result.fold(
      (failure) => false, // Log or handle failure.
      (success) => success,
    );
  }

  Future<void> refreshWallpapers() async {
    await _loadWallpapers();
  }
}
