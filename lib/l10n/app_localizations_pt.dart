// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Portuguese (`pt`).
class AppLocalizationsPt extends AppLocalizations {
  AppLocalizationsPt([String locale = 'pt']) : super(locale);

  @override
  String get appTitle => 'Easier Drop';

  @override
  String get dropHere => 'Jogue os arquivos aqui';

  @override
  String get clearFilesTitle => 'Limpar arquivos?';

  @override
  String get clearFilesMessage => 'Essa ação removerá todos os arquivos coletados.';

  @override
  String get clearCancel => 'Cancelar';

  @override
  String get clearConfirm => 'Limpar';

  @override
  String get share => 'Compartilhar';

  @override
  String get removeAll => 'Remover arquivos';

  @override
  String get close => 'Fechar';

  @override
  String get tooltipShare => 'Compartilhar (Cmd+Shift+C)';

  @override
  String get tooltipClear => 'Limpar (Cmd+Backspace)';

  @override
  String get semAreaLabel => 'Área de colecionar arquivos';

  @override
  String get semAreaHintEmpty => 'Vazio. Arraste arquivos aqui.';

  @override
  String semAreaHintHas(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count arquivos',
      one: '$count arquivo',
    );
    return 'Contém $_temp0. Arraste para fora para mover ou compartilhar.';
  }

  @override
  String get semShareHintNone => 'Nenhum arquivo para compartilhar';

  @override
  String semShareHintSome(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count arquivos',
      one: '$count arquivo',
    );
    return 'Compartilhar $_temp0';
  }

  @override
  String get semRemoveHintNone => 'Nenhum arquivo para remover';

  @override
  String semRemoveHintSome(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count arquivos',
      one: '$count arquivo',
    );
    return 'Remover $_temp0';
  }

  @override
  String get trayExit => 'Fechar o aplicativo';

  @override
  String get openTray => 'Abrir bandeja';

  @override
  String get languageLabel => 'Idioma:';

  @override
  String get languageEnglish => 'Inglês';

  @override
  String get languagePortuguese => 'Português';

  @override
  String get languageSpanish => 'Espanhol';

  @override
  String limitReached(int max) {
    return 'Limite de $max arquivos atingido';
  }

  @override
  String get shareNone => 'Sem arquivos para compartilhar';

  @override
  String get shareError => 'Erro ao compartilhar arquivos';

  @override
  String fileLabelSingle(String name) {
    return '$name';
  }

  @override
  String fileLabelMultiple(int count) {
    return '$count arquivos';
  }

  @override
  String get genericFileName => 'arquivo';

  @override
  String get semHandleLabel => 'Barra de arraste';

  @override
  String get semHandleHint => 'Arraste para mover a janela';

  @override
  String get welcomeTo => 'Olá, bem-vindo ao';

  @override
  String get updateAvailable => 'Atualização Disponível';

  @override
  String get preferences => 'Preferências';

  @override
  String get settingsGeneral => 'Geral';

  @override
  String get settingsAppearance => 'Aparência';

  @override
  String get settingsLaunchAtLogin => 'Iniciar no Login';

  @override
  String get settingsAlwaysOnTop => 'Sempre no Topo';

  @override
  String get settingsOpacity => 'Opacidade da Janela';

  @override
  String get checkForUpdates => 'Verificar atualizações';

  @override
  String get noUpdatesAvailable => 'Nenhuma atualização disponível';

  @override
  String get checkingForUpdates => 'Verificando atualizações';

  @override
  String get updateAvailableMessage => 'Uma nova versão está disponível.';

  @override
  String get download => 'Baixar';

  @override
  String get later => 'Depois';

  @override
  String get settingsShakeGesture => 'Gesto de Agitar';

  @override
  String get settingsShakePermissionActive => 'Ativo';

  @override
  String get settingsShakePermissionInactive => 'Inativo';

  @override
  String get settingsShakePermissionDescription => 'Agite o cursor do mouse para abrir rapidamente a janela de arquivos.';

  @override
  String get settingsShakePermissionInstruction => 'Para ativar este recurso, permita a acessibilidade nas Preferências do Sistema.';

  @override
  String settingsShakeRestartHint(String link) {
    return 'Caso já esteja com a permissão ativada clique $link para reiniciar o app.';
  }

  @override
  String get settingsShakeRestartLink => 'aqui';

  @override
  String get webHeroTitle => 'Arraste, Solte, Pronto.';

  @override
  String get webHeroSubtitle => 'A maneira mais fácil de coletar e mover arquivos no seu Mac.';

  @override
  String get webDownloadMac => 'Baixar para macOS';

  @override
  String get webInstallBrew => 'Instalar via Homebrew';

  @override
  String get webFeaturesTitle => 'Recursos';

  @override
  String get webChangelogTitle => 'Novidades';

  @override
  String get webFooterText => 'Código Aberto no GitHub.';

  @override
  String get webFeature1Title => 'Armazenamento Temporário';

  @override
  String get webFeature1Desc => 'Arraste arquivos para o Easier Drop e eles ficam lá até você precisar.';

  @override
  String get webFeature2Title => 'Operações em Lote';

  @override
  String get webFeature2Desc => 'Selecione vários arquivos e arraste-os juntos para outro lugar.';

  @override
  String get webFeature3Title => 'Agite para Abrir';

  @override
  String get webFeature3Desc => 'Basta agitar o mouse para revelar rapidamente a janela.';

  @override
  String get webBypassTitle => 'Informação Importante sobre a Instalação';

  @override
  String get webBypassInstruction => 'Como o Easier Drop é um projeto independente/hobby e não possui uma assinatura paga de desenvolvedor Apple (US\$ 99/ano), o macOS aplicará uma quarentena de segurança. **Mesmo instalando via Homebrew**, você precisará executar o comando abaixo no Terminal para permitir a abertura:';

  @override
  String get webBypassMotivation => 'A Apple exige o pagamento de uma anuidade para que aplicativos sejam \'notarizados\' de forma transparente. Até atingirmos nossa meta de patrocínio, o comando manual é o único meio de garantir o funcionamento do app e das permissões de Acessibilidade.';

  @override
  String get webBypassVisualTitle => 'Alternativa Visual (Sem Terminal)';

  @override
  String get webBypassVisualInstruction => 'Se o comando no Terminal não funcionar ou você preferir a interface visual:\n\n1. Tente abrir o Easier Drop normalmente na pasta **Aplicativos**.\n2. Quando aparecer o aviso de segurança, clique em **\'OK\'**.\n3. Abra os **Ajustes do Sistema** (System Settings) > **Privacidade e Segurança**.\n4. Role até o final e procure a seção \'Segurança\'. Você verá uma mensagem sobre o Easier Drop. Clique em **\'Abrir Mesmo Assim\'**.\n5. Digite sua senha do Mac e confirme. Agora o app abrirá normalmente!';

  @override
  String get webSponsorsTitle => 'Apoie o Projeto';

  @override
  String get webSponsorsDesc => 'Ajude o Easier Drop a se tornar um desenvolvedor verificado da Apple!';

  @override
  String get webSponsorsGoal => 'Nosso objetivo é atingir US\$ 100/ano via GitHub Sponsors para adquirir a assinatura oficial. Isso permitirá que o app seja instalado sem avisos do Gatekeeper e mantenha as permissões de Acessibilidade entre atualizações.';
}
