import 'package:easier_drop/helpers/system.dart';
import 'package:easier_drop/providers/files_provider.dart';
import 'package:easier_drop/screens/file_transfer_screen.dart';
import 'package:easier_drop/theme/app_theme.dart';
import 'package:easier_drop/l10n/app_localizations.dart';
import 'package:easier_drop/services/settings_service.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import 'package:flutter/services.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

class _ClearAllIntent extends Intent {
  const _ClearAllIntent();
}

class _ShareIntent extends Intent {
  const _ShareIntent();
}

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
      shortcuts: <LogicalKeySet, Intent>{
        LogicalKeySet(LogicalKeyboardKey.meta, LogicalKeyboardKey.backspace):
            const _ClearAllIntent(),
        LogicalKeySet(LogicalKeyboardKey.meta, LogicalKeyboardKey.delete):
            const _ClearAllIntent(),
        LogicalKeySet(
              LogicalKeyboardKey.meta,
              LogicalKeyboardKey.shift,
              LogicalKeyboardKey.keyC,
            ):
            const _ShareIntent(),
        LogicalKeySet(LogicalKeyboardKey.meta, LogicalKeyboardKey.enter):
            const _ShareIntent(),
      },
      child: Actions(
        actions: <Type, Action<Intent>>{
          _ClearAllIntent: CallbackAction<_ClearAllIntent>(
            onInvoke: (intent) {
              final ctx = navigatorKey.currentContext;
              if (ctx == null) return null;
              final provider = ctx.read<FilesProvider>();
              provider.clear();
              return null;
            },
          ),
          _ShareIntent: CallbackAction<_ShareIntent>(
            onInvoke: (intent) {
              final ctx = navigatorKey.currentContext;
              if (ctx == null) return null;
              final provider = ctx.read<FilesProvider>();
              provider.shared();
              return null;
            },
          ),
        },
        child: AnimatedBuilder(
          animation: SettingsService.instance,
          builder: (context, _) {
            final settings = SettingsService.instance;
            Locale? forced;
            if (settings.localeCode != null) {
              final parts = settings.localeCode!.split('_');
              forced =
                  parts.length == 2
                      ? Locale(parts[0], parts[1])
                      : Locale(parts[0]);
            }
            return MaterialApp(
              navigatorKey: navigatorKey,
              onGenerateTitle: (ctx) => AppLocalizations.of(ctx).t('app.title'),
              theme: AppTheme.lightTheme,
              darkTheme: AppTheme.darkTheme,
              themeMode: ThemeMode.system,
              debugShowCheckedModeBanner: false,
              localizationsDelegates: const [
                AppLocalizationsDelegate(),
                GlobalWidgetsLocalizations.delegate,
                GlobalMaterialLocalizations.delegate,
                GlobalCupertinoLocalizations.delegate,
              ],
              supportedLocales: AppLocalizations.supportedLocales,
              locale: forced,
              scrollBehavior: const MaterialScrollBehavior().copyWith(
                dragDevices: {
                  PointerDeviceKind.mouse,
                  PointerDeviceKind.trackpad,
                  PointerDeviceKind.touch,
                },
              ),
              home: const FileTransferScreen(),
            );
          },
        ),
      ),
    );
  }
}
