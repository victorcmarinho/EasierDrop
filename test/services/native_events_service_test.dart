import 'dart:io' as io;
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:easier_drop/services/native_events_service.dart';
import 'package:easier_drop/helpers/app_constants.dart';
import 'package:url_launcher_platform_interface/url_launcher_platform_interface.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';
import 'package:mocktail/mocktail.dart';

class MockUrlLauncher extends Mock
    with MockPlatformInterfaceMixin
    implements UrlLauncherPlatform {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('NativeEventsService', () {
    late NativeEventsService service;
    late MockUrlLauncher mockUrlLauncher;

    setUpAll(() {
      registerFallbackValue(const LaunchOptions());
      registerFallbackValue(Uri.parse('x-apple.systempreferences:test'));
    });

    setUp(() {
      service = NativeEventsService.instance;
      mockUrlLauncher = MockUrlLauncher();
      UrlLauncherPlatform.instance = mockUrlLauncher;
      
      // Reset function hooks to default real implementations before each test
      // Actually, we should probably mock them for ALL tests to avoid accidental death
      service.exitAppFn = () async {};
      service.processStarter = (cmd, args) async {};
      
      // Stub generic as true by default
      when(() => mockUrlLauncher.canLaunch(any())).thenAnswer((_) async => true);
      when(() => mockUrlLauncher.launchUrl(any(), any())).thenAnswer((_) async => true);
    });

    test('initialize configura o handler do canal de shake', () {
      expect(() => service.initialize(), returnsNormally);
    });

    test('checkShakePermission retorna o valor do canal nativo', () async {
      const channel = MethodChannel(AppConstants.shakeChannelName);
      
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(channel, (call) async {
        if (call.method == 'checkPermission') return true;
        return null;
      });

      final (result, error) = await service.checkShakePermission();
      expect(result, isTrue);
      expect(error, isNull);
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(channel, null);
    });

    test('openAccessibilitySettings abre primeiro link com sucesso', () async {
      await service.openAccessibilitySettings();
      verify(() => mockUrlLauncher.canLaunch(any())).called(1);
    });

    test('openAccessibilitySettings usa fallback se primeiro falhar', () async {
      final firstUrl = 'x-apple.systempreferences:com.apple.preference.security?Privacy_Accessibility';
      final secondUrl = 'x-apple.systempreferences:com.apple.preference.security';

      when(() => mockUrlLauncher.canLaunch(firstUrl)).thenAnswer((_) async => false);
      when(() => mockUrlLauncher.canLaunch(secondUrl)).thenAnswer((_) async => true);

      await service.openAccessibilitySettings();

      verify(() => mockUrlLauncher.canLaunch(firstUrl)).called(1);
      verify(() => mockUrlLauncher.canLaunch(secondUrl)).called(1);
    });

    test('openAccessibilitySettings não tenta abrir se ambos falharem', () async {
      when(() => mockUrlLauncher.canLaunch(any())).thenAnswer((_) async => false);

      await service.openAccessibilitySettings();

      verify(() => mockUrlLauncher.canLaunch(any())).called(2);
      verifyNever(() => mockUrlLauncher.launchUrl(any(), any()));
    });

    test('lida com eventos de shake simulados', () async {
      const channel = MethodChannel(AppConstants.shakeChannelName);
      service.initialize();
      
      await TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.handlePlatformMessage(
        channel.name,
        channel.codec.encodeMethodCall(
          const MethodCall('shake_detected', {'x': 100.0, 'y': 200.0}),
        ),
        (data) {},
      );
    });

    test('restartApp funciona no MacOS usando mocks', () async {
      if (io.Platform.isMacOS) {
        bool processStarted = false;
        bool appExited = false;

        service.processStarter = (cmd, args) async {
          if (cmd == 'open') processStarted = true;
        };
        service.exitAppFn = () async {
          appExited = true;
        };

        await service.restartApp();

        expect(processStarted, isTrue);
        expect(appExited, isTrue);
      }
    });

    test('checkShakePermission lida com erro no canal', () async {
      const channel = MethodChannel(AppConstants.shakeChannelName);
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(channel, (call) async {
        throw Exception('Native Error');
      });

      final (result, error) = await service.checkShakePermission();
      expect(result, isNull);
      expect(error, isNotNull);
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(channel, null);
    });
  });
}
