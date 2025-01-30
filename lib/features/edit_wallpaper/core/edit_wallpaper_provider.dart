import 'dart:io';

import 'package:carousel/core/services/image_click_service.dart';
import 'package:flutter/material.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';

import '../../../core/domain/entities/wallpaper.dart';
import '../../../core/domain/usecases/wallpaper_usecase.dart';
import '../../../core/state/image_selection_state.dart';
import '../../../core/state/wallpaper_provider.dart';

class EditWallpaperProvider extends ChangeNotifier {
  final ImagePicker _picker = ImagePicker();
  final ImageClickService _imageClickService;
  final WallpaperUseCase _wallpaperUseCase;

  final ImageSelectionState _imageSelectionState;
  final WallpaperProvider _wallpaperProvider;

  bool _isLoading = false;

  bool get isLoading => _isLoading;

  EditWallpaperProvider(this._imageClickService, this._wallpaperUseCase,
      {required ImageSelectionState imageSelectionState,
      required WallpaperProvider wallpaperProvider})
      : _imageSelectionState = imageSelectionState,
        _wallpaperProvider = wallpaperProvider;

  Future<void> pickImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      File? croppedImage = await _cropImage(File(image.path));
      if (croppedImage != null) {
        _imageSelectionState.setSelectedImage(croppedImage);
      }
    }
  }

  Future<void> pickMultipleImages() async {
    final List<XFile> images = await _picker.pickMultiImage();
    List<File> croppedImages = [];
    for (var image in images) {
      File? croppedImage = await _cropImage(File(image.path));
      if (croppedImage != null) {
        croppedImages.add(croppedImage);
      }
    }
    _imageSelectionState.setSelectedImages(croppedImages);
  }

  Future<File?> _cropImage(File imageFile) async {
    CroppedFile? croppedFile = await ImageCropper().cropImage(
      sourcePath: imageFile.path,
      aspectRatioPresets: [
        CropAspectRatioPreset.square,
        CropAspectRatioPreset.ratio3x2,
        CropAspectRatioPreset.original,
        CropAspectRatioPreset.ratio4x3,
        CropAspectRatioPreset.ratio16x9
      ],
      uiSettings: [
        AndroidUiSettings(
          toolbarTitle: 'Cropper',
          toolbarColor: Colors.blueGrey[800],
          toolbarWidgetColor: Colors.white,
          initAspectRatio: CropAspectRatioPreset.original,
          lockAspectRatio: false,
        ),
        IOSUiSettings(title: 'Cropper'),
      ],
    );
    return croppedFile != null ? File(croppedFile.path) : null;
  }

  Future<void> saveWallpapers(BuildContext context) async {
    _isLoading = true;
    notifyListeners();

    final singleImage = _imageSelectionState.selectedImage;
    final multipleImages = _imageSelectionState.selectedImages;

    if (singleImage != null) {
      await _saveWallpaper(singleImage);
    }

    for (File image in multipleImages) {
      await _saveWallpaper(image);
    }

    _isLoading = false;
    notifyListeners();
    if (context.mounted) {
      Navigator.pop(context);
    }

    _imageSelectionState.setSelectedImage(null);
    _imageSelectionState.setSelectedImages([]);
  }

  Future<void> _saveWallpaper(File image) async {
    final wallpaper = Wallpaper(path: image.path, id: DateTime.now().millisecond);
    final result = await _wallpaperUseCase.saveWallpaper(wallpaper);
    result.fold((failure) => debugPrint("Failed to save wallpaper"),
        (success) => _wallpaperProvider.addWallpaper(wallpaper));
  }
}
