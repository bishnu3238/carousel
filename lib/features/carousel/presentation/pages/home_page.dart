import 'package:flutter/material.dart';

import '../widgets/edit_mode_actions.dart';
import '../widgets/float_button.dart';
import '../widgets/home_app_bar.dart';
import '../widgets/wallpaper_grid.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: CustomScrollView(
        slivers: [
          HomeAppBar(),
          EditModeActions(),
          WallpaperGrid(),
        ],
      ),
      floatingActionButton: FloatButtonHome(),
    );
  }
}
