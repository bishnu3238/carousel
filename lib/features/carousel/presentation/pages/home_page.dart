import 'package:carousel/core/state/wallpaper_provider.dart';
import 'package:carousel/features/carousel/domain/entities/wallpaper.dart';
import 'package:carousel/features/carousel/presentation/widgets/wallpaper_grid.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../../core/di/injection_container.dart';
import '../../domain/usecases/wallpaper_usecase.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool _isEditing = false;
  List<Wallpaper> _selectedWallpapers = [];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text(
          'Carousel Wallpapers',
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
              icon: const Icon(Icons.settings),
              onPressed: () => context.push('/settings'))
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(10),
        child: Consumer<WallpaperProvider>(
          builder: (context, wallpaperProvider, child) {
            final wallpapers = wallpaperProvider.wallpapers;
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                    padding: const EdgeInsets.only(top: 15, bottom: 10, right: 10),
                    child: Align(
                      alignment: Alignment.topRight,
                      child: _isEditing
                          ? TextButton(
                              onPressed: () {
                                setState(() {
                                  _isEditing = false;
                                  _selectedWallpapers.clear();
                                });
                              },
                              child: const Text(
                                'Cancel',
                                style: TextStyle(color: Colors.blue),
                              ),
                            )
                          : wallpapers.isNotEmpty
                              ? TextButton(
                                  onPressed: () {
                                    setState(() {
                                      _isEditing = true;
                                    });
                                  },
                                  child: const Text(
                                    'Edit',
                                    style: TextStyle(color: Colors.blue),
                                  ),
                                )
                              : null,
                    )),
                Expanded(
                    child: wallpapers.isNotEmpty
                        ? WallpaperGrid(
                            wallpapers: wallpapers,
                            isEditing: _isEditing,
                            selectedWallpapers: _selectedWallpapers,
                            onTap: _selectWallpaper,
                          )
                        : Center(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Container(
                                  width: 100,
                                  height: 150,
                                  decoration: BoxDecoration(
                                      color: Colors.blue.shade900,
                                      borderRadius: BorderRadius.circular(10)),
                                  child: TextButton(
                                    onPressed: () {
                                      context.push('/edit-wallpaper');
                                    },
                                    child: const Text(
                                      'Add',
                                      style: TextStyle(color: Colors.white),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 10),
                                const Text("Select carousel wallpaper",
                                    style: TextStyle(color: Colors.white, fontSize: 16))
                              ],
                            ),
                          ))
              ],
            );
          },
        ),
      ),
      floatingActionButton:  _isEditing && _selectedWallpapers.isNotEmpty  ? FloatingActionButton(
        onPressed: () {
          _removeSelectedWallpapers();
          setState(() {
            _isEditing = false;
            _selectedWallpapers.clear();
          });
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
  void _selectWallpaper(Wallpaper wallpaper){
    setState(() {
      if(_selectedWallpapers.contains(wallpaper)){
        _selectedWallpapers.remove(wallpaper);
      } else {
        _selectedWallpapers.add(wallpaper);
      }
    });
  }
  void _removeSelectedWallpapers() async {
    for(Wallpaper wallpaper in _selectedWallpapers){
      final result = await  sl<WallpaperUseCase>().removeWallpaper(wallpaper);
      result.fold((failure) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to remove wallpaper')),
        );
      }, (success){
        if(success){
          Provider.of<WallpaperProvider>(context, listen: false).removeWallpaper(wallpaper);
        }
      });
    }
  }

}