import 'package:dartz/dartz.dart';

import '../../../../core/error/failure.dart';
import '../entities/wallpaper.dart';

abstract class WallpaperRepository {
  Future<Either<Failure, List<Wallpaper>>> getWallpapers();

  Future<Either<Failure, bool>> saveWallpaper(Wallpaper wallpaper);

  Future<Either<Failure, bool>> removeWallpaper(Wallpaper wallpaper);
}
