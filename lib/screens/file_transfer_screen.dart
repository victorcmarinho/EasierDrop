import 'package:easier_drop/components/drag_drop.dart';
import 'package:easier_drop/components/tray.dart';
import 'package:flutter/material.dart';

class FileTransferScreen extends StatelessWidget {
  const FileTransferScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Stack(
        children: [
          Row(children: [Expanded(child: DragDrop())]),
          Tray(),
        ],
      ),
    );
  }
}
