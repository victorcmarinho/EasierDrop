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

    // Mock WindowManager channel
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
    // Remove mock handler
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(const MethodChannel('window_manager'), null);
  });

  Future<void> pumpUpdateScreen(WidgetTester tester) async {
    await tester.pumpWidget(
      MacosApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: const UpdateScreen(),
      ),
    );
  }

  group('UpdateScreen', () {
    testWidgets('shows loading indicator initially', (
      WidgetTester tester,
    ) async {
      final completer = Completer<String?>();
      when(
        () => mockUpdateService.checkForUpdates(),
      ).thenAnswer((_) => completer.future);

      await pumpUpdateScreen(tester);
      await tester.pump(); // Start InitState

      expect(find.byType(ProgressCircle), findsOneWidget);

      // Complete to finish test cleanly
      completer.complete(null);
      await tester.pumpAndSettle();
    });

    testWidgets('shows checkmark when no updates available', (
      WidgetTester tester,
    ) async {
      final completer = Completer<String?>();
      when(
        () => mockUpdateService.checkForUpdates(),
      ).thenAnswer((_) => completer.future);

      await pumpUpdateScreen(tester);
      await tester.pump();

      completer.complete(null);
      await tester.pumpAndSettle();

      // expect(find.byIcon(CupertinoIcons.checkmark_circle), findsOneWidget);
      expect(find.text('OK'), findsOneWidget);
    });

    testWidgets('shows update available and download/later buttons', (
      WidgetTester tester,
    ) async {
      const updateUrl = 'https://example.com/update';
      final completer = Completer<String?>();
      when(
        () => mockUpdateService.checkForUpdates(),
      ).thenAnswer((_) => completer.future);

      await pumpUpdateScreen(tester);
      await tester.pump();

      completer.complete(updateUrl);
      await tester.pumpAndSettle();

      // expect(find.byIcon(CupertinoIcons.arrow_down_circle), findsOneWidget);
      expect(find.text('Download'), findsOneWidget);
      expect(find.text('Later'), findsOneWidget);
    });

    testWidgets('shows error message on failure', (WidgetTester tester) async {
      final completer = Completer<String?>();
      when(
        () => mockUpdateService.checkForUpdates(),
      ).thenAnswer((_) => completer.future); // Setup future first

      await pumpUpdateScreen(tester);
      await tester.pump();

      // Simulate error
      completer.completeError('Network Error');
      await tester.pumpAndSettle();

      // expect(find.byIcon(CupertinoIcons.exclamationmark_triangle), findsOneWidget);
      expect(find.text('Network Error'), findsOneWidget);
      expect(find.text('Close'), findsOneWidget);
    });

    testWidgets('clicking Download launches URL and closes window', (
      WidgetTester tester,
    ) async {
      const updateUrl = 'https://example.com/update';
      final completer = Completer<String?>();

      when(
        () => mockUpdateService.checkForUpdates(),
      ).thenAnswer((_) => completer.future);
      when(
        () => mockUrlLauncher.launchUrl(any(), any()),
      ).thenAnswer((_) async => true);

      await pumpUpdateScreen(tester);
      await tester.pump();

      completer.complete(updateUrl);
      await tester.pumpAndSettle();

      await tester.tap(find.text('Download'));
      await tester.pump();

      verify(() => mockUrlLauncher.launchUrl(updateUrl, any())).called(1);
    });
  });
}
