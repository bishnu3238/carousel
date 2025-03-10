 import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/state/wallpaper_provider.dart';
import '../../../../core/util/app_constants.dart';
import '../state/home_provider.dart';

class EditModeActions extends StatelessWidget {
  const EditModeActions({super.key});

  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(
      child: Consumer2<WallpaperProvider, HomePageProvider>(
        builder: (context, wallpaperProvider, homePageProvider, child) {
          var wallpapers = wallpaperProvider.wallpapers;
          return Card(
            child: Align(
              alignment: Alignment.topRight,
              child: homePageProvider.isEditing
                  ? Row(
                      mainAxisSize: MainAxisSize.max,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        TextButton(
                          onPressed: () => homePageProvider.setIsEditing(false),
                          child: const Text(
                            'Cancel',
                            // style: TextStyle(color: Colors.blue),
                          ),
                        ),
                        Text(
                          '${homePageProvider.selectedWallpapers.length} Selected',
                          style: const TextStyle(color: Colors.white),
                        ),
                        CheckboxMenuButton(
                          value: homePageProvider.isSelectAll,
                          onChanged: homePageProvider.setIsSelectAll,
                          child: const Text(
                            'Select All',
                            // style: TextStyle(color: Colors.white),
                          ),
                        ),
                      ],
                    )
                  : wallpapers.isNotEmpty
                      ? GestureDetector(
                          onLongPress: () {
                            homePageProvider.setIsEditing(true);
                          },
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Wallpaper Select: (${wallpapers.length}/${AppConstants.wallpaperLimit})',
                              ),
                              TextButton(
                                onPressed: () => homePageProvider.setIsEditing(true),
                                child: const Text(
                                  'Edit',
                                  // style: TextStyle(color: Colors.white),
                                ),
                              ),
                            ],
                          ),
                        )
                      : const SizedBox(),
            ),
          );
        },
      ),
    );
  }
}
