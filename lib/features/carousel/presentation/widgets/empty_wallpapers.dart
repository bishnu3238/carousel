import 'package:flutter/material.dart';

class EmptyWallpapers extends StatelessWidget {
  const EmptyWallpapers({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return const SliverToBoxAdapter(
      child: Text(
        "Select carousel wallpaper",
        style: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
