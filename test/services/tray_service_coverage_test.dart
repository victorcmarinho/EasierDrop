import 'package:easier_drop/services/tray_service.dart';
import 'package:easier_drop/services/update_service.dart';
import 'package:easier_drop/services/analytics_service.dart';
import 'package:easier_drop/services/window_manager_service.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tray_manager/tray_manager.dart';
import 'package:mocktail/mocktail.dart';

class MockUpdateService extends Mock implements UpdateService {}
class MockAnalyticsService extends Mock implements AnalyticsService {}
class MockWindowManagerService extends Mock implements WindowManagerService {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late MockUpdateService mockUpdateService;
  late MockAnalyticsService mockAnalytics;
  late MockWindowManagerService mockWindowManager;

  setUpAll(() {
    registerFallbackValue(Uri.parse('http://localhost'));
    registerFallbackValue(MenuItem(key: 'test'));
  });

  const MethodChannel trayChannel = MethodChannel('tray_manager');

  setUp(() {
    mockUpdateService = MockUpdateService();
    mockAnalytics = MockAnalyticsService();
    mockWindowManager = MockWindowManagerService();

    // Inject mocks
    UpdateService.instance = mockUpdateService;
    AnalyticsService.instance = mockAnalytics;
    WindowManagerService.instance = mockWindowManager;

    // Default behaviors
    when(() => mockAnalytics.warn(any(), tag: any(named: 'tag'))).thenAnswer((_) {});
    when(() => mockAnalytics.error(any(), tag: any(named: 'tag'))).thenAnswer((_) {});
    when(() => mockAnalytics.updateCheckStarted()).thenAnswer((_) {});
    
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(trayChannel, (MethodCall methodCall) async {
      return null;
    });
  });

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(trayChannel, null);
  });

  group('TrayService Error Handling & Coverage', () {
    test('configure logs warning on failure', () async {
      // Force MethodChannel to throw
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(trayChannel, (call) async => throw Exception('Tray Icon Error'));

      await TrayService.instance.configure();

      verify(() => mockAnalytics.warn(any(that: contains('Failed to load tray icon')), tag: any(named: 'tag'))).called(1);
    });

    test('checkForUpdates updates state on success', () async {
      when(() => mockUpdateService.checkForUpdates())
          .thenAnswer((_) async => ('https://new-update.com', null));

      await TrayService.instance.checkForUpdates();

      expect(TrayService.instance.updateUrl, 'https://new-update.com');
    });

    test('handleMenuItemClick processes preferences', () async {
      when(() => mockWindowManager.openSettings()).thenAnswer((_) async {});
      
      await TrayService.instance.handleMenuItemClick(MenuItem(key: 'preferences'));
      
      verify(() => mockWindowManager.openSettings()).called(1);
    });

    test('handleMenuItemClick logs error on exception', () async {
      // Force an exception inside the switch case
      when(() => mockWindowManager.open()).thenThrow(Exception('Window open error'));
      
      await TrayService.instance.handleMenuItemClick(MenuItem(key: 'show_window'));
      
      verify(() => mockAnalytics.error(any(that: contains('Error handling tray menu item')), tag: any(named: 'tag'))).called(1);
    });

    test('handleMenuItemClick processes exit_app', () async {
       when(() => mockWindowManager.exitApp()).thenAnswer((_) async {});
       await TrayService.instance.handleMenuItemClick(MenuItem(key: 'exit_app'));
       verify(() => mockWindowManager.exitApp()).called(1);
    });
  });
}
