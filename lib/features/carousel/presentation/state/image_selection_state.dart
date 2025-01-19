import 'dart:convert';
import 'dart:io';
import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ImageSelectionState extends ChangeNotifier with EquatableMixin {
  File? _selectedImage;
  List<File> _selectedImages = [];
  final SharedPreferences _sharedPreferences;

  ImageSelectionState({required SharedPreferences sharedPreferences})
      : _sharedPreferences = sharedPreferences {
    _loadState();
  }
  File? get selectedImage => _selectedImage;
  List<File> get selectedImages => _selectedImages;
  static const String _selectedImagePathKey = 'selected_image_path';
  static const String _selectedImagesPathsKey = 'selected_images_paths';

  void setSelectedImage(File? image) {
    _selectedImage = image;
    _saveState();
    notifyListeners();
  }

  void setSelectedImages(List<File> images) {
    _selectedImages = images;
    _saveState();
    notifyListeners();
  }

  Future<void> _saveState() async {
    await _sharedPreferences.remove(_selectedImagePathKey);
    await _sharedPreferences.remove(_selectedImagesPathsKey);

    if (_selectedImage != null) {
      await _sharedPreferences.setString(_selectedImagePathKey, _selectedImage!.path);
    }

    if (_selectedImages.isNotEmpty) {
      List<String> paths = _selectedImages.map((e) => e.path).toList();
      await _sharedPreferences.setStringList(_selectedImagesPathsKey, paths);
    }
  }

  Future<void> _loadState() async {
    final selectedPath = _sharedPreferences.getString(_selectedImagePathKey);
    if (selectedPath != null) {
      _selectedImage = File(selectedPath);
    }

    final imagesPaths = _sharedPreferences.getStringList(_selectedImagesPathsKey);
    if (imagesPaths != null) {
      _selectedImages = imagesPaths.map((e) => File(e)).toList();
    }

    notifyListeners();
  }

  @override
  List<Object?> get props => [_selectedImage, _selectedImages];
}
