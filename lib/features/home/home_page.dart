import 'package:flutter/material.dart';

import 'body/edit_mode_actions.dart';
import 'body/float_button.dart';
import 'body/home_app_bar.dart';
import 'body/wallpaper_grid.dart';

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
