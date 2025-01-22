import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';


class EmptyWallpapers extends StatelessWidget {
  const EmptyWallpapers({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Container(
          width: 100,
          height: 150,
          decoration: BoxDecoration(
              color: Colors.blue.shade900,
              borderRadius: BorderRadius.circular(10)),
          child: TextButton(
            onPressed: () {
              context.push('/edit-wallpaper');
            },
            child: const Text(
              'Add',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ),
        const SizedBox(width: 10),
        const Text("Select carousel wallpaper",
            style: TextStyle(color: Colors.white, fontSize: 16))
      ],
    );
  }
}
