import 'package:flutter_test/flutter_test.dart';
import 'package:easier_drop/l10n/app_localizations_en.dart';
import 'package:easier_drop/l10n/app_localizations_pt.dart';
import 'package:easier_drop/l10n/app_localizations_es.dart';
import 'package:easier_drop/l10n/app_localizations.dart';

void main() {
  group('Cobertura Completa de Internacionalização', () {
    void testFullCoverage(AppLocalizations loc) {
      // Essas chamadas garantem que todos os getters e métodos sejam acessados
      expect(loc.appTitle, isNotEmpty);
      expect(loc.dropHere, isNotEmpty);
      expect(loc.clearFilesTitle, isNotEmpty);
      expect(loc.clearFilesMessage, isNotEmpty);
      expect(loc.clearCancel, isNotEmpty);
      expect(loc.clearConfirm, isNotEmpty);
      expect(loc.share, isNotEmpty);
      expect(loc.removeAll, isNotEmpty);
      expect(loc.close, isNotEmpty);
      expect(loc.tooltipShare, isNotEmpty);
      expect(loc.tooltipClear, isNotEmpty);
      expect(loc.semAreaLabel, isNotEmpty);
      expect(loc.semAreaHintEmpty, isNotEmpty);
      
      // Plurais e Métodos com argumentos
      expect(loc.semAreaHintHas(1), isNotEmpty);
      expect(loc.semAreaHintHas(2), isNotEmpty);
      expect(loc.semShareHintNone, isNotEmpty);
      expect(loc.semShareHintSome(1), isNotEmpty);
      expect(loc.semShareHintSome(2), isNotEmpty);
      expect(loc.semRemoveHintNone, isNotEmpty);
      expect(loc.semRemoveHintSome(1), isNotEmpty);
      expect(loc.semRemoveHintSome(2), isNotEmpty);
      
      expect(loc.trayExit, isNotEmpty);
      expect(loc.openTray, isNotEmpty);
      expect(loc.languageLabel, isNotEmpty);
      expect(loc.languageEnglish, isNotEmpty);
      expect(loc.languagePortuguese, isNotEmpty);
      expect(loc.languageSpanish, isNotEmpty);
      
      expect(loc.limitReached(10), isNotEmpty);
      expect(loc.shareNone, isNotEmpty);
      expect(loc.shareError, isNotEmpty);
      expect(loc.fileLabelSingle('filename.txt'), isNotEmpty);
      expect(loc.fileLabelMultiple(5), isNotEmpty);
      expect(loc.genericFileName, isNotEmpty);
      
      expect(loc.semHandleLabel, isNotEmpty);
      expect(loc.semHandleHint, isNotEmpty);
      expect(loc.welcomeTo, isNotEmpty);
      expect(loc.updateAvailable, isNotEmpty);
      expect(loc.preferences, isNotEmpty);
      
      // Configurações
      expect(loc.settingsGeneral, isNotEmpty);
      expect(loc.settingsAppearance, isNotEmpty);
      expect(loc.settingsLaunchAtLogin, isNotEmpty);
      expect(loc.settingsAlwaysOnTop, isNotEmpty);
      expect(loc.settingsOpacity, isNotEmpty);
      
      // Updates
      expect(loc.checkForUpdates, isNotEmpty);
      expect(loc.noUpdatesAvailable, isNotEmpty);
      expect(loc.checkingForUpdates, isNotEmpty);
      expect(loc.updateAvailableMessage, isNotEmpty);
      expect(loc.download, isNotEmpty);
      expect(loc.later, isNotEmpty);
      
      // Shake Gesture
      expect(loc.settingsShakeGesture, isNotEmpty);
      expect(loc.settingsShakePermissionActive, isNotEmpty);
      expect(loc.settingsShakePermissionInactive, isNotEmpty);
      expect(loc.settingsShakePermissionDescription, isNotEmpty);
      expect(loc.settingsShakePermissionInstruction, isNotEmpty);
      expect(loc.settingsShakeRestartHint('aqui'), isNotEmpty);
      expect(loc.settingsShakeRestartLink, isNotEmpty);
      
      // Web Landing Page
      expect(loc.webHeroTitle, isNotEmpty);
      expect(loc.webHeroSubtitle, isNotEmpty);
      expect(loc.webDownloadMac, isNotEmpty);
      expect(loc.webInstallBrew, isNotEmpty);
      expect(loc.webFeaturesTitle, isNotEmpty);
      expect(loc.webChangelogTitle, isNotEmpty);
      expect(loc.webFooterText, isNotEmpty);
      expect(loc.webFeature1Title, isNotEmpty);
      expect(loc.webFeature1Desc, isNotEmpty);
      expect(loc.webFeature2Title, isNotEmpty);
      expect(loc.webFeature2Desc, isNotEmpty);
      expect(loc.webFeature3Title, isNotEmpty);
      expect(loc.webFeature3Desc, isNotEmpty);
      expect(loc.webBypassTitle, isNotEmpty);
      expect(loc.webBypassInstruction, isNotEmpty);
      expect(loc.webBypassMotivation, isNotEmpty);
      expect(loc.webBypassVisualTitle, isNotEmpty);
      expect(loc.webBypassVisualInstruction, isNotEmpty);
      expect(loc.webSponsorsTitle, isNotEmpty);
      expect(loc.webSponsorsDesc, isNotEmpty);
      expect(loc.webSponsorsGoal, isNotEmpty);
    }

    test('Cobertura Completa - Inglês', () {
      testFullCoverage(AppLocalizationsEn());
    });

    test('Cobertura Completa - Português', () {
      testFullCoverage(AppLocalizationsPt());
    });

    test('Cobertura Completa - Espanhol', () {
      testFullCoverage(AppLocalizationsEs());
    });
  });
}
