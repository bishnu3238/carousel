import 'package:carousel/features/edit_wallpaper/core/edit_wallpaper_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_constants.dart';
import '../../core/di/injection_container.dart';
import '../../core/domain/usecases/add_wallpaper_usecase.dart';
import '../../core/services/image_click_service.dart';
import '../../core/state/image_selection_state.dart';
import '../../core/state/wallpaper_provider.dart';
import '../../routes.dart';
import '../../theme/theme_manager.dart';
import '../full_image_view/core/full_image_view_provider.dart';
import '../home/core/home_provider.dart';
import '../settings/core/settings_provider.dart';

class Carousel extends StatelessWidget {
  const Carousel({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => sl<ThemeManager>()),
        ChangeNotifierProvider(create: (_) => sl<WallpaperProvider>()),
        ChangeNotifierProxyProvider<WallpaperProvider, HomePageProvider>(
          create: (ctx) => HomePageProvider(
            sl<WallpaperProvider>(),
            sl<ImageClickService>(),
            sl<AddWallpaperUseCase>(),
          ),
          update: (context, wallpaperProvider, previous) => HomePageProvider(
            wallpaperProvider,
            sl<ImageClickService>(),
            sl<AddWallpaperUseCase>(),
          ),
        ),
        ChangeNotifierProvider(create: (_) => sl<EditWallpaperProvider>()),
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
