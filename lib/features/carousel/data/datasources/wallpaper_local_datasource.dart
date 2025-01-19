import 'dart:convert';
import 'package:carousel/core/error/exception.dart';
import 'package:carousel/core/util/app_constants.dart';
import 'package:carousel/features/carousel/data/models/wallpaper_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

abstract class WallpaperLocalDataSource {
  Future<List<WallpaperModel>> getWallpapers();
  Future<bool> saveWallpaper(WallpaperModel wallpaper);
  Future<bool> removeWallpaper(WallpaperModel wallpaper);

}

class WallpaperLocalDataSourceImpl implements WallpaperLocalDataSource {
  final SharedPreferences sharedPreferences;

  WallpaperLocalDataSourceImpl({required this.sharedPreferences});

  @override
  Future<List<WallpaperModel>> getWallpapers() {
    final jsonString = sharedPreferences.getString(AppConstants.wallpaperKey);
    if(jsonString != null){
      final List decodedJson = json.decode(jsonString);
      final List<WallpaperModel> wallpaperModels = decodedJson.map((e) => WallpaperModel.fromJson(e)).toList();
      return Future.value(wallpaperModels);
    }else {
      return Future.value([]);
    }
  }

  @override
  Future<bool> saveWallpaper(WallpaperModel wallpaper) async {
    try {
      final allWallpapers = await getWallpapers();
      allWallpapers.add(wallpaper);
      String wallpaperString = json.encode(allWallpapers);
      await sharedPreferences.setString(AppConstants.wallpaperKey, wallpaperString);
      return true;
    } catch (e) {
      throw const LocalStorageException('Failed to save wallpaper');
    }
  }

  @override
  Future<bool> removeWallpaper(WallpaperModel wallpaper) async {
    try {
      final allWallpapers = await getWallpapers();
      allWallpapers.removeWhere((element) => element.id == wallpaper.id);
      String wallpaperString = json.encode(allWallpapers);
      await sharedPreferences.setString(AppConstants.wallpaperKey, wallpaperString);
      return true;
    } catch (e) {
      throw const LocalStorageException('Failed to remove wallpaper');
    }
  }


}