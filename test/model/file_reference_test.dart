import 'dart:typed_data';
import 'package:easier_drop/model/file_reference.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('FileReference getters', () {
    test('fileName extracts filename correctly', () {
      final fileRef = FileReference(pathname: '/path/to/test_file.txt');
      expect(fileRef.fileName, 'test_file.txt');
    });

    test('extension extracts extension correctly', () {
      final fileRef1 = FileReference(pathname: '/path/to/test_file.txt');
      expect(fileRef1.extension, 'txt');

      final fileRef2 = FileReference(pathname: '/path/to/test_file');
      expect(fileRef2.extension, 'test_file');
    });
  });

  group('FileReference withIcon and withPreview', () {
    test('withIcon creates new reference with icon', () {
      final originalRef = FileReference(pathname: '/path/to/file.txt');
      final mockIcon = Uint8List.fromList([1, 2, 3, 4]);
      final newRef = originalRef.withIcon(mockIcon);

      expect(newRef.pathname, originalRef.pathname);
      expect(newRef.iconData, mockIcon);
    });

    test('withPreview creates new reference with preview', () {
      final originalRef = FileReference(pathname: '/path/to/file.txt');
      final mockPreview = Uint8List.fromList([5, 6, 7, 8]);
      final newRef = originalRef.withPreview(mockPreview);

      expect(newRef.pathname, originalRef.pathname);
      expect(newRef.previewData, mockPreview);
    });
  });

  group('FileReference equality and hashCode', () {
    test('References to same path are equal regardless of metadata', () {
      final ref1 = FileReference(pathname: '/path/to/file.txt');
      final ref2 = FileReference(pathname: '/path/to/file.txt');
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
