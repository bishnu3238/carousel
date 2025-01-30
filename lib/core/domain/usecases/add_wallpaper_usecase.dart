import 'package:image_picker/image_picker.dart';

import '../repositories/wallpaper_repository.dart';

class AddWallpaperUseCase {
  final WallpaperRepository repository;

  AddWallpaperUseCase({required this.repository});

  void execute(List<XFile?> files) {
    final paths = files.map((e) => e!.path).toList();
    repository.addWallpapers(paths);
  }
}
