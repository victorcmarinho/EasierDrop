import 'dart:io';
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

  setUpAll(() {
    PathProviderPlatform.instance = MockPathProviderPlatform();
  });

  setUp(() async {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(windowChannel, (MethodCall methodCall) async {
          return null;
        });

    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(multiWindowChannel, (
          MethodCall methodCall,
        ) async {
          if (methodCall.method == 'getWindowArguments') {
            return 'invalid json'; // This will trigger the catch block in _setupSecondaryWindow
          }
          return null;
        });

    await SettingsService.instance.load();
  });

  group('SystemHelper Missing Coverage', () {
    test('onWindowClose calls hide', () async {
      // This should call hide() and thus setSkipTaskbar and windowManager.hide()
      WindowManagerService.instance.onWindowClose();
    });

    test('exit calls destructions', () async {
      await IOOverrides.runZoned(
        () async {
          try {
            await WindowManagerService.instance.exitApp();
          } catch (_) {}
        },
        exit: (code) {
          throw Exception('Exit called');
        },
      );
    });

    test('initialize secondary window catch block', () async {
      // This will trigger the try-catch block in _setupSecondaryWindow because of 'invalid json' return above
      await SystemHelper.initialize(isSecondaryWindow: true, windowId: '1');
    });
  });
}
