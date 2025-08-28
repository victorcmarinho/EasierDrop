import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:easier_drop/providers/files_provider.dart';
import 'package:easier_drop/model/file_reference.dart';
import 'package:easier_drop/services/settings_service.dart';

void main() {
  group('FilesProvider limit & duplicates', () {
    test('enforces maxFiles and recentlyAtLimit flag', () async {
      final settings = SettingsService.instance;
      final prev = settings.maxFiles;
      settings.maxFiles = 2;
      final p = FilesProvider(enableMonitoring: false);
      final dir = await Directory.systemTemp.createTemp('files_limit');
      final f1 = File('${dir.path}/a.txt')..writeAsStringSync('a');
      final f2 = File('${dir.path}/b.txt')..writeAsStringSync('b');
      final f3 = File('${dir.path}/c.txt')..writeAsStringSync('c');
      await p.addFile(FileReference(pathname: f1.path));
      await p.addFile(FileReference(pathname: f2.path));
      expect(p.files.length, 2);
      expect(p.recentlyAtLimit, isFalse);
      await p.addFile(FileReference(pathname: f3.path));
      expect(p.files.length, 2);
      expect(p.recentlyAtLimit, isTrue);
      settings.maxFiles = prev;
    });

    test('duplicate path not added twice', () async {
      final settings = SettingsService.instance;
      final prev = settings.maxFiles;
      settings.maxFiles = 5;
      final p = FilesProvider(enableMonitoring: false);
      final dir = await Directory.systemTemp.createTemp('files_dup');
      final f = File('${dir.path}/dup.txt')..writeAsStringSync('dup');
      await p.addFile(FileReference(pathname: f.path));
      await p.addFile(FileReference(pathname: f.path));
      expect(p.files.length, 1);
      settings.maxFiles = prev;
    });

    test('removeByPath vs removeFile', () async {
      final p = FilesProvider(enableMonitoring: false);
      final dir = await Directory.systemTemp.createTemp('files_remove');
      final f1 = File('${dir.path}/x.txt')..writeAsStringSync('x');
      final f2 = File('${dir.path}/y.txt')..writeAsStringSync('y');
      final ref1 = FileReference(pathname: f1.path);
      final ref2 = FileReference(pathname: f2.path);
      await p.addFile(ref1);
      await p.addFile(ref2);
      p.removeByPath(ref1.pathname);
      expect(p.files.length, 1);
      await p.removeFile(ref2);
      expect(p.files, isEmpty);
    });
  });
}
