import 'package:easier_drop/model/file_reference.dart';
import 'package:easier_drop/providers/files_provider.dart';
import 'package:easier_drop/services/file_repository.dart';
import 'package:easier_drop/services/settings_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:path_provider_platform_interface/path_provider_platform_interface.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class MockFileReference extends Mock implements FileReference {}

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

  setUp(() async {
    mockRepo = MockFileRepository();
    await SettingsService.instance.load();
    provider = FilesProvider(repository: mockRepo, enableMonitoring: false);
  });

  group('FilesProvider Tests', () {
    test('addFile adds a single file', () async {
      final file = MockFileReference();
      when(() => file.pathname).thenReturn('/path/to/file1.txt');
      when(() => file.fileName).thenReturn('file1.txt');
      when(() => file.withIcon(any())).thenReturn(file);
      when(() => file.withPreview(any())).thenReturn(file);
      when(() => file.iconData).thenReturn(null);
      when(() => file.previewData).thenReturn(null);

      when(() => mockRepo.validateFile(any())).thenAnswer((_) async => true);
      when(() => mockRepo.getIcon(any())).thenAnswer((_) async => null);
      when(() => mockRepo.getPreview(any())).thenAnswer((_) async => null);

      await provider.addFile(file);

      expect(provider.files.length, 1);
      expect(provider.files.first, file);
      verify(() => mockRepo.validateFile('/path/to/file1.txt')).called(1);
    });

    test('addFiles adds multiple files', () async {
      final file1 = FileReference(pathname: '/path/to/file1.txt');
      final file2 = FileReference(pathname: '/path/to/file2.txt');

      when(() => mockRepo.validateFile(any())).thenAnswer((_) async => true);
      when(() => mockRepo.getIcon(any())).thenAnswer((_) async => null);
      when(() => mockRepo.getPreview(any())).thenAnswer((_) async => null);

      await provider.addFiles([file1, file2]);

      expect(provider.files.length, 2);
      verify(() => mockRepo.validateFile('/path/to/file1.txt')).called(1);
      verify(() => mockRepo.validateFile('/path/to/file2.txt')).called(1);
    });

    test('does not add duplicate files', () async {
      final file1 = FileReference(pathname: '/path/to/file1.txt');

      when(() => mockRepo.validateFile(any())).thenAnswer((_) async => true);
      when(() => mockRepo.getIcon(any())).thenAnswer((_) async => null);
      when(() => mockRepo.getPreview(any())).thenAnswer((_) async => null);

      await provider.addFile(file1);
      await provider.addFile(file1);

      expect(provider.files.length, 1);
    });

    test('clear removes all files', () async {
      final file1 = FileReference(pathname: '/path/to/file1.txt');

      when(() => mockRepo.validateFile(any())).thenAnswer((_) async => true);
      when(() => mockRepo.getIcon(any())).thenAnswer((_) async => null);
      when(() => mockRepo.getPreview(any())).thenAnswer((_) async => null);

      await provider.addFile(file1);
      expect(provider.files.isNotEmpty, true);

      provider.clear();
      expect(provider.files.isEmpty, true);
    });
  });
}
