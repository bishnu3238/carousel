import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../core/home_provider.dart';

class FloatButtonHome extends StatelessWidget {
  const FloatButtonHome({super.key});

  @override
  Widget build(BuildContext context) {
    return Builder(builder: (context) {
      return Consumer<HomePageProvider>(
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
      );
    });
  }
}
