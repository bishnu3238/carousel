import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../../core/state/wallpaper_provider.dart';
import '../state/home_provider.dart';
import '../widgets/edit_mode_actions.dart';
import '../widgets/empty_wallpapers.dart';
import '../widgets/home_app_bar.dart';
import '../widgets/wallpaper_grid.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                const SizedBox(height: 20),
                Expanded(
                  child: wallpapers.isNotEmpty
                      ? WallpaperGrid(
                          wallpapers: wallpapers,
                          isEditing: homePageProvider.isEditing,
                          selectedWallpapers: homePageProvider.selectedWallpapers,
                          onTap: homePageProvider.selectWallpaper,
                          onReorder: (oldIndex, newIndex) {
                            debugPrint(
                                'Reordering wallpapers: oldIndex=$oldIndex, newIndex=$newIndex');
                            setState(() {
                              final wallpapers = List.of(
                                  wallpaperProvider.wallpapers); // Make a mutable copy
                              final wallpaper = wallpapers
                                  .removeAt(oldIndex); // Remove wallpaper at old index
                              wallpapers.insert(
                                  newIndex, wallpaper); // Insert wallpaper at new index
                              context
                                  .read<WallpaperProvider>()
                                  .setWallpapers(wallpapers); // Update the provider
                            });
                          },
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
