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
      other: '# arquivos',
      one: '# arquivo',
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
      other: '# arquivos',
      one: '# arquivo',
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
      other: '# arquivos',
      one: '# arquivo',
    );
    return 'Remover $_temp0';
  }

  @override
  String get trayFilesNone => '📂 Sem arquivos';

  @override
  String trayFilesCount(int count) {
    return '📁 Arquivos: $count';
  }

  @override
  String get trayExit => 'Fechar o aplicativo';

  @override
  String get openTray => 'Abrir bandeja';

  @override
  String get filesCountTooltip => 'Quantidade atual na bandeja';

  @override
  String get languageLabel => 'Idioma:';
}
