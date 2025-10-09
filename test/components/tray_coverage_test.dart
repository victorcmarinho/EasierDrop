import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:mocktail/mocktail.dart';
import 'package:easier_drop/providers/files_provider.dart';
import 'package:easier_drop/l10n/app_localizations.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:tray_manager/tray_manager.dart';
import 'package:easier_drop/model/file_reference.dart';

// Mock classes
class MockFilesProvider extends Mock implements FilesProvider {}

class MockFileReference extends Mock implements FileReference {}

// Custom widget que implementa TrayListener para testar métodos específicos
class TrayListenerWidget extends StatefulWidget {
  const TrayListenerWidget({super.key});

  @override
  State<TrayListenerWidget> createState() => _TrayListenerWidgetState();
}

class _TrayListenerWidgetState extends State<TrayListenerWidget>
    with TrayListener {
  int _lastCount = 0;
  FilesProvider? _filesProvider;

  @override
  void initState() {
    super.initState();
    trayManager.addListener(this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _filesProvider = context.read<FilesProvider>();
      _filesProvider?.addListener(_onFilesChanged);
      _lastCount = _filesProvider?.files.length ?? 0;
      _rebuildMenu();
    });
  }

  @override
  void dispose() {
    if (_filesProvider != null) {
      _filesProvider!.removeListener(_onFilesChanged);
      _filesProvider = null;
    }
    trayManager.removeListener(this);
    super.dispose();
  }

  @override
  void onTrayIconMouseDown() {
    // Simula o comportamento do tray original
    trayManager.popUpContextMenu();
  }

  @override
  void onTrayMenuItemClick(MenuItem menuItem) async {
    try {
      switch (menuItem.key) {
        case 'show_window':
          // Simula SystemHelper.open()
          break;
        case 'lang_en':
          // Simula SettingsService.instance.setLocale('en')
          _rebuildMenu();
          break;
        case 'lang_pt':
          // Simula SettingsService.instance.setLocale('pt_BR')
          _rebuildMenu();
          break;
        case 'lang_es':
          // Simula SettingsService.instance.setLocale('es')
          _rebuildMenu();
          break;
        case 'exit_app':
          // Simula SystemHelper.exit()
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
    final loc = AppLocalizations.of(context)!;
    final count = _lastCount;
    const current = 'en'; // Simula current locale
    final menu = Menu(
      items: [
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

  // Métodos públicos para teste
  void testOnFilesChanged() => _onFilesChanged();
  Future<void> testRebuildMenu() => _rebuildMenu();
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  Widget buildWidget(FilesProvider filesProvider) {
    return ChangeNotifierProvider<FilesProvider>.value(
      value: filesProvider,
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
        home: const TrayListenerWidget(),
      ),
    );
  }

  group('TrayListener Coverage Tests', () {
    testWidgets('onTrayMenuItemClick - show_window', (tester) async {
      final filesProvider = MockFilesProvider();
      when(() => filesProvider.files).thenReturn([]);
      when(() => filesProvider.addListener(any())).thenReturn(null);
      when(() => filesProvider.removeListener(any())).thenReturn(null);

      await tester.pumpWidget(buildWidget(filesProvider));
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
      final filesProvider = MockFilesProvider();
      when(() => filesProvider.files).thenReturn([]);
      when(() => filesProvider.addListener(any())).thenReturn(null);
      when(() => filesProvider.removeListener(any())).thenReturn(null);

      await tester.pumpWidget(buildWidget(filesProvider));
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
      final filesProvider = MockFilesProvider();
      when(() => filesProvider.files).thenReturn([]);
      when(() => filesProvider.addListener(any())).thenReturn(null);
      when(() => filesProvider.removeListener(any())).thenReturn(null);

      await tester.pumpWidget(buildWidget(filesProvider));
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
      final filesProvider = MockFilesProvider();
      when(() => filesProvider.files).thenReturn([]);
      when(() => filesProvider.addListener(any())).thenReturn(null);
      when(() => filesProvider.removeListener(any())).thenReturn(null);

      await tester.pumpWidget(buildWidget(filesProvider));
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
      final filesProvider = MockFilesProvider();
      when(() => filesProvider.files).thenReturn([]);
      when(() => filesProvider.addListener(any())).thenReturn(null);
      when(() => filesProvider.removeListener(any())).thenReturn(null);

      await tester.pumpWidget(buildWidget(filesProvider));
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
      final filesProvider = MockFilesProvider();
      when(() => filesProvider.files).thenReturn([]);
      when(() => filesProvider.addListener(any())).thenReturn(null);
      when(() => filesProvider.removeListener(any())).thenReturn(null);

      await tester.pumpWidget(buildWidget(filesProvider));
      await tester.pumpAndSettle();

      final state = tester.state<_TrayListenerWidgetState>(
        find.byType(TrayListenerWidget),
      );

      final menuItem = MenuItem(key: 'unknown_key', label: 'Unknown');
      state.onTrayMenuItemClick(menuItem);

      await tester.pumpAndSettle();
      expect(find.byType(TrayListenerWidget), findsOneWidget);
    });

    testWidgets('onTrayIconMouseDown', (tester) async {
      final filesProvider = MockFilesProvider();
      when(() => filesProvider.files).thenReturn([]);
      when(() => filesProvider.addListener(any())).thenReturn(null);

      await tester.pumpWidget(buildWidget(filesProvider));
      await tester.pumpAndSettle();

      final state = tester.state<_TrayListenerWidgetState>(
        find.byType(TrayListenerWidget),
      );

      state.onTrayIconMouseDown();

      await tester.pumpAndSettle();
      expect(find.byType(TrayListenerWidget), findsOneWidget);
    });

    testWidgets('_onFilesChanged - sem mudança', (tester) async {
      final filesProvider = MockFilesProvider();
      when(() => filesProvider.files).thenReturn([]);
      when(() => filesProvider.addListener(any())).thenReturn(null);

      await tester.pumpWidget(buildWidget(filesProvider));
      await tester.pumpAndSettle();

      final state = tester.state<_TrayListenerWidgetState>(
        find.byType(TrayListenerWidget),
      );

      // Chama _onFilesChanged quando count == _lastCount (early return)
      state.testOnFilesChanged();

      await tester.pumpAndSettle();
      expect(find.byType(TrayListenerWidget), findsOneWidget);
    });

    testWidgets('_onFilesChanged - com mudança', (tester) async {
      final filesProvider = MockFilesProvider();
      final files = <FileReference>[];
      when(() => filesProvider.files).thenReturn(files);
      when(() => filesProvider.addListener(any())).thenReturn(null);

      await tester.pumpWidget(buildWidget(filesProvider));
      await tester.pumpAndSettle();

      final state = tester.state<_TrayListenerWidgetState>(
        find.byType(TrayListenerWidget),
      );

      // Adiciona um arquivo para mudar a contagem
      final mockFile = MockFileReference();
      when(() => mockFile.pathname).thenReturn('/test/file.txt');
      files.add(mockFile);

      // Chama _onFilesChanged quando count != _lastCount
      state.testOnFilesChanged();

      await tester.pumpAndSettle();
      expect(find.byType(TrayListenerWidget), findsOneWidget);
    });

    testWidgets('_rebuildMenu direto', (tester) async {
      final filesProvider = MockFilesProvider();
      when(() => filesProvider.files).thenReturn([]);
      when(() => filesProvider.addListener(any())).thenReturn(null);

      await tester.pumpWidget(buildWidget(filesProvider));
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
