import 'dart:async';
import 'package:easier_drop/helpers/system.dart';
import 'package:easier_drop/services/constants.dart';
import 'package:flutter/widgets.dart';
import 'package:tray_manager/tray_manager.dart';

class Tray extends StatefulWidget {
  const Tray({super.key});

  @override
  State<Tray> createState() => _TrayState();
}

class _TrayState extends State<Tray> with TrayListener {
  @override
  void initState() {
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
  void onTrayMenuItemClick(MenuItem menuItem) async {
    try {
      switch (menuItem.key) {
        case 'show_window':
          await SystemHelper.open();
          break;
        case 'toggle_autoclear_in':
          FeatureFlags.autoClearInbound = !FeatureFlags.autoClearInbound;
          // Persiste alteração
          unawaited(FeatureFlags.persist());
          // Atualiza visual do menu marcado
          await trayManager.setContextMenu(
            Menu(
              items: [
                MenuItem(key: 'show_window', label: 'Abrir bandeja'),
                MenuItem.separator(),
                MenuItem(
                  key: 'toggle_autoclear_in',
                  label: 'Auto limpar entrada',
                  checked: FeatureFlags.autoClearInbound,
                ),
                MenuItem.separator(),
                MenuItem(key: 'exit_app', label: 'Fechar o aplicativo'),
              ],
            ),
          );
          break;
        case 'exit_app':
          await SystemHelper.exit();
          break;
        default:
          debugPrint('Menu item desconhecido: ${menuItem.key}');
      }
    } catch (e) {
      debugPrint('Erro ao executar ação do menu: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container();
  }
}
