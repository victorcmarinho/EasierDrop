import 'dart:io';
import 'dart:typed_data';
import 'package:easier_drop/model/file_reference.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('FileReference validation', () {
    late Directory tmp;

    setUp(() async {
      tmp = await Directory.systemTemp.createTemp('fr_test_');
    });

    tearDown(() async {
      await tmp.delete(recursive: true);
    });

    test('valid file sync/async', () async {
      final f = File('${tmp.path}/a.txt');
      await f.writeAsString('hello');
      final ref = FileReference(pathname: f.path);
      expect(ref.isValidSync(), isTrue);
      expect(await ref.isValidAsync(), isTrue);
    });

    test('non existing file invalid', () async {
      final ref = FileReference(pathname: '${tmp.path}/missing.txt');
      expect(ref.isValidSync(), isFalse);
      expect(await ref.isValidAsync(), isFalse);
    });

    test('directory invalid', () async {
      final dir = Directory('${tmp.path}/sub');
      await dir.create();
      final ref = FileReference(pathname: dir.path);
      expect(ref.isValidSync(), isFalse);
      expect(await ref.isValidAsync(), isFalse);
    });

    test('extension, size and withIcon/equality', () async {
      final f = File('${tmp.path}/b.data.long');
      await f.writeAsBytes(List.generate(10, (i) => i));
      final ref = FileReference(pathname: f.path);
      expect(ref.extension, 'long');
      final sz = await ref.size;
      expect(sz, 10);
      final ref2 = ref.withIcon(Uint8List.fromList([1, 2, 3]));
      expect(ref2.iconData, isNotNull);
      expect(ref2.pathname, ref.pathname);
      expect(
        ref,
        equals(FileReference(pathname: f.path)),
      ); // equality by pathname
    });
  });
}
