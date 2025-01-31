import 'package:dartz/dartz.dart';

import '../../../../core/error/failure.dart';
import '../../domain/entities/wallpaper.dart';
import '../../domain/repositories/wallpaper_repository.dart';
import '../datasources/wallpaper_local_datasource.dart';
import '../datasources/wallpaper_remote_datasource.dart';
import '../models/wallpaper_model.dart';

class WallpaperRepositoryImpl implements WallpaperRepository {
  final WallpaperLocalDataSource localDataSource;
  final WallpaperRemoteDataSource remoteDataSource;

  WallpaperRepositoryImpl(
      {required this.localDataSource, required this.remoteDataSource});

  @override
  Future<Either<Failure, List<Wallpaper>>> getWallpapers() async {
    try {
      final response = await localDataSource.getWallpapers();
      final wallpapers = response
          .map((e) => Wallpaper(path: e.path, isNetwork: e.isNetwork, id: e.id))
          .toList();
      return Right(wallpapers);
    } on Exception catch (e) {
      return Left(LocalStorageFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, bool>> saveWallpaper(Wallpaper wallpaper) async {
    try {
      final model = WallpaperModel(
          path: wallpaper.path, isNetwork: wallpaper.isNetwork, id: wallpaper.id);
      final result = await localDataSource.saveWallpaper(model);
      return Right(result);
    } on Exception catch (e) {
      return Left(LocalStorageFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, bool>> removeWallpaper(Wallpaper wallpaper) async {
    try {
      final model = WallpaperModel(
          path: wallpaper.path, isNetwork: wallpaper.isNetwork, id: wallpaper.id);
      final result = await localDataSource.removeWallpaper(model);
      return Right(result);
    } on Exception catch (e) {
      return Left(LocalStorageFailure(e.toString()));
    }
  }
}
