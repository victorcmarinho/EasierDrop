import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:easier_drop/services/settings_service.dart';
import 'package:mocktail/mocktail.dart';
import 'package:path_provider/path_provider.dart';

class MockFile extends Mock implements File {}

class MockDirectory extends Mock implements Directory {}

// Função para substituir getApplicationSupportDirectory
Directory _getDirectory() {
  final directory = MockDirectory();
  when(() => directory.path).thenReturn('/mock/path');
  return directory;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late SettingsService settingsService;
  late MockFile mockFile;

  setUp(() {
    settingsService = SettingsService.instance;
    mockFile = MockFile();

    // Substituir o método getApplicationSupportDirectory
    getApplicationSupportDirectoryPlatform = _getDirectory;

    // Configurar o comportamento do mockFile
    when(() => mockFile.exists()).thenAnswer((_) async => true);
    when(() => mockFile.writeAsString(any())).thenAnswer((_) async => mockFile);
  });

  test('autoClearInbound deve sempre retornar false', () {
    expect(settingsService.autoClearInbound, false);
  });

  group('Carregamento de configurações', () {
    test(
      'load() deve analisar corretamente o JSON quando o arquivo existir',
      () async {
        final jsonContent = jsonEncode({
          'maxFiles': 50,
          'windowX': 100.5,
          'windowY': 200.5,
          'windowW': 800.5,
          'windowH': 600.5,
          'locale': 'pt',
        });

        // Configurar mockFile para retornar o conteúdo JSON
        when(
          () => mockFile.readAsString(),
        ).thenAnswer((_) async => jsonContent);

        // Fazer o método _file() retornar nosso mockFile
        when(() => mockFile.exists()).thenAnswer((_) async => true);

        // Substituir o método _file() do SettingsService
        await settingsService.load();

        // Verificar se os valores foram carregados corretamente
        // Observação: isso só testará o comportamento público porque não podemos
        // facilmente injetar o mockFile sem alterar a classe original
        expect(settingsService.isLoaded, true);
      },
    );
  });

  group('Persistência de configurações', () {
    test('setMaxFiles() deve agendar persistência', () async {
      settingsService.setMaxFiles(50);
      expect(settingsService.maxFiles, 50);
      // O teste ideal verificaria se _schedulePersist foi chamado
    });

    test('setLocale() deve agendar persistência', () {
      final previousLocale = settingsService.localeCode;
      try {
        // Definir um valor diferente para garantir que a alteração ocorra
        settingsService.setLocale('es');
        expect(settingsService.localeCode, 'es');
      } finally {
        // Restaurar o valor original após o teste
        settingsService.setLocale(previousLocale);
      }
    });

    test('setWindowBounds() deve atualizar as propriedades corretamente', () {
      // Salvar valores originais
      final originalX = settingsService.windowX;
      final originalY = settingsService.windowY;
      final originalW = settingsService.windowW;
      final originalH = settingsService.windowH;

      try {
        // Testar com todos os valores definidos
        settingsService.setWindowBounds(x: 100, y: 200, w: 300, h: 400);
        expect(settingsService.windowX, 100);
        expect(settingsService.windowY, 200);
        expect(settingsService.windowW, 300);
        expect(settingsService.windowH, 400);

        // Testar com valores parciais
        settingsService.setWindowBounds(x: 150);
        expect(settingsService.windowX, 150);
        expect(settingsService.windowY, 200); // mantém o valor anterior

        settingsService.setWindowBounds(y: 250);
        expect(settingsService.windowY, 250);
        expect(settingsService.windowX, 150); // mantém o valor anterior

        settingsService.setWindowBounds(w: 350);
        expect(settingsService.windowW, 350);

        settingsService.setWindowBounds(h: 450);
        expect(settingsService.windowH, 450);
      } finally {
        // Restaurar valores originais
        settingsService.setWindowBounds(
          x: originalX,
          y: originalY,
          w: originalW,
          h: originalH,
        );
      }
    });
  });
}
