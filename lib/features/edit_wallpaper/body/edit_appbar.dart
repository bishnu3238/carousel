import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class EditAppbar extends StatelessWidget implements PreferredSizeWidget {
  const EditAppbar({super.key});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: const Text('Edit Wallpaper'),
      actions: [
        IconButton(onPressed: () {}, icon: const FaIcon(FontAwesomeIcons.image)),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
