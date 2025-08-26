import 'dart:typed_data';
import 'package:easier_drop/model/file_reference.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('FileReference getters', () {
    test('fileName extrai corretamente o nome do arquivo', () {
      final fileRef = FileReference(pathname: '/path/to/test_file.txt');
      expect(fileRef.fileName, 'test_file.txt');
    });

    test('extension extrai corretamente a extensão do arquivo', () {
      final fileRef1 = FileReference(pathname: '/path/to/test_file.txt');
      expect(fileRef1.extension, 'txt');

      final fileRef2 = FileReference(pathname: '/path/to/test_file');
      expect(fileRef2.extension, 'test_file');

      final fileRef3 = FileReference(pathname: '/path/to/test_file.');
      expect(fileRef3.extension, 'test_file.');

      final fileRef4 = FileReference(pathname: '/path/to/.gitignore');
      expect(fileRef4.extension, '.gitignore');
    });
  });

  group('FileReference withIcon', () {
    test('withIcon cria uma nova referência com ícone', () {
      final originalRef = FileReference(pathname: '/path/to/file.txt');
      expect(originalRef.iconData, isNull);

      final mockIcon = Uint8List.fromList([1, 2, 3, 4]);
      final newRef = originalRef.withIcon(mockIcon);

      expect(newRef.pathname, originalRef.pathname);
      expect(newRef.iconData, mockIcon);
    });

    test('withIcon com null remove ícone existente', () {
      final mockIcon = Uint8List.fromList([1, 2, 3, 4]);
      final originalRef = FileReference(
        pathname: '/path/to/file.txt',
        iconData: mockIcon,
      );
      expect(originalRef.iconData, isNotNull);

      final newRef = originalRef.withIcon(null);
      expect(newRef.pathname, originalRef.pathname);
      expect(newRef.iconData, isNull);
    });
  });

  group('FileReference equalidade e hashCode', () {
    test('Referências ao mesmo arquivo são iguais independente do ícone', () {
      final ref1 = FileReference(pathname: '/path/to/file.txt');
      final ref2 = FileReference(pathname: '/path/to/file.txt');
      final ref3 = FileReference(
        pathname: '/path/to/file.txt',
        iconData: Uint8List.fromList([1, 2, 3]),
      );

      expect(ref1 == ref2, isTrue);
      expect(ref1 == ref3, isTrue);
      expect(ref1.hashCode, ref2.hashCode);
      expect(ref1.hashCode, ref3.hashCode);
    });

    test('Referências a arquivos diferentes não são iguais', () {
      final ref1 = FileReference(pathname: '/path/to/file1.txt');
      final ref2 = FileReference(pathname: '/path/to/file2.txt');

      expect(ref1 == ref2, isFalse);
      expect(ref1.hashCode == ref2.hashCode, isFalse);
    });
  });

  test('toString retorna representação correta', () {
    final ref = FileReference(pathname: '/path/to/file.txt');
    expect(ref.toString(), 'FileReference(pathname: /path/to/file.txt)');
  });
}
