import 'package:carousel/features/carousel/domain/entities/wallpaper.dart';

class WallpaperModel extends Wallpaper{
  const WallpaperModel({required super.path, super.isNetwork, super.id});


  factory WallpaperModel.fromJson(Map<String, dynamic> json) {
    return WallpaperModel(
        path: json['path'],
        isNetwork: json['isNetwork'],
        id: json['id']
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'path': path,
      'isNetwork': isNetwork,
      'id':id
    };
  }

}