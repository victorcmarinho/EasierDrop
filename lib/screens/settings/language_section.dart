import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:macos_ui/macos_ui.dart';
import 'package:easier_drop/l10n/app_localizations.dart';
import 'package:easier_drop/services/settings_service.dart';

class LanguageSection extends StatelessWidget {
  const LanguageSection({super.key});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: SettingsService.instance,
      builder: (context, _) {
        final settings = SettingsService.instance;
        final loc = AppLocalizations.of(context)!;

        return CupertinoListSection.insetGrouped(
          header: Text(
            loc.languageLabel.toUpperCase(),
            style: MacosTheme.of(context).typography.title3,
          ),
          backgroundColor: Colors.transparent,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
              child: SizedBox(
                width: double.infinity,
                child: CupertinoSlidingSegmentedControl<String>(
                  children: {
                    'en': Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 4,
                      ),
                      child: Text(
                        loc.languageEnglish,
                        style: MacosTheme.of(context).typography.body,
                      ),
                    ),
                    'pt_BR': Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 4,
                      ),
                      child: Text(
                        loc.languagePortuguese,
                        style: MacosTheme.of(context).typography.body,
                      ),
                    ),
                    'es': Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 4,
                      ),
                      child: Text(
                        loc.languageSpanish,
                        style: MacosTheme.of(context).typography.body,
                      ),
                    ),
                  },
                  groupValue: settings.localeCode ?? 'en',
                  onValueChanged: (v) {
                    if (v != null) settings.setLocale(v);
                  },
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
