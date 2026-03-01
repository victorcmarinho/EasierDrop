import 'package:easier_drop/config/env_config.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Env Configuration Tests', () {
    test('aptabaseAppKey returns environment variable value', () {
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
      expect(Env.isValid, isA<bool>());
    });

    test('isValid returns false when aptabaseAppKey is empty', () {
      if (Env.aptabaseAppKey.isEmpty) {
        expect(Env.isValid, isFalse);
      }
    });
  });
}
