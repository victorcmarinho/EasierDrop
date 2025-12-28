import 'package:easier_drop/model/file_reference.dart';
import 'package:easier_drop/providers/files_provider.dart';
import 'package:easier_drop/services/settings_service.dart';
import 'package:easier_drop/services/constants.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:path_provider_platform_interface/path_provider_platform_interface.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class MockFileReference extends Mock implements FileReference {}

class MockPathProviderPlatform extends Mock
    with MockPlatformInterfaceMixin
    implements PathProviderPlatform {
  @override
  Future<String?> getApplicationSupportPath() async {
    return '.';
  }
}

void main() {
  late FilesProvider provider;
  final List<MethodCall> iconCalls = [];

  setUpAll(() {
    TestWidgetsFlutterBinding.ensureInitialized();
    PathProviderPlatform.instance = MockPathProviderPlatform();

    const MethodChannel(PlatformChannels.fileIcon).setMockMethodCallHandler((
      MethodCall methodCall,
    ) async {
      iconCalls.add(methodCall);
      if (methodCall.method == 'getFileIcon') {
        return Uint8List(0); // Return empty bytes as icon
      }
      return null;
    });
  });

  setUp(() async {
    iconCalls.clear();
    await SettingsService.instance.load();
    provider = FilesProvider(enableMonitoring: false);
  });

  group('FilesProvider Tests', () {
    test('addFile adds a single file', () async {
      final file = MockFileReference();
      when(() => file.pathname).thenReturn('/path/to/file1.txt');
      when(() => file.fileName).thenReturn('file1.txt');
      when(() => file.isValidAsync()).thenAnswer((_) async => true);
      when(() => file.isValidSync()).thenReturn(true);
      when(() => file.withIcon(any())).thenReturn(file);
      when(() => file.withPreview(any())).thenReturn(file);
      when(() => file.iconData).thenReturn(null);
      when(() => file.previewData).thenReturn(null);

      await provider.addFile(file);

      expect(provider.files.length, 1);
      expect(provider.files.first, file);
    });

    test('addFiles adds multiple files', () async {
      final file1 = MockFileReference();
      when(() => file1.pathname).thenReturn('/path/to/file1.txt');
      when(() => file1.fileName).thenReturn('file1.txt');
      when(() => file1.isValidAsync()).thenAnswer((_) async => true);
      when(() => file1.isValidSync()).thenReturn(true);
      when(() => file1.withIcon(any())).thenReturn(file1);
      when(() => file1.withPreview(any())).thenReturn(file1);
      when(() => file1.iconData).thenReturn(null);
      when(() => file1.previewData).thenReturn(null);

      final file2 = MockFileReference();
      when(() => file2.pathname).thenReturn('/path/to/file2.txt');
      when(() => file2.fileName).thenReturn('file2.txt');
      when(() => file2.isValidAsync()).thenAnswer((_) async => true);
      when(() => file2.isValidSync()).thenReturn(true);
      when(() => file2.withIcon(any())).thenReturn(file2);
      when(() => file2.withPreview(any())).thenReturn(file2);
      when(() => file2.iconData).thenReturn(null);
      when(() => file2.previewData).thenReturn(null);

      await provider.addFiles([file1, file2]);

      expect(provider.files.length, 2);
    });

    test('does not add duplicate files', () async {
      final file1 = MockFileReference();
      when(() => file1.pathname).thenReturn('/path/to/file1.txt');
      when(() => file1.fileName).thenReturn('file1.txt');
      when(() => file1.isValidAsync()).thenAnswer((_) async => true);
      when(() => file1.isValidSync()).thenReturn(true);
      when(() => file1.withIcon(any())).thenReturn(file1);
      when(() => file1.withPreview(any())).thenReturn(file1);
      when(() => file1.iconData).thenReturn(null);
      when(() => file1.previewData).thenReturn(null);

      await provider.addFile(file1);
      await provider.addFile(file1);

      expect(provider.files.length, 1);
    });

    test('clear removes all files', () async {
      final file1 = MockFileReference();
      when(() => file1.pathname).thenReturn('/path/to/file1.txt');
      when(() => file1.isValidAsync()).thenAnswer((_) async => true);
      when(() => file1.isValidSync()).thenReturn(true);
      when(() => file1.withIcon(any())).thenReturn(file1);
      when(() => file1.withPreview(any())).thenReturn(file1);
      when(() => file1.iconData).thenReturn(null);
      when(() => file1.previewData).thenReturn(null);

      await provider.addFile(file1);
      expect(provider.files.isNotEmpty, true);

      provider.clear();
      expect(provider.files.isEmpty, true);
    });
  });
}
