import 'package:carousel/core/state/wallpaper_provider.dart';
import 'package:carousel/features/carousel/presentation/widgets/edit_mode_actions.dart';
import 'package:carousel/features/carousel/presentation/widgets/wallpaper_grid.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../state/home_provider.dart';
import '../widgets/empty_wallpapers.dart';
import '../widgets/home_app_bar.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: const HomeAppBar(),
      body: Padding(
        padding: const EdgeInsets.all(10),
        child: Consumer2<WallpaperProvider, HomePageProvider>(
          builder: (context, wallpaperProvider, homePageProvider, child) {
            final wallpapers = wallpaperProvider.wallpapers;
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const EditModeActions(),
                Expanded(
                  child: wallpapers.isNotEmpty
                      ? WallpaperGrid(
                          wallpapers: wallpapers,
                          isEditing: homePageProvider.isEditing,
                          selectedWallpapers: homePageProvider.selectedWallpapers,
                          onTap: homePageProvider.selectWallpaper,
                        )
                      : const EmptyWallpapers(),
                )
              ],
            );
          },
        ),
      ),
      floatingActionButton: Consumer<HomePageProvider>(
        builder: (context, homePageProvider, _) {
          return homePageProvider.isEditing &&
                  homePageProvider.selectedWallpapers.isNotEmpty
              ? FloatingActionButton(
                  onPressed: () {
                    homePageProvider.removeSelectedWallpapers();
                    homePageProvider.setIsEditing(false);
                    homePageProvider.clearSelectedWallpapers();
                  },
                  child: const Icon(Icons.delete),
                )
              : FloatingActionButton(
                  onPressed: () => context.push('/edit-wallpaper'),
                  child: const Icon(Icons.add),
                );
        },
      ),
    );
  }
}
