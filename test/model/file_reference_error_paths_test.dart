import 'dart:io';
import 'package:easier_drop/model/file_reference.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('FileReference error paths', () {
    test(
      'async validation returns false if file deleted before stat',
      () async {
        final dir = await Directory.systemTemp.createTemp('fr_err_');
        final f = File('${dir.path}/temp.bin');
        await f.writeAsString('data');
        final ref = FileReference(pathname: f.path);

        await f.delete();
        expect(await ref.isValidAsync(), isFalse);
        await dir.delete(recursive: true);
      },
    );

    test('sync validation false for removed file', () async {
      final dir = await Directory.systemTemp.createTemp('fr_err2_');
      final f = File('${dir.path}/t.bin');
      await f.writeAsString('x');
      final ref = FileReference(pathname: f.path);
      await f.delete();
      expect(ref.isValidSync(), isFalse);
      await dir.delete(recursive: true);
    });

    test('extension with no dot returns whole last segment', () async {
      final dir = await Directory.systemTemp.createTemp('fr_ext_');
      final f = File('${dir.path}/filename')..writeAsStringSync('z');
      final ref = FileReference(pathname: f.path);

      expect(ref.extension, 'filename');
      await dir.delete(recursive: true);
    });
  });
}
