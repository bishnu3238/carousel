import 'package:carousel/core/error/failure.dart';
import 'package:carousel/features/carousel/domain/entities/wallpaper.dart';
import 'package:dartz/dartz.dart';

abstract class WallpaperRepository {
  Future<Either<Failure, List<Wallpaper>>> getWallpapers();
  Future<Either<Failure, bool>> saveWallpaper(Wallpaper wallpaper);
  Future<Either<Failure, bool>> removeWallpaper(Wallpaper wallpaper);
}