import 'package:flutter_test/flutter_test.dart';
import 'package:easier_drop/l10n/app_localizations_en.dart';

void main() {
  group('AppLocalizationsEn', () {
    late AppLocalizationsEn localizations;

    setUp(() {
      localizations = AppLocalizationsEn();
    });

    test('should have English locale', () {
      expect(localizations.localeName, 'en');
    });

    test('appTitle should return Easier Drop', () {
      expect(localizations.appTitle, 'Easier Drop');
    });

    test('dropHere should return Drop files here', () {
      expect(localizations.dropHere, 'Drop files here');
    });

    test('clearFilesTitle should return Clear files?', () {
      expect(localizations.clearFilesTitle, 'Clear files?');
    });

    test('clearFilesMessage should return explanation', () {
      expect(
        localizations.clearFilesMessage,
        'This will remove all collected files.',
      );
    });

    test('clearCancel should return Cancel', () {
      expect(localizations.clearCancel, 'Cancel');
    });

    test('clearConfirm should return Clear', () {
      expect(localizations.clearConfirm, 'Clear');
    });

    test('share should return Share', () {
      expect(localizations.share, 'Share');
    });

    test('removeAll should return Remove files', () {
      expect(localizations.removeAll, 'Remove files');
    });

    test('close should return Close', () {
      expect(localizations.close, 'Close');
    });

    test('tooltipShare should return share tooltip', () {
      expect(localizations.tooltipShare, 'Share (Cmd+Shift+C)');
    });

    test('tooltipClear should return clear tooltip', () {
      expect(localizations.tooltipClear, 'Clear (Cmd+Backspace)');
    });

    test('semAreaLabel should return area label', () {
      expect(localizations.semAreaLabel, 'File collection area');
    });

    test('semAreaHintEmpty should return empty hint', () {
      expect(localizations.semAreaHintEmpty, 'Empty. Drag files here.');
    });

    test('semAreaHintHas should return hint with files', () {
      expect(
        localizations.semAreaHintHas(1),
        'Contains 1 file. Drag out to move or share.',
      );
      expect(
        localizations.semAreaHintHas(3),
        'Contains 3 files. Drag out to move or share.',
      );
    });

    test('semShareHintNone should return no files hint', () {
      expect(localizations.semShareHintNone, 'No files to share');
    });

    test('semShareHintSome should return share hint', () {
      expect(localizations.semShareHintSome(1), 'Share 1 file');
      expect(localizations.semShareHintSome(2), 'Share 2 files');
    });

    test('semRemoveHintNone should return no remove hint', () {
      expect(localizations.semRemoveHintNone, 'No files to remove');
    });

    test('semRemoveHintSome should return remove hint', () {
      expect(localizations.semRemoveHintSome(1), 'Remove 1 file');
      expect(localizations.semRemoveHintSome(2), 'Remove 2 files');
    });

    test('trayExit should return Quit application', () {
      expect(localizations.trayExit, 'Quit application');
    });

    test('openTray should return Open tray', () {
      expect(localizations.openTray, 'Open tray');
    });

    test('languageLabel should return Language:', () {
      expect(localizations.languageLabel, 'Language:');
    });

    test('languageEnglish should return English', () {
      expect(localizations.languageEnglish, 'English');
    });

    test('languagePortuguese should return Portuguese', () {
      expect(localizations.languagePortuguese, 'Portuguese');
    });

    test('languageSpanish should return Spanish', () {
      expect(localizations.languageSpanish, 'Spanish');
    });

    test('limitReached should return limit message', () {
      expect(localizations.limitReached(100), 'File limit (100) reached');
    });

    test('shareNone should return no files message', () {
      expect(localizations.shareNone, 'No files to share');
    });

    test('shareError should return error message', () {
      expect(localizations.shareError, 'Error sharing files');
    });

    test('fileLabelSingle should return file name', () {
      expect(localizations.fileLabelSingle('test.txt'), 'test.txt');
    });

    test('fileLabelMultiple should return file count', () {
      expect(localizations.fileLabelMultiple(5), '5 files');
    });

    test('genericFileName should return file', () {
      expect(localizations.genericFileName, 'file');
    });

    test('semHandleLabel should return handle label', () {
      expect(localizations.semHandleLabel, 'Window handle');
    });

    test('semHandleHint should return handle hint', () {
      expect(localizations.semHandleHint, 'Drag to move the window');
    });

    test('welcomeTo should return welcome message', () {
      expect(localizations.welcomeTo, 'Hello, welcome to');
    });

    test('updateAvailable should return Update Available', () {
      expect(localizations.updateAvailable, 'Update Available');
    });

    test('preferences should return Preferences', () {
      expect(localizations.preferences, 'Preferences');
    });

    test('settingsGeneral should return General', () {
      expect(localizations.settingsGeneral, 'General');
    });

    test('settingsAppearance should return Appearance', () {
      expect(localizations.settingsAppearance, 'Appearance');
    });

    test('settingsLaunchAtLogin should return Launch at Login', () {
      expect(localizations.settingsLaunchAtLogin, 'Launch at Login');
    });

    test('settingsAlwaysOnTop should return Always on Top', () {
      expect(localizations.settingsAlwaysOnTop, 'Always on Top');
    });

    test('settingsOpacity should return Window Opacity', () {
      expect(localizations.settingsOpacity, 'Window Opacity');
    });
  });
}
