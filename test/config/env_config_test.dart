import 'package:easier_drop/config/env_config.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Configurações de Ambiente (Env)', () {
    test('aptabaseAppKey retorna um valor de string', () {
      expect(Env.aptabaseAppKey, isA<String>());
    });

    test('githubLatestReleaseUrl tem o valor padrão correto', () {
      expect(
        Env.githubLatestReleaseUrl,
        equals(
          'https://api.github.com/repos/victorcmarinho/EasierDrop/releases/latest',
        ),
      );
    });

    test('isValid retorna o valor booleano baseado na chave Aptabase', () {
      expect(Env.isValid, equals(Env.aptabaseAppKey.isNotEmpty));
    });

    test('cobertura de construtor privado', () {
      Env.testCoverage();
    });
  });
}
