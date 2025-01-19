import 'package:carousel/core/di/injection_container.dart';
import 'package:carousel/core/util/app_constants.dart';
import 'package:carousel/core/state/wallpaper_provider.dart';
import 'package:carousel/features/carousel/presentation/state/image_selection_state.dart';
import 'package:carousel/features/carousel/presentation/state/settings_provider.dart';
import 'package:carousel/routes.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await init();
  runApp(MultiProvider(
    providers: [
      ChangeNotifierProvider(create: (_) => sl<WallpaperProvider>()),
      ChangeNotifierProvider(create: (_) => sl<ImageSelectionState>()),
      ChangeNotifierProvider(create: (_) => sl<SettingsProvider>()),
    ],
    child: const MyApp(),
  ));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      title: AppConstants.appTitle,
      routerConfig: router,
    );
  }
}
