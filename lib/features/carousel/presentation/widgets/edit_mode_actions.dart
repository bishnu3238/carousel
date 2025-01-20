import 'package:carousel/features/carousel/domain/entities/wallpaper.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/state/wallpaper_provider.dart';
import '../state/home_provider.dart';

class EditModeActions extends StatelessWidget {
  const EditModeActions({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<HomePageProvider>(
      builder: (context, homePageProvider, child) {
        var wallpapers = context.read<WallpaperProvider>().wallpapers;
        return Padding(
          padding: const EdgeInsets.only(top: 15, bottom: 10, right: 10),
          child: Align(
            alignment: Alignment.topRight,
            child: homePageProvider.isEditing
                ? Row(
                    // mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      TextButton(
                        onPressed: () {
                          homePageProvider.setIsEditing(false);
                        },
                        child: const Text(
                          'Cancel',
                          style: TextStyle(color: Colors.blue),
                        ),
                      ),
                      CheckboxMenuButton(
                        value: homePageProvider.isSelectAll,
                        onChanged:   homePageProvider.setIsSelectAll,
                        child: const Text(
                          'Select All',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),

                    ],
                  )
                : wallpapers.isNotEmpty
                    ? GestureDetector(
                        onLongPress: () {
                          homePageProvider.setIsEditing(true);
                        },
                        child: TextButton(
                          onPressed: () {
                            homePageProvider.setIsEditing(true);
                          },
                          child: const Text(
                            'Edit',
                            style: TextStyle(color: Colors.blue),
                          ),
                        ))
                    : null,
          ),
        );
      },
    );
  }
}
