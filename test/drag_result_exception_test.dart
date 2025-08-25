import 'package:easier_drop/services/drag_result.dart';
import 'package:flutter_test/flutter_test.dart';

class _WeirdObject {
  @override
  String toString() => throw Exception('boom');
}

void main() {
  test('parse gracefully handles unexpected object', () {
    final r = ChannelDragResult.parse(_WeirdObject());
    expect(r.isSuccess, isTrue); // falls back to success unknown
    expect(r.operation, DragOperation.unknown);
  });
}
