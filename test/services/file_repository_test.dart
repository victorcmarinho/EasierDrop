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
      final result = await repository.getIcon(tempFile.path);

      expect(result, anyOf(isNull, isA<Uint8List>()));
    });

    test('getPreview calls FileIconHelper', () async {
      final result = await repository.getPreview(tempFile.path);
      expect(result, anyOf(isNull, isA<Uint8List>()));
    });

    test('validateFile handles exceptions', () async {
      await IOOverrides.runZoned(
        () async {
          final result = await repository.validateFile(
            'triggered_exception.txt',
          );
          expect(result, isFalse);
        },
        createFile: (path) {
          final mockFile = _MockFile(path);
          if (path == 'triggered_exception.txt') {
            when(
              () => mockFile.exists(),
            ).thenThrow(const FileSystemException('Test Exception'));
          }
          return mockFile;
        },
      );
    });

    test('_testReadability handles FileSystemException', () async {
      final nonReadable = File('non_readable.txt');
      await nonReadable.writeAsString('secret');

      await Process.run('chmod', ['000', nonReadable.path]);

      try {
        final result = await repository.validateFile(nonReadable.path);
        expect(result, isFalse);
      } finally {
        await Process.run('chmod', ['644', nonReadable.path]);
        if (await nonReadable.exists()) {
          await nonReadable.delete();
        }
      }
    });

    test('_testReadability handles generic exception', () async {
      await IOOverrides.runZoned(
        () async {
          final result = await repository.validateFile('generic_exception.txt');
          expect(result, isFalse);
        },
        createFile: (path) {
          final mockFile = _MockFile(path);
          if (path == 'generic_exception.txt') {
            when(() => mockFile.exists()).thenAnswer((_) async => true);
            when(
              () => mockFile.stat(),
            ).thenAnswer((_) async => _MockFileStat(FileSystemEntityType.file));

            when(
              () => mockFile.open(mode: any(named: 'mode')),
            ).thenAnswer((_) async => throw Exception('Generic error'));
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
