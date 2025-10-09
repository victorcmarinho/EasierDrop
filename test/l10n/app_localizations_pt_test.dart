import 'package:flutter_test/flutter_test.dart';
import 'package:easier_drop/l10n/app_localizations_pt.dart';

void main() {
  group('AppLocalizationsPt', () {
    late AppLocalizationsPt localizations;

    setUp(() {
      localizations = AppLocalizationsPt();
    });

    test('deve ter locale português', () {
      expect(localizations.localeName, 'pt');
    });

    test('appTitle deve retornar Easier Drop', () {
      expect(localizations.appTitle, 'Easier Drop');
    });

    test('dropHere deve retornar mensagem em português', () {
      expect(localizations.dropHere, 'Jogue os arquivos aqui');
    });

    test('clearFilesTitle deve retornar pergunta em português', () {
      expect(localizations.clearFilesTitle, 'Limpar arquivos?');
    });

    test('clearFilesMessage deve retornar explicação em português', () {
      expect(
        localizations.clearFilesMessage,
        'Essa ação removerá todos os arquivos coletados.',
      );
    });

    test('clearCancel deve retornar Cancelar', () {
      expect(localizations.clearCancel, 'Cancelar');
    });

    test('clearConfirm deve retornar Limpar', () {
      expect(localizations.clearConfirm, 'Limpar');
    });

    test('share deve retornar Compartilhar', () {
      expect(localizations.share, 'Compartilhar');
    });

    test('removeAll deve retornar Remover arquivos', () {
      expect(localizations.removeAll, 'Remover arquivos');
    });

    test('trayExit deve retornar mensagem de sair', () {
      expect(localizations.trayExit, 'Fechar o aplicativo');
    });

    test('openTray deve retornar Abrir bandeja', () {
      expect(localizations.openTray, 'Abrir bandeja');
    });

    test('trayFilesNone deve retornar mensagem sem arquivos', () {
      expect(localizations.trayFilesNone, '📂 Sem arquivos');
    });

    test('trayFilesCount deve retornar contagem formatada', () {
      expect(localizations.trayFilesCount(1), '📁 Arquivos: 1');
      expect(localizations.trayFilesCount(2), '📁 Arquivos: 2');
      expect(localizations.trayFilesCount(5), '📁 Arquivos: 5');
    });

    test('filesCountTooltip deve retornar dica', () {
      expect(localizations.filesCountTooltip, 'Quantidade atual na bandeja');
    });

    test('languageLabel deve retornar Idioma:', () {
      expect(localizations.languageLabel, 'Idioma:');
    });

    test('languageEnglish deve retornar Inglês', () {
      expect(localizations.languageEnglish, 'Inglês');
    });

    test('languagePortuguese deve retornar Português', () {
      expect(localizations.languagePortuguese, 'Português');
    });

    test('languageSpanish deve retornar Espanhol', () {
      expect(localizations.languageSpanish, 'Espanhol');
    });

    test('limitReached deve retornar mensagem de limite', () {
      expect(
        localizations.limitReached(100),
        'Limite de 100 arquivos atingido',
      );
    });

    test('shareNone deve retornar mensagem sem arquivos', () {
      expect(localizations.shareNone, 'Sem arquivos para compartilhar');
    });

    test('shareError deve retornar mensagem de erro', () {
      expect(localizations.shareError, 'Erro ao compartilhar arquivos');
    });

    test('close deve retornar Fechar', () {
      expect(localizations.close, 'Fechar');
    });

    test('tooltipShare deve retornar dica de compartilhar', () {
      expect(localizations.tooltipShare, 'Compartilhar (Cmd+Shift+C)');
    });

    test('tooltipClear deve retornar dica de limpar', () {
      expect(localizations.tooltipClear, 'Limpar (Cmd+Backspace)');
    });

    test('semAreaLabel deve retornar rótulo da área', () {
      expect(localizations.semAreaLabel, 'Área de colecionar arquivos');
    });

    test('semAreaHintEmpty deve retornar dica vazia', () {
      expect(localizations.semAreaHintEmpty, 'Vazio. Arraste arquivos aqui.');
    });

    test('semAreaHintHas deve retornar dica com arquivos', () {
      expect(
        localizations.semAreaHintHas(1),
        'Contém 1 arquivo. Arraste para fora para mover ou compartilhar.',
      );
      expect(
        localizations.semAreaHintHas(3),
        'Contém 3 arquivos. Arraste para fora para mover ou compartilhar.',
      );
    });

    test('semShareHintNone deve retornar dica sem compartilhamento', () {
      expect(
        localizations.semShareHintNone,
        'Nenhum arquivo para compartilhar',
      );
    });

    test('semShareHintSome deve retornar dica de compartilhamento', () {
      expect(localizations.semShareHintSome(1), 'Compartilhar 1 arquivo');
      expect(localizations.semShareHintSome(2), 'Compartilhar 2 arquivos');
    });

    test('semRemoveHintNone deve retornar dica sem remoção', () {
      expect(localizations.semRemoveHintNone, 'Nenhum arquivo para remover');
    });

    test('semRemoveHintSome deve retornar dica de remoção', () {
      expect(localizations.semRemoveHintSome(1), 'Remover 1 arquivo');
      expect(localizations.semRemoveHintSome(2), 'Remover 2 arquivos');
    });

    test('fileLabelSingle deve retornar nome do arquivo', () {
      expect(localizations.fileLabelSingle('teste.txt'), 'teste.txt');
    });

    test('fileLabelMultiple deve retornar contagem de arquivos', () {
      expect(localizations.fileLabelMultiple(5), '5 arquivos');
    });

    test('genericFileName deve retornar arquivo', () {
      expect(localizations.genericFileName, 'arquivo');
    });

    test('semHandleLabel deve retornar rótulo da barra', () {
      expect(localizations.semHandleLabel, 'Barra de arraste');
    });

    test('semHandleHint deve retornar dica da barra', () {
      expect(localizations.semHandleHint, 'Arraste para mover a janela');
    });
  });
}
