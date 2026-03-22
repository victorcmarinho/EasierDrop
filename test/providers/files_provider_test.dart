import 'dart:typed_data';
import 'package:easier_drop/l10n/app_localizations_en.dart';
import 'package:easier_drop/model/file_reference.dart';
import 'package:easier_drop/providers/files_provider.dart';
import 'package:easier_drop/services/file_repository.dart';
import 'package:easier_drop/services/settings_service.dart';
import 'package:easier_drop/services/file_thumbnail_service.dart';
import 'package:easier_drop/helpers/share_message_helper.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:path_provider_platform_interface/path_provider_platform_interface.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class MockFileRepository extends Mock implements FileRepository {}
class MockThumbnailService extends Mock implements FileThumbnailService {}

class MockPathProviderPlatform extends Mock
    with MockPlatformInterfaceMixin
    implements PathProviderPlatform {
  @override
  Future<String?> getApplicationSupportPath() async => '.';
}

void main() {
  late FilesProvider provider;
  late MockFileRepository mockRepo;
  late MockThumbnailService mockThumb;

  setUpAll(() {
    TestWidgetsFlutterBinding.ensureInitialized();
    PathProviderPlatform.instance = MockPathProviderPlatform();
  });

  setUp(() async {
    mockRepo = MockFileRepository();
    mockThumb = MockThumbnailService();
    
    when(() => mockRepo.validateFile(any())).thenAnswer((_) async => (true, null));
    when(() => mockRepo.validateFileSync(any())).thenReturn(true);
    when(() => mockRepo.getIcon(any())).thenAnswer((_) async => null);
    when(() => mockRepo.getPreview(any())).thenAnswer((_) async => null);
    
    when(() => mockThumb.loadThumbnails(
      pathname: any(named: 'pathname'),
      getCurrentFile: any(named: 'getCurrentFile'),
      onUpdate: any(named: 'onUpdate'),
    )).thenAnswer((_) async {});

    await SettingsService.instance.load();
    provider = FilesProvider(
      repository: mockRepo,
      thumbnailService: mockThumb,
      enableMonitoring: false,
      maxFiles: 10,
    );
    registerFallbackValue('/default/path');
  });

  group('FilesProvider Completo', () {
    test('Getters de estado básico e limites do singleton', () {
      expect(provider.isEmpty, isTrue);
      // hasFiles está no ignore
      expect(provider.fileCount, 0);
      
      // Testa _maxFiles pegando do SettingsService (cobertura da linha 40)
      final p2 = FilesProvider(repository: mockRepo, enableMonitoring: false);
      expect(p2.fileCount, 0);
    });

    test('addFile funcionalidade básica', () async {
      final file = const FileReference(pathname: '/f1.txt');
      await provider.addFile(file);
      expect(provider.files.length, 1);
    });

    test('addFiles lida com duplicados e inválidos', () async {
      final f1 = const FileReference(pathname: '/f1.txt');
      await provider.addFiles([f1, f1]);
      expect(provider.files.length, 1);
    });

    test('addFiles lida com erro no repositório', () async {
      when(() => mockRepo.validateFile(any())).thenAnswer((_) async => (null, Exception('disk error')));
      await provider.addFiles([const FileReference(pathname: '/error.txt')]);
      expect(provider.files.isEmpty, isTrue);
    });

    test('validXFiles e cache', () {
      provider.addFileForTest(const FileReference(pathname: '/v1.txt'));
      final x1 = provider.validXFiles;
      final x2 = provider.validXFiles;
      expect(x1, same(x2));
    });

    test('recentlyAtLimit e lastLimitHit', () async {
      provider = FilesProvider(maxFiles: 1, repository: mockRepo, enableMonitoring: false);
      await provider.addFiles([const FileReference(pathname: '/1.txt'), const FileReference(pathname: '/2.txt')]);
      expect(provider.recentlyAtLimit, isTrue);
    });

    test('addFiles impede adição após limite', () async {
       provider = FilesProvider(maxFiles: 1, repository: mockRepo, enableMonitoring: false);
       await provider.addFile(const FileReference(pathname: '/1.txt'));
       await provider.addFiles([const FileReference(pathname: '/2.txt')]);
       expect(provider.files.length, 1);
    });

    test('rescanInternal remove arquivos inválidos', () {
      provider.addFileForTest(const FileReference(pathname: '/bad.txt'));
      when(() => mockRepo.validateFileSync('/bad.txt')).thenReturn(false);
      provider.rescanNow();
      expect(provider.files.isEmpty, isTrue);
    });

    test('removeFile e removeByPath', () async {
      final f1 = const FileReference(pathname: '/f1.txt');
      provider.addFileForTest(f1);
      await provider.removeFile(f1);
      expect(provider.files.isEmpty, isTrue);
      
      provider.addFileForTest(f1);
      provider.removeByPath('/f1.txt');
      expect(provider.files.isEmpty, isTrue);
    });

    test('clear limpa tudo', () {
      provider.addFileForTest(const FileReference(pathname: '/1.txt'));
      provider.clear();
      expect(provider.files.isEmpty, isTrue);
    });

    test('onUpdate via loadThumbnails atualiza provider', () async {
      void Function(FileReference)? captured;
      when(() => mockThumb.loadThumbnails(
        pathname: any(named: 'pathname'),
        getCurrentFile: any(named: 'getCurrentFile'),
        onUpdate: any(named: 'onUpdate'),
      )).thenAnswer((i) async => captured = i.namedArguments[#onUpdate]);

      final f = const FileReference(pathname: '/t.txt');
      await provider.addFile(f);
      captured!(f.withIcon(Uint8List(0)));
      expect(provider.files.first.iconData, isNotNull);
      captured!(const FileReference(pathname: '/non.txt'));
    });

    test('Helper ShareMessageHelper', () {
      final loc = AppLocalizationsEn();
      expect(ShareMessageHelper.resolveShareMessage('shareNone', loc), loc.shareNone);
      expect(ShareMessageHelper.resolveShareMessage('shareError', loc), loc.shareError);
      expect(ShareMessageHelper.resolveShareMessage('t', loc), 't');
    });

    test('dispose e shared', () async {
      final p = FilesProvider(enableMonitoring: true);
      p.dispose();
      final res = await provider.shared();
      expect(res.toString(), contains('shareNone'));
    });
  });
}
