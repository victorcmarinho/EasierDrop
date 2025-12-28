import 'dart:io';
import 'package:easier_drop/l10n/app_localizations.dart';
import 'package:easier_drop/model/file_reference.dart';
import 'package:easier_drop/providers/files_provider.dart';
import 'package:flutter_test/flutter_test.dart';

class CustomShareResult {
  final String raw;
  final String status;

  CustomShareResult(this.raw, this.status);
}

class _TestLocalizations extends AppLocalizations {
  _TestLocalizations() : super('en');

  @override
  String get shareNone => 'No files to share';

  @override
  String get shareError => 'Error sharing files';

  @override
  String get appTitle => 'Test App';

  @override
  String get clearCancel => 'Cancel';

  @override
  String get clearConfirm => 'Clear';

  @override
  String get clearFilesMessage => 'Clear files message';

  @override
  String get clearFilesTitle => 'Clear files?';

  @override
  String get close => 'Close';

  @override
  String get dropHere => 'Drop here';

  @override
  String get filesCountTooltip => 'Files count';

  @override
  String get genericFileName => 'file';

  @override
  String get languageEnglish => 'English';

  @override
  String get languageLabel => 'Language';

  @override
  String get languagePortuguese => 'Portuguese';

  @override
  String get languageSpanish => 'Spanish';

  @override
  String fileLabelMultiple(int count) => '$count files';

  @override
  String fileLabelSingle(String name) => name;

  @override
  String limitReached(int max) => 'Limit reached ($max)';

  @override
  String get openTray => 'Open tray';

  @override
  String get removeAll => 'Remove all';

  @override
  String semAreaHintHas(int count) => '$count files';

  @override
  String get semAreaHintEmpty => 'Empty';

  @override
  String get semAreaLabel => 'Files area';

  @override
  String get semHandleHint => 'Drag to move';

  @override
  String get semHandleLabel => 'Handle';

  @override
  String get semRemoveHintNone => 'Nothing to remove';

  @override
  String semRemoveHintSome(int count) => 'Remove $count';

  @override
  String get semShareHintNone => 'Nothing to share';

  @override
  String semShareHintSome(int count) => 'Share $count';

  @override
  String get share => 'Share';

  @override
  String trayFilesCount(int count) => 'Files: $count';

  @override
  String get trayExit => 'Exit';

  @override
  String get trayFilesNone => 'No files';

  @override
  String get tooltipClear => 'Clear';

  @override
  String get tooltipShare => 'Share';

  @override
  String get welcomeTo => 'Welcome';

  @override
  String get updateAvailable => 'Update Available';
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('FilesProvider métodos adicionais', () {
    late Directory tempDir;

    setUp(() async {
      tempDir = await Directory.systemTemp.createTemp('fp_test');
    });

    tearDown(() async {
      await tempDir.delete(recursive: true);
    });

    test('addFiles adiciona múltiplos arquivos', () async {
      final provider = FilesProvider(enableMonitoring: false);

      final file1 = File('${tempDir.path}/file1.txt')
        ..writeAsStringSync('test1');
      final file2 = File('${tempDir.path}/file2.txt')
        ..writeAsStringSync('test2');

      await provider.addFiles([
        FileReference(pathname: file1.path),
        FileReference(pathname: file2.path),
      ]);

      expect(provider.files.length, 2);
    });

    test('shared retorna objeto quando não há arquivos', () async {
      final provider = FilesProvider(enableMonitoring: false);
      final result = await provider.shared();

      expect((result as dynamic).raw, 'shareNone');
    });

    test('dispose não causa exceções', () {
      final provider = FilesProvider(enableMonitoring: true);
      provider.dispose();
    });

    test('duplicated files não são adicionados', () async {
      final provider = FilesProvider(enableMonitoring: false);

      final file = File('${tempDir.path}/file.txt')..writeAsStringSync('test');

      await provider.addFile(FileReference(pathname: file.path));
      expect(provider.files.length, 1);

      await provider.addFile(FileReference(pathname: file.path));
      expect(provider.files.length, 1);
    });

    test('resolveShareMessage funciona com mensagens predefinidas', () {
      final testLoc = _TestLocalizations();

      expect(
        FilesProvider.resolveShareMessage('shareNone', testLoc),
        'No files to share',
      );

      expect(
        FilesProvider.resolveShareMessage('shareError', testLoc),
        'Error sharing files',
      );

      expect(
        FilesProvider.resolveShareMessage('outra mensagem', testLoc),
        'outra mensagem',
      );
    });
  });
}
