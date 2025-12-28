// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class AppLocalizationsEs extends AppLocalizations {
  AppLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String get appTitle => 'Easier Drop';

  @override
  String get dropHere => 'Suelta los archivos aquí';

  @override
  String get clearFilesTitle => '¿Limpiar archivos?';

  @override
  String get clearFilesMessage => 'Esta acción eliminará todos los archivos recolectados.';

  @override
  String get clearCancel => 'Cancelar';

  @override
  String get clearConfirm => 'Limpiar';

  @override
  String get share => 'Compartir';

  @override
  String get removeAll => 'Eliminar archivos';

  @override
  String get close => 'Cerrar';

  @override
  String get tooltipShare => 'Compartir (Cmd+Shift+C)';

  @override
  String get tooltipClear => 'Limpiar (Cmd+Backspace)';

  @override
  String get semAreaLabel => 'Área de recolección de archivos';

  @override
  String get semAreaHintEmpty => 'Vacío. Arrastra archivos aquí.';

  @override
  String semAreaHintHas(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count archivos',
      one: '$count archivo',
    );
    return 'Contiene $_temp0. Arrastra para mover o compartir.';
  }

  @override
  String get semShareHintNone => 'No hay archivos para compartir';

  @override
  String semShareHintSome(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count archivos',
      one: '$count archivo',
    );
    return 'Compartir $_temp0';
  }

  @override
  String get semRemoveHintNone => 'No hay archivos para eliminar';

  @override
  String semRemoveHintSome(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count archivos',
      one: '$count archivo',
    );
    return 'Eliminar $_temp0';
  }

  @override
  String get trayFilesNone => '📂 Sin archivos';

  @override
  String trayFilesCount(int count) {
    return '📁 Archivos: $count';
  }

  @override
  String get trayExit => 'Cerrar la aplicación';

  @override
  String get openTray => 'Abrir bandeja';

  @override
  String get filesCountTooltip => 'Cantidad actual en la bandeja';

  @override
  String get languageLabel => 'Idioma:';

  @override
  String get languageEnglish => 'Inglés';

  @override
  String get languagePortuguese => 'Portugués';

  @override
  String get languageSpanish => 'Español';

  @override
  String limitReached(int max) {
    return 'Se alcanzó el límite de archivos ($max)';
  }

  @override
  String get shareNone => 'No hay archivos para compartir';

  @override
  String get shareError => 'Error al compartir archivos';

  @override
  String fileLabelSingle(String name) {
    return '$name';
  }

  @override
  String fileLabelMultiple(int count) {
    return '$count archivos';
  }

  @override
  String get genericFileName => 'archivo';

  @override
  String get semHandleLabel => 'Barra de arrastre';

  @override
  String get semHandleHint => 'Arrastra para mover la ventana';

  @override
  String get welcomeTo => 'Hola, bienvenido a';

  @override
  String get updateAvailable => 'Actualización Disponible';
}
