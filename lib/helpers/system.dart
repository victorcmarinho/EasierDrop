import 'package:flutter/services.dart';
import 'package:window_manager/window_manager.dart';

class SystemHelper {
  static hide() async {
    await windowManager.hide();
  }

  static open() async {
    await Future.wait([windowManager.show(), windowManager.focus()]);
  }

  static exit() async {
    await SystemNavigator.pop(animated: true);
  }
}
