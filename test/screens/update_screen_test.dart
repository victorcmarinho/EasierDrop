import 'dart:async';

import 'package:easier_drop/l10n/app_localizations.dart';
import 'package:easier_drop/screens/update_screen.dart';
import 'package:easier_drop/services/update_service.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:macos_ui/macos_ui.dart';
import 'package:mocktail/mocktail.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';
import 'package:url_launcher_platform_interface/url_launcher_platform_interface.dart';
import 'package:flutter/material.dart';

class MockUpdateService extends Mock implements UpdateService {}

class MockUrlLauncher extends Mock
    with MockPlatformInterfaceMixin
    implements UrlLauncherPlatform {}

class FakeLaunchOptions extends Fake implements LaunchOptions {}

void main() {
  late MockUpdateService mockUpdateService;
  late MockUrlLauncher mockUrlLauncher;

  setUpAll(() {
    registerFallbackValue(FakeLaunchOptions());
  });

  setUp(() {
    mockUpdateService = MockUpdateService();
    UpdateService.instance = mockUpdateService;

    mockUrlLauncher = MockUrlLauncher();
    UrlLauncherPlatform.instance = mockUrlLauncher;

    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(const MethodChannel('window_manager'), (
          MethodCall methodCall,
        ) async {
          if (methodCall.method == 'ensureInitialized') {
            return null;
          }
          if (methodCall.method == 'setAlwaysOnTop') {
            return null;
          }
          if (methodCall.method == 'close') {
            return null;
          }
          return null;
        });
  });

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(const MethodChannel('window_manager'), null);
  });

  Future<void> pumpUpdateScreen(WidgetTester tester) async {
    await tester.pumpWidget(
      const MacosApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        locale: Locale('pt'),
        home: UpdateScreen(),
      ),
    );
  }

  group('UpdateScreen Tests', () {
    testWidgets('exibe indicador de carregamento inicialmente', (
      WidgetTester tester,
    ) async {
      final completer = Completer<(String?, Object?)>();
      when(
        () => mockUpdateService.checkForUpdates(),
      ).thenAnswer((_) => completer.future);

      await pumpUpdateScreen(tester);
      await tester.pump();

      expect(find.byType(ProgressCircle), findsOneWidget);

      completer.complete((null, null));
      await tester.pumpAndSettle();
    });

    testWidgets('exibe ícone de sucesso quando não houver atualizações disponíveis', (
      WidgetTester tester,
    ) async {
      final completer = Completer<(String?, Object?)>();
      when(
        () => mockUpdateService.checkForUpdates(),
      ).thenAnswer((_) => completer.future);

      await pumpUpdateScreen(tester);
      await tester.pump();

      completer.complete((null, null));
      await tester.pumpAndSettle();

      expect(find.text('OK'), findsOneWidget);
    });

    testWidgets('exibe atualização disponível e botões de baixar/depois', (
      WidgetTester tester,
    ) async {
      const updateUrl = 'https://example.com/update';
      final completer = Completer<(String?, Object?)>();
      when(
        () => mockUpdateService.checkForUpdates(),
      ).thenAnswer((_) => completer.future);

      await pumpUpdateScreen(tester);
      await tester.pump();

      completer.complete((updateUrl, null));
      await tester.pumpAndSettle();

      expect(find.text('Baixar'), findsOneWidget);
      expect(find.text('Depois'), findsOneWidget);
    });

    testWidgets('exibe mensagem de erro na falha', (WidgetTester tester) async {
      final completer = Completer<(String?, Object?)>();
      when(
        () => mockUpdateService.checkForUpdates(),
      ).thenAnswer((_) => completer.future);

      await pumpUpdateScreen(tester);
      await tester.pump();

      completer.complete((null, 'Erro de Rede'));
      await tester.pumpAndSettle();

      expect(find.text('Erro de Rede'), findsOneWidget);
      expect(find.text('Fechar'), findsOneWidget);
    });

    testWidgets('clicar em Baixar abre a URL e fecha a janela', (
      WidgetTester tester,
    ) async {
      const updateUrl = 'https://example.com/update';
      final completer = Completer<(String?, Object?)>();

      when(
        () => mockUpdateService.checkForUpdates(),
      ).thenAnswer((_) => completer.future);
      when(
        () => mockUrlLauncher.launchUrl(any(), any()),
      ).thenAnswer((_) async => true);

      await pumpUpdateScreen(tester);
      await tester.pump();

      completer.complete((updateUrl, null));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Baixar'));
      await tester.pump();

      verify(() => mockUrlLauncher.launchUrl(updateUrl, any())).called(1);
    });
  });
}
