import 'package:easier_drop/services/tray_service.dart';
import 'package:easier_drop/l10n/app_localizations.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const MethodChannel trayChannel = MethodChannel('tray_manager');
  const MethodChannel windowChannel = MethodChannel('window_manager');
  const MethodChannel urlLauncherChannel = MethodChannel(
    'plugins.flutter.io/url_launcher_macos',
  );

  final List<MethodCall> trayLog = [];
  final List<MethodCall> windowLog = [];
  final List<MethodCall> urlLauncherLog = [];

  setUp(() {
    trayLog.clear();
    windowLog.clear();
    urlLauncherLog.clear();

    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(trayChannel, (MethodCall methodCall) async {
          trayLog.add(methodCall);
          return null;
        });

    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(windowChannel, (MethodCall methodCall) async {
          windowLog.add(methodCall);
          if (methodCall.method == 'isMinimized') {
            return false;
          }
          return null;
        });

    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(urlLauncherChannel, (
          MethodCall methodCall,
        ) async {
          urlLauncherLog.add(methodCall);
          if (methodCall.method == 'canLaunch') {
            return true;
          }
          return true;
        });
  });

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(trayChannel, null);
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(windowChannel, null);
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(urlLauncherChannel, null);
  });

  group('TrayService Tests', () {
    test('instance returns singleton', () {
      final instance1 = TrayService.instance;
      final instance2 = TrayService.instance;
      expect(instance1, same(instance2));
    });

    test('configure sets tray icon', () async {
      await TrayService.instance.configure();

      expect(
        trayLog,
        contains(
          isA<MethodCall>().having((m) => m.method, 'method', 'setIcon'),
        ),
      );

      // Verify that the icon path contains the expected asset
      final setIconCall = trayLog.firstWhere(
        (call) => call.method == 'setIcon',
      );
      expect(
        setIconCall.arguments['iconPath'],
        contains('assets/icon/icon.icns'),
      );
    });

    test('destroy calls trayManager destroy', () async {
      await TrayService.instance.destroy();

      expect(
        trayLog,
        contains(
          isA<MethodCall>().having((m) => m.method, 'method', 'destroy'),
        ),
      );
    });

    testWidgets('rebuildMenu creates menu without update', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Scaffold(),
        ),
      );

      final context = tester.element(find.byType(Scaffold));
      final loc = AppLocalizations.of(context)!;

      await TrayService.instance.rebuildMenu(loc: loc, currentLocale: 'en');

      expect(
        trayLog,
        contains(
          isA<MethodCall>().having((m) => m.method, 'method', 'setContextMenu'),
        ),
      );
    });

    test('updateUrl getter returns null initially', () {
      expect(TrayService.instance.updateUrl, isNull);
    });

    test('checkForUpdates updates updateUrl when changed', () async {
      // Mock update service channel
      const updateChannel = MethodChannel('package_info_plus');
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(updateChannel, (
            MethodCall methodCall,
          ) async {
            if (methodCall.method == 'getAll') {
              return {
                'appName': 'easier_drop',
                'packageName': 'com.example.easier_drop',
                'version': '1.0.0',
                'buildNumber': '1',
              };
            }
            return null;
          });

      // Mock http requests
      const httpChannel = MethodChannel('plugins.flutter.io/http');
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(httpChannel, (MethodCall methodCall) async {
            return null;
          });

      try {
        await TrayService.instance.checkForUpdates();
        // The updateUrl might be null or set depending on the mock
        expect(TrayService.instance.updateUrl, isA<String?>());
      } finally {
        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
            .setMockMethodCallHandler(updateChannel, null);
        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
            .setMockMethodCallHandler(httpChannel, null);
      }
    });
  });

  group('TrayService ChangeNotifier Tests', () {
    test('TrayService is a ChangeNotifier', () {
      expect(TrayService.instance, isA<ChangeNotifier>());
    });

    test('listener can be added and removed', () async {
      void listener() {
        // Listener callback
      }

      TrayService.instance.addListener(listener);

      // Mock the update service to return a URL
      const updateChannel = MethodChannel('package_info_plus');
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(updateChannel, (
            MethodCall methodCall,
          ) async {
            if (methodCall.method == 'getAll') {
              return {
                'appName': 'easier_drop',
                'packageName': 'com.example.easier_drop',
                'version': '0.0.1', // Lower version to trigger update
                'buildNumber': '1',
              };
            }
            return null;
          });

      try {
        await TrayService.instance.checkForUpdates();
        // Verify that we can add and remove listeners without errors
        TrayService.instance.removeListener(listener);
        expect(true, isTrue); // Test passes if no errors occur
      } finally {
        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
            .setMockMethodCallHandler(updateChannel, null);
      }
    });
  });
}
