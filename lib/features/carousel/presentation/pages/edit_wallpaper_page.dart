import 'dart:io';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../../../../core/di/injection_container.dart';
import '../../../../core/state/wallpaper_provider.dart';
import '../../domain/entities/wallpaper.dart';
import '../../domain/usecases/wallpaper_usecase.dart';
import '../state/image_selection_state.dart';

class EditWallpaperPage extends StatefulWidget {
  const EditWallpaperPage({super.key});

  @override
  State<EditWallpaperPage> createState() => _EditWallpaperPageState();
}

class _EditWallpaperPageState extends State<EditWallpaperPage> {
  final ImagePicker _picker = ImagePicker();
  late ImageSelectionState _imageSelectionState;
  late WallpaperProvider _wallpaperProvider;
  final WallpaperUseCase _wallpaperUseCase = sl();
  bool _isLoading = false;

  @override
  void didChangeDependencies() {
    _imageSelectionState = Provider.of<ImageSelectionState>(context);
    _wallpaperProvider = Provider.of<WallpaperProvider>(context);
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Wallpaper'),
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                      onPressed: _pickImage, child: const Text('Pick single Image')),
                  ElevatedButton(
                      onPressed: _pickMultipleImage,
                      child: const Text('Pick Multiple Image')),
                  if (_imageSelectionState.selectedImage != null)
                    Image.file(_imageSelectionState.selectedImage!),
                  if (_imageSelectionState.selectedImages.isNotEmpty)
                    SizedBox(
                      height: 100,
                      child: ListView.builder(
                          itemCount: _imageSelectionState.selectedImages.length,
                          scrollDirection: Axis.horizontal,
                          itemBuilder: (context, index) {
                            return Padding(
                              padding: const EdgeInsets.all(8.0),
                              child:
                                  Image.file(_imageSelectionState.selectedImages[index]),
                            );
                          }),
                    ),
                  if (_imageSelectionState.selectedImage != null ||
                      _imageSelectionState.selectedImages.isNotEmpty)
                    ElevatedButton(
                        onPressed: () {
                          _saveWallpapers();
                        },
                        child: const Text('Save Wallpaper')),
                ],
              ),
            ),
          ),
          if (_isLoading)
            const Center(
              child: CircularProgressIndicator(),
            )
        ],
      ),
    );
  }

  Future<void> _pickImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      File? croppedImage = await _cropImage(File(image.path));
      if (croppedImage != null) {
        _imageSelectionState.setSelectedImage(croppedImage);
      }
    }
  }

  Future<void> _pickMultipleImage() async {
    final List<XFile> images = await _picker.pickMultiImage();
    List<File> croppedImages = [];
    if (images.isNotEmpty) {
      for (var image in images) {
        File? croppedImage = await _cropImage(File(image.path));
        if (croppedImage != null) {
          croppedImages.add(croppedImage);
        }
      }
      _imageSelectionState.setSelectedImages(croppedImages);
    }
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
        IOSUiSettings(
          title: 'Cropper',
        ),
      ],
    );
    if (croppedFile != null) {
      return File(croppedFile.path);
    }
    return null;
  }

  void _saveWallpapers() async {
    setState(() {
      _isLoading = true;
    });
    final singleImage = _imageSelectionState.selectedImage;
    final multipleImages = _imageSelectionState.selectedImages;
    if (singleImage != null) {
      final wallpaper = Wallpaper(path: singleImage.path, id: DateTime.now().millisecond);
      final result = await _wallpaperUseCase.saveWallpaper(wallpaper);
      result.fold((failure) {
        setState(() {
          _isLoading = false;
        });
      }, (success) {
        _wallpaperProvider.addWallpaper(wallpaper);
      });
    }
    if (multipleImages.isNotEmpty) {
      for (File image in multipleImages) {
        final wallpaper = Wallpaper(path: image.path, id: DateTime.now().millisecond);
        final result = await _wallpaperUseCase.saveWallpaper(wallpaper);
        result.fold((failure) {
          setState(() {
            _isLoading = false;
          });
        }, (success) {
          _wallpaperProvider.addWallpaper(wallpaper);
        });
      }
    }
    setState(() {
      _isLoading = false;
    });
    if (mounted) {
      context.pop();
    }

    _imageSelectionState.setSelectedImage(null);
    _imageSelectionState.setSelectedImages([]);
  }
}
