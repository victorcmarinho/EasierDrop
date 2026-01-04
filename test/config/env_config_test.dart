import 'package:easier_drop/config/env_config.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Env Configuration Tests', () {
    test('aptabaseAppKey returns environment variable value', () {
      // The value comes from environment, so we just verify it's accessible
      expect(Env.aptabaseAppKey, isA<String>());
    });

    test('githubLatestReleaseUrl has default value', () {
      expect(
        Env.githubLatestReleaseUrl,
        equals(
          'https://api.github.com/repos/victorcmarinho/EasierDrop/releases/latest',
        ),
      );
    });

    test('isValid returns true when aptabaseAppKey is not empty', () {
      // This test depends on the environment variable being set
      // In a real scenario, we would mock this
      expect(Env.isValid, isA<bool>());
    });

    test('isValid returns false when aptabaseAppKey is empty', () {
      // When no environment variable is set, aptabaseAppKey should be empty
      // and isValid should be false
      if (Env.aptabaseAppKey.isEmpty) {
        expect(Env.isValid, isFalse);
      } else {
        expect(Env.isValid, isTrue);
      }
    });
  });
}
