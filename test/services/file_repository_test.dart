import 'dart:io';
import 'package:easier_drop/services/file_repository.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late FileRepository repository;
  late File tempFile;

  setUp(() async {
    repository = const FileRepository();
    tempFile = File('test_file.txt');
    await tempFile.writeAsString('hello');
  });

  tearDown(() async {
    if (await tempFile.exists()) {
      await tempFile.delete();
    }
  });

  group('FileRepository Tests', () {
    test('validateFile returns true for existing file', () async {
      final isValid = await repository.validateFile(tempFile.path);
      expect(isValid, isTrue);
    });

    test('validateFile returns false for non-existing file', () async {
      final isValid = await repository.validateFile('non_existing.txt');
      expect(isValid, isFalse);
    });

    test('validateFileSync returns true for existing file', () {
      final isValid = repository.validateFileSync(tempFile.path);
      expect(isValid, isTrue);
    });

    test('validateFileSync returns false for non-existing file', () {
      final isValid = repository.validateFileSync('non_existing.txt');
      expect(isValid, isFalse);
    });
  });
}
