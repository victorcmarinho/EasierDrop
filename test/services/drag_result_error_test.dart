import 'package:flutter_test/flutter_test.dart';
import 'package:easier_drop/services/drag_result.dart';

void main() {
  test('ChannelDragResult parses error map', () {
    final r = ChannelDragResult.parse({
      'status': 'error',
      'code': 'perm',
      'message': 'Permission denied',
    });
    expect(r.isSuccess, isFalse);
    expect(r.operation, DragOperation.unknown);
    expect(r, isA<ChannelDragError>());
    final err = r as ChannelDragError;
    expect(err.code, 'perm');
  });

  test('ChannelDragResult legacy string parsing', () {
    final r = ChannelDragResult.parse('move');
    expect(r.isSuccess, isTrue);
    expect(r.operation, DragOperation.move);
  });

  test('ChannelDragResult handles parse exception with stack trace', () {
    // Initialize analytics to ensure debug logging works
    TestWidgetsFlutterBinding.ensureInitialized();

    // Create a map that will throw during parsing
    final badMap = {
      'status': 'ok',
      'op': Object(), // This will cause a cast exception
    };

    final r = ChannelDragResult.parse(badMap);
    // Should return success unknown instead of throwing
    expect(r.isSuccess, isTrue);
    expect(r.operation, DragOperation.unknown);
  });

  test('ChannelDragResult handles parse exception gracefully', () {
    // Create a map that will throw during parsing
    final badMap = {
      'status': 'ok',
      'op': Object(), // This will cause a cast exception
    };

    final r = ChannelDragResult.parse(badMap);
    // Should return success unknown instead of throwing
    expect(r.isSuccess, isTrue);
    expect(r.operation, DragOperation.unknown);
  });
}
