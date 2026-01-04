import 'package:easier_drop/components/parts/files_surface_helpers.dart';
import 'package:easier_drop/l10n/app_localizations.dart';
import 'package:easier_drop/model/file_reference.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockAppLocalizations extends Mock implements AppLocalizations {}

void main() {
  group('FilesSurfaceHelpers Tests', () {
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
      test('generateHint returns correct hint for empty list', () {
        final hint = FilesSemanticsHelper.generateHint([], mockLoc);
        expect(hint, equals('empty_hint'));
      });

      test('generateHint returns correct hint for non-empty list', () {
        final files = <FileReference>[
          const FileReference(pathname: 'test.txt'),
        ];
        final hint = FilesSemanticsHelper.generateHint(files, mockLoc);
        expect(hint, equals('has_files_hint'));
      });

      test('generateFileLabel returns empty for empty list', () {
        final label = FilesSemanticsHelper.generateFileLabel(
          <FileReference>[],
          mockLoc,
        );
        expect(label, isEmpty);
      });

      test('generateFileLabel returns label for single file', () {
        final files = <FileReference>[
          const FileReference(pathname: 'test.txt'),
        ];
        final label = FilesSemanticsHelper.generateFileLabel(files, mockLoc);
        expect(label, equals('single_file_label'));
        verify(() => mockLoc.fileLabelSingle('test.txt')).called(1);
      });

      test('generateFileLabel returns label for multiple files', () {
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
      test('constants are accessible', () {
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
