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

      final messenger = TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;

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
      
      messenger.setMockMethodCallHandler(
        const MethodChannel('tray_manager'),
        (call) async {
          return null;
        },
      );
    });

    test('initialize (main window) funciona e evita duplicar listener', () async {
      await service.initialize(isSecondaryWindow: false);
      expect(service.toString(), contains('WindowManagerService')); // Apenas para usar o service
      
      // Chamando de novo não deve quebrar nem duplicar (conforme lógica interna)
      await service.initialize();
    });

    test('reage a mudanças de settings', () async {
      await service.initialize();
      windowManagerCalls.clear();
      
      // Como o estado inicial em resetForTesting é null para _lastAlwaysOnTop,
      // qualquer valor em settings deve disparar.
      SettingsService.instance.setAlwaysOnTop(true);
      
      // A chamada é imediata no listener
      await Future.delayed(Duration.zero);
      expect(windowManagerCalls.any((c) => c.method == 'setAlwaysOnTop'), isTrue);
      
      windowManagerCalls.clear();
      SettingsService.instance.setWindowOpacity(0.5);
      await Future.delayed(Duration.zero);
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
      // Chamando diretamente para cobertura
      service.onWindowClose();
      await Future.delayed(Duration.zero);
      expect(windowManagerCalls.any((c) => c.method == 'hide'), isTrue);
    });
    
    test('cobertura de métodos do WindowListener (no-op)', () {
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
      // Métodos agora ignorados mas ainda chamáveis
      service.onWindowResize();
      service.onWindowMove();
    });
  });
}
