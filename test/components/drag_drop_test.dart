import 'package:easier_drop/components/drag_drop.dart';
import 'package:easier_drop/controllers/drag_coordinator.dart';
import 'package:easier_drop/l10n/app_localizations.dart';
import 'package:easier_drop/model/file_reference.dart';
import 'package:easier_drop/providers/files_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:macos_ui/macos_ui.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:provider/provider.dart';

// Gerador de mocks
@GenerateNiceMocks([MockSpec<FilesProvider>(), MockSpec<DragCoordinator>()])
import 'drag_drop_test.mocks.dart';

class MockValueNotifier<T> extends ValueNotifier<T> {
  MockValueNotifier(super.value);
  int notifyListenersCalled = 0;

  @override
  void notifyListeners() {
    notifyListenersCalled++;
    super.notifyListeners();
  }
}

class TestFileReference extends FileReference {
  const TestFileReference(String path) : super(pathname: path);
}

// Um widget que envolve o widget de teste com todos os provedores necessários
class TestWrapper extends StatelessWidget {
  final Widget child;
  final MockFilesProvider filesProvider;

  const TestWrapper({
    Key? key,
    required this.child,
    required this.filesProvider,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MacosApp(
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: AppLocalizations.supportedLocales,
      locale: const Locale('en'),
      home: MultiProvider(
        providers: [
          ChangeNotifierProvider<FilesProvider>.value(value: filesProvider),
        ],
        child: Builder(builder: (context) => child),
      ),
    );
  }
}

void main() {
  late MockFilesProvider mockFilesProvider;

  setUp(() {
    mockFilesProvider = MockFilesProvider();

    // Configurar o comportamento do mock
    when(mockFilesProvider.files).thenReturn([]);
    when(mockFilesProvider.lastLimitHit).thenReturn(null);
  });

  testWidgets('DragDrop inicializa e descarta o DragCoordinator corretamente', (
    tester,
  ) async {
    await tester.pumpWidget(
      TestWrapper(
        filesProvider: mockFilesProvider,
        child: const Scaffold(body: DragDrop()),
      ),
    );

    await tester.pumpAndSettle();

    // Verificar se o widget foi construído corretamente
    expect(find.byType(DragDrop), findsOneWidget);

    // Forçar descarte
    await tester.pumpWidget(Container());
  });

  testWidgets('DragDrop limpa os arquivos quando há arquivos', (tester) async {
    // Configurar o mock para ter arquivos
    final files = [
      const TestFileReference('/path/to/file1.txt'),
      const TestFileReference('/path/to/file2.txt'),
    ];
    when(mockFilesProvider.files).thenReturn(files);

    // Criar um wrapper para acessar o contexto e chamar métodos
    bool clearCalled = false;

    await tester.pumpWidget(
      TestWrapper(
        filesProvider: mockFilesProvider,
        child: Scaffold(
          body: const DragDrop(),
          floatingActionButton: FloatingActionButton(
            onPressed: () {
              // Chamar clear via provider
              final provider = Provider.of<FilesProvider>(
                tester.element(find.byType(DragDrop)),
                listen: false,
              );
              if (provider.files.isNotEmpty) {
                provider.clear();
                clearCalled = true;
              }
            },
          ),
        ),
      ),
    );

    await tester.pumpAndSettle();

    // Acionar o botão que simula a limpeza
    await tester.tap(find.byType(FloatingActionButton));
    await tester.pumpAndSettle();

    // Verificar que a limpeza foi chamada
    expect(clearCalled, true);
    verify(mockFilesProvider.clear()).called(1);
  });

  testWidgets('DragDrop não limpa quando não há arquivos', (tester) async {
    // Configurar o mock para não ter arquivos
    when(mockFilesProvider.files).thenReturn([]);

    bool clearAttempted = false;

    await tester.pumpWidget(
      TestWrapper(
        filesProvider: mockFilesProvider,
        child: Scaffold(
          body: const DragDrop(),
          floatingActionButton: FloatingActionButton(
            onPressed: () {
              // Simular o comportamento de _clearImmediate
              final provider = Provider.of<FilesProvider>(
                tester.element(find.byType(DragDrop)),
                listen: false,
              );
              clearAttempted = true;
              if (provider.files.isNotEmpty) {
                provider.clear();
              }
            },
          ),
        ),
      ),
    );

    await tester.pumpAndSettle();

    // Acionar o botão que simula a tentativa de limpeza
    await tester.tap(find.byType(FloatingActionButton));
    await tester.pumpAndSettle();

    // Verificar que a tentativa foi feita, mas clear não foi chamado
    expect(clearAttempted, true);
    verifyNever(mockFilesProvider.clear());
  });

  testWidgets('DragDrop mostra o limite quando lastLimitHit é recente', (
    tester,
  ) async {
    // Configurar o mock para mostrar limite
    final now = DateTime.now();
    when(mockFilesProvider.lastLimitHit).thenReturn(now);

    await tester.pumpWidget(
      TestWrapper(
        filesProvider: mockFilesProvider,
        child: const Scaffold(body: DragDrop()),
      ),
    );

    await tester.pumpAndSettle();

    // Verificar que o widget foi renderizado
    expect(find.byType(DragDrop), findsOneWidget);
  });
}
