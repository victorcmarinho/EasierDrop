import 'dart:convert';
import 'dart:io';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('All ARB files share same keys', () async {
    final dir = Directory('lib/l10n');
    final arbFiles =
        dir
            .listSync()
            .whereType<File>()
            .where((f) => f.path.endsWith('.arb'))
            .toList();
    expect(arbFiles, isNotEmpty);
    final keySets = <Set<String>>[];
    for (final f in arbFiles) {
      final map = jsonDecode(await f.readAsString()) as Map<String, dynamic>;
      keySets.add(map.keys.where((k) => !k.startsWith('@')).toSet());
    }
    final intersection = keySets.reduce((a, b) => a.intersection(b));
    final union = keySets.reduce((a, b) => a.union(b));
    // Parity: union and intersection must match
    expect(
      intersection,
      union,
      reason:
          'Missing keys across locales: union= $union intersection= $intersection',
    );
  });
}
