import 'dart:io';

import 'package:carousel/features/carousel/domain/entities/wallpaper.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:reorderable_grid_view/reorderable_grid_view.dart';

import '../../../../theme/theme_manager.dart';
import 'wave_painter.dart';

class WallpaperGrid extends StatefulWidget {
  final List<Wallpaper> wallpapers;
  final bool isEditing;
  final List<Wallpaper> selectedWallpapers;
  final Function(Wallpaper) onTap;
  final Function(int, int) onReorder;

  const WallpaperGrid({
    super.key,
    required this.wallpapers,
    this.isEditing = false,
    required this.selectedWallpapers,
    required this.onTap,
    required this.onReorder,
  });

  @override
  State<WallpaperGrid> createState() => _WallpaperGridState();
}

class _WallpaperGridState extends State<WallpaperGrid> {
  @override
  Widget build(BuildContext context) {
    var theme = context.read<ThemeManager>().themeData;
    return Card(
      child: ReorderableGridView.builder(
        padding: const EdgeInsets.all(10),

        dragEnabled: true,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
          childAspectRatio: 0.6,
        ),
        itemCount: widget.wallpapers.length + 1,
        // Include "add" button
        itemBuilder: (context, index) {
          if (index == 0) {
            // Add button
            return GestureDetector(
              key: const ValueKey('add_button'),
              onTap: () => context.push('/edit-wallpaper'),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: CustomPaint(
                  painter: WavePainter(),
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: theme.colorScheme.error, width: 2),
                    ),
                    child: const Center(
                      child: Icon(
                        Icons.add,
                        color: Colors.white,
                        size: 40,
                      ),
                    ),
                  ),
                ),
              ),
            );
          } else {
            // Wallpaper items
            final wallpaper = widget.wallpapers[index - 1]; // Adjust for "add" button
            final isSelected = widget.selectedWallpapers.contains(wallpaper);
            return ReorderableDelayedDragStartListener(
              key: ValueKey(wallpaper.path), // Key must be unique for each wallpaper
              index: index, // Pass the correct index
              child: GestureDetector(
                key: ValueKey(wallpaper.path), // Ensure unique key
                onTap: widget.isEditing
                    ? () => widget.onTap(wallpaper)
                    : () => context.push('/full-image', extra: wallpaper.path),
                onDoubleTap: () => setState(() {
                  print('Double tap');
                  if (isSelected) {
                    widget.selectedWallpapers.remove(wallpaper);
                  } else {
                    widget.selectedWallpapers.add(wallpaper);
                  }
                }),
                // onLongPress: () {
                //   setState(() {
                //     if (isSelected) {
                //       widget.selectedWallpapers.remove(wallpaper);
                //     } else {
                //       widget.selectedWallpapers.add(wallpaper);
                //     }
                //   });
                // },
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    border: widget.isEditing && isSelected
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
                      if (widget.isEditing)
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
                              color:
                                  isSelected ? Colors.blueGrey[800] : Colors.transparent,
                              size: 16,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            );
          }
        },
        onReorder: (oldIndex, newIndex) {
          if (newIndex == 0 || oldIndex == 0)
            return; // Prevent reordering the "add" button
          final adjustedOldIndex = oldIndex - 1; // Offset by "add" button
          final adjustedNewIndex = newIndex - 1;

          // Trigger the callback with adjusted indexes
          widget.onReorder(adjustedOldIndex, adjustedNewIndex);
        },
      ),
    );
  }
}
