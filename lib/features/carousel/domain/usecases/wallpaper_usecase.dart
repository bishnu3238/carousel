import 'package:dartz/dartz.dart';

import '../../../../core/error/failure.dart';
import '../entities/wallpaper.dart';
import '../repositories/wallpaper_repository.dart';

class WallpaperUseCase {
  final WallpaperRepository repository;

  WallpaperUseCase({required this.repository});

  Future<Either<Failure, List<Wallpaper>>> getWallpapers() async {
    try {
      return await repository.getWallpapers();
    } catch (e) {
      return Left(WallpaperUserCaseFailure(
        'Failed to fetch wallpapers: $e',
      ));
    }
  }

  Future<Either<Failure, bool>> saveWallpaper(Wallpaper wallpaper) async {
    try {
      return await repository.saveWallpaper(wallpaper);
    } catch (e) {
      return Left(WallpaperUserCaseFailure('Failed to save wallpaper: $e'));
    }
  }

  Future<Either<Failure, bool>> removeWallpaper(Wallpaper wallpaper) async {
    try {
      return await repository.removeWallpaper(wallpaper);
    } catch (e) {
      return Left(WallpaperUserCaseFailure('Failed to remove wallpaper: $e'));
    }
  }
}
