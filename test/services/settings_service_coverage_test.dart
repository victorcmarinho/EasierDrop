import 'package:flutter_test/flutter_test.dart';
import 'package:easier_drop/services/settings_service.dart';
import 'package:easier_drop/services/analytics_service.dart';
import 'package:path_provider_platform_interface/path_provider_platform_interface.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';
import 'package:flutter/services.dart';
import 'dart:io';
import 'package:mocktail/mocktail.dart';

class MockPathProviderPlatform extends Fake
    with MockPlatformInterfaceMixin
    implements PathProviderPlatform {
  @override
  Future<String?> getApplicationSupportPath() async => '.';
}

class FakeAnalyticsService extends Fake implements AnalyticsService {
  final List<(String, String)> warnCalls = [];
  final List<(String, String)> errorCalls = [];
  final List<(String, dynamic)> settingsChangedCalls = [];

  @override
  void warn(String message, {String tag = 'App'}) {
    warnCalls.add((message, tag));
  }

  @override
  void error(String message, {Object? error, StackTrace? stackTrace, String tag = 'App'}) {
    errorCalls.add((message, tag));
  }

  @override
  void info(String message, {String tag = 'App'}) {}
  
  @override
  void settingsChanged(String key, dynamic value) {
    settingsChangedCalls.add((key, value));
  }

  @override
  Future<void> trackEvent(String name, [Map<String, dynamic>? properties]) async {}
  
  @override
  void debug(String message, {String tag = 'App'}) {}
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  
  late SettingsService service;
  late FakeAnalyticsService fakeAnalytics;
  final testFile = File('./settings.json');
  const launchChannel = MethodChannel('com.easierdrop/launch_at_login');

  setUpAll(() {
    PathProviderPlatform.instance = MockPathProviderPlatform();
  });

  setUp(() async {
    fakeAnalytics = FakeAnalyticsService();
    AnalyticsService.instance = fakeAnalytics;
    
    service = SettingsService.instance;
    service.resetForTesting();
    if (await testFile.exists()) await testFile.delete();
    
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(launchChannel, (call) async {
      if (call.method == 'checkPermission') return true;
      if (call.method == 'isEnabled') return false;
      if (call.method == 'setEnabled') return null;
      return null;
    });
  });

  tearDown(() async {
    if (await testFile.exists()) await testFile.delete();
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(launchChannel, null);
  });

  group('SettingsService Full Coverage', () {
    test('load() default settings when file missing', () async {
       await service.load();
       expect(service.isLoaded, isTrue);
       expect(service.settings.isAlwaysOnTop, isTrue);
    });

    test('load() with specific locale', () async {
       SettingsService.testLocaleName = 'pt_BR';
       await service.load();
       expect(service.settings.localeCode, equals('pt_BR'));
       SettingsService.testLocaleName = null;
    });

    test('setMaxFiles updates settings and tracks event', () {
       service.setMaxFiles(10);
       expect(service.maxFiles, equals(10));
       expect(fakeAnalytics.settingsChangedCalls.any((call) => call.$1 == 'maxFiles' && call.$2 == 10), isTrue);
       
       service.setMaxFiles(10); // redundant call
       service.setMaxFiles(-1); // invalid call
    });

    test('setWindowBounds updates settings', () {
       service.setWindowBounds(x: 100, y: 200, w: 300, h: 400);
       expect(service.windowX, equals(100));
       expect(service.windowY, equals(200));
       expect(service.windowW, equals(300));
       expect(service.windowH, equals(400));
    });

    test('setLocale/setTelemetryEnabled/setAlwaysOnTop/setWindowOpacity', () {
       service.setLocale('en');
       expect(service.localeCode, equals('en'));
       
       service.setTelemetryEnabled(false);
       expect(service.telemetryEnabled, isFalse);
       
       service.setAlwaysOnTop(false);
       expect(service.settings.isAlwaysOnTop, isFalse);
       
       service.setWindowOpacity(0.5);
       expect(service.settings.windowOpacity, equals(0.5));
    });

    test('setLaunchAtLogin updates settings', () async {
       await service.setLaunchAtLogin(true);
       expect(service.settings.launchAtLogin, isTrue);
    });

    test('dispose works on non-singleton instance', () {
       final s = SettingsService.forTesting();
       s.dispose();
    });

    test('load() logs warning when file reading fails', () async {
       await testFile.writeAsString('invalid json{');
       await service.load();
       expect(fakeAnalytics.warnCalls, isNotEmpty);
    });

    test('persist() logs warning on file write failure', () async {
       final serviceForTest = SettingsService.forTesting();
       
       await IOOverrides.runZoned(() async {
         await serviceForTest.persist();
         expect(fakeAnalytics.warnCalls, isNotEmpty);
       }, createFile: (path) {
         if (path.contains('settings.json')) {
           final mockFile = _MockFile(path);
           when(() => mockFile.writeAsString(any(), 
               mode: any(named: 'mode'), 
               encoding: any(named: 'encoding'), 
               flush: any(named: 'flush')))
               .thenThrow(FileSystemException('Disk full', path));
           return mockFile;
         }
         return File(path);
       });
    });
  });
}

class _MockFile extends Mock implements File {
  @override
  final String path;
  _MockFile(this.path);
  @override
  Directory get parent => Directory('.');
}
