import 'package:carousel/core/di/injection_container.dart';
import 'package:carousel/core/util/app_constants.dart';
import 'package:carousel/routes.dart';
import 'package:flutter/material.dart';

import 'carousel.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await init();
  runApp(const Carousel());
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
