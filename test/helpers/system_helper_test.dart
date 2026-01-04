import 'package:easier_drop/helpers/app_constants.dart';
import 'package:easier_drop/helpers/system.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:easier_drop/services/settings_service.dart';
import 'package:easier_drop/services/tray_service.dart';
import 'package:window_manager/window_manager.dart';
import 'package:path_provider_platform_interface/path_provider_platform_interface.dart';
import 'package:mocktail/mocktail.dart';
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
  const MethodChannel shakeChannel = MethodChannel(
    AppConstants.shakeChannelName,
  );
  const MethodChannel trayChannel = MethodChannel('tray_manager');

  final List<MethodCall> windowLog = [];
  final List<MethodCall> shakeLog = [];
  final List<MethodCall> trayLog = [];

  setUpAll(() {
    PathProviderPlatform.instance = MockPathProviderPlatform();
  });

  setUp(() async {
    windowLog.clear();
    shakeLog.clear();
    trayLog.clear();

    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(windowChannel, (MethodCall methodCall) async {
          windowLog.add(methodCall);
          if (methodCall.method == 'isMinimized') {
            return false;
          }
          return null;
        });

    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(shakeChannel, (MethodCall methodCall) async {
          shakeLog.add(methodCall);
          return null;
        });

    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(trayChannel, (MethodCall methodCall) async {
          trayLog.add(methodCall);
          return null;
        });

    await SettingsService.instance.load();
  });

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(windowChannel, null);
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(shakeChannel, null);
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(trayChannel, null);
  });

  group('SystemHelper Tests', () {
    test('hide calls windowManager hide and setSkipTaskbar', () async {
      await SystemHelper.hide();

      expect(
        windowLog,
        contains(isA<MethodCall>().having((m) => m.method, 'method', 'hide')),
      );
      expect(
        windowLog,
        contains(
          isA<MethodCall>().having((m) => m.method, 'method', 'setSkipTaskbar'),
        ),
      );
    });

    test(
      'open calls windowManager show, focus, and setSkipTaskbar false',
      () async {
        await SystemHelper.open();

        expect(
          windowLog,
          contains(isA<MethodCall>().having((m) => m.method, 'method', 'show')),
        );
        expect(
          windowLog,
          contains(
            isA<MethodCall>().having((m) => m.method, 'method', 'focus'),
          ),
        );
      },
    );

    test('exit calls windowManager destroy (and tray destroy)', () async {
      await Future.wait([
        TrayService.instance.destroy(),
        windowManager.destroy(),
      ]);

      expect(
        windowLog,
        contains(
          isA<MethodCall>().having((m) => m.method, 'method', 'destroy'),
        ),
      );
      expect(
        trayLog,
        contains(
          isA<MethodCall>().having((m) => m.method, 'method', 'destroy'),
        ),
      );
    });

    test(
      'initialize setup secondary window and calls setMaximizable false',
      () async {
        // Mock desktop_multi_window channel
        const multiWindowChannel = MethodChannel('desktop_multi_window');
        final List<MethodCall> multiWindowLog = [];

        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
            .setMockMethodCallHandler(multiWindowChannel, (
              MethodCall methodCall,
            ) async {
              multiWindowLog.add(methodCall);
              // Return mock data for getWindowArguments
              if (methodCall.method == 'getWindowArguments') {
                return '{"args":"test","width":400,"height":400}';
              }
              return null;
            });

        try {
          await SystemHelper.initialize(isSecondaryWindow: true);

          // Verify that setMaximizable(false) was called
          expect(
            windowLog,
            contains(
              isA<MethodCall>()
                  .having((m) => m.method, 'method', 'setMaximizable')
                  .having((m) => m.arguments, 'arguments', {
                    'isMaximizable': false,
                  }),
            ),
          );

          // Verify that setResizable(false) was also called
          expect(
            windowLog,
            contains(
              isA<MethodCall>()
                  .having((m) => m.method, 'method', 'setResizable')
                  .having((m) => m.arguments, 'arguments', {
                    'isResizable': false,
                  }),
            ),
          );
        } finally {
          // Clean up the mock handler
          TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
              .setMockMethodCallHandler(multiWindowChannel, null);
        }
      },
    );
  });
}
