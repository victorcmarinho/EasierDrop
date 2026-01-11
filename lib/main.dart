import 'dart:convert';

import 'package:desktop_multi_window/desktop_multi_window.dart';
import 'package:flutter/cupertino.dart';
import 'package:macos_ui/macos_ui.dart';
import 'package:provider/provider.dart';

import 'package:easier_drop/helpers/app_constants.dart';
import 'package:easier_drop/helpers/keyboard_shortcuts.dart';
import 'package:easier_drop/helpers/system.dart';
import 'package:easier_drop/l10n/app_localizations.dart';
import 'package:easier_drop/providers/files_provider.dart';
import 'package:easier_drop/screens/file_transfer_screen.dart';
import 'package:easier_drop/screens/settings_screen.dart';
import 'package:easier_drop/screens/update_screen.dart';
import 'package:easier_drop/screens/welcome_screen.dart';
import 'package:easier_drop/services/analytics_service.dart';
import 'package:easier_drop/services/settings_service.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

Future<void> main(List<String> args) async {
  WidgetsFlutterBinding.ensureInitialized();

  await AnalyticsService.instance.initialize();
  AnalyticsService.instance.appStarted();

  if (args.firstOrNull == 'multi_window') {
    final windowId = args[1];

    final controller = await WindowController.fromCurrentEngine();
    final argument = controller.arguments.isNotEmpty
        ? jsonDecode(controller.arguments) as Map<String, dynamic>
        : <String, dynamic>{};

    await SystemHelper.initialize(isSecondaryWindow: true, windowId: windowId);

    final String initialRoute = argument['args'] ?? AppConstants.routeHome;

    runApp(
      MultiProvider(
        providers: [ChangeNotifierProvider(create: (_) => FilesProvider())],
        child: EasierDrop(isSecondaryWindow: true, initialRoute: initialRoute),
      ),
    );
  } else {
    await SystemHelper.initialize();

    runApp(
      MultiProvider(
        providers: [ChangeNotifierProvider(create: (_) => FilesProvider())],
        child: const EasierDrop(initialRoute: AppConstants.routeHome),
      ),
    );
  }
}

class EasierDrop extends StatelessWidget {
  final bool isSecondaryWindow;
  final String initialRoute;

  const EasierDrop({
    super.key,
    this.isSecondaryWindow = false,
    this.initialRoute = AppConstants.routeHome,
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

        // Define localized strings helper
        // We need a context to get localizations, but PlatformMenuBar is outside MacosApp.
        // However, PlatformMenuBar builds with the context of the builder.
        // We can move PlatformMenuBar inside.
        // But AppLocalizations.of(context) usually requires Localizations widget ancestor.
        // MacosApp provides it.
        // So we should put PlatformMenuBar INSIDE MacosApp's builder or wrap MacosApp and assume context has it?
        // No, context passed to AnimatedBuilder is above MacosApp?
        // Wait, main() -> runApp(MultiProvider(child: EasierDrop)) -> Shortcuts -> Actions -> _buildApp
        // -> AnimatedBuilder -> MacosApp.
        // AppLocalizations is typically configured in MacosApp.
        // If we place PlatformMenuBar around MacosApp, it won't have access to AppLocalizations OF MacosApp.
        // We should use `WidgetsApp` or `MaterialApp` localizations?
        // Actually, the keys for menu items need to be localized.
        // PlatformMenuBar can be constructed dynamically.
        // If I put it inside `MacosApp`'s `builder` property it would work, but `MacosApp` doesn't expose `builder` easily like MaterialApp does.
        // `MacosApp` creates `WidgetsApp`.
        // If I put it inside `home`? MacosApp has `builder`?
        // Looking at file, `MacosApp` has `routes`.
        // If I can't put it inside, I have to provide keys manually or use a Builder below MacosApp?
        // But PlatformMenuBar puts menu at system level.
        // Solution: Wrap the `child` of `MacosApp` in a `Builder` that returns `PlatformMenuBar`?
        // Can `PlatformMenuBar` be anywhere? Yes.
        // So I can wrap the `MacosWindow` in `FileTransferScreen`.
        // But that's per screen.
        // If I put it in `_buildApp`, I don't have localizations yet.
        // But I can get localizations if I ensure `EasierDrop` is wrapped in Localizations? No, it's the root.
        // Issue: Localizing menu items at root app level.
        // If I can't get localizations, I might defaults or simple english?
        // Or I can use `builder` of `MacosApp` if it exists.
        // Let's assume MacosApp has `builder`? The file shows it doesn't use it.
        // Checking `MacosApp` source (mental check): it usually has `builder`.
        // If not, I'll place `PlatformMenuBar` inside `MacosWindow` contents or `WelcomeScreen`.
        // Placing it in `WelcomeScreen` means it only appears there.
        // Putting it in `builder` of `MacosApp` is best.
        // I will declare `builder: (context, child) { return PlatformMenuBar(..., child: child); }` in `MacosApp`.

        return MacosApp(
          navigatorKey: navigatorKey,
          title: 'Easier Drop',
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          locale: locale,
          theme: MacosThemeData.light(),
          darkTheme: MacosThemeData.dark(),
          initialRoute: initialRoute,
          routes: {
            AppConstants.routeHome: (_) => isSecondaryWindow
                ? const MacosWindow(child: FileTransferScreen())
                : const WelcomeScreen(),
            AppConstants.routeSettings: (_) =>
                const MacosWindow(child: SettingsScreen()),
            AppConstants.routeShare: (_) =>
                const MacosWindow(child: FileTransferScreen()),
            AppConstants.routeUpdate: (_) =>
                const MacosWindow(child: UpdateScreen()),
          },
          builder: (context, child) {
            return _buildMenuBar(context, child);
          },
        );
      },
    );
  }

  Widget _buildMenuBar(BuildContext context, Widget? child) {
    final loc = AppLocalizations.of(context);
    final checkUpdateLabel = loc?.checkForUpdates ?? 'Check for Updates...';

    return PlatformMenuBar(
      menus: [
        PlatformMenu(
          label: 'Easier Drop',
          menus: [
            PlatformProvidedMenuItem(type: PlatformProvidedMenuItemType.about),
            PlatformMenuItemGroup(
              members: [
                PlatformMenuItem(
                  label: checkUpdateLabel,
                  onSelected: () => _checkForUpdates(context),
                ),
              ],
            ),
            PlatformProvidedMenuItem(type: PlatformProvidedMenuItemType.quit),
          ],
        ),
      ],
      child: child ?? const SizedBox.shrink(),
    );
  }

  Future<void> _checkForUpdates(BuildContext context) async {
    await SystemHelper.openUpdateWindow();
  }

  Locale? _parseLocale(String? localeCode) {
    if (localeCode == null) return null;

    final parts = localeCode.split('_');
    return parts.length == 2 ? Locale(parts[0], parts[1]) : Locale(parts[0]);
  }
}
