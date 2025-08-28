import 'package:flutter/material.dart';

/// Versão simplificada de DragDrop para testes
class MockDragDrop extends StatelessWidget {
  const MockDragDrop({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.blue.withOpacity(0.1),
      child: const Center(child: Text('Mock DragDrop para Testes')),
    );
  }
}
