import 'package:easier_drop/l10n/app_localizations.dart';
import 'package:flutter/cupertino.dart';
import 'package:macos_ui/macos_ui.dart';

class AnimatedWelcomeContent extends StatelessWidget {
  final Animation<double> fadeAnimation;
  final Animation<double> scaleAnimation;

  const AnimatedWelcomeContent({
    super.key,
    required this.fadeAnimation,
    required this.scaleAnimation,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        FadeTransition(
          opacity: fadeAnimation,
          child: ScaleTransition(
            scale: scaleAnimation,
            child: Icon(
              CupertinoIcons.cloud_download,
              size: 48,
              color: MacosTheme.of(context).primaryColor,
            ),
          ),
        ),
        const SizedBox(height: 16),
        FadeTransition(
          opacity: fadeAnimation,
          child: Text(
            AppLocalizations.of(context)!.welcomeTo,
            style: MacosTheme.of(context).typography.headline.copyWith(
              color: MacosTheme.of(context).typography.headline.color,
              fontSize: 13,
            ),
            textAlign: TextAlign.center,
          ),
        ),
        const SizedBox(height: 4),
        FadeTransition(
          opacity: fadeAnimation,
          child: Text(
            'Easier Drop',
            style: MacosTheme.of(context).typography.headline.copyWith(
              fontWeight: FontWeight.bold,
              color: MacosTheme.of(context).primaryColor,
              fontSize: 18,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ],
    );
  }
}
