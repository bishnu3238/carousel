import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../../theme/theme_manager.dart';
import 'wave_painter.dart';

class AddCarouselWidget extends StatelessWidget {
  const AddCarouselWidget({super.key});

  @override
  Widget build(BuildContext context) {
    var theme = context.read<ThemeManager>().themeData;

    return GestureDetector(
      key: const ValueKey('add_button'),
      onTap: () => context.push('/edit-wallpaper'),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: CustomPaint(
          painter: WavePainter(),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: theme.colorScheme.error, width: 2),
            ),
            child: const Center(
              child: Icon(
                Icons.add,
                color: Colors.white,
                size: 40,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
