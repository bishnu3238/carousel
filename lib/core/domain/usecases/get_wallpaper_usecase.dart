import 'package:dartz/dartz.dart';

import '../../error/failure.dart';
import '../entities/wallpaper.dart';
import '../repositories/wallpaper_repository.dart';

class GetWallpaperUseCase {
  final WallpaperRepository repository;

  GetWallpaperUseCase({required this.repository});

  Future<Either<Failure, List<Wallpaper>>> execute() async {
    return await repository.getttingWallpapers();
  }
}
