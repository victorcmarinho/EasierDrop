import 'dart:io';
import 'package:easier_drop/model/file_reference.dart';
import 'package:easier_drop/providers/files_provider.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('FilesProvider', () {
    late Directory tmpDir;
    late FilesProvider provider;

    setUp(() async {
      tmpDir = await Directory.systemTemp.createTemp('easier_drop_test_');
      provider = FilesProvider(enableMonitoring: false); // sem timer nos testes
    });

    tearDown(() async {
      await tmpDir.delete(recursive: true);
    });

    Future<File> createFile(String name, {String content = 'x'}) async {
      final f = File('${tmpDir.path}/$name');
      await f.writeAsString(content);
      return f;
    }

    test('adiciona arquivo válido', () async {
      final f = await createFile('a.txt');
      await provider.addFile(FileReference(pathname: f.path));
      expect(provider.files.length, 1);
    });

    test('ignora duplicado', () async {
      final f = await createFile('b.txt');
      await provider.addFile(FileReference(pathname: f.path));
      await provider.addFile(FileReference(pathname: f.path));
      expect(provider.files.length, 1);
    });

    test('rescan remove arquivo deletado', () async {
      final f = await createFile('d.txt');
      await provider.addFile(FileReference(pathname: f.path));
      expect(provider.files.length, 1);
      await f.delete();
      provider.rescanNow();
      expect(provider.files.length, 0);
    });

    test('share sem arquivos retorna unavailable', () async {
      final result = await provider.shared();
      expect(result.toString(), contains('unavailable')); // fallback genérico
    });

    test('ignora diretório', () async {
      final dir = Directory('${tmpDir.path}/sub');
      await dir.create();
      await provider.addFile(FileReference(pathname: dir.path));
      expect(provider.files.length, 0);
    });

    test('respeita limite máximo de arquivos (100)', () async {
      // cria 105 arquivos e tenta adicionar
      for (int i = 0; i < 105; i++) {
        final f = await createFile('f_$i.txt');
        await provider.addFile(FileReference(pathname: f.path));
      }
      expect(provider.files.length, lessThanOrEqualTo(100));
    });
  });
}
