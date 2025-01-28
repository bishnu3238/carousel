import 'package:flutter/material.dart';

import 'carousel.dart';
import 'core/di/injection_container.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await init();
  runApp(const Carousel());
}
