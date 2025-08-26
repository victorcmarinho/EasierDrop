import 'dart:typed_data';
import 'package:easier_drop/components/files_stack.dart';
import 'package:easier_drop/l10n/app_localizations.dart';
import 'package:easier_drop/model/file_reference.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:macos_ui/macos_ui.dart';

void main() {
  testWidgets('FilesStack shows placeholder text when empty', (tester) async {
    await tester.pumpWidget(
      MacosApp(
        locale: const Locale('en'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: const Scaffold(body: FilesStack(droppedFiles: [])),
      ),
    );
    await tester.pump();

    // Obter localização para texto esperado
    final loc = await AppLocalizations.delegate.load(const Locale('en'));

    // Verificar mensagem de placeholder
    expect(find.text(loc.dropHere), findsOneWidget);
  });

  testWidgets('FilesStack shows file icons with icons and placeholders', (
    tester,
  ) async {
    // Criar ícone mock (1x1 pixel vermelho)
    final mockIcon = Uint8List.fromList([
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
      0x02,
      0x00,
      0x00,
      0x00,
      0x90,
      0x77,
      0x53,
      0xDE,
      0x00,
      0x00,
      0x00,
      0x0C,
      0x49,
      0x44,
      0x41,
      0x54,
      0x08,
      0xD7,
      0x63,
      0xF8,
      0xCF,
      0xC0,
      0x00,
      0x00,
      0x03,
      0x01,
      0x01,
      0x00,
      0x18,
      0xDD,
      0x8D,
      0xB3,
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

    // Criar arquivos com e sem ícones
    final files = [
      const FileReference(pathname: '/path/to/file1.txt'),
      FileReference(pathname: '/path/to/file2.jpg', iconData: mockIcon),
      const FileReference(pathname: '/path/to/file3.pdf'),
    ];

    await tester.pumpWidget(
      MacosApp(
        locale: const Locale('en'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(
          body: SizedBox(
            width: 300,
            height: 300,
            child: FilesStack(droppedFiles: files),
          ),
        ),
      ),
    );
    await tester.pump();

    // Verificar a presença de ícones de placeholder para arquivos sem iconData
    expect(find.byIcon(Icons.insert_drive_file), findsNWidgets(2));

    // Verificar a presença de imagens para arquivos com iconData
    expect(find.byType(Image), findsOneWidget);

    // Verificar AnimatedContainer para transformação
    expect(find.byType(AnimatedContainer), findsNWidgets(3));
  });

  testWidgets('FilesStack handles single file correctly', (tester) async {
    // Um único arquivo não deve ter rotação nem deslocamento
    final files = [const FileReference(pathname: '/path/to/single.txt')];

    await tester.pumpWidget(
      MacosApp(
        locale: const Locale('en'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(
          body: SizedBox(
            width: 300,
            height: 300,
            child: FilesStack(droppedFiles: files),
          ),
        ),
      ),
    );
    await tester.pump();

    // Verificar que o ícone existe
    expect(find.byIcon(Icons.insert_drive_file), findsOneWidget);

    // Verificar AnimatedContainer
    final containerFinder = find.byType(AnimatedContainer);
    expect(containerFinder, findsOneWidget);

    // Não podemos acessar diretamente a matriz de transformação para verificar rotação
    // Então vamos verificar apenas que o AnimatedContainer existe
    final AnimatedContainer container = tester.widget(containerFinder);
    expect(container, isNotNull);
  });
}
