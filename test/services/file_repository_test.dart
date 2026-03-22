import 'dart:io';
import 'dart:typed_data';
import 'package:easier_drop/services/file_repository.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

void main() {
  late FileRepository repository;
  late File tempFile;

  setUpAll(() {
    registerFallbackValue(FileMode.read);
  });

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
      final (isValid, error) = await repository.validateFile(tempFile.path);
      expect(error, isNull);
      expect(isValid, isTrue);
    });

    test('validateFile returns false for non-existing file', () async {
      final (isValid, error) = await repository.validateFile('non_existing.txt');
      expect(error, isNull);
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
        final (isValid, error) = await repository.validateFile(dir.path);
        expect(error, isNull);
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
      final result = await repository.getIcon(tempFile.path);

      expect(result, anyOf(isNull, isA<Uint8List>()));
    });

    test('getPreview calls FileIconHelper', () async {
      final result = await repository.getPreview(tempFile.path);
      expect(result, anyOf(isNull, isA<Uint8List>()));
    });

    test('validateFile: file with no read permission still passes stat check',
        () async {
      // After the perf refactor, validateFile only checks stat() (file exists
      // and is a regular file). It no longer opens the file to read a byte.
      // A chmod-000 file still has a valid stat, so validateFile returns true.
      final nonReadable = File('non_readable.txt');
      await nonReadable.writeAsString('secret');
      await Process.run('chmod', ['000', nonReadable.path]);
      try {
        final (result, error) = await repository.validateFile(nonReadable.path);
        expect(error, isNull);
        expect(result, isTrue); // stat succeeds; readability is not checked
      } finally {
        await Process.run('chmod', ['644', nonReadable.path]);
        if (await nonReadable.exists()) await nonReadable.delete();
      }
    });

    test('validateFile returns error tuple when stat() throws', () async {
      // Verify that an exception during stat() is caught and returns an error tuple.
      await IOOverrides.runZoned(
        () async {
          final (result, error) = await repository.validateFile('stat_exception.txt');
          expect(error, isNotNull);
          expect(result, isNull);
        },
        createFile: (path) {
          final mockFile = _MockFile(path);
          if (path == 'stat_exception.txt') {
            when(
              () => mockFile.stat(),
            ).thenThrow(const FileSystemException('stat error'));
          }
          return mockFile;
        },
      );
    });

    test('validateFileSync handles generic exception', () {
      IOOverrides.runZoned(
        () {
          final result = repository.validateFileSync(
            'sync_generic_exception.txt',
          );
          expect(result, isFalse);
        },
        createFile: (path) {
          final mockFile = _MockFile(path);
          if (path == 'sync_generic_exception.txt') {
            when(() => mockFile.existsSync()).thenReturn(true);
            when(
              () => mockFile.statSync(),
            ).thenReturn(_MockFileStat(FileSystemEntityType.file));
            when(
              () => mockFile.openSync(mode: any(named: 'mode')),
            ).thenThrow(Exception('Sync generic error'));
          }
          return mockFile;
        },
      );
    });

    test('validateFileSync handles exceptions in existsSync', () {
      IOOverrides.runZoned(
        () {
          final result = repository.validateFileSync(
            'sync_exists_exception.txt',
          );
          expect(result, isFalse);
        },
        createFile: (path) {
          final mockFile = _MockFile(path);
          if (path == 'sync_exists_exception.txt') {
            when(
              () => mockFile.existsSync(),
            ).thenThrow(const FileSystemException('Sync error'));
          }
          return mockFile;
        },
      );
    });

    test('_testReadabilitySync handles exceptions', () {
      IOOverrides.runZoned(
        () {
          final result = repository.validateFileSync(
            'read_sync_fs_exception.txt',
          );
          expect(result, isFalse);
        },
        createFile: (path) {
          final mockFile = _MockFile(path);
          if (path == 'read_sync_fs_exception.txt') {
            when(() => mockFile.existsSync()).thenReturn(true);
            when(
              () => mockFile.statSync(),
            ).thenReturn(_MockFileStat(FileSystemEntityType.file));
            when(
              () => mockFile.openSync(mode: any(named: 'mode')),
            ).thenThrow(const FileSystemException('Read error'));
          }
          return mockFile;
        },
      );
    });
  });
}

class _MockFile extends Mock implements File {
  @override
  final String path;
  _MockFile(this.path);
}

class _MockFileStat extends Mock implements FileStat {
  @override
  final FileSystemEntityType type;
  _MockFileStat(this.type);
}
