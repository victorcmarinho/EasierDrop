import 'package:flutter_test/flutter_test.dart';
import 'package:easier_drop/helpers/system.dart';
import 'package:easier_drop/services/settings_service.dart';
import 'package:easier_drop/services/window_manager_service.dart';
import 'package:easier_drop/services/native_events_service.dart';
import 'package:mocktail/mocktail.dart';

class MockSettingsService extends Mock implements SettingsService {}
class MockWindowManagerService extends Mock implements WindowManagerService {}
class MockNativeEventsService extends Mock implements NativeEventsService {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late MockSettingsService mockSettings;
  late MockWindowManagerService mockWindowManager;
  late MockNativeEventsService mockNativeEvents;

  setUp(() {
    mockSettings = MockSettingsService();
    mockWindowManager = MockWindowManagerService();
    mockNativeEvents = MockNativeEventsService();

    SettingsService.instance = mockSettings;
    WindowManagerService.instance = mockWindowManager;
    NativeEventsService.instance = mockNativeEvents;

    when(() => mockNativeEvents.initialize()).thenReturn(null);
    when(() => mockSettings.load()).thenAnswer((_) async {});
    when(() => mockWindowManager.initialize(
      isSecondaryWindow: any(named: 'isSecondaryWindow'),
      windowId: any(named: 'windowId'),
    )).thenAnswer((_) async {});
  });

  group('SystemHelper', () {
    test('initialize calls service methods', () async {
      await SystemHelper.initialize(isSecondaryWindow: true, windowId: 'main');
      
      verify(() => mockNativeEvents.initialize()).called(1);
      verify(() => mockSettings.load()).called(1);
      verify(() => mockWindowManager.initialize(
        isSecondaryWindow: true,
        windowId: 'main',
      )).called(1);
    });
  });
}
