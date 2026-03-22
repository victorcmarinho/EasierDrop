import 'package:easier_drop/components/parts/file_name_badge.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('FileNameBadge exibe o texto corretamente', (
    WidgetTester tester,
  ) async {
    const fileName = 'example.txt';

    await tester.pumpWidget(
      const MaterialApp(home: Scaffold(body: FileNameBadge(label: fileName))),
    );

    expect(find.bySemanticsLabel(fileName), findsOneWidget);
  });

  testWidgets('FileNameBadge lida com texto curto', (WidgetTester tester) async {
    const fileName = 'a';

    await tester.pumpWidget(
      const MaterialApp(home: Scaffold(body: FileNameBadge(label: fileName))),
    );

    expect(find.bySemanticsLabel(fileName), findsOneWidget);
  });
}
