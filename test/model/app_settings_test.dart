import 'package:flutter_test/flutter_test.dart';
import 'package:easier_drop/model/app_settings.dart';

void main() {
  group('AppSettings Tests', () {
    test('should create with default values', () {
      const settings = AppSettings();
      expect(settings.maxFiles, 100);
      expect(settings.telemetryEnabled, true);
      expect(settings.isAlwaysOnTop, false);
      expect(settings.launchAtLogin, false);
      expect(settings.windowOpacity, 1.0);
      expect(settings.windowX, isNull);
      expect(settings.localeCode, isNull);
    });

    test('fromMap should parse correctly with all values', () {
      final map = {
        'maxFiles': 50,
        'windowX': 10.0,
        'windowY': 20.0,
        'windowW': 30.0,
        'windowH': 40.0,
        'locale': 'en',
        'telemetryEnabled': false,
        'isAlwaysOnTop': true,
        'launchAtLogin': true,
        'windowOpacity': 0.8,
      };

      final settings = AppSettings.fromMap(map);

      expect(settings.maxFiles, 50);
      expect(settings.windowX, 10.0);
      expect(settings.windowY, 20.0);
      expect(settings.windowW, 30.0);
      expect(settings.windowH, 40.0);
      expect(settings.localeCode, 'en');
      expect(settings.telemetryEnabled, false);
      expect(settings.isAlwaysOnTop, true);
      expect(settings.launchAtLogin, true);
      expect(settings.windowOpacity, 0.8);
    });

    test('fromMap should parse correctly with missing values (defaults)', () {
      final map = <String, dynamic>{};
      final settings = AppSettings.fromMap(map);

      expect(settings.maxFiles, 100);
      expect(settings.telemetryEnabled, true);
      expect(settings.isAlwaysOnTop, false);
      expect(settings.launchAtLogin, false);
      expect(settings.windowOpacity, 1.0);
    });

    test('toMap should generate correct map', () {
      const settings = AppSettings(
        maxFiles: 50,
        windowX: 10.0,
        localeCode: 'pt',
        telemetryEnabled: false,
      );

      final map = settings.toMap(1);

      expect(map['maxFiles'], 50);
      expect(map['windowX'], 10.0);
      expect(map['locale'], 'pt');
      expect(map['telemetryEnabled'], false);
      expect(map['schemaVersion'], 1);
      expect(map['windowY'], isNull);
    });

    test('copyWith should update specified values', () {
      const settings = AppSettings();

      final updated = settings.copyWith(maxFiles: 200, isAlwaysOnTop: true);

      expect(updated.maxFiles, 200);
      expect(updated.isAlwaysOnTop, true);
      expect(updated.telemetryEnabled, settings.telemetryEnabled);
      expect(updated.windowOpacity, settings.windowOpacity);
    });

    test('copyWith with null values should not change existing values', () {
      const settings = AppSettings(maxFiles: 50);
      final updated = settings.copyWith(maxFiles: null);
      expect(updated.maxFiles, 50);
    });
  });
}
