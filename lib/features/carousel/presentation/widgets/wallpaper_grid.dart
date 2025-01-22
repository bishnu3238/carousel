import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';

import 'package:carousel/features/carousel/domain/entities/wallpaper.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class WallpaperGrid extends StatelessWidget {
  final List<Wallpaper> wallpapers;
  final bool isEditing;
  final List<Wallpaper> selectedWallpapers;
  final Function(Wallpaper) onTap;

  const WallpaperGrid(
      {super.key,
      required this.wallpapers,
      this.isEditing = false,
      required this.selectedWallpapers,
      required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
        childAspectRatio: 0.6,
      ),
      itemCount: wallpapers.length,
      itemBuilder: (context, index) {
        final wallpaper = wallpapers[index];
        final isSelected = selectedWallpapers.contains(wallpaper);
        return GestureDetector(
          onTap: isEditing
              ? () => onTap(wallpaper)
              : () => context.push('/full-image', extra: wallpaper.path),
          onDoubleTap: () => print("hello world"),
          // context.push('/edit-wallpaper', extra: wallpaper.path),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              border: isEditing && isSelected
                  ? Border.all(color: Colors.white, width: 2)
                  : null,
            ),
            child: Stack(
              fit: StackFit.expand,
              children: [
                Padding(
                  padding: const EdgeInsets.all(1),
                  child: ClipRRect(
                    borderRadius: const BorderRadius.all(Radius.circular(10)),
                    child: FadeInImage(
                      image: FileImage(File(wallpaper.path)),
                      placeholder: const AssetImage('assets/full.jpeg'),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                // Padding(
                //     padding: const EdgeInsets.all(1),
                //     child: ClipRRect(
                //       borderRadius: const BorderRadius.all(Radius.circular(10)),
                //       child: Image.file(
                //         File(wallpaper.path),
                //         fit: BoxFit.cover,
                //       ),
                //     )),
                if (isEditing)
                  Align(
                    alignment: Alignment.bottomRight,
                    child: Container(
                      margin: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(5),
                          border: Border.all(
                            color: isSelected ? Colors.white : Colors.black,
                            width: 1.2,
                          ),
                          color: isSelected
                              ? Colors.pinkAccent.withOpacity(0.8)
                              : Colors.white.withOpacity(0.8)),
                      child: Icon(
                        isSelected ? Icons.check : Icons.check_box_outline_blank,
                        color: isSelected ? Colors.blueGrey[800] : Colors.transparent,
                        size: 16,
                      ),
                    ),
                  )
              ],
            ),
          ),
        );
      },
    );
  }
}
