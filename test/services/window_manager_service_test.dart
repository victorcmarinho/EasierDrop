import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:easier_drop/services/window_manager_service.dart';
import 'package:easier_drop/services/settings_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('WindowManagerService', () {
    late WindowManagerService service;
    final List<MethodCall> windowManagerCalls = [];

    setUp(() {
      service = WindowManagerService.instance;
      service.resetForTesting();
      windowManagerCalls.clear();
      service.mockExitApp = null;

      SettingsService.instance.resetForTesting();

      final messenger =
          TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;

      // Mock para window_manager
      messenger.setMockMethodCallHandler(
        const MethodChannel('window_manager'),
        (call) async {
          windowManagerCalls.add(call);
          switch (call.method) {
            case 'getSize':
              return {'width': 250.0, 'height': 250.0};
            case 'getPosition':
              return {'x': 100.0, 'y': 100.0};
            case 'isFullScreen':
            case 'isMinimized':
            case 'isMaximized':
            case 'isAlwaysOnTop':
            case 'isVisible':
            case 'isFocused':
              return false;
            default:
              return null;
          }
        },
      );

      messenger.setMockMethodCallHandler(const MethodChannel('tray_manager'), (
        call,
      ) async {
        return null;
      });
    });

    test('initialize (main window) configura inicialização básica', () async {
      await service.initialize(isSecondaryWindow: false);
      expect(
        windowManagerCalls.any((c) => c.method == 'ensureInitialized'),
        isTrue,
      );
    });

    test('reage a mudanças de settings - alwaysOnTop', () async {
      await service.initialize();
      windowManagerCalls.clear();

      SettingsService.instance.setAlwaysOnTop(true);
      await Future.delayed(const Duration(milliseconds: 300));
      expect(
        windowManagerCalls.any((c) => c.method == 'setAlwaysOnTop'),
        isTrue,
      );
    });

    test('reage a mudanças de settings - opacity', () async {
      await service.initialize();
      windowManagerCalls.clear();

      SettingsService.instance.setWindowOpacity(0.5);
      await Future.delayed(const Duration(milliseconds: 300));
      expect(windowManagerCalls.any((c) => c.method == 'setOpacity'), isTrue);
    });

    test('hide e open chamam métodos nativos', () async {
      await service.hide();
      expect(windowManagerCalls.any((c) => c.method == 'hide'), isTrue);

      await service.open();
      expect(windowManagerCalls.any((c) => c.method == 'show'), isTrue);
    });

    test('exitApp encerra app com segurança', () async {
      bool exited = false;
      service.mockExitApp = () async => exited = true;

      await service.exitApp();
      expect(exited, isTrue);
      expect(windowManagerCalls.any((c) => c.method == 'destroy'), isTrue);
    });

    test('onWindowClose esconde janela', () async {
      service.onWindowClose();
      await Future.delayed(const Duration(milliseconds: 100));
      expect(windowManagerCalls.any((c) => c.method == 'hide'), isTrue);
    });

    test('WindowListener overrides implementados (no-op)', () {
      service.onWindowFocus();
      service.onWindowBlur();
      service.onWindowMaximize();
      service.onWindowUnmaximize();
      service.onWindowMinimize();
      service.onWindowRestore();
      service.onWindowEnterFullScreen();
      service.onWindowLeaveFullScreen();
      service.onWindowDocked();
      service.onWindowUndocked();
      service.onWindowMoved();
      service.onWindowResized();
    });
  });
}
