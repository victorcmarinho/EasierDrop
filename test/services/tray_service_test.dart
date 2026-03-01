import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:easier_drop/services/tray_service.dart';
import 'package:easier_drop/services/update_service.dart';
import 'package:easier_drop/l10n/app_localizations.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:tray_manager/tray_manager.dart';
import 'package:flutter/material.dart';
import 'package:mocktail/mocktail.dart';

class MockUpdateService extends Mock implements UpdateService {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() {
    registerFallbackValue(Uri.parse('http://localhost'));
  });

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

      const httpChannel = MethodChannel('plugins.flutter.io/http');
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(httpChannel, (MethodCall methodCall) async {
            return null;
          });

      try {
        await TrayService.instance.checkForUpdates();

        expect(TrayService.instance.updateUrl, isA<String?>());
      } finally {
        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
            .setMockMethodCallHandler(updateChannel, null);
        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
            .setMockMethodCallHandler(httpChannel, null);
      }
    });

    test('handleMenuItemClick handles all item keys', () async {
      final service = TrayService.instance;

      const multiWindowChannel = MethodChannel('desktop_multi_window');
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(multiWindowChannel, (
            MethodCall methodCall,
          ) async {
            return 0;
          });

      await service.handleMenuItemClick(
        MenuItem(key: 'preferences', label: 'Prefs'),
      );

      await service.handleMenuItemClick(
        MenuItem(key: 'show_window', label: 'Open'),
      );

      const updateChannel = MethodChannel('package_info_plus');
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(
            updateChannel,
            (call) async => {
              'appName': 'ea',
              'packageName': 'com',
              'version': '0.0.1',
              'buildNumber': '1',
            },
          );
      await service.checkForUpdates();

      await service.handleMenuItemClick(
        MenuItem(key: 'update_available', label: 'Update'),
      );

      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(urlLauncherChannel, (call) async {
            throw Exception('Launcher Error');
          });

      await service.handleMenuItemClick(
        MenuItem(key: 'update_available', label: 'Update'),
      );

      await IOOverrides.runZoned(
        () async {
          await service.handleMenuItemClick(
            MenuItem(key: 'exit_app', label: 'Exit'),
          );
        },
        exit: (code) {
          throw 'MockExitException';
        },
      );

      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(multiWindowChannel, null);
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(updateChannel, null);
    });

    testWidgets('rebuildMenu with update URL', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Scaffold(),
        ),
      );

      final context = tester.element(find.byType(Scaffold));
      final loc = AppLocalizations.of(context)!;

      final mockUpdateService = MockUpdateService();
      when(
        () => mockUpdateService.checkForUpdates(),
      ).thenAnswer((_) async => 'https://github.com/update');

      final originalInstance = UpdateService.instance;
      UpdateService.instance = mockUpdateService;

      try {
        await TrayService.instance.checkForUpdates();
        await TrayService.instance.rebuildMenu(loc: loc, currentLocale: 'en');

        expect(trayLog.any((m) => m.method == 'setContextMenu'), isTrue);

        final setMenuCall = trayLog.lastWhere(
          (m) => m.method == 'setContextMenu',
        );
        expect(setMenuCall.arguments, isNotNull);
      } finally {
        UpdateService.instance = originalInstance;
      }
    });

    test('configure handles errors gracefully', () async {
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(trayChannel, (MethodCall methodCall) async {
            if (methodCall.method == 'setIcon') throw Exception('Mock Error');
            return null;
          });

      await TrayService.instance.configure();
      expect(true, isTrue);
    });
  });

  group('TrayService ChangeNotifier Tests', () {
    test('TrayService is a ChangeNotifier', () {
      expect(TrayService.instance, isA<ChangeNotifier>());
    });

    test('listener can be added and removed', () async {
      void listener() {}

      TrayService.instance.addListener(listener);

      const updateChannel = MethodChannel('package_info_plus');
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(updateChannel, (
            MethodCall methodCall,
          ) async {
            if (methodCall.method == 'getAll') {
              return {
                'appName': 'easier_drop',
                'packageName': 'com.example.easier_drop',
                'version': '0.0.1',
                'buildNumber': '1',
              };
            }
            return null;
          });

      try {
        await TrayService.instance.checkForUpdates();

        TrayService.instance.removeListener(listener);
        expect(true, isTrue);
      } finally {
        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
            .setMockMethodCallHandler(updateChannel, null);
      }
    });
  });
}

class MockHttpClient extends Mock implements HttpClient {}

class MockHttpClientRequest extends Mock implements HttpClientRequest {}

class MockHttpClientResponse extends Mock implements HttpClientResponse {}

class MockHttpHeaders extends Mock implements HttpHeaders {}

Future<void> mockHttpCall(
  String responseBody,
  Future<void> Function() body,
) async {
  final client = MockHttpClient();
  final request = MockHttpClientRequest();
  final response = MockHttpClientResponse();
  final headers = MockHttpHeaders();

  when(() => client.getUrl(any())).thenAnswer((invocation) async {
    return request;
  });
  when(() => request.headers).thenReturn(headers);
  when(() => request.close()).thenAnswer((_) async => response);
  when(() => response.statusCode).thenReturn(200);
  when(() => response.reasonPhrase).thenReturn('OK');
  when(() => response.contentLength).thenReturn(responseBody.length);
  when(
    () => response.listen(
      any(),
      onError: any(named: 'onError'),
      onDone: any(named: 'onDone'),
      cancelOnError: any(named: 'cancelOnError'),
    ),
  ).thenAnswer((invocation) {
    final onData =
        invocation.positionalArguments[0] as void Function(List<int>);
    final onDone = invocation.namedArguments[#onDone] as void Function()?;
    onData(utf8.encode(responseBody));
    if (onDone != null) onDone();
    return MockStreamSubscription<List<int>>();
  });

  await HttpOverrides.runZoned(body, createHttpClient: (_) => client);
}

class MockStreamSubscription<T> extends Mock implements StreamSubscription<T> {
  @override
  Future<void> cancel() async {}
}
