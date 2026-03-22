import 'package:easier_drop/components/parts/files_surface_helpers.dart';
import 'package:easier_drop/l10n/app_localizations.dart';
import 'package:easier_drop/model/file_reference.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockAppLocalizations extends Mock implements AppLocalizations {}

void main() {
  group('Testes do FilesSurfaceHelpers', () {
    late MockAppLocalizations mockLoc;

    setUp(() {
      mockLoc = MockAppLocalizations();
      when(() => mockLoc.semAreaHintEmpty).thenReturn('empty_hint');
      when(() => mockLoc.semAreaHintHas(any())).thenReturn('has_files_hint');
      when(
        () => mockLoc.fileLabelSingle(any()),
      ).thenReturn('single_file_label');
      when(
        () => mockLoc.fileLabelMultiple(any()),
      ).thenReturn('multiple_files_label');
    });

    group('FilesSemanticsHelper', () {
      test('generateHint retorna a dica correta para lista vazia', () {
        final hint = FilesSemanticsHelper.generateHint([], mockLoc);
        expect(hint, equals('empty_hint'));
      });

      test('generateHint retorna a dica correta para lista não vazia', () {
        final files = <FileReference>[
          const FileReference(pathname: 'test.txt'),
        ];
        final hint = FilesSemanticsHelper.generateHint(files, mockLoc);
        expect(hint, equals('has_files_hint'));
      });

      test('generateFileLabel retorna vazio para lista vazia', () {
        final label = FilesSemanticsHelper.generateFileLabel(
          <FileReference>[],
          mockLoc,
        );
        expect(label, isEmpty);
      });

      test('generateFileLabel retorna o rótulo para um único arquivo', () {
        final files = <FileReference>[
          const FileReference(pathname: 'test.txt'),
        ];
        final label = FilesSemanticsHelper.generateFileLabel(files, mockLoc);
        expect(label, equals('single_file_label'));
        verify(() => mockLoc.fileLabelSingle('test.txt')).called(1);
      });

      test('generateFileLabel retorna o rótulo para vários arquivos', () {
        final files = <FileReference>[
          const FileReference(pathname: 'test1.txt'),
          const FileReference(pathname: 'test2.txt'),
        ];
        final label = FilesSemanticsHelper.generateFileLabel(files, mockLoc);
        expect(label, equals('multiple_files_label'));
        verify(() => mockLoc.fileLabelMultiple(2)).called(1);
      });
    });

    group('FilesSurfaceStyles', () {
      test('as constantes estão acessíveis', () {
        expect(FilesSurfaceStyles.animationDuration, isA<Duration>());
        expect(FilesSurfaceStyles.opacityDuration, isA<Duration>());
        expect(FilesSurfaceStyles.borderWidth, greaterThan(0));
        expect(FilesSurfaceStyles.borderRadius, greaterThan(0));
        expect(FilesSurfaceStyles.contentHeightFactor, greaterThan(0));
        expect(FilesSurfaceStyles.badgeTopPadding, greaterThan(0));
      });
    });
  });
}
