import 'package:flutter/material.dart';
import 'package:easier_drop/services/constants.dart';

class DropHit extends StatelessWidget {
  const DropHit({super.key});

  @override
  Widget build(BuildContext context) {
    return const Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.file_download_outlined, size: 100),
        Text(AppTexts.dropHere),
      ],
    );
  }
}
