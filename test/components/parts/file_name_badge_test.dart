import 'package:easier_drop/components/parts/file_name_badge.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('FileNameBadge displays text correctly', (
    WidgetTester tester,
  ) async {
    const fileName = 'example.txt';

    await tester.pumpWidget(
      const MaterialApp(home: Scaffold(body: FileNameBadge(label: fileName))),
    );

    expect(find.text(fileName), findsOneWidget);
  });

  testWidgets('FileNameBadge handles short text', (WidgetTester tester) async {
    const fileName = 'a';

    await tester.pumpWidget(
      const MaterialApp(home: Scaffold(body: FileNameBadge(label: fileName))),
    );

    expect(find.text(fileName), findsOneWidget);
  });
}
