import 'dart:convert';
import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:path_provider/path_provider.dart';
import 'package:easier_drop/services/settings_service.dart';
import 'package:path/path.dart' as p;

class MockDirectory extends Mock implements Directory {
  @override
  String get path => '/mock/path';
}

class MockFile extends Mock implements File {}

// Esta classe nos permite sobrescrever funções estáticas
class MockPathProvider {
  static late Directory mockDirectory;
  static late File mockFile;
  static late String mockFileContent;
  static bool fileExists = false;

  static Future<void> setup() async {
    mockDirectory = MockDirectory();
    mockFile = MockFile();
    mockFileContent = '';
    fileExists = false;

    // Preparando os mocks
    when(() => mockFile.exists()).thenAnswer((_) async => fileExists);
    when(
      () => mockFile.readAsString(),
    ).thenAnswer((_) async => mockFileContent);
    when(() => mockFile.writeAsString(any())).thenAnswer((_) async => mockFile);
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('SettingsService', () {
    late SettingsService settingsService;

    setUp(() async {
      // Configura os mocks
      await MockPathProvider.setup();

      // Sobrescreve a função getApplicationSupportDirectory
      getApplicationSupportDirectory =
          () async => MockPathProvider.mockDirectory;

      // Pegar a instância do singleton
      settingsService = SettingsService.instance;
    });

    test(
      'Deve carregar configurações de arquivo existente com conteúdo válido',
      () async {
        // Preparar o arquivo com dados
        MockPathProvider.fileExists = true;
        MockPathProvider.mockFileContent = jsonEncode({
          'maxFiles': 50,
          'windowX': 100.5,
          'windowY': 200.5,
          'windowW': 800.5,
          'windowH': 600.5,
          'locale': 'pt-BR',
        });

        // Sobrescreve a função _file
        final originalFile = settingsService._file;
        settingsService._file = () async => MockPathProvider.mockFile;

        try {
          // Carregar as configurações
          await settingsService.load();

          // Verificar se os valores foram carregados corretamente
          expect(settingsService.maxFiles, 50);
          expect(settingsService.windowX, 100.5);
          expect(settingsService.windowY, 200.5);
          expect(settingsService.windowW, 800.5);
          expect(settingsService.windowH, 600.5);
          expect(settingsService.localeCode, 'pt-BR');
          expect(settingsService.autoClearInbound, false);
          expect(settingsService.isLoaded, true);
        } finally {
          // Restaurar a função original
          settingsService._file = originalFile;
        }
      },
    );
  });
}
