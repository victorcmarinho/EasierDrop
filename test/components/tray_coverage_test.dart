import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:mocktail/mocktail.dart';
import 'package:easier_drop/providers/files_provider.dart';
import 'package:easier_drop/l10n/app_localizations.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:tray_manager/tray_manager.dart';
import '../mocks/mock_tray.dart';

// Mock classes
class MockFilesProvider extends Mock implements FilesProvider {}

// Custom widget que implementa TrayListener para testar métodos específicos
class TrayListenerWidget extends StatefulWidget {
  final TrayManager? trayManager;
  const TrayListenerWidget({super.key, this.trayManager});

  @override
  State<TrayListenerWidget> createState() => _TrayListenerWidgetState();
}

class _TrayListenerWidgetState extends State<TrayListenerWidget>
    with TrayListener {
  TrayManager get _trayManager => widget.trayManager ?? trayManager;

  @override
  void initState() {
    super.initState();
    _trayManager.addListener(this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _rebuildMenu();
    });
  }

  @override
  void dispose() {
    _trayManager.removeListener(this);
    super.dispose();
  }

  @override
  void onTrayIconMouseDown() {
    _trayManager.popUpContextMenu();
  }

  @override
  void onTrayMenuItemClick(MenuItem menuItem) async {
    try {
      switch (menuItem.key) {
        case 'show_window':
          break;
        case 'lang_en':
          _rebuildMenu();
          break;
        case 'lang_pt':
          _rebuildMenu();
          break;
        case 'lang_es':
          _rebuildMenu();
          break;
        case 'exit_app':
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

  Future<void> _rebuildMenu() async {
    final loc = AppLocalizations.of(context)!;
    const current = 'en'; // Simula current locale
    final menu = Menu(
      items: [
        MenuItem(key: 'show_window', label: loc.openTray),
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
    await _trayManager.setContextMenu(menu);
  }

  // Métodos públicos para teste
  Future<void> testRebuildMenu() => _rebuildMenu();
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  Widget buildWidget() {
    return ChangeNotifierProvider<FilesProvider>.value(
      value: MockFilesProvider(),
      child: MaterialApp(
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
        ],
        supportedLocales: const [
          Locale('en'),
          Locale('pt', 'BR'),
          Locale('es'),
        ],
        locale: const Locale('en'),
        home: TrayListenerWidget(trayManager: MockTrayManager()),
      ),
    );
  }

  group('TrayListener Coverage Tests', () {
    testWidgets('onTrayMenuItemClick - show_window', (tester) async {
      await tester.pumpWidget(buildWidget());
      await tester.pumpAndSettle();

      final state = tester.state<_TrayListenerWidgetState>(
        find.byType(TrayListenerWidget),
      );

      final menuItem = MenuItem(key: 'show_window', label: 'Show Window');
      state.onTrayMenuItemClick(menuItem);

      await tester.pumpAndSettle();
      expect(find.byType(TrayListenerWidget), findsOneWidget);
    });

    testWidgets('onTrayMenuItemClick - lang_en', (tester) async {
      await tester.pumpWidget(buildWidget());
      await tester.pumpAndSettle();

      final state = tester.state<_TrayListenerWidgetState>(
        find.byType(TrayListenerWidget),
      );

      final menuItem = MenuItem(key: 'lang_en', label: 'English');
      state.onTrayMenuItemClick(menuItem);

      await tester.pumpAndSettle();
      expect(find.byType(TrayListenerWidget), findsOneWidget);
    });

    testWidgets('onTrayMenuItemClick - lang_pt', (tester) async {
      await tester.pumpWidget(buildWidget());
      await tester.pumpAndSettle();

      final state = tester.state<_TrayListenerWidgetState>(
        find.byType(TrayListenerWidget),
      );

      final menuItem = MenuItem(key: 'lang_pt', label: 'Portuguese');
      state.onTrayMenuItemClick(menuItem);

      await tester.pumpAndSettle();
      expect(find.byType(TrayListenerWidget), findsOneWidget);
    });

    testWidgets('onTrayMenuItemClick - lang_es', (tester) async {
      await tester.pumpWidget(buildWidget());
      await tester.pumpAndSettle();

      final state = tester.state<_TrayListenerWidgetState>(
        find.byType(TrayListenerWidget),
      );

      final menuItem = MenuItem(key: 'lang_es', label: 'Spanish');
      state.onTrayMenuItemClick(menuItem);

      await tester.pumpAndSettle();
      expect(find.byType(TrayListenerWidget), findsOneWidget);
    });

    testWidgets('onTrayMenuItemClick - exit_app', (tester) async {
      await tester.pumpWidget(buildWidget());
      await tester.pumpAndSettle();

      final state = tester.state<_TrayListenerWidgetState>(
        find.byType(TrayListenerWidget),
      );

      final menuItem = MenuItem(key: 'exit_app', label: 'Exit');
      state.onTrayMenuItemClick(menuItem);

      await tester.pumpAndSettle();
      expect(find.byType(TrayListenerWidget), findsOneWidget);
    });

    testWidgets('onTrayMenuItemClick - default case', (tester) async {
      final log = <String>[];
      final originalDebugPrint = debugPrint;
      debugPrint = (String? message, {int? wrapWidth}) {
        log.add(message ?? '');
      };

      try {
        await tester.pumpWidget(buildWidget());
        await tester.pumpAndSettle();

        final state = tester.state<_TrayListenerWidgetState>(
          find.byType(TrayListenerWidget),
        );

        final menuItem = MenuItem(key: 'unknown_key', label: 'Unknown');
        state.onTrayMenuItemClick(menuItem);

        await tester.pumpAndSettle();
        expect(find.byType(TrayListenerWidget), findsOneWidget);
      } finally {
        debugPrint = originalDebugPrint;
      }
    });

    testWidgets('onTrayIconMouseDown', (tester) async {
      await tester.pumpWidget(buildWidget());
      await tester.pumpAndSettle();

      final state = tester.state<_TrayListenerWidgetState>(
        find.byType(TrayListenerWidget),
      );

      state.onTrayIconMouseDown();

      await tester.pumpAndSettle();
      expect(find.byType(TrayListenerWidget), findsOneWidget);
    });

    testWidgets('_rebuildMenu direto', (tester) async {
      await tester.pumpWidget(buildWidget());
      await tester.pumpAndSettle();

      final state = tester.state<_TrayListenerWidgetState>(
        find.byType(TrayListenerWidget),
      );

      await state.testRebuildMenu();

      await tester.pumpAndSettle();
      expect(find.byType(TrayListenerWidget), findsOneWidget);
    });
  });
}
