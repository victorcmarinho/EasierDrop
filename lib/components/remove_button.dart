import 'package:flutter/widgets.dart';
import 'package:macos_ui/macos_ui.dart';
import 'package:flutter/cupertino.dart';
import 'package:easier_drop/l10n/app_localizations.dart';
import 'hover_icon_button.dart';

class RemoveButton extends StatefulWidget {
  final void Function() onPressed;
  const RemoveButton({super.key, required this.onPressed});

  @override
  State<RemoveButton> createState() => _RemoveButtonState();
}

class _RemoveButtonState extends State<RemoveButton> {
  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    return HoverIconButton(
      icon: const MacosIcon(CupertinoIcons.trash),
      onPressed: widget.onPressed,
      semanticsLabel: loc.removeAll,
      addSemantics: false,
    );
  }
}
