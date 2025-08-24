import 'dart:async';
import 'package:flutter/widgets.dart';

/// Manual localization legacy (pt-BR, en, es).
/// TODO: Remover após migração completa para gen_l10n (usar ARB gerado).
class AppLocalizations {
  final Locale locale;
  AppLocalizations(this.locale);

  static const supportedLocales = [
    Locale('en'),
    Locale('pt', 'BR'),
    Locale('es'),
  ];

  static const _localizedValues = <String, Map<String, String>>{
    'en': {
      'app.title': 'Easier Drop',
      'drop.here': 'Drop files here',
      'drag.none': 'No files to drag.',
      'share': 'Share',
      'remove.all': 'Remove files',
      'close': 'Close',
      'kept.on.copy': 'Kept (copy)',
      'dialog.clear.title': 'Clear files?',
      'dialog.clear.message': 'This will remove all collected files.',
      'dialog.clear.cancel': 'Cancel',
      'dialog.clear.confirm': 'Clear',
      'tooltip.share': 'Share (Cmd+Shift+C)',
      'tooltip.clear': 'Clear (Cmd+Backspace)',
      'sem.area.label': 'File collection area',
      'sem.area.hint.empty': 'Empty. Drag files here.',
      'sem.area.hint.has':
          'Contains {count} file(s). Drag out to move or share.',
      'sem.share.hint.none': 'No files to share',
      'sem.share.hint.some': 'Share {count} file(s)',
      'sem.remove.hint.none': 'No files to remove',
      'sem.remove.hint.some': 'Remove {count} files',
      'tray.files.none': '📂 No files',
      'tray.files.count': '📁 Files: {count}',
      'tray.exit': 'Quit application',
      'tray.open': 'Open tray',
      'tray.lang': 'Language:',
      'tray.files.tooltip': 'Current count in tray',
    },
    'pt': {
      'app.title': 'Easier Drop',
      'drop.here': 'Jogue os arquivos aqui',
      'drag.none': 'Nenhum arquivo para arrastar.',
      'share': 'Compartilhar',
      'remove.all': 'Remover arquivos',
      'close': 'Fechar',
      'kept.on.copy': 'Mantido por cópia',
      'dialog.clear.title': 'Limpar arquivos?',
      'dialog.clear.message': 'Essa ação removerá todos os arquivos coletados.',
      'dialog.clear.cancel': 'Cancelar',
      'dialog.clear.confirm': 'Limpar',
      'tooltip.share': 'Compartilhar (Cmd+Shift+C)',
      'tooltip.clear': 'Limpar (Cmd+Backspace)',
      'sem.area.label': 'Área de colecionar arquivos',
      'sem.area.hint.empty': 'Vazio. Arraste arquivos aqui.',
      'sem.area.hint.has':
          'Contém {count} arquivos. Arraste para fora para mover ou compartilhar.',
      'sem.share.hint.none': 'Nenhum arquivo para compartilhar',
      'sem.share.hint.some': 'Compartilhar {count} arquivos',
      'sem.remove.hint.none': 'Nenhum arquivo para remover',
      'sem.remove.hint.some': 'Remover {count} arquivos',
      'tray.files.none': '📂 Sem arquivos',
      'tray.files.count': '📁 Arquivos: {count}',
      'tray.exit': 'Fechar o aplicativo',
      'tray.open': 'Abrir bandeja',
      'tray.lang': 'Idioma:',
      'tray.files.tooltip': 'Quantidade atual na bandeja',
    },
    'es': {
      'app.title': 'Easier Drop',
      'drop.here': 'Suelta los archivos aquí',
      'drag.none': 'No hay archivos para arrastrar.',
      'share': 'Compartir',
      'remove.all': 'Eliminar archivos',
      'close': 'Cerrar',
      'kept.on.copy': 'Mantenido por copia',
      'dialog.clear.title': '¿Limpiar archivos?',
      'dialog.clear.message':
          'Esta acción eliminará todos los archivos recolectados.',
      'dialog.clear.cancel': 'Cancelar',
      'dialog.clear.confirm': 'Limpiar',
      'tooltip.share': 'Compartir (Cmd+Shift+C)',
      'tooltip.clear': 'Limpiar (Cmd+Backspace)',
      'sem.area.label': 'Área de recolección de archivos',
      'sem.area.hint.empty': 'Vacío. Arrastra archivos aquí.',
      'sem.area.hint.has':
          'Contiene {count} archivo(s). Arrastra para mover o compartir.',
      'sem.share.hint.none': 'No hay archivos para compartir',
      'sem.share.hint.some': 'Compartir {count} archivos',
      'sem.remove.hint.none': 'No hay archivos para eliminar',
      'sem.remove.hint.some': 'Eliminar {count} archivos',
      'tray.files.none': '📂 Sin archivos',
      'tray.files.count': '📁 Archivos: {count}',
      'tray.exit': 'Cerrar la aplicación',
      'tray.open': 'Abrir bandeja',
      'tray.lang': 'Idioma:',
      'tray.files.tooltip': 'Cantidad actual en la bandeja',
    },
  };

  String _langKey() =>
      _localizedValues.containsKey(locale.languageCode)
          ? locale.languageCode
          : 'en';

  String t(String key, {Map<String, String>? params}) {
    final lang = _langKey();
    final map = _localizedValues[lang]!;
    String value = map[key] ?? _localizedValues['en']![key] ?? key;
    if (params != null) {
      params.forEach((k, v) => value = value.replaceAll('{$k}', v));
    }
    return value;
  }

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }
}

class AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) =>
      ['en', 'pt', 'es'].contains(locale.languageCode);

  @override
  Future<AppLocalizations> load(Locale locale) async {
    return AppLocalizations(locale);
  }

  @override
  bool shouldReload(covariant LocalizationsDelegate<AppLocalizations> old) =>
      false;
}
