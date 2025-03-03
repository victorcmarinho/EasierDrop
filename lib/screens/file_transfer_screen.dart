import 'package:easier_drop/components/drag_drop.dart';
import 'package:flutter/material.dart';

class FileTransferScreen extends StatelessWidget {
  const FileTransferScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(body: Row(children: [Expanded(child: DragDrop())]));
  }
}
