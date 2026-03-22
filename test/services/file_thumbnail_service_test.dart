import 'dart:typed_data';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:easier_drop/model/file_reference.dart';
import 'package:easier_drop/services/file_repository.dart';
import 'package:easier_drop/services/file_thumbnail_service.dart';

class MockFileRepository extends Mock implements FileRepository {}

void main() {
  late FileThumbnailService service;
  late MockFileRepository mockRepo;

  setUp(() {
    mockRepo = MockFileRepository();
    service = FileThumbnailService(mockRepo);
    
    // Default answers for methods
    when(() => mockRepo.getIcon(any())).thenAnswer((_) async => null);
    when(() => mockRepo.getPreview(any())).thenAnswer((_) async => null);
  });

  group('FileThumbnailService', () {
    test('loadThumbnails updates icon and preview if not present', () async {
      final f = const FileReference(pathname: '/test.txt', isProcessing: true);
      FileReference? current = f;
      final updates = <FileReference>[];

      when(() => mockRepo.getIcon('/test.txt'))
          .thenAnswer((_) async => Uint8List.fromList([1, 2, 3]));
      when(() => mockRepo.getPreview('/test.txt'))
          .thenAnswer((_) async => Uint8List.fromList([4, 5, 6]));

      await service.loadThumbnails(
        pathname: '/test.txt',
        getCurrentFile: () => current,
        onUpdate: (updated) {
          updates.add(updated);
          current = updated;
        },
      );

      expect(updates.length, 3); // 1. icon, 2. preview, 3. not processing
      expect(current!.iconData, isNotNull);
      expect(current!.previewData, isNotNull);
      expect(current!.isProcessing, false);
    });

    test('loadThumbnails does nothing if current file is null', () async {
      await service.loadThumbnails(
        pathname: '/none.txt',
        getCurrentFile: () => null,
        onUpdate: (_) => fail('Should not update'),
      );
    });

    test('_loadFileIcon does not update if icon already exists', () async {
      final f = FileReference(pathname: '/exists.txt', iconData: Uint8List(1), isProcessing: true);
      when(() => mockRepo.getIcon(any())).thenAnswer((_) async => Uint8List(2));
      
      var called = false;
      await service.loadThumbnails(
        pathname: '/exists.txt',
        getCurrentFile: () => f,
        onUpdate: (upd) {
           if(upd.isProcessing == false) called = true;
        },
      );
      expect(called, isTrue);
    });

    test('_loadFilePreview does not update if preview already exists', () async {
      final f = FileReference(pathname: '/exists.txt', previewData: Uint8List(1), isProcessing: true);
      when(() => mockRepo.getPreview(any())).thenAnswer((_) async => Uint8List(2));
      
      var called = false;
      await service.loadThumbnails(
        pathname: '/exists.txt',
        getCurrentFile: () => f,
        onUpdate: (upd) {
            if(upd.isProcessing == false) called = true;
        },
      );
      expect(called, isTrue);
    });

    test('finally block handles files without processing state', () async {
       final f = const FileReference(pathname: '/no_proc.txt', isProcessing: false);
       await service.loadThumbnails(
         pathname: '/no_proc.txt',
         getCurrentFile: () => f,
         onUpdate: (_) => fail('Should not call onUpdate'),
       );
    });
  });
}
