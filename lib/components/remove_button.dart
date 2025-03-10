import 'package:flutter/material.dart';

class RemoveButton extends StatelessWidget {
  final void Function() onPressed;

  const RemoveButton({super.key, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'Remover arquivos',
      hint: 'Clique para remover todos os arquivos',
      child: IconButton(
        icon: const Icon(Icons.delete_forever),
        onPressed: onPressed,
      ),
    );
  }
}
