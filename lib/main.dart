import 'package:carousel/core/di/injection_container.dart';
import 'package:flutter/material.dart';

import 'carousel.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await init();
  runApp(const Carousel());
}
