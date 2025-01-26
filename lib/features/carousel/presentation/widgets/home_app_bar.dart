import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class HomeAppBar extends StatelessWidget {
  const HomeAppBar({super.key});

  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      title: const Text(
        'Carousel Wallpapers',
        style: TextStyle(color: Colors.white),
      ),
      centerTitle: true,
      pinned: true,
      iconTheme: const IconThemeData(color: Colors.white),
      actions: [
        IconButton(
            icon: const Icon(Icons.settings), onPressed: () => context.push('/settings'))
      ],
    );
  }
}
