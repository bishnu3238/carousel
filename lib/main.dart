import 'package:flutter/material.dart';

import 'core/di/injection_container.dart';
import 'features/carousel/carousel.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await init();
  runApp(const Carousel());
}
