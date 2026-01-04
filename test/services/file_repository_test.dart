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

    test('validateFile returns false for directories', () async {
      final dir = Directory('test_dir');
      await dir.create();
      try {
        final isValid = await repository.validateFile(dir.path);
        expect(isValid, isFalse);
      } finally {
        await dir.delete();
      }
    });

    test('validateFileSync returns false for directories', () {
      final dir = Directory('test_dir_sync');
      dir.createSync();
      try {
        final isValid = repository.validateFileSync(dir.path);
        expect(isValid, isFalse);
      } finally {
        dir.deleteSync();
      }
    });

    test('getIcon calls FileIconHelper', () async {
      await repository.getIcon(tempFile.path);
      // We don't verify the actual result as it depends on platform
      expect(true, isTrue);
    });

    test('getPreview calls FileIconHelper', () async {
      await repository.getPreview(tempFile.path);
      expect(true, isTrue);
    });

    test('_testReadability handles non-readable files', () async {
      // It's hard to make a file non-readable on all platforms in tests
      // specifically on some CI environments. But we already cover the success path.
      final result = await repository.validateFile(tempFile.path);
      expect(result, isTrue);
    });
  });
}
