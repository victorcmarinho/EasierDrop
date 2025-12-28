import 'package:easier_drop/helpers/system.dart';
import 'package:easier_drop/services/settings_service.dart';
import 'package:provider/provider.dart';
import 'package:easier_drop/providers/files_provider.dart';
import 'package:flutter/widgets.dart';
import 'package:tray_manager/tray_manager.dart';
import 'package:easier_drop/l10n/app_localizations.dart';
import 'package:easier_drop/services/update_service.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:async';

class Tray extends StatefulWidget {
  const Tray({super.key});

  @override
  State<Tray> createState() => _TrayState();
}

class _TrayState extends State<Tray> with TrayListener {
  int _lastCount = 0;
  String? _updateUrl;
  Timer? _updateTimer;

  // Guardar referência ao provider para evitar acesso ao context durante dispose
  FilesProvider? _filesProvider;

  @override
  void initState() {
    super.initState();
    trayManager.addListener(this);
    _checkForUpdates();
    _updateTimer = Timer.periodic(
      const Duration(hours: 6),
      (_) => _checkForUpdates(),
    );
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _filesProvider = context.read<FilesProvider>();
      _filesProvider?.addListener(_onFilesChanged);
      _lastCount = _filesProvider?.files.length ?? 0;
      _rebuildMenu();
    });
  }

  @override
  void dispose() {
    _updateTimer?.cancel();
    // Usar a referência salva em vez de acessar o context durante dispose
    if (_filesProvider != null) {
      _filesProvider!.removeListener(_onFilesChanged);
      _filesProvider = null;
    }
    trayManager.removeListener(this);
    super.dispose();
  }

  @override
  void onTrayIconMouseDown() {
    _checkForUpdates();
    trayManager.popUpContextMenu();
  }

  @override
  void onTrayMenuItemClick(MenuItem menuItem) async {
    try {
      switch (menuItem.key) {
        case 'update_available':
          if (_updateUrl != null) {
            await launchUrl(Uri.parse(_updateUrl!));
          }
          break;
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

  Future<void> _checkForUpdates() async {
    final url = await UpdateService.instance.checkForUpdates();
    if (url != _updateUrl && mounted) {
      setState(() {
        _updateUrl = url;
      });
      _rebuildMenu();
    }
  }

  void _onFilesChanged() {
    final provider = context.read<FilesProvider>();
    final count = provider.files.length;
    if (count == _lastCount) return;
    _lastCount = count;
    _rebuildMenu();
  }

  Future<void> _rebuildMenu() async {
    final loc = AppLocalizations.of(context)!;
    final count = _lastCount;
    final settings = SettingsService.instance;
    final current = settings.localeCode ?? loc.localeName.split('_').first;
    final menu = Menu(
      items: [
        if (_updateUrl != null) ...[
          MenuItem(key: 'update_available', label: '🌟 ${loc.updateAvailable}'),
          MenuItem.separator(),
        ],
        MenuItem(key: 'show_window', label: loc.openTray),
        MenuItem(
          key: 'files_count',
          label: count > 0 ? loc.trayFilesCount(count) : loc.trayFilesNone,
          toolTip: loc.filesCountTooltip,
        ),
        MenuItem.separator(),
        MenuItem(key: 'lang_label', label: loc.languageLabel),
        MenuItem(
          key: 'lang_en',
          label:
              current == 'en'
                  ? '• ${loc.languageEnglish}'
                  : loc.languageEnglish,
        ),
        MenuItem(
          key: 'lang_pt',
          label:
              (current == 'pt_BR' || current == 'pt')
                  ? '• ${loc.languagePortuguese}'
                  : loc.languagePortuguese,
        ),
        MenuItem(
          key: 'lang_es',
          label:
              current == 'es'
                  ? '• ${loc.languageSpanish}'
                  : loc.languageSpanish,
        ),
        MenuItem.separator(),
        MenuItem(key: 'exit_app', label: loc.trayExit),
      ],
    );
    await trayManager.setContextMenu(menu);
  }
}
