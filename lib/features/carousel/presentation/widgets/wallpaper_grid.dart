 import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:reorderable_grid_view/reorderable_grid_view.dart';

import '../../../../core/state/wallpaper_provider.dart';
import '../../../../theme/theme_manager.dart';
import '../../domain/entities/wallpaper.dart';
import '../state/home_provider.dart';
import 'add_carousel_widget.dart';
import 'empty_wallpapers.dart';
import 'wallpaper_card.dart';

class WallpaperGrid extends StatelessWidget {
  const WallpaperGrid({super.key});

  @override
  Widget build(BuildContext context) {
    var theme = context.read<ThemeManager>().themeData;

    return Consumer2<WallpaperProvider, HomePageProvider>(
      builder: (context, wallpaperProvider, homeProvider, child) {
        var wallpapers = wallpaperProvider.wallpapers;
        return ReorderableSliverGridView(
          crossAxisCount: 3,
          mainAxisSpacing: 5,
          crossAxisSpacing: 5,
          childAspectRatio: 0.6,
          onReorder: homeProvider.reOrderWallpapers,
          children: [
            const AddCarouselWidget(key: ValueKey('add-carousel-widget')),
            if (wallpapers.isEmpty)
              const EmptyWallpapers(key: ValueKey('empty-wallpaper')),
            if (wallpapers.isNotEmpty)
              ...wallpaperProvider.wallpapers.map(
                (Wallpaper wallpaper) {
                  return WallpaperCard(
                    key: ValueKey(wallpaper.path),
                    wallpaper: wallpaper,
                  );
                },
              ),
          ],
        );
      },
    );
  }
}
