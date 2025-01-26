import 'dart:io';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../domain/entities/wallpaper.dart';
import '../state/home_provider.dart';

class WallpaperCard extends StatelessWidget {
  const WallpaperCard({super.key, required this.wallpaper});

  final Wallpaper wallpaper;

  @override
  Widget build(BuildContext context) {
    return Consumer<HomePageProvider>(
        key: ValueKey(wallpaper.id),
        builder: (context, homeProvider, _) {
          bool isSelected = homeProvider.selectedWallpapers.contains(wallpaper);

          return GestureDetector(
            key: ValueKey("${wallpaper.path}01"),
            onTap: homeProvider.isEditing
                ? () => homeProvider.selectWallpaper(wallpaper)
                : () => context.push('/full-image', extra: wallpaper.path),
            onDoubleTap: () => homeProvider.selectAndDeselect(isSelected, wallpaper),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                border: homeProvider.isEditing && isSelected
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
                  if (homeProvider.isEditing)
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
                              ? Colors.pinkAccent.withValues(alpha: 0.8)
                              : Colors.white.withValues(alpha: 0.8),
                        ),
                        child: Icon(
                          isSelected ? Icons.check : Icons.check_box_outline_blank,
                          color: isSelected ? Colors.blueGrey[800] : Colors.transparent,
                          size: 16,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          );
        });
  }
}
