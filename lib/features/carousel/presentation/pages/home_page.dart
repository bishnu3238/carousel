 import 'package:carousel/core/state/wallpaper_provider.dart';
 import 'package:carousel/features/carousel/presentation/widgets/edit_mode_actions.dart';
import 'package:carousel/features/carousel/presentation/widgets/wallpaper_grid.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../state/home_provider.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {

  late HomePageProvider _homePageProvider;

  @override
  void didChangeDependencies() {
    _homePageProvider = Provider.of<HomePageProvider>(context);
    super.didChangeDependencies();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title:  const Text('Carousel Wallpapers', style: TextStyle(color: Colors.white),),
        centerTitle: true,
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
              icon: const Icon(Icons.settings),
              onPressed: () => context.push('/settings')
          )
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(10),
        child:  Consumer<WallpaperProvider>(
          builder: (context, wallpaperProvider, child) {
            final wallpapers = wallpaperProvider.wallpapers;
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const EditModeActions(),
                Expanded(
                    child:  wallpapers.isNotEmpty ? WallpaperGrid(wallpapers: wallpapers,
                      isEditing: _homePageProvider.isEditing,
                      selectedWallpapers: _homePageProvider.selectedWallpapers,
                      onTap: _homePageProvider.selectWallpaper,
                    ) :
                    Center(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            width: 100,
                            height: 150,
                            decoration: BoxDecoration(
                                color: Colors.blue.shade900,
                                borderRadius: BorderRadius.circular(10)
                            ),
                            child:   TextButton(
                              onPressed: () {
                                context.push('/edit-wallpaper');
                              },
                              child: const Text('Add', style: TextStyle(color: Colors.white),),
                            ),
                          ),
                          const SizedBox(width: 10),
                          const Text("Select carousel wallpaper", style: TextStyle(color: Colors.white, fontSize: 16))
                        ],
                      ),
                    )
                )
              ],
            );
          },
        ),
      ),
      floatingActionButton:  _homePageProvider.isEditing && _homePageProvider.selectedWallpapers.isNotEmpty  ? FloatingActionButton(
        onPressed: () {
          _homePageProvider.removeSelectedWallpapers();
          _homePageProvider.setIsEditing(false);
          _homePageProvider.clearSelectedWallpapers();
        },
        child: const Icon(Icons.delete),
      ) : FloatingActionButton(
        onPressed: () {
          context.push('/edit-wallpaper');
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}