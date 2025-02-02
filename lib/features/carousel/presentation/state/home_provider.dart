import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../core/di/injection_container.dart';
import '../../../../core/services/image_click_service.dart';
import '../../../../core/state/wallpaper_provider.dart';
import '../../../../core/util/app_constants.dart';
import '../../domain/entities/wallpaper.dart';
import '../../domain/usecases/wallpaper_usecase.dart';

class HomePageProvider extends ChangeNotifier {
  final ImageClickService _imageClickService = sl();
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
    if (_isSelectAll) return setSelectedAllWallpapers();
    _selectedWallpapers.clear();
    notifyListeners();
  }

  void selectWallpaper(Wallpaper wallpaper) {
    if (_selectedWallpapers.contains(wallpaper)) {
      _selectedWallpapers.remove(wallpaper);
      _isSelectAll = false;
    } else {
      _selectedWallpapers.add(wallpaper);
    }
    if (_wallpaperProvider.wallpapers.length == selectedWallpapers.length) {
      setIsSelectAll(true);
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

  void reOrderWallpapers(int oldIndex, int newIndex) async {
    if (newIndex == 0 || oldIndex == 0) return; // Prevent reordering the "add" button
    final adjustedOldIndex = oldIndex - 1; // Offset by "add" button
    final adjustedNewIndex = newIndex - 1;

    // Trigger the callback with adjusted indexes
    final wallpapers = List.of(_wallpaperProvider.wallpapers); // Make a mutable copy
    final wallpaper = wallpapers.removeAt(adjustedOldIndex); // Remove at old index
    wallpapers.insert(adjustedNewIndex, wallpaper); // Insert wallpaper at new index
    _wallpaperProvider.setWallpapers(wallpapers); // Update the provider
    // Update shared preferences
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final pathsJson = jsonEncode(wallpapers.map((e) => e.path).toList());
    await prefs.setString(AppConstants.lockScreenWallpapersKey, pathsJson);
  }

  void selectAndDeselect(bool isSelected, Wallpaper wallpaper) {
    if (isSelected) {
      selectedWallpapers.remove(wallpaper);
    } else {
      selectedWallpapers.add(wallpaper);
    }
    notifyListeners();
  }

  Future<void> clickImage(BuildContext context) async {
    await _imageClickService
        .showImagePickingAlert(context, title: 'PICK WALLPAPERS', multi: true)
        .then((value) => value.fold(
              (l) => null,
              (List<XFile?> right) async {
                List<Wallpaper> wallpapers =
                    right.map((e) => Wallpaper(path: e!.path)).toList();
                for (var wallpaper in wallpapers) {
                  await _wallpaperUseCase.saveWallpaper(wallpaper);
                  _wallpaperProvider.addWallpaper(wallpaper);
                }
              },
            ));
  }
}
