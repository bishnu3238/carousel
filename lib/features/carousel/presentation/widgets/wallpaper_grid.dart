import 'dart:io';

import 'package:carousel/features/carousel/domain/entities/wallpaper.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:reorderable_grid_view/reorderable_grid_view.dart';

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
    return ReorderableGridView.builder(
      dragEnabled: true,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
        childAspectRatio: 0.6,
      ),
      itemCount: widget.wallpapers.length + 1,
      itemBuilder: (context, index) {
        if (index == 0) {
          return GestureDetector(
            key: const ValueKey('add_button'),
            onTap: () => context.push('/edit-wallpaper'),
            child: CustomPaint(
              painter: WavePainter(),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.white, width: 2),
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
          );
        } else {
          final wallpaper = widget.wallpapers[index - 1];
          final isSelected = widget.selectedWallpapers.contains(wallpaper);
          return ReorderableDelayedDragStartListener(
            key: ValueKey(wallpaper.path),
            index: index,
            child: GestureDetector(
              key: ValueKey(wallpaper.path),
              onTap: widget.isEditing
                  ? () => widget.onTap(wallpaper)
                  : () => context.push('/full-image', extra: wallpaper.path),
              onLongPress: () {
                setState(() {
                  if (isSelected) {
                    widget.selectedWallpapers.remove(wallpaper);
                  } else {
                    widget.selectedWallpapers.add(wallpaper);
                  }
                });
              },
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
                                ? Colors.pinkAccent.withOpacity(0.8)
                                : Colors.white.withOpacity(0.8),
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
            ),
          );
        }
      },
      onReorder: (oldIndex, newIndex) {
        if (newIndex == 0) return; // Prevent reordering to the add button position
        if (oldIndex < newIndex) newIndex -= 1; // Adjust for the add button
        widget.onReorder(oldIndex - 1, newIndex - 1); // Adjust for the add button
      },
      dragWidgetBuilder: (index, child) {
        return Card(
          color: Colors.blue,
          child: Text(index.toString()),
        );
      },
      onDragStart: (index) {
        print("onDragStart: $index");
      },
    );
  }
}
