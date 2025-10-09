import 'package:flutter/widgets.dart';
import 'package:tray_manager/tray_manager.dart';

class MockTrayManager implements TrayManager {
  List<TrayListener> get listeners => [];

  @override
  void addListener(TrayListener listener) {}

  @override
  void removeListener(TrayListener listener) {}

  @override
  Future<void> destroy() async {}

  @override
  Future<void> popUpContextMenu({bool bringAppToFront = false}) async {}

  @override
  Future<void> setContextMenu(Menu menu) async {}

  @override
  Future<void> setIcon(
    String iconPath, {
    TrayIconPosition? iconPosition,
    int? iconSize,
    bool? isTemplate,
  }) async {}

  @override
  Future<void> setToolTip(String toolTip) async {}

  @override
  Future<Rect?> getBounds() {
    // TODO: implement getBounds
    throw UnimplementedError();
  }

  @override
  // TODO: implement hasListeners
  bool get hasListeners => throw UnimplementedError();

  @override
  Future<void> setIconPosition(TrayIconPosition trayIconPosition) {
    // TODO: implement setIconPosition
    throw UnimplementedError();
  }

  @override
  Future<void> setTitle(String title) {
    // TODO: implement setTitle
    throw UnimplementedError();
  }
}
