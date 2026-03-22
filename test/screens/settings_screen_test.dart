import 'package:easier_drop/screens/settings_screen.dart';
import 'package:easier_drop/services/settings_service.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/cupertino.dart';
import 'package:macos_ui/macos_ui.dart';
import 'package:easier_drop/l10n/app_localizations.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:path_provider_platform_interface/path_provider_platform_interface.dart';

class MockPathProviderPlatform extends PathProviderPlatform {
  @override
  Future<String> getApplicationSupportPath() async {
    return '.';
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late MethodChannel shakeChannel;
  late MethodChannel launchChannel;

  setUpAll(() {
    PathProviderPlatform.instance = MockPathProviderPlatform();
  });

  setUp(() {
    shakeChannel = const MethodChannel('com.easier_drop/shake');
    launchChannel = const MethodChannel('com.easierdrop/launch_at_login');

    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(shakeChannel, (MethodCall methodCall) async {
          if (methodCall.method == 'checkPermission') {
            return true;
          }
          return null;
        });

    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(launchChannel, (MethodCall methodCall) async {
          if (methodCall.method == 'checkPermission') {
            return true;
          }
          return null;
        });

    SettingsService.instance.resetForTesting();
  });

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(shakeChannel, null);
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(launchChannel, null);
  });

  Widget createWidgetUnderTest() {
    return MacosApp(
      theme: MacosThemeData.light(),
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [Locale('pt', '')],
      locale: const Locale('pt', ''),
      home: const SettingsScreen(),
    );
  }

  testWidgets('SettingsScreen renderiza corretamente', (WidgetTester tester) async {
    await tester.pumpWidget(createWidgetUnderTest());
    await tester.pumpAndSettle();

    expect(find.text('Preferências'), findsOneWidget);

    expect(find.text('GERAL'), findsOneWidget);
    expect(find.text('GESTO DE AGITAR'), findsOneWidget);
    expect(find.text('IDIOMA:'), findsOneWidget);

    expect(find.text('Iniciar no Login'), findsOneWidget);
    expect(find.text('Sempre no Topo'), findsOneWidget);
    expect(find.text('Gesto de Agitar'), findsOneWidget);

    expect(find.text('Ativo'), findsOneWidget);
  });

  testWidgets('SettingsScreen lida com falta de permissão', (
    WidgetTester tester,
  ) async {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(shakeChannel, (MethodCall methodCall) async {
          if (methodCall.method == 'checkPermission') {
            return false;
          }
          return null;
        });

    await tester.pumpWidget(createWidgetUnderTest());
    await tester.pumpAndSettle();

    expect(find.text('Inativo'), findsOneWidget);
  });

  testWidgets('Test lifecycle change manually triggers didChangeAppLifecycleState', (tester) async {
    await tester.pumpWidget(createWidgetUnderTest());
    await tester.pumpAndSettle();

    final state = tester.state(find.byType(SettingsScreen));
    // dynamic call since state is State<SettingsScreen> with WidgetsBindingObserver
    (state as dynamic).didChangeAppLifecycleState(AppLifecycleState.resumed);
    await tester.pumpAndSettle();
  });

  testWidgets('Test language selection calls settings.setLocale', (tester) async {
    await tester.pumpWidget(createWidgetUnderTest());
    await tester.pumpAndSettle();

    final segmentedControl = find.byType(CupertinoSlidingSegmentedControl<String>);
    expect(segmentedControl, findsOneWidget);

    // Tap on Spanish option. Wait, does tests render Spanish? Yes supportedLocales has pt.
    await tester.tap(find.text('Espanhol'));
    await tester.pumpAndSettle();

    expect(SettingsService.instance.localeCode, 'es');
  });

  testWidgets('Test language selection fallback covers pt_BR', (tester) async {
    SettingsService.instance.setLocale(null);
    await tester.pumpWidget(
      MacosApp(
        theme: MacosThemeData.light(),
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: const [Locale('pt', '')],
        locale: const Locale('pt', ''),
        home: const SettingsScreen(),
      ),
    );
    await tester.pumpAndSettle();
    final segmentedControl = find.byType(CupertinoSlidingSegmentedControl<String>);
    expect(segmentedControl, findsOneWidget);
  });

  testWidgets('Test language selection fallback covers es', (tester) async {
    SettingsService.instance.setLocale(null);
    await tester.pumpWidget(
      MacosApp(
        theme: MacosThemeData.light(),
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: const [Locale('es', '')],
        locale: const Locale('es', ''),
        home: const SettingsScreen(),
      ),
    );
    await tester.pumpAndSettle();
    final segmentedControl = find.byType(CupertinoSlidingSegmentedControl<String>);
    expect(segmentedControl, findsOneWidget);
  });

  testWidgets('Test language selection fallback covers en', (tester) async {
    SettingsService.instance.setLocale(null);
    await tester.pumpWidget(
      MacosApp(
        theme: MacosThemeData.light(),
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: const [Locale('en', '')],
        locale: const Locale('en', ''),
        home: const SettingsScreen(),
      ),
    );
    await tester.pumpAndSettle();
    final segmentedControl = find.byType(CupertinoSlidingSegmentedControl<String>);
    expect(segmentedControl, findsOneWidget);
  });
}
