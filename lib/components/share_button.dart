import 'package:flutter/material.dart';

class ShareButton extends StatelessWidget {
  final void Function() onPressed;
  const ShareButton({super.key, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: "Compartilhar",
      hint: "Toque para compartilhar este conteúdo",
      child: IconButton(
        onPressed: onPressed,
        icon: const Icon(Icons.share),
        tooltip: "Compartilhar",
      ),
    );
  }
}
