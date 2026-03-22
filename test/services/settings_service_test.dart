import 'package:flutter_test/flutter_test.dart';
import 'package:easier_drop/services/settings_service.dart';
import 'package:path_provider_platform_interface/path_provider_platform_interface.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';
import 'package:flutter/services.dart';
import 'dart:io';
import 'dart:convert';

class MockPathProviderPlatform extends Fake
    with MockPlatformInterfaceMixin
    implements PathProviderPlatform {
  @override
  Future<String?> getApplicationSupportPath() async {
    return '.';
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  group('Testes de SettingsService', () {
    late SettingsService settingsService;
    final testSettingsFile = File('./settings.json');

    setUp(() async {
      PathProviderPlatform.instance = MockPathProviderPlatform();
      settingsService = SettingsService.instance;
      settingsService.resetForTesting();

      if (await testSettingsFile.exists()) {
        await testSettingsFile.delete();
      }
    });

    tearDown(() async {
      if (await testSettingsFile.exists()) {
        await testSettingsFile.delete();
      }
    });

    test('deve carregar valores padrão quando o arquivo não existe', () async {
      await settingsService.load();

      expect(settingsService.isLoaded, true);
      expect(settingsService.maxFiles, 100);

      expect(settingsService.settings.isAlwaysOnTop, true);
    });

    test('deve atualizar e persistir MaxFiles', () async {
      await settingsService.load();
      settingsService.setMaxFiles(50);

      await settingsService.persist();

      expect(await testSettingsFile.exists(), true);
      final content = await testSettingsFile.readAsString();
      expect(content, contains('"maxFiles": 50'));
    });

    test('deve alternar Sempre no Topo', () async {
      await settingsService.load();
      expect(settingsService.settings.isAlwaysOnTop, true);

      settingsService.setAlwaysOnTop(false);
      expect(settingsService.settings.isAlwaysOnTop, false);
    });

    test('deve atualizar a opacidade da janela', () async {
      await settingsService.load();
      settingsService.setWindowOpacity(0.5);
      expect(settingsService.settings.windowOpacity, 0.5);
    });

    test('deve atualizar os limites da janela', () async {
      await settingsService.load();
      settingsService.setWindowBounds(x: 10, y: 20, w: 30, h: 40);
      expect(settingsService.windowX, 10);
      expect(settingsService.windowY, 20);
      expect(settingsService.windowW, 30);
      expect(settingsService.windowH, 40);
    });

    test('deve atualizar o idioma (locale)', () async {
      await settingsService.load();
      settingsService.setLocale('pt');
      expect(settingsService.localeCode, 'pt');
    });

    test('deve atualizar se a telemetria está habilitada', () async {
      await settingsService.load();
      settingsService.setTelemetryEnabled(false);
      expect(settingsService.telemetryEnabled, false);
    });

    test('deve lidar com iniciar no login', () async {
      const channel = MethodChannel('com.easierdrop/launch_at_login');
      final log = <MethodCall>[];
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(channel, (MethodCall methodCall) async {
            log.add(methodCall);
            if (methodCall.method == 'checkPermission') return true;
            if (methodCall.method == 'isEnabled') return true;
            return null;
          });

      await settingsService.load();
      await settingsService.setLaunchAtLogin(true);
      expect(settingsService.settings.launchAtLogin, true);

      final hasPerm = await settingsService.checkLaunchAtLoginPermission();
      expect(hasPerm, true);

      final isEnabled = await settingsService.getLaunchAtLoginStatus();
      expect(isEnabled, true);

      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(channel, null);
    });

    test('deve lidar com erros de iniciar no login', () async {
      const channel = MethodChannel('com.easierdrop/launch_at_login');
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(channel, (MethodCall methodCall) async {
            throw Exception('Erro nativo');
          });

      await settingsService.load();
      await settingsService.setLaunchAtLogin(true);

      final hasPerm = await settingsService.checkLaunchAtLoginPermission();
      expect(hasPerm, false);

      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(channel, null);
    });

    test('dispose deve cancelar o timer e a inscrição', () {
      final s = SettingsService.forTesting();
      expect(() => s.dispose(), returnsNormally);
    });

    test('deve recarregar as configurações quando o arquivo muda', () async {
      await settingsService.load();

      final updatedSettings = {'maxFiles': 150, 'version': 1};
      await testSettingsFile.writeAsString(jsonEncode(updatedSettings));

      // File watchers podem ser um pouco lentos em alguns sistemas, vamos esperar um momento
      for (int i = 0; i < 10; i++) {
        await Future.delayed(const Duration(milliseconds: 200));
        if (settingsService.maxFiles == 150) break;
      }

      expect(settingsService.maxFiles, 150);
    });

    test('deve lidar com arquivo de configurações vazio ou inválido', () async {
      await testSettingsFile.writeAsString('');
      await settingsService.load();

      expect(settingsService.maxFiles, 100);

      await testSettingsFile.writeAsString('{invalid_json}');

      await Future.delayed(const Duration(milliseconds: 100));

      expect(settingsService.isLoaded, true);
    });

    test('deve detectar o idioma do sistema durante a primeira execução', () async {
      SettingsService.testLocaleName = 'pt_BR';
      await settingsService.load();
      expect(settingsService.localeCode, 'pt_BR');

      settingsService.resetForTesting();
      if (await testSettingsFile.exists()) await testSettingsFile.delete();

      SettingsService.testLocaleName = 'es_ES';
      await settingsService.load();
      expect(settingsService.localeCode, 'es');

      SettingsService.testLocaleName = null;
    });
  });
}
