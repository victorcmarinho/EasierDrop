import 'dart:convert';
import 'package:easier_drop/helpers/system.dart';
import 'package:desktop_multi_window/desktop_multi_window.dart';
import 'package:easier_drop/services/analytics_service.dart';

import 'package:easier_drop/providers/files_provider.dart';
import 'package:easier_drop/screens/welcome_screen.dart';
import 'package:easier_drop/l10n/app_localizations.dart';
import 'package:easier_drop/services/settings_service.dart';
import 'package:easier_drop/helpers/keyboard_shortcuts.dart';

import 'package:easier_drop/screens/file_transfer_screen.dart';
import 'package:easier_drop/screens/settings_screen.dart';
import 'package:flutter/widgets.dart';
import 'package:macos_ui/macos_ui.dart';
import 'package:provider/provider.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

Future<void> main(List<String> args) async {
  WidgetsFlutterBinding.ensureInitialized();

  await AnalyticsService.instance.initialize();
  AnalyticsService.instance.appStarted();

  if (args.firstOrNull == 'multi_window') {
    final windowId = args[1];

    final controller = await WindowController.fromCurrentEngine();
    final argument =
        controller.arguments.isNotEmpty
            ? jsonDecode(controller.arguments) as Map<String, dynamic>
            : <String, dynamic>{};

    await SystemHelper.initialize(isSecondaryWindow: true, windowId: windowId);

    runApp(
      MultiProvider(
        providers: [ChangeNotifierProvider(create: (_) => FilesProvider())],
        child: EasierDrop(
          isSecondaryWindow: true,
          isSettingsWindow: argument['args'] == 'settings_window',
        ),
      ),
    );
  } else {
    await SystemHelper.initialize();

    runApp(
      MultiProvider(
        providers: [ChangeNotifierProvider(create: (_) => FilesProvider())],
        child: const EasierDrop(),
      ),
    );
  }
}

class EasierDrop extends StatelessWidget {
  final bool isSecondaryWindow;
  final bool isSettingsWindow;

  const EasierDrop({
    super.key,
    this.isSecondaryWindow = false,
    this.isSettingsWindow = false,
  });

  @override
  Widget build(BuildContext context) {
    return Shortcuts(
      shortcuts: KeyboardShortcuts.shortcuts,
      child: Actions(
        actions: KeyboardShortcuts.createActions(context),
        child: _buildApp(),
      ),
    );
  }

  Widget _buildApp() {
    return AnimatedBuilder(
      animation: SettingsService.instance,
      builder: (context, _) {
        final settings = SettingsService.instance;
        final locale = _parseLocale(settings.localeCode);

        return MacosApp(
          navigatorKey: navigatorKey,
          title: 'Easier Drop',
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          locale: locale,
          theme: MacosThemeData.light(),
          darkTheme: MacosThemeData.dark(),
          home:
              isSettingsWindow
                  ? const MacosWindow(child: SettingsScreen())
                  : isSecondaryWindow
                  ? const MacosWindow(child: FileTransferScreen())
                  : const WelcomeScreen(),
        );
      },
    );
  }

  Locale? _parseLocale(String? localeCode) {
    if (localeCode == null) return null;

    final parts = localeCode.split('_');
    return parts.length == 2 ? Locale(parts[0], parts[1]) : Locale(parts[0]);
  }
}
