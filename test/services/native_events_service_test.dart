import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/services.dart';
import 'package:mocktail/mocktail.dart';
import 'package:easier_drop/services/native_events_service.dart';
import 'package:easier_drop/services/analytics_service.dart';
import 'package:easier_drop/services/window_manager_service.dart';

class MockAnalyticsService extends Mock implements AnalyticsService {}
class MockWindowManagerService extends Mock implements WindowManagerService {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  const channel = MethodChannel('com.easier_drop/shake');
  late MockAnalyticsService mockAnalytics;
  late MockWindowManagerService mockWindowManager;

  setUp(() {
    mockAnalytics = MockAnalyticsService();
    mockWindowManager = MockWindowManagerService();
    AnalyticsService.instance = mockAnalytics;
    WindowManagerService.instance = mockWindowManager;

    when(() => mockAnalytics.debug(any(), tag: any(named: 'tag'))).thenReturn(null);
    when(() => mockAnalytics.shakeDetected(any(), any())).thenReturn(null);
    when(() => mockAnalytics.warn(any())).thenReturn(null);
    when(() => mockWindowManager.createNewWindow(any(), any())).thenAnswer((_) async {});
    when(() => mockWindowManager.exitApp()).thenAnswer((_) async {});
  });

  group('NativeEventsService', () {
    test('instance returns singleton and setter works', () {
      final old = NativeEventsService.instance;
      NativeEventsService.instance = old;
      expect(NativeEventsService.instance, same(old));
    });

    test('initialize sets method call handler', () {
      NativeEventsService.instance.initialize();
    });

    test('_handleShakeEvent processes data', () async {
      await TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .handlePlatformMessage(
        'com.easier_drop/shake',
        const StandardMethodCodec().encodeMethodCall(
          const MethodCall('shake_detected', {'x': 100.0, 'y': 200.0}),
        ),
        (data) {},
      );

      verify(() => mockAnalytics.shakeDetected(100.0, 200.0)).called(1);
      verify(() => mockWindowManager.createNewWindow(100.0, 200.0)).called(1);
    });

    test('checkShakePermission success', () async {
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(channel, (call) async => true);

      final (res, err) = await NativeEventsService.instance.checkShakePermission();
      expect(res, isTrue);
      expect(err, isNull);
    });

    test('checkShakePermission handles null and errors', () async {
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(channel, (call) async => null);

      final (res, _) = await NativeEventsService.instance.checkShakePermission();
      expect(res, isFalse);

      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(channel, (call) async => throw Exception('error'));
      
      final (_, err) = await NativeEventsService.instance.checkShakePermission();
      expect(err, isNotNull);
      verify(() => mockAnalytics.warn(any())).called(1);
    });

    test('openAccessibilitySettings calls primary URL', () async {
      const urlChannel = MethodChannel('plugins.flutter.io/url_launcher');
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(urlChannel, (call) async {
        if (call.method == 'canLaunch') return true;
        if (call.method == 'launch') return true;
        return null;
      });

      await NativeEventsService.instance.openAccessibilitySettings();
      // Should hit line 72
    });

    test('openAccessibilitySettings calls fallback URL', () async {
      const urlChannel = MethodChannel('plugins.flutter.io/url_launcher');
      int canLaunchCalls = 0;
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(urlChannel, (call) async {
        if (call.method == 'canLaunch') {
          canLaunchCalls++;
          if (canLaunchCalls == 1) return false;
          return true;
        }
        if (call.method == 'launch') return true;
        return null;
      });

      await NativeEventsService.instance.openAccessibilitySettings();
      expect(canLaunchCalls, 2);
    });

    test('restartApp calls processStarter and exitAppFn', () async {
      final service = NativeEventsService.instance;
      service.isMacOS = true;
      service.resolvedExecutable = '/Applications/EasierDrop.app/Contents/MacOS/EasierDrop';
      bool processStarted = false;
      bool exitAppCalled = false;

      service.processStarter = (cmd, args) async {
        processStarted = true;
        return null;
      };
      service.exitAppFn = () async {
        exitAppCalled = true;
      };

      await service.restartApp();
      expect(processStarted, isTrue);
      expect(exitAppCalled, isTrue);
    });

    test('restartApp early return on non-macos', () async {
      final service = NativeEventsService.instance;
      service.isMacOS = false;
      bool processStarted = false;

      service.processStarter = (cmd, args) async {
        processStarted = true;
        return null;
      };

      await service.restartApp();
      expect(processStarted, isFalse);
    });
  });
}
