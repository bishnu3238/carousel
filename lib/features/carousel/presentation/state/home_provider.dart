import 'package:carousel/core/di/injection_container.dart';
import 'package:carousel/features/carousel/domain/entities/wallpaper.dart';
import 'package:carousel/features/carousel/domain/usecases/wallpaper_usecase.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/state/wallpaper_provider.dart';

class HomePageProvider extends ChangeNotifier {
  final WallpaperUseCase _wallpaperUseCase = sl();
  late WallpaperProvider _wallpaperProvider;

  bool _isEditing = false;
  bool _isSelectAll = false;
  List<Wallpaper> _selectedWallpapers = [];

  HomePageProvider() {
    _wallpaperProvider = sl<WallpaperProvider>();
  }

  bool get isEditing => _isEditing;
  bool get isSelectAll => _isSelectAll;
  List<Wallpaper> get selectedWallpapers => _selectedWallpapers;

  void setIsEditing(bool value) {
    _isEditing = value;
    _selectedWallpapers.clear();
    notifyListeners();
  }

  void setIsSelectAll(bool? value) {
    _isSelectAll = value ?? false;
    notifyListeners();
  }

  void selectWallpaper(Wallpaper wallpaper) {
    if (_selectedWallpapers.contains(wallpaper)) {
      _selectedWallpapers.remove(wallpaper);
    } else {
      _selectedWallpapers.add(wallpaper);
    }
    notifyListeners();
  }

  void setSelectedAllWallpapers() {
    _selectedWallpapers = [..._wallpaperProvider.wallpapers];
    notifyListeners();
  }

  void clearSelectedWallpapers() {
    _selectedWallpapers.clear();
    notifyListeners();
  }

  Future<void> removeSelectedWallpapers() async {
    List<Wallpaper> itemsToDelete = List.from(_selectedWallpapers);
    for (Wallpaper wallpaper in itemsToDelete) {
      final result = await _wallpaperUseCase.removeWallpaper(wallpaper);
      result.fold((failure) {}, (success) {
        if (success) {
          _wallpaperProvider.removeWallpaper(wallpaper);
        }
      });
    }
  }
}
