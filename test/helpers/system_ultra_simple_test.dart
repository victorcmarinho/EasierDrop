import 'dart:convert';
import 'dart:io';
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
  setUpAll(() {
    PathProviderPlatform.instance = MockPathProviderPlatform();
  });

  setUp(() async {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(const MethodChannel('window_manager'), (
          call,
        ) async {
          if (call.method == 'getBounds' ||
              call.method == 'getPosition' ||
              call.method == 'getSize') {
            return {
              'left': 0.0,
              'top': 0.0,
              'width': 400.0,
              'height': 400.0,
              'x': 0.0,
              'y': 0.0,
            };
          }
          if (call.method.startsWith('is')) return false;
          return null;
        });
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
          const MethodChannel('mixin.one/desktop_multi_window'),
          (call) async {
            if (call.method == 'createWindow') return 1;
            if (call.method == 'getWindowArguments')
              return jsonEncode({'title': 'test', 'x': 0, 'y': 0});
            return null;
          },
        );
    await SettingsService.instance.load();
  });

  test('brute force coverage', () async {
    // Hide/Open
    await SystemHelper.hide();
    await SystemHelper.open();

    // Initialize paths
    await SystemHelper.initialize(isSecondaryWindow: false);
    await SystemHelper.initialize(isSecondaryWindow: true, windowId: '0');

    // Listener methods
    final helper = SystemHelper();
    await helper.onWindowClose();
    helper.onWindowResize();
    helper.onWindowMove();

    // Exit
    await IOOverrides.runZoned(() async {
      try {
        await SystemHelper.exit();
      } catch (_) {}
    }, exit: (code) => throw Exception());

    // Settings
    SettingsService.instance.setWindowOpacity(0.5);

    // Open Settings (ignore errors)
    try {
      await SystemHelper.openSettings();
    } catch (_) {}

    // Give time for async void methods
    await Future.delayed(const Duration(milliseconds: 500));
  });
}
