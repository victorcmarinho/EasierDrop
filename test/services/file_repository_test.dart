import 'dart:io';
import 'package:easier_drop/services/file_repository.dart';
import 'package:easier_drop/services/analytics_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockAnalyticsService extends Mock implements AnalyticsService {}

void main() {
  late FileRepository repository;
  late MockAnalyticsService mockAnalytics;

  setUp(() {
    repository = const FileRepository();
    mockAnalytics = MockAnalyticsService();
    AnalyticsService.instance = mockAnalytics;
    
    when(() => mockAnalytics.error(any(), tag: any(named: 'tag'))).thenReturn(null);
    when(() => mockAnalytics.debug(any(), tag: any(named: 'tag'))).thenReturn(null);
  });

  group('FileRepository', () {
    test('validateFile returns true for existing file', () async {
      await IOOverrides.runZoned(() async {
        final (bool? result, Object? error) = await repository.validateFile('test.txt');
        expect(result, isTrue);
        expect(error, isNull);
      }, createFile: (path) {
        final mockFile = _MockFile(path);
        when(() => mockFile.stat()).thenAnswer((_) async => _MockFileStat(FileSystemEntityType.file));
        return mockFile;
      });
    });

    test('validateFile returns false for non-existent file', () async {
      await IOOverrides.runZoned(() async {
        final (bool? result, Object? error) = await repository.validateFile('non_existent.txt');
        expect(result, isFalse);
        expect(error, isNull);
      }, createFile: (path) {
        final mockFile = _MockFile(path);
        when(() => mockFile.stat()).thenAnswer((_) async => _MockFileStat(FileSystemEntityType.notFound));
        return mockFile;
      });
    });
    
    test('validateFile handles exceptions', () async {
      await IOOverrides.runZoned(() async {
        final (bool? result, Object? error) = await repository.validateFile('error.txt');
        expect(result, isNull); // safeCall returns (null, error)
        expect(error, isA<FileSystemException>());
        verify(() => mockAnalytics.debug(any(), tag: any(named: 'tag'))).called(1);
      }, createFile: (path) {
        if (path == 'error.txt') {
          final mockFile = _MockFile(path);
          when(() => mockFile.stat()).thenThrow(FileSystemException('Error', path));
          return mockFile;
        }
        return File(path);
      });
    });

    test('validateFileSync handles exceptions', () {
      IOOverrides.runZoned(() {
        final result = repository.validateFileSync('error_sync.txt');
        expect(result, isFalse);
        verifyNever(() => mockAnalytics.debug(any(), tag: any(named: 'tag')));
      }, createFile: (path) {
        if (path == 'error_sync.txt') {
          final mockFile = _MockFile(path);
          when(() => mockFile.existsSync()).thenReturn(true); // Exists but stat fails
          when(() => mockFile.statSync()).thenThrow(FileSystemException('Error', path));
          return mockFile;
        }
        return File(path);
      });
    });

    test('validateFileSync returns false for non-file entity', () {
      IOOverrides.runZoned(() {
        final result = repository.validateFileSync('dir.txt');
        expect(result, isFalse);
      }, createFile: (path) {
        final mockFile = _MockFile(path);
        when(() => mockFile.existsSync()).thenReturn(true);
        when(() => mockFile.statSync()).thenReturn(_MockFileStat(FileSystemEntityType.directory));
        return mockFile;
      });
    });

    test('getFileIcon and getFilePreview cover native calls (ignored)', () async {
      final icon = await repository.getIcon('test.txt');
      final preview = await repository.getPreview('test.txt');
      expect(icon, isNull);
      expect(preview, isNull);
    });
  });
}

class _MockFile extends Mock implements File {
  @override
  final String path;
  _MockFile(this.path);
  
  @override
  Directory get parent => Directory('.');
}

class _MockFileStat extends Fake implements FileStat {
  @override
  final FileSystemEntityType type;
  _MockFileStat(this.type);
}
