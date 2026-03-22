import 'dart:typed_data';
import 'package:easier_drop/model/file_reference.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Getters de FileReference', () {
    test('fileName extrai o nome do arquivo corretamente', () {
      final fileRef = const FileReference(pathname: '/path/to/test_file.txt');
      expect(fileRef.fileName, 'test_file.txt');
    });

    test('extension extrai a extensão corretamente', () {
      final fileRef1 = const FileReference(pathname: '/path/to/test_file.txt');
      expect(fileRef1.extension, 'txt');

      final fileRef2 = const FileReference(pathname: '/path/to/test_file');
      expect(fileRef2.extension, 'test_file');
    });

    test('extension lida com casos extremos corretamente', () {
      final fileRef1 = const FileReference(pathname: '/path/to/.gitignore');
      expect(fileRef1.extension, '.gitignore');

      final fileRef2 = const FileReference(pathname: '/path/to/file.');
      expect(fileRef2.extension, 'file.');

      final fileRef3 = const FileReference(pathname: '/path/to/FILE.TXT');
      expect(fileRef3.extension, 'txt');
    });
  });

  group('FileReference com Processamento', () {
    test('withProcessing cria nova referência com estado de processamento', () {
      final originalRef = const FileReference(pathname: '/path/to/file.txt');
      final newRef = originalRef.withProcessing(true);

      expect(newRef.pathname, originalRef.pathname);
      expect(newRef.isProcessing, isTrue);
    });
  });

  group('FileReference - Outros', () {
    test('toString retorna o formato correto', () {
      final fileRef = const FileReference(pathname: '/file.txt');
      expect(fileRef.toString(), contains('FileReference(pathname: /file.txt'));
    });
  });

  group('FileReference - Ícone e Preview', () {
    test('withIcon cria nova referência com ícone', () {
      final originalRef = const FileReference(pathname: '/path/to/file.txt');
      final mockIcon = Uint8List.fromList([1, 2, 3, 4]);
      final newRef = originalRef.withIcon(mockIcon);

      expect(newRef.pathname, originalRef.pathname);
      expect(newRef.iconData, mockIcon);
    });

    test('withPreview cria nova referência com prévia', () {
      final originalRef = const FileReference(pathname: '/path/to/file.txt');
      final mockPreview = Uint8List.fromList([5, 6, 7, 8]);
      final newRef = originalRef.withPreview(mockPreview);

      expect(newRef.pathname, originalRef.pathname);
      expect(newRef.previewData, mockPreview);
    });
  });

  group('FileReference - Igualdade e hashCode', () {
    test('Referências com o mesmo caminho são iguais, independentemente dos metadados', () {
      final ref1 = const FileReference(pathname: '/path/to/file.txt');
      final ref2 = const FileReference(pathname: '/path/to/file.txt');
      final ref3 = FileReference(
        pathname: '/path/to/file.txt',
        iconData: Uint8List.fromList([1, 2, 3]),
      );

      expect(ref1 == ref2, isTrue);
      expect(ref1 == ref3, isTrue);
      expect(ref1.hashCode, ref2.hashCode);
    });
  });
}
