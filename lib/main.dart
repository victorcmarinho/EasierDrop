import 'package:easier_drop/helpers/system.dart';
import 'package:easier_drop/providers/files_provider.dart';
import 'package:easier_drop/screens/welcome_screen.dart';
import 'package:easier_drop/l10n/app_localizations.dart';
import 'package:easier_drop/services/settings_service.dart';
import 'package:easier_drop/helpers/keyboard_shortcuts.dart';
import 'package:flutter/widgets.dart';
import 'package:macos_ui/macos_ui.dart';
import 'package:provider/provider.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await SystemHelper.setup();

  runApp(
    MultiProvider(
      providers: [ChangeNotifierProvider(create: (_) => FilesProvider())],
      child: const EasierDrop(),
    ),
  );
}

class EasierDrop extends StatelessWidget {
  const EasierDrop({super.key});

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
          debugShowCheckedModeBanner: false,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          locale: locale,
          theme: MacosThemeData.light(),
          darkTheme: MacosThemeData.dark(),
          home: const WelcomeScreen(),
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
