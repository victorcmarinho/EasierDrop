import 'package:flutter/widgets.dart';
import 'package:tray_manager/tray_manager.dart';

// Esta classe é um mock para o componente Tray
// O problema nos testes é que o Tray acessa o contexto durante o dispose
// o que causa erros durante a desmontagem dos widgets nos testes
class MockTrayManager implements TrayManager {
  @override
  List<TrayListener> get listeners => [];

  @override
  void addListener(TrayListener listener) {}

  @override
  void removeListener(TrayListener listener) {}

  @override
  Future<void> destroy() async {}

  @override
  Future<void> popUpContextMenu() async {}

  @override
  Future<void> setContextMenu(Menu menu) async {}

  @override
  Future<void> setIcon(String iconPath) async {}

  @override
  Future<void> setToolTip(String toolTip) async {}
}
