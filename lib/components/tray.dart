import 'package:easier_drop/helpers/system.dart';
import 'package:easier_drop/services/settings_service.dart';
import 'package:provider/provider.dart';
import 'package:easier_drop/providers/files_provider.dart';
import 'package:flutter/widgets.dart';
import 'package:tray_manager/tray_manager.dart';
import 'package:easier_drop/l10n/app_localizations.dart';

class Tray extends StatefulWidget {
  const Tray({super.key});

  @override
  State<Tray> createState() => _TrayState();
}

class _TrayState extends State<Tray> with TrayListener {
  int _lastCount = 0;

  @override
  void initState() {
    super.initState();
    trayManager.addListener(this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = context.read<FilesProvider>();
      provider.addListener(_onFilesChanged);
      _lastCount = provider.files.length;
      _rebuildMenu();
    });
  }

  @override
  void dispose() {
    context.read<FilesProvider>().removeListener(_onFilesChanged);
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
        case 'lang_en':
          SettingsService.instance.setLocale('en');
          _rebuildMenu();
          break;
        case 'lang_pt':
          SettingsService.instance.setLocale('pt_BR');
          _rebuildMenu();
          break;
        case 'lang_es':
          SettingsService.instance.setLocale('es');
          _rebuildMenu();
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

  void _onFilesChanged() {
    final provider = context.read<FilesProvider>();
    final count = provider.files.length;
    if (count == _lastCount) return;
    _lastCount = count;
    _rebuildMenu();
  }

  Future<void> _rebuildMenu() async {
    final loc = AppLocalizations.of(context);
    final count = _lastCount;
    final settings = SettingsService.instance;
    final current = settings.localeCode ?? loc.locale.languageCode;
    final menu = Menu(
      items: [
        MenuItem(key: 'show_window', label: 'Abrir bandeja'),
        MenuItem(
          key: 'files_count',
          label:
              count > 0
                  ? loc.t(
                    'tray.files.count',
                    params: {'count': count.toString()},
                  )
                  : loc.t('tray.files.none'),
          toolTip: 'Quantidade atual na bandeja',
        ),
        MenuItem.separator(),
        MenuItem(key: 'lang_label', label: 'Idioma:'),
        MenuItem(
          key: 'lang_en',
          label: current == 'en' ? '• English' : 'English',
        ),
        MenuItem(
          key: 'lang_pt',
          label:
              current == 'pt_BR' || current == 'pt'
                  ? '• Português'
                  : 'Português',
        ),
        MenuItem(
          key: 'lang_es',
          label: current == 'es' ? '• Español' : 'Español',
        ),
        MenuItem.separator(),
        MenuItem(key: 'exit_app', label: loc.t('tray.exit')),
      ],
    );
    await trayManager.setContextMenu(menu);
  }
}
