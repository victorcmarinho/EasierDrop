import 'package:flutter/material.dart';
import 'package:easier_drop/l10n/app_localizations.dart';

class DropHit extends StatelessWidget {
  const DropHit({super.key});

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.file_download_outlined,
            size: 72,
            color: Colors.grey,
          ),
          const SizedBox(height: 12),
          Text(
            loc.t('drop.here'),
            style: const TextStyle(fontSize: 16, color: Colors.grey),
          ),
        ],
      ),
    );
  }
}
