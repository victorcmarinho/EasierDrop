import 'package:flutter/material.dart';

class MockDragDrop extends StatelessWidget {
  const MockDragDrop({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.blue.withValues(alpha: 0.1),
      child: const Center(child: Text('Mock DragDrop para Testes')),
    );
  }
}
