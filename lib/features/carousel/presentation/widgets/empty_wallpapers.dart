import 'package:flutter/material.dart';

class EmptyWallpapers extends StatelessWidget {
  const EmptyWallpapers({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.center,
      margin: EdgeInsets.all(10),
      width: 400,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        // border: Border.all(color: Colors.white, width: 2),
      ),
      child: const Text(
        "Select carousel wallpaper",
        style: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
