import 'package:flutter_test/flutter_test.dart';
import 'package:easier_drop/l10n/app_localizations_es.dart';

void main() {
  group('AppLocalizationsEs', () {
    late AppLocalizationsEs localizations;

    setUp(() {
      localizations = AppLocalizationsEs();
    });

    test('deve ter locale espanhol', () {
      expect(localizations.localeName, 'es');
    });

    test('appTitle deve retornar Easier Drop', () {
      expect(localizations.appTitle, 'Easier Drop');
    });

    test('dropHere deve retornar mensaje en español', () {
      expect(localizations.dropHere, 'Suelta los archivos aquí');
    });

    test('clearFilesTitle deve retornar pregunta en español', () {
      expect(localizations.clearFilesTitle, '¿Limpiar archivos?');
    });

    test('clearFilesMessage deve retornar explicación en español', () {
      expect(
        localizations.clearFilesMessage,
        'Esta acción eliminará todos los archivos recolectados.',
      );
    });

    test('clearCancel deve retornar Cancelar', () {
      expect(localizations.clearCancel, 'Cancelar');
    });

    test('clearConfirm deve retornar Limpiar', () {
      expect(localizations.clearConfirm, 'Limpiar');
    });

    test('share deve retornar Compartir', () {
      expect(localizations.share, 'Compartir');
    });

    test('removeAll deve retornar Eliminar archivos', () {
      expect(localizations.removeAll, 'Eliminar archivos');
    });

    test('close deve retornar Cerrar', () {
      expect(localizations.close, 'Cerrar');
    });

    test('tooltipShare deve retornar dica de compartir', () {
      expect(localizations.tooltipShare, 'Compartir (Cmd+Shift+C)');
    });

    test('tooltipClear deve retornar dica de limpiar', () {
      expect(localizations.tooltipClear, 'Limpiar (Cmd+Backspace)');
    });

    test('semAreaLabel deve retornar rótulo del área', () {
      expect(localizations.semAreaLabel, 'Área de recolección de archivos');
    });

    test('semAreaHintEmpty deve retornar dica vacía', () {
      expect(localizations.semAreaHintEmpty, 'Vacío. Arrastra archivos aquí.');
    });

    test('semAreaHintHas deve retornar dica con archivos', () {
      expect(
        localizations.semAreaHintHas(1),
        'Contiene 1 archivo. Arrastra para mover o compartir.',
      );
      expect(
        localizations.semAreaHintHas(3),
        'Contiene 3 archivos. Arrastra para mover o compartir.',
      );
    });

    test('semShareHintNone deve retornar dica sin compartir', () {
      expect(localizations.semShareHintNone, 'No hay archivos para compartir');
    });

    test('semShareHintSome deve retornar dica de compartir', () {
      expect(localizations.semShareHintSome(1), 'Compartir 1 archivo');
      expect(localizations.semShareHintSome(2), 'Compartir 2 archivos');
    });

    test('semRemoveHintNone deve retornar dica sin eliminar', () {
      expect(localizations.semRemoveHintNone, 'No hay archivos para eliminar');
    });

    test('semRemoveHintSome deve retornar dica de eliminar', () {
      expect(localizations.semRemoveHintSome(1), 'Eliminar 1 archivo');
      expect(localizations.semRemoveHintSome(2), 'Eliminar 2 archivos');
    });

    test('trayExit deve retornar mensaje de salir', () {
      expect(localizations.trayExit, 'Cerrar la aplicación');
    });

    test('openTray deve retornar Abrir bandeja', () {
      expect(localizations.openTray, 'Abrir bandeja');
    });

    test('languageLabel deve retornar Idioma:', () {
      expect(localizations.languageLabel, 'Idioma:');
    });

    test('languageEnglish deve retornar Inglés', () {
      expect(localizations.languageEnglish, 'Inglés');
    });

    test('languagePortuguese deve retornar Portugués', () {
      expect(localizations.languagePortuguese, 'Portugués');
    });

    test('languageSpanish deve retornar Español', () {
      expect(localizations.languageSpanish, 'Español');
    });

    test('limitReached deve retornar mensaje de límite', () {
      expect(
        localizations.limitReached(100),
        'Se alcanzó el límite de archivos (100)',
      );
    });

    test('shareNone deve retornar mensaje sin archivos', () {
      expect(localizations.shareNone, 'No hay archivos para compartir');
    });

    test('shareError deve retornar mensaje de error', () {
      expect(localizations.shareError, 'Error al compartir archivos');
    });

    test('fileLabelSingle deve retornar nombre del archivo', () {
      expect(localizations.fileLabelSingle('teste.txt'), 'teste.txt');
    });

    test('fileLabelMultiple deve retornar conteo de archivos', () {
      expect(localizations.fileLabelMultiple(5), '5 archivos');
    });

    test('genericFileName deve retornar archivo', () {
      expect(localizations.genericFileName, 'archivo');
    });

    test('semHandleLabel deve retornar rótulo de la barra', () {
      expect(localizations.semHandleLabel, 'Barra de arrastre');
    });

    test('semHandleHint deve retornar dica de la barra', () {
      expect(localizations.semHandleHint, 'Arrastra para mover la ventana');
    });

    test('welcomeTo deve retornar mensaje de bienvenida', () {
      expect(localizations.welcomeTo, 'Hola, bienvenido a');
    });

    test('updateAvailable deve retornar Actualización Disponible', () {
      expect(localizations.updateAvailable, 'Actualización Disponible');
    });

    test('preferences deve retornar Preferencias', () {
      expect(localizations.preferences, 'Preferencias');
    });

    test('settingsGeneral deve retornar General', () {
      expect(localizations.settingsGeneral, 'General');
    });

    test('settingsAppearance deve retornar Apariencia', () {
      expect(localizations.settingsAppearance, 'Apariencia');
    });

    test('settingsLaunchAtLogin deve retornar Iniciar al iniciar sesión', () {
      expect(localizations.settingsLaunchAtLogin, 'Iniciar al iniciar sesión');
    });

    test('settingsAlwaysOnTop deve retornar Siempre visible', () {
      expect(localizations.settingsAlwaysOnTop, 'Siempre visible');
    });

    test('settingsOpacity deve retornar Opacidad de la ventana', () {
      expect(localizations.settingsOpacity, 'Opacidad de la ventana');
    });
  });
}
