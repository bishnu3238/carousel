import 'package:go_router/go_router.dart';

import 'features/carousel/presentation/pages/edit_wallpaper_page.dart';
import 'features/carousel/presentation/pages/full_image_view_page.dart';
import 'features/carousel/presentation/pages/home_page.dart';
import 'features/carousel/presentation/pages/settings_page.dart';

final router = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const HomePage(),
    ),
    GoRoute(
      path: '/settings',
      builder: (context, state) => const SettingsPage(),
    ),
    GoRoute(
      path: '/edit-wallpaper',
      builder: (context, state) => const EditWallpaperPage(),
    ),
    GoRoute(
      path: '/full-image',
      builder: (context, state) => FullImageViewPage(imagePath: state.extra as String),
    ),
  ],
);
