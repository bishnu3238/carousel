import '../models/wallpaper_model.dart';

abstract class WallpaperLocalDataSource {
  Future<List<WallpaperModel>> getWallpapers();

  Future<bool> saveWallpaper(WallpaperModel wallpaper);

  Future<bool> removeWallpaper(WallpaperModel wallpaper);
}
