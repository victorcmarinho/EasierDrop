import 'package:easier_drop/helpers/system.dart';
import 'package:flutter/widgets.dart';
import 'package:tray_manager/tray_manager.dart';

class Tray extends StatefulWidget {
  const Tray({super.key});

  @override
  State<Tray> createState() => _TrayState();
}

class _TrayState extends State<Tray> with TrayListener {
  @override
  void initState() async {
    super.initState();
    trayManager.addListener(this);
  }

  @override
  void dispose() {
    trayManager.removeListener(this);
    super.dispose();
  }

  @override
  void onTrayIconMouseDown() {
    trayManager.popUpContextMenu();
  }

  @override
  void onTrayIconRightMouseDown() {
    // do something
  }

  @override
  void onTrayIconRightMouseUp() {
    // do something
  }

  @override
  void onTrayMenuItemClick(MenuItem menuItem) {
    if (menuItem.key == 'show_window') {
      SystemHelper.open();
    } else if (menuItem.key == 'exit_app') {
      SystemHelper.exit();
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}
