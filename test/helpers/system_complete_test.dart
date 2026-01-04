import 'dart:convert';
import 'dart:io';
import 'package:easier_drop/helpers/app_constants.dart';
import 'package:easier_drop/helpers/system.dart';
import 'package:easier_drop/services/settings_service.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:path_provider_platform_interface/path_provider_platform_interface.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class MockPathProviderPlatform extends Mock
    with MockPlatformInterfaceMixin
    implements PathProviderPlatform {
  @override
  Future<String?> getApplicationSupportPath() async => '.';
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const MethodChannel windowChannel = MethodChannel('window_manager');
  const MethodChannel multiWindowChannel = MethodChannel(
    'mixin.one/desktop_multi_window',
  );

  final List<MethodCall> windowLog = [];
  final List<MethodCall> multiWindowLog = [];

  setUpAll(() {
    PathProviderPlatform.instance = MockPathProviderPlatform();
  });

  setUp(() async {
    windowLog.clear();
    multiWindowLog.clear();

    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(windowChannel, (MethodCall methodCall) async {
          windowLog.add(methodCall);
          switch (methodCall.method) {
            case 'isMinimized':
            case 'isFullScreen':
            case 'isAlwaysOnTop':
            case 'isPreventClose':
            case 'isMaximized':
            case 'isVisible':
            case 'isClosable':
            case 'isResizable':
            case 'isMaximizable':
            case 'isMinimizable':
            case 'isMovable':
            case 'isFocused':
              return false;
            case 'getBounds':
              return {'x': 100.0, 'y': 100.0, 'width': 400.0, 'height': 400.0};
            case 'getPosition':
              return {'x': 100.0, 'y': 100.0};
            case 'getSize':
              return {'width': 400.0, 'height': 400.0};
            case 'waitUntilReadyToShow':
              return null;
            case 'setPosition':
              if (methodCall.arguments['x'] == 999.0) {
                throw Exception('Mock position error');
              }
              return null;
            default:
              return null;
          }
        });

    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(multiWindowChannel, (
          MethodCall methodCall,
        ) async {
          multiWindowLog.add(methodCall);
          switch (methodCall.method) {
            case 'getWindowArguments':
              return jsonEncode({
                'args': 'test',
                'title': 'Mock Title',
                'width': 400.0,
                'height': 400.0,
                'x': 100.0,
                'y': 100.0,
              });
            case 'createWindow':
              return 1; // Return an int ID
            case 'show':
            case 'hide':
            case 'focus':
            case 'setFrame':
            case 'center':
              return null;
            default:
              return null;
          }
        });

    // Reset settings
    await SettingsService.instance.load();
  });

  group('SystemHelper Comprehensive Tests', () {
    test('hide and open', () async {
      await SystemHelper.hide();
      expect(windowLog.any((m) => m.method == 'hide'), isTrue);

      windowLog.clear();
      await SystemHelper.open();
      expect(windowLog.any((m) => m.method == 'show'), isTrue);
    });

    test('openSettings creates window', () async {
      await SystemHelper.openSettings();
      expect(multiWindowLog.any((m) => m.method == 'createWindow'), isTrue);
    });

    test('exit calls destroy', () async {
      await IOOverrides.runZoned(
        () async {
          try {
            await SystemHelper.exit();
          } catch (_) {}
          expect(windowLog.any((m) => m.method == 'destroy'), isTrue);
        },
        exit: (code) {
          throw Exception('Exit called');
        },
      );
    });

    test('onWindowClose calls hide', () async {
      final helper = SystemHelper();
      await helper.onWindowClose();
      expect(windowLog.any((m) => m.method == 'hide'), isTrue);
    });

    test('initialize secondary window', () async {
      await SystemHelper.initialize(isSecondaryWindow: true, windowId: '1');
      expect(windowLog.any((m) => m.method == 'ensureInitialized'), isTrue);
      expect(windowLog.any((m) => m.method == 'setTitle'), isTrue);
    });

    test('initialize main window', () async {
      await SystemHelper.initialize(isSecondaryWindow: false);
      expect(windowLog.any((m) => m.method == 'ensureInitialized'), isTrue);
    });

    test('window events', () async {
      final helper = SystemHelper();
      helper.onWindowResize();
      await Future.delayed(const Duration(milliseconds: 200));
      expect(windowLog.any((m) => m.method == 'getSize'), isTrue);

      helper.onWindowMove();
      await Future.delayed(const Duration(milliseconds: 200));
      expect(windowLog.any((m) => m.method == 'getPosition'), isTrue);
    });

    test('shake event', () async {
      await SystemHelper.initialize();
      await TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .handlePlatformMessage(
            AppConstants.shakeChannelName,
            const StandardMethodCodec().encodeMethodCall(
              const MethodCall('shake_detected', {'x': 100.0, 'y': 100.0}),
            ),
            (ByteData? data) {},
          );
      expect(multiWindowLog.any((m) => m.method == 'createWindow'), isTrue);
    });

    test('settings changed', () async {
      await SystemHelper.initialize();
      SettingsService.instance.setWindowOpacity(0.5);
      await Future.delayed(const Duration(milliseconds: 200));
      expect(windowLog.any((m) => m.method == 'setOpacity'), isTrue);
    });

    test('restore position error handling', () async {
      SettingsService.instance.setWindowBounds(x: 999.0, y: 999.0);
      await SystemHelper.initialize();
      // Should not crash
    });
  });
}
