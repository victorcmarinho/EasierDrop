import 'dart:convert';
import 'dart:io';
import 'package:easier_drop/helpers/app_constants.dart';
import 'package:easier_drop/helpers/system.dart';
import 'package:easier_drop/services/window_manager_service.dart';
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
    SettingsService.instance.resetForTesting();

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
              return {
                'left': 100.0,
                'top': 100.0,
                'width': 400.0,
                'height': 400.0,
                'x': 100.0,
                'y': 100.0,
              };
            case 'getPosition':
              return {'x': 100.0, 'y': 100.0};
            case 'getSize':
              return {'width': 400.0, 'height': 400.0};
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
                'title': 'Test Title',
                'width': 500.0,
                'height': 500.0,
                'x': 100.0,
                'y': 100.0,
                'center': true,
              });
            case 'createWindow':
              return '1';
            default:
              return null;
          }
        });

    await SettingsService.instance.load();
  });

  group('SystemHelper Final 100% Coverage', () {
    test('lifecycle: hide, open, exit', () async {
      await WindowManagerService.instance.hide();
      await WindowManagerService.instance.open();
      await IOOverrides.runZoned(() async {
        try {
          await WindowManagerService.instance.exitApp();
        } catch (_) {}
      }, exit: (code) => throw Exception());
    });

    test('initialization: main and secondary', () async {
      await SystemHelper.initialize(isSecondaryWindow: false);

      await SystemHelper.initialize(isSecondaryWindow: true, windowId: '0');

      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(multiWindowChannel, (call) async {
            if (call.method == 'getWindowArguments') return 'invalid';
            return null;
          });
      await SystemHelper.initialize(isSecondaryWindow: true, windowId: '1');
    });

    test('window listener methods', () async {
      WindowManagerService.instance.onWindowClose();

      SettingsService.instance.setWindowBounds(w: 0.0, h: 0.0);
      WindowManagerService.instance.onWindowResize();

      for (
        int i = 0;
        i < 10 && SettingsService.instance.settings.windowW != 400.0;
        i++
      ) {
        await Future.delayed(const Duration(milliseconds: 100));
      }
      expect(SettingsService.instance.settings.windowW, equals(400.0));

      SettingsService.instance.setWindowBounds(x: 0.0, y: 0.0);
      WindowManagerService.instance.onWindowMove();
      for (
        int i = 0;
        i < 10 && SettingsService.instance.settings.windowX != 100.0;
        i++
      ) {
        await Future.delayed(const Duration(milliseconds: 100));
      }
      expect(SettingsService.instance.settings.windowX, equals(100.0));
    });

    test('shake event and settings trigger', () async {
      await SystemHelper.initialize();

      await TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .handlePlatformMessage(
            AppConstants.shakeChannelName,
            const StandardMethodCodec().encodeMethodCall(
              const MethodCall('shake_detected', {'x': 0.0, 'y': 0.0}),
            ),
            (_) {},
          );

      SettingsService.instance.setWindowOpacity(0.5);
      await Future.delayed(const Duration(milliseconds: 100));
    });

    test('openSettings and restore position error', () async {
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(multiWindowChannel, (call) async {
            if (call.method == 'createWindow') return 1;
            if (call.method == 'getWindowArguments') {
              return jsonEncode({'args': 'test'});
            }
            return null;
          });

      try {
        await WindowManagerService.instance.openSettings();
      } catch (_) {
        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
            .setMockMethodCallHandler(multiWindowChannel, (call) async {
              if (call.method == 'createWindow') return '1';
              if (call.method == 'getWindowArguments') {
                return jsonEncode({'args': 'test'});
              }
              return null;
            });
        await WindowManagerService.instance.openSettings();
      }

      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(windowChannel, (call) async {
            if (call.method == 'setPosition') throw Exception();
            if (call.method.startsWith('is')) return false;
            return null;
          });
      SettingsService.instance.setWindowBounds(x: 1, y: 1);
      await SystemHelper.initialize();
    });
  });
}
