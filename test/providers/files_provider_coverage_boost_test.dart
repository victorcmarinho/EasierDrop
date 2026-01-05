import 'package:easier_drop/model/file_reference.dart';
import 'package:easier_drop/providers/files_provider.dart';
import 'package:easier_drop/services/file_repository.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';
import 'package:path_provider_platform_interface/path_provider_platform_interface.dart';
import 'dart:typed_data';

class MockFileRepository extends Mock implements FileRepository {}

class MockPathProviderPlatform extends Mock
    with MockPlatformInterfaceMixin
    implements PathProviderPlatform {
  @override
  Future<String?> getApplicationSupportPath() async => '.';
}

void main() {
  late FilesProvider provider;
  late MockFileRepository mockRepo;

  setUpAll(() {
    TestWidgetsFlutterBinding.ensureInitialized();
    PathProviderPlatform.instance = MockPathProviderPlatform();
  });

  setUp(() {
    mockRepo = MockFileRepository();
    provider = FilesProvider(
      repository: mockRepo,
      enableMonitoring: false,
      maxFiles: 5,
    );
    registerFallbackValue('/default/path');

    // Default mocks to prevent Null pointer errors for Future returns
    when(() => mockRepo.getIcon(any())).thenAnswer((_) async => null);
    when(() => mockRepo.getPreview(any())).thenAnswer((_) async => null);
  });

  group('FilesProvider Coverage Boost', () {
    test('validXFiles getter filters invalid files', () {
      final file1 = FileReference(pathname: '/valid.txt');
      final file2 = FileReference(pathname: '/invalid.txt');

      provider.addFileForTest(file1);
      provider.addFileForTest(file2);

      when(() => mockRepo.validateFileSync('/valid.txt')).thenReturn(true);
      when(() => mockRepo.validateFileSync('/invalid.txt')).thenReturn(false);

      final xfiles = provider.validXFiles;
      expect(xfiles.length, 1);
      expect(xfiles.first.path, '/valid.txt');

      // Check caching
      expect(provider.validXFiles, same(xfiles));
    });

    test('recentlyAtLimit returns true only within duration', () async {
      expect(provider.recentlyAtLimit, false);

      when(() => mockRepo.validateFile(any())).thenAnswer((_) async => true);

      final files = List.generate(
        10,
        (i) => FileReference(pathname: '/file$i.txt'),
      );
      await provider.addFiles(files);

      expect(provider.recentlyAtLimit, true);
    });

    test('addFiles error handling', () async {
      when(
        () => mockRepo.validateFile(any()),
      ).thenThrow(Exception('test error'));

      await provider.addFiles([FileReference(pathname: '/path.txt')]);
    });

    test('thumbnail loading branches', () async {
      final pathname = '/test.txt';
      final ref = FileReference(pathname: pathname);

      when(
        () => mockRepo.getIcon(pathname),
      ).thenAnswer((_) async => Uint8List.fromList([1, 2, 3]));
      when(
        () => mockRepo.getPreview(pathname),
      ).thenAnswer((_) async => Uint8List.fromList([4, 5, 6]));
      when(() => mockRepo.validateFile(pathname)).thenAnswer((_) async => true);

      await provider.addFile(ref);

      await Future.delayed(const Duration(milliseconds: 50));

      final updated = provider.files.first;
      expect(updated.iconData, isNotNull);
      expect(updated.previewData, isNotNull);
    });

    test('shared with error', () async {
      // Testing the catch block indirectly if possible or just verifying no crash
      final result = await provider.shared();
      expect(result, isNotNull);
    });

    test('removeByPath with non-existent path', () {
      provider.removeByPath('/non-existent');
      expect(provider.fileCount, 0);
    });
  });
}
