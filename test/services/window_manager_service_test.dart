import 'dart:async';
import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:window_manager/window_manager.dart';
import 'package:easier_drop/services/window_manager_service.dart';
import 'package:easier_drop/services/settings_service.dart';
import 'package:easier_drop/services/tray_service.dart';
import 'package:easier_drop/services/analytics_service.dart';
import 'package:easier_drop/model/app_settings.dart';
import 'package:easier_drop/helpers/app_constants.dart';
import '../mocks/window_manager_mock.dart';

class MockTrayService extends Mock implements TrayService {}
class MockSettingsService extends Mock implements SettingsService {}
class MockAnalyticsService extends Mock implements AnalyticsService {}
class FakeWindowListener extends Fake implements WindowListener {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late WindowManagerService service;
  late MockWindowManager mockWindowManager;
  late MockTrayService mockTrayService;
  late MockSettingsService mockSettingsService;
  late MockAnalyticsService mockAnalyticsService;

  setUpAll(() {
    registerFallbackValue(FakeWindowListener());
    registerFallbackValue(const Size(0, 0));
    registerFallbackValue(const Offset(0, 0));
    registerFallbackValue(const Rect.fromLTWH(0, 0, 0, 0));
    registerFallbackValue(const WindowOptions());
    registerFallbackValue(TitleBarStyle.normal);
  });

  setUp(() {
    mockWindowManager = MockWindowManager();
    mockTrayService = MockTrayService();
    mockSettingsService = MockSettingsService();
    mockAnalyticsService = MockAnalyticsService();

    // Setup instances
    WindowManagerService.instance.mockWindowManager = mockWindowManager;
    service = WindowManagerService.instance;
    service.resetForTesting();

    TrayService.instance = mockTrayService;
    SettingsService.instance = mockSettingsService;
    AnalyticsService.instance = mockAnalyticsService;

    // Default mocks
    when(() => mockSettingsService.settings).thenReturn(const AppSettings());
    when(() => mockTrayService.configure()).thenAnswer((_) async {});
    when(() => mockWindowManager.addListener(any())).thenReturn(null);
    when(() => mockWindowManager.ensureInitialized()).thenAnswer((_) async {});
    when(() => mockWindowManager.setResizable(any())).thenAnswer((_) async {});
    when(() => mockWindowManager.setMaximizable(any())).thenAnswer((_) async {});
    when(() => mockWindowManager.waitUntilReadyToShow(any(), any())).thenAnswer((invocation) async {
      final callback = invocation.positionalArguments[1] as Function;
      await callback();
    });
    when(() => mockWindowManager.setPreventClose(any())).thenAnswer((_) async {});
    when(() => mockWindowManager.setVisibleOnAllWorkspaces(any())).thenAnswer((_) async {});
    when(() => mockWindowManager.setPosition(any(), animate: any(named: 'animate'))).thenAnswer((_) async {});
  });

  group('WindowManagerService', () {
    test('initialize main window sets up tray and window managers', () async {
      when(() => mockSettingsService.windowX).thenReturn(100.0);
      when(() => mockSettingsService.windowY).thenReturn(100.0);
      
      await service.initialize(isSecondaryWindow: false);
      
      verify(() => mockWindowManager.addListener(service)).called(1);
      verify(() => mockTrayService.configure()).called(1);
      verify(() => mockWindowManager.ensureInitialized()).called(1);
      verify(() => mockWindowManager.setPosition(const Offset(100, 100), animate: false)).called(1);
    });

    test('initialize secondary window sets up window correcty', () async {
      final args = jsonEncode({
        'title': 'Test Window',
        'width': 300.0,
        'height': 200.0,
        'center': true,
      });

      // Mock MethodChannel for desktop_multi_window
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(const MethodChannel('mixin.one/desktop_multi_window'), (methodCall) async {
        if (methodCall.method == 'getAllWindows') {
          return [{'windowId': '0', 'windowArgument': args}];
        }
        if (methodCall.method == 'getWindowDefinition') {
          return {'windowId': '0', 'windowArgument': args};
        }
        if (methodCall.method == 'window_show') return null;
        if (methodCall.method == 'createWindow') return '1';
        return null;
      });

      when(() => mockWindowManager.setTitle(any())).thenAnswer((_) async {});
      when(() => mockWindowManager.setTitleBarStyle(any(), windowButtonVisibility: any(named: 'windowButtonVisibility'))).thenAnswer((_) async {});
      when(() => mockWindowManager.setAlwaysOnTop(any())).thenAnswer((_) async {});
      when(() => mockWindowManager.setSize(any())).thenAnswer((_) async {});
      when(() => mockWindowManager.center()).thenAnswer((_) async {});

      await service.initialize(isSecondaryWindow: true, windowId: 'sec-1');

      verify(() => mockWindowManager.setTitle(any())).called(1);
      verify(() => mockWindowManager.setSize(const Size(300, 200))).called(1);
      verify(() => mockWindowManager.center()).called(1);
    });

    test('initialize secondary window with bounds sets up window correcty', () async {
      final args = jsonEncode({
        'title': 'Bounds Window',
        'width': 300.0,
        'height': 200.0,
        'x': 10.0,
        'y': 20.0,
      });

      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(const MethodChannel('mixin.one/desktop_multi_window'), (methodCall) async {
        if (methodCall.method == 'getWindowDefinition') {
          return {'windowId': '0', 'windowArgument': args};
        }
        if (methodCall.method == 'window_show') return null;
        return null;
      });

      when(() => mockWindowManager.setBounds(any())).thenAnswer((_) async {});
      when(() => mockWindowManager.setTitle(any())).thenAnswer((_) async {});
      when(() => mockWindowManager.setTitleBarStyle(any(), windowButtonVisibility: any(named: 'windowButtonVisibility'))).thenAnswer((_) async {});
      when(() => mockWindowManager.setAlwaysOnTop(any())).thenAnswer((_) async {});

      await service.initialize(isSecondaryWindow: true);

      verify(() => mockWindowManager.setBounds(const Rect.fromLTWH(10, 20, 300, 200))).called(1);
    });

    test('initialize secondary window handles errors', () async {
      // Cause an error by returning invalid JSON
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(const MethodChannel('mixin.one/desktop_multi_window'), (methodCall) async {
        if (methodCall.method == 'getWindowDefinition') {
          return {'windowId': 'sec-err', 'windowArgument': 'invalid-json'};
        }
        if (methodCall.method == 'window_show') return null;
        return null;
      });

      when(() => mockWindowManager.ensureInitialized()).thenAnswer((_) async {});
      when(() => mockWindowManager.setTitleBarStyle(any(), windowButtonVisibility: any(named: 'windowButtonVisibility'))).thenAnswer((_) async {});
      when(() => mockWindowManager.setResizable(any())).thenAnswer((_) async {});
      when(() => mockWindowManager.setMaximizable(any())).thenAnswer((_) async {});
      when(() => mockWindowManager.setAlwaysOnTop(any())).thenAnswer((_) async {});

      when(() => mockAnalyticsService.warn(any())).thenReturn(null);

      await service.initialize(isSecondaryWindow: true, windowId: 'sec-err');

      verify(() => mockAnalyticsService.warn(any(that: contains('Failed to setup secondary window')))).called(1);
    });

    test('onSettingsChanged updates opacity and alwaysOnTop', () async {
      when(() => mockWindowManager.setOpacity(any())).thenAnswer((_) async {});
      when(() => mockWindowManager.setAlwaysOnTop(any())).thenAnswer((_) async {});
      
      final settings = const AppSettings(windowOpacity: 0.8, isAlwaysOnTop: true);
      when(() => mockSettingsService.settings).thenReturn(settings);
      
      late Function() settingsListener;
      when(() => mockSettingsService.addListener(any())).thenAnswer((invocation) {
        settingsListener = invocation.positionalArguments[0] as Function();
      });

      await service.initialize();
      
      settingsListener();

      verify(() => mockWindowManager.setOpacity(0.8)).called(1);
      verify(() => mockWindowManager.setAlwaysOnTop(true)).called(1);
    });

    test('createNewWindow creates a share window', () async {
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(const MethodChannel('mixin.one/desktop_multi_window'), (methodCall) async {
        if (methodCall.method == 'getAllWindows') {
          return [{'windowId': '0', 'windowArgument': '{}'}];
        }
        if (methodCall.method == 'createWindow') return '1';
        return null;
      });
      when(() => mockAnalyticsService.debug(any(), tag: any(named: 'tag'))).thenReturn(null);
      when(() => mockAnalyticsService.shakeWindowCreated()).thenReturn(null);

      await service.createNewWindow(400, 300);

      verify(() => mockAnalyticsService.shakeWindowCreated()).called(1);
    });

    test('createNewWindow ignores if max windows reached', () async {
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(const MethodChannel('mixin.one/desktop_multi_window'), (methodCall) async {
        if (methodCall.method == 'getAllWindows') {
          return List.generate(
            AppConstants.maxWindows,
            (i) => {'windowId': '$i', 'windowArgument': '{}'},
          );
        }
        return null;
      });
      when(() => mockAnalyticsService.debug(any(), tag: any(named: 'tag'))).thenReturn(null);
      when(() => mockAnalyticsService.shakeLimitReached()).thenReturn(null);

      await service.createNewWindow(400, 300);

      verify(() => mockAnalyticsService.shakeLimitReached()).called(1);
    });

    test('onWindowClose calls hide', () async {
      when(() => mockWindowManager.hide()).thenAnswer((_) async {});
      when(() => mockWindowManager.setSkipTaskbar(any())).thenAnswer((_) async {});
      when(() => mockAnalyticsService.windowHidden()).thenReturn(null);

      service.onWindowClose();

      verify(() => mockWindowManager.hide()).called(1);
    });

    test('openSettings creates a settings window', () async {
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(const MethodChannel('mixin.one/desktop_multi_window'), (methodCall) async {
        if (methodCall.method == 'createWindow') return '1';
        if (methodCall.method == 'window_show') return null;
        return null;
      });
      when(() => mockAnalyticsService.settingsOpened()).thenReturn(null);

      await service.openSettings();

      verify(() => mockAnalyticsService.settingsOpened()).called(1);
    });

    test('openUpdateWindow creates an update window', () async {
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(const MethodChannel('mixin.one/desktop_multi_window'), (methodCall) async {
        if (methodCall.method == 'createWindow') return '1';
        if (methodCall.method == 'window_show') return null;
        return null;
      });

      await service.openUpdateWindow();
    });

    test('hide calls windowManager.hide', () async {
      when(() => mockWindowManager.hide()).thenAnswer((_) async {});
      when(() => mockWindowManager.setSkipTaskbar(any())).thenAnswer((_) async {});
      when(() => mockAnalyticsService.windowHidden()).thenReturn(null);

      await service.hide();

      verify(() => mockWindowManager.hide()).called(1);
      verify(() => mockWindowManager.setSkipTaskbar(true)).called(1);
      verify(() => mockAnalyticsService.windowHidden()).called(1);
    });

    test('open calls windowManager.show and focus', () async {
      when(() => mockWindowManager.show()).thenAnswer((_) async {});
      when(() => mockWindowManager.focus()).thenAnswer((_) async {});
      when(() => mockWindowManager.setSkipTaskbar(any())).thenAnswer((_) async {});
      when(() => mockAnalyticsService.windowShown()).thenReturn(null);

      await service.open();

      verify(() => mockWindowManager.show()).called(1);
      verify(() => mockWindowManager.focus()).called(1);
      verify(() => mockWindowManager.setSkipTaskbar(false)).called(1);
      verify(() => mockAnalyticsService.windowShown()).called(1);
    });

    test('onWindowResize debounces and saves bounds', () async {
      final completer = Completer<void>();
      when(() => mockWindowManager.getSize()).thenAnswer((_) async => const Size(200, 200));
      when(() => mockSettingsService.setWindowBounds(w: 200, h: 200)).thenAnswer((_) {
        completer.complete();
      });

      service.onWindowResize();
      
      await completer.future;
      verify(() => mockSettingsService.setWindowBounds(w: 200, h: 200)).called(1);
    });

    test('onWindowMove debounces and saves position', () async {
      final completer = Completer<void>();
      when(() => mockWindowManager.getPosition()).thenAnswer((_) async => const Offset(50, 50));
      when(() => mockSettingsService.setWindowBounds(x: 50, y: 50)).thenAnswer((_) {
        completer.complete();
      });

      service.onWindowMove();
      
      await completer.future;
      verify(() => mockSettingsService.setWindowBounds(x: 50, y: 50)).called(1);
    });

    test('restoreWindowPosition handles errors', () async {
      when(() => mockSettingsService.windowX).thenReturn(10);
      when(() => mockSettingsService.windowY).thenReturn(20);
      when(() => mockWindowManager.setPosition(any(), animate: any(named: 'animate')))
          .thenThrow(Exception('Native error'));
      when(() => mockAnalyticsService.warn(any())).thenReturn(null);

      // Trigger restore by initializing a main window
      when(() => mockWindowManager.ensureInitialized()).thenAnswer((_) async {});
      when(() => mockWindowManager.setResizable(any())).thenAnswer((_) async {});
      when(() => mockWindowManager.setMaximizable(any())).thenAnswer((_) async {});
      when(() => mockWindowManager.waitUntilReadyToShow(any(), any())).thenAnswer((invocation) {
        final callback = invocation.positionalArguments[1] as Function();
        callback();
        return Future.value();
      });
      when(() => mockWindowManager.addListener(any())).thenReturn(null);
      when(() => mockTrayService.configure()).thenAnswer((_) async {});

      await service.initialize();

      verify(() => mockAnalyticsService.warn(any(that: contains('Failed to restore window position')))).called(1);
    });

    test('exitApp destroys tray and window', () async {
      when(() => mockTrayService.destroy()).thenAnswer((_) async {});
      when(() => mockWindowManager.destroy()).thenAnswer((_) async {});
      
      var exited = false;
      service.mockExitApp = () async { exited = true; };

      await service.exitApp();

      verify(() => mockTrayService.destroy()).called(1);
      verify(() => mockWindowManager.destroy()).called(1);
      expect(exited, isTrue);
    });
  });
}
