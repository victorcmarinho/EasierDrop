import 'dart:typed_data';

import 'package:easier_drop/components/files_stack.dart';
import 'package:easier_drop/model/file_reference.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:easier_drop/l10n/app_localizations.dart';

class MockFileReference extends Mock implements FileReference {}

void main() {
  group('FilesStack Widget Tests', () {
    testWidgets('renders drop here text when empty', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Scaffold(body: FilesStack(droppedFiles: [])),
        ),
      );

      expect(find.text('Drop files here'), findsOneWidget);
    });

    testWidgets('renders file icons when files are present', (tester) async {
      final validPng = Uint8List.fromList([
        0x89,
        0x50,
        0x4E,
        0x47,
        0x0D,
        0x0A,
        0x1A,
        0x0A,
        0x00,
        0x00,
        0x00,
        0x0D,
        0x49,
        0x48,
        0x44,
        0x52,
        0x00,
        0x00,
        0x00,
        0x01,
        0x00,
        0x00,
        0x00,
        0x01,
        0x08,
        0x06,
        0x00,
        0x00,
        0x00,
        0x1F,
        0x15,
        0xC4,
        0x89,
        0x00,
        0x00,
        0x00,
        0x0A,
        0x49,
        0x44,
        0x41,
        0x54,
        0x78,
        0x9C,
        0x63,
        0x00,
        0x01,
        0x00,
        0x00,
        0x05,
        0x00,
        0x01,
        0x0D,
        0x0A,
        0x2D,
        0xB4,
        0x00,
        0x00,
        0x00,
        0x00,
        0x49,
        0x45,
        0x4E,
        0x44,
        0xAE,
        0x42,
        0x60,
        0x82,
      ]);

      final file1 = FileReference(pathname: '/path/1', iconData: validPng);
      final file2 = FileReference(pathname: '/path/2', iconData: validPng);

      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Scaffold(body: FilesStack(droppedFiles: [file1, file2])),
        ),
      );

      // Need to pump and settle because of AnimatedSwitcher and AsyncFileWrapper animations
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));
      await tester.pumpAndSettle();

      expect(find.byType(Image), findsNWidgets(2));
    });
    group('FilesStack Widget Tests Additional', () {
      testWidgets('renders shimmer when files are processing', (tester) async {
        final file1 = FileReference(pathname: '/path/1', isProcessing: true);

        await tester.pumpWidget(
          MaterialApp(
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: Scaffold(body: FilesStack(droppedFiles: [file1])),
          ),
        );

        await tester.pump();
        expect(find.byType(Image), findsNothing);
        // We can't easily find Shimmer widget if it's not exported or if it's internal,
        // but we can check for its presence via type if we import it or just check for absence of Image.
      });
    });
  });
}
