import 'dart:typed_data';
import 'package:easier_drop/components/parts/animated_file_icon.dart';
import 'package:easier_drop/model/file_reference.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('AnimatedFileIcon builds preview when available', (tester) async {
    final file = FileReference(
      pathname: '/test.png',

      previewData: Uint8List.fromList([
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
        0x08,
        0xD7,
        0x63,
        0x60,
        0x00,
        0x02,
        0x00,
        0x00,
        0x05,
        0x00,
        0x01,
        0x0D,
        0x26,
        0xE5,
        0x2E,
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
      ]),
    );

    await tester.pumpWidget(
      MaterialApp(
        home: AnimatedFileIcon(
          file: file,
          size: 100,
          rotationDegrees: 0,
          dx: 0,
          elevation: 0,
          duration: Duration.zero,
          curve: Curves.linear,
        ),
      ),
    );

    expect(find.byType(Image), findsOneWidget);
  });

  testWidgets('AnimatedFileIcon builds icon when preview unavailable', (
    tester,
  ) async {
    final file = FileReference(
      pathname: '/test.png',

      iconData: Uint8List.fromList([
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
        0x08,
        0xD7,
        0x63,
        0x60,
        0x00,
        0x02,
        0x00,
        0x00,
        0x05,
        0x00,
        0x01,
        0x0D,
        0x26,
        0xE5,
        0x2E,
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
      ]),
    );

    await tester.pumpWidget(
      MaterialApp(
        home: AnimatedFileIcon(
          file: file,
          size: 100,
          rotationDegrees: 0,
          dx: 0,
          elevation: 0,
          duration: Duration.zero,
          curve: Curves.linear,
        ),
      ),
    );

    expect(find.byType(Image), findsOneWidget);
  });

  testWidgets('AnimatedFileIcon builds default icon when nothing available', (
    tester,
  ) async {
    final file = FileReference(pathname: '/test.png');

    await tester.pumpWidget(
      MaterialApp(
        home: AnimatedFileIcon(
          file: file,
          size: 100,
          rotationDegrees: 0,
          dx: 0,
          elevation: 0,
          duration: Duration.zero,
          curve: Curves.linear,
        ),
      ),
    );

    expect(find.byType(Icon), findsOneWidget);
    expect(
      (tester.widget(find.byType(Icon)) as Icon).icon,
      Icons.insert_drive_file,
    );
  });
}
