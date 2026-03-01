import 'package:easier_drop/l10n/app_localizations_en.dart';
import 'package:easier_drop/model/file_reference.dart';
import 'package:easier_drop/providers/files_provider.dart';
import 'package:easier_drop/services/file_repository.dart';
import 'package:easier_drop/services/settings_service.dart';
import 'package:easier_drop/helpers/share_message_helper.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:path_provider_platform_interface/path_provider_platform_interface.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

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
    provider = FilesProvider(
      repository: mockRepo,
      enableMonitoring: false,
      maxFiles: 10,
    );
    registerFallbackValue('/default/path');
  });

  group('FilesProvider Tests', () {
    test('addFile adds a single file and manages isProcessing', () async {
      final file = FileReference(pathname: '/path/to/file1.txt');

      when(() => mockRepo.validateFile(any())).thenAnswer((_) async => true);
      when(() => mockRepo.getIcon(any())).thenAnswer((_) async => null);
      when(() => mockRepo.getPreview(any())).thenAnswer((_) async => null);

      final addFuture = provider.addFile(file);

      await Future.microtask(() {});

      expect(provider.files.length, 1);
      expect(provider.files.first.pathname, file.pathname);
      expect(provider.files.first.isProcessing, true);

      await addFuture;
      await Future.microtask(() {});

      expect(provider.files.first.isProcessing, false);
      verify(() => mockRepo.validateFile('/path/to/file1.txt')).called(1);
    });

    test('addFiles adds multiple files and manages isProcessing', () async {
      final file1 = FileReference(pathname: '/path/to/file1.txt');
      final file2 = FileReference(pathname: '/path/to/file2.txt');

      when(() => mockRepo.validateFile(any())).thenAnswer((_) async => true);
      when(() => mockRepo.getIcon(any())).thenAnswer((_) async => null);
      when(() => mockRepo.getPreview(any())).thenAnswer((_) async => null);

      final addFuture = provider.addFiles([file1, file2]);

      await Future.microtask(() {});
      expect(provider.files.length, 2);
      expect(provider.files.every((f) => f.isProcessing), true);

      await addFuture;
      await Future.microtask(() {});

      expect(provider.files.every((f) => !f.isProcessing), true);
    });

    test('does not add duplicate files', () async {
      final file1 = FileReference(pathname: '/path/to/file1.txt');

      when(() => mockRepo.validateFile(any())).thenAnswer((_) async => true);
      when(() => mockRepo.getIcon(any())).thenAnswer((_) async => null);
      when(() => mockRepo.getPreview(any())).thenAnswer((_) async => null);

      await provider.addFile(file1);
      await provider.addFile(file1);

      await Future.microtask(() {});
      expect(provider.files.length, 1);
    });

    test('clear removes all files', () async {
      final file1 = FileReference(pathname: '/path/to/file1.txt');

      when(() => mockRepo.validateFile(any())).thenAnswer((_) async => true);
      when(() => mockRepo.getIcon(any())).thenAnswer((_) async => null);
      when(() => mockRepo.getPreview(any())).thenAnswer((_) async => null);

      await provider.addFile(file1);
      await Future.microtask(() {});
      expect(provider.files.isNotEmpty, true);

      provider.clear();
      await Future.microtask(() {});
      expect(provider.files.isEmpty, true);
    });

    test('removeFile removes specific file', () async {
      final file1 = FileReference(pathname: '/path/to/file1.txt');

      when(() => mockRepo.validateFile(any())).thenAnswer((_) async => true);
      when(() => mockRepo.getIcon(any())).thenAnswer((_) async => null);
      when(() => mockRepo.getPreview(any())).thenAnswer((_) async => null);

      await provider.addFile(file1);
      await Future.microtask(() {});
      expect(provider.files.length, 1);

      await provider.removeFile(file1);
      await Future.microtask(() {});
      expect(provider.files.isEmpty, true);
    });

    test('removeByPath removes specific file by path', () async {
      const path = '/path/to/file1.txt';
      final file1 = FileReference(pathname: path);

      when(() => mockRepo.validateFile(any())).thenAnswer((_) async => true);
      when(() => mockRepo.getIcon(any())).thenAnswer((_) async => null);
      when(() => mockRepo.getPreview(any())).thenAnswer((_) async => null);

      await provider.addFile(file1);
      await Future.microtask(() {});
      expect(provider.files.length, 1);

      provider.removeByPath(path);
      await Future.microtask(() {});
      expect(provider.files.isEmpty, true);
    });

    test('respects maxFiles limit', () async {
      provider = FilesProvider(
        repository: mockRepo,
        enableMonitoring: false,
        maxFiles: 2,
      );

      final file1 = FileReference(pathname: '/file1.txt');
      final file2 = FileReference(pathname: '/file2.txt');
      final file3 = FileReference(pathname: '/file3.txt');

      when(() => mockRepo.validateFile(any())).thenAnswer((_) async => true);
      when(() => mockRepo.getIcon(any())).thenAnswer((_) async => null);
      when(() => mockRepo.getPreview(any())).thenAnswer((_) async => null);

      await provider.addFiles([file1, file2, file3]);
      await Future.microtask(() {});

      expect(provider.files.length, 2);
      expect(provider.recentlyAtLimit, true);
      expect(provider.lastLimitHit, isNotNull);
    });

    test('maxFiles override via SettingsService', () async {
      provider = FilesProvider(repository: mockRepo, enableMonitoring: false);

      expect(provider.files.isEmpty, true);
    });

    test('rescan removes invalid files', () async {
      provider = FilesProvider(
        repository: mockRepo,
        enableMonitoring: false,
        maxFiles: 10,
      );

      final file1 = FileReference(pathname: '/valid.txt');
      final file2 = FileReference(pathname: '/invalid.txt');

      when(() => mockRepo.validateFile(any())).thenAnswer((_) async => true);
      when(() => mockRepo.getIcon(any())).thenAnswer((_) async => null);
      when(() => mockRepo.getPreview(any())).thenAnswer((_) async => null);

      await provider.addFiles([file1, file2]);
      await Future.microtask(() {});
      expect(provider.files.length, 2);

      when(() => mockRepo.validateFileSync('/valid.txt')).thenReturn(true);
      when(() => mockRepo.validateFileSync('/invalid.txt')).thenReturn(false);
      provider.rescanNow();
      await Future.microtask(() {});

      expect(provider.files.length, 1);
      expect(provider.files.first.pathname, '/valid.txt');
    });

    test('resolveShareMessage returns correct localizations', () {
      final loc = AppLocalizationsEn();

      expect(
        ShareMessageHelper.resolveShareMessage('shareNone', loc),
        loc.shareNone,
      );
      expect(
        ShareMessageHelper.resolveShareMessage('shareError', loc),
        loc.shareError,
      );
      expect(ShareMessageHelper.resolveShareMessage('custom', loc), 'custom');
    });

    test('dispose cancels timer', () {
      final provider = FilesProvider(enableMonitoring: true);
      expect(() => provider.dispose(), returnsNormally);
    });

    test('shared handles empty list', () async {
      final result = await provider.shared();
      expect(result.toString(), contains('shareNone'));
    });
  });
}
