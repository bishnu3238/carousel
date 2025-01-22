import 'package:dartz/dartz.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

ImagePicker picker = ImagePicker();

class ImageClickService {
  final ImagePicker picker;
  ImageClickService({required this.picker});

  Future<Either<ImageClickFailure, List<XFile?>>> showImagePickingAlert(
      BuildContext context,
      {required String title,
      bool? multi = false}) async {
    List<XFile?> images = [];
    final imageSource = await showDialog(
      context: context,
      builder: (BuildContext ctx) {
        return CupertinoAlertDialog(
          title: Text(title.toUpperCase()),
          actions: <Widget>[
            CupertinoDialogAction(
              child: const Text(
                'Take a picture',
              ),
              onPressed: () => Navigator.of(context).pop(ImageSource.camera),
            ),
            CupertinoDialogAction(
              child: const Text(
                'Choose from gallery',
              ),
              onPressed: () => Navigator.of(context).pop(ImageSource.gallery),
            ),
          ],
        );
      },
    );
    if (imageSource == null) {
      return left(ImageClickFailure('No source available'));
    } else if (imageSource == ImageSource.camera) {
      await openCamera().then((value) => value.fold(
            (l) => left(ImageClickFailure(l.toString())),
            (r) => images = r,
          ));
    } else if (imageSource == ImageSource.gallery && multi!) {
      await openGalleryMulti().then((value) => value.fold(
            (l) => left(ImageClickFailure(l.toString())),
            (r) => images = r,
          ));
    } else {
      await openGallery().then((value) => value.fold(
            (l) => left(ImageClickFailure(l.toString())),
            (r) => images = r,
          ));
    }
    return right(images);
  }

  Future<Either<ImageClickFailure, List<XFile?>>> openCamera() async {
    try {
      var data = await picker.pickImage(source: ImageSource.camera);
      if (data == null) return right([]);
      return right([data]);
    } catch (e) {
      return left(ImageClickFailure(e.toString()));
    }
  }

  Future<Either<ImageClickFailure, List<XFile?>>> openGalleryMulti() async {
    try {
      var data = await picker.pickMultiImage();
      return right(data);
    } catch (e) {
      return left(ImageClickFailure(e.toString()));
    }
  }

  Future<Either<ImageClickFailure, List<XFile?>>> openGallery() async {
    try {
      var data = await picker.pickImage(source: ImageSource.gallery);
      if (data == null) return left(ImageClickFailure('user cancel'));
      return right([data]);
    } catch (e) {
      return left(ImageClickFailure(e.toString()));
    }
  }

  Future<Either<ImageClickFailure, List<XFile?>>> openMedia() async {
    try {
      var data = await picker.pickMedia();
      if (data == null) return right([]);
      return right([data]);
    } catch (e) {
      return left(ImageClickFailure(e.toString()));
    }
  }

  Future<Either<ImageClickFailure, List<XFile?>>> openMultiMedia() async {
    try {
      var data = await picker.pickMultipleMedia();
      return right(data);
    } catch (e) {
      return left(ImageClickFailure(e.toString()));
    }
  }
}

class ImageClickFailure implements Exception {
  final String err;
  ImageClickFailure(String? error) : err = "ImageClickError => $error";

  @override
  String toString() => 'ImageClickFailure{err: $err}';
}
