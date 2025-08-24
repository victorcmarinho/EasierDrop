import 'package:flutter/widgets.dart';
import 'package:macos_ui/macos_ui.dart';
import 'package:flutter/cupertino.dart';
import 'package:easier_drop/l10n/app_localizations.dart';
import 'hover_icon_button.dart';

class ShareButton extends StatefulWidget {
  final void Function() onPressed;
  const ShareButton({super.key, required this.onPressed});

  @override
  State<ShareButton> createState() => _ShareButtonState();
}

class _ShareButtonState extends State<ShareButton> {
  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    return HoverIconButton(
      icon: const MacosIcon(CupertinoIcons.share),
      onPressed: widget.onPressed,
      semanticsLabel: loc.share,
      addSemantics: false,
    );
  }
}
