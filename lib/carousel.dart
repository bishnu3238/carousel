import 'package:carousel/features/carousel/presentation/state/full_image_view_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'core/di/injection_container.dart';
import 'core/state/wallpaper_provider.dart';
import 'core/util/app_constants.dart';
import 'features/carousel/presentation/state/home_provider.dart';
import 'features/carousel/presentation/state/image_selection_state.dart';
import 'features/carousel/presentation/state/settings_provider.dart';
import 'routes.dart';
import 'theme/theme_manager.dart';

class Carousel extends StatelessWidget {
  const Carousel({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => sl<ThemeManager>()),
        ChangeNotifierProvider(create: (_) => sl<WallpaperProvider>()),
        ChangeNotifierProvider(create: (_) => sl<HomePageProvider>()),
        ChangeNotifierProvider(create: (_) => sl<ImageSelectionState>()),
        ChangeNotifierProvider(create: (_) => sl<SettingsProvider>()),
        ChangeNotifierProvider(create: (_) => sl<FullImageViewProvider>()),
      ],
      child: Builder(
        builder: (context) {
          return Consumer<ThemeManager>(
            builder: (context, themeManager, _) {
              return MaterialApp.router(
                  debugShowCheckedModeBanner: false,
                  theme: themeManager.themeData, // Use the dynamic theme
                  title: AppConstants.appTitle,
                  routerConfig: router);
            },
          );
        },
      ),
    );
  }
}
