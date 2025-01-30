import 'package:flutter/cupertino.dart';

class FullImageViewProvider extends ChangeNotifier {
  bool _isFullScreen = true;

  bool get isFullScreen => _isFullScreen;

  void setFullScreen(bool value) {
    _isFullScreen = value;
    notifyListeners();
  }

  toggleIsFullScreen() {
    _isFullScreen = !_isFullScreen;
    notifyListeners();
  }
}
