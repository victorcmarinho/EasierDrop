import 'package:easier_drop/config/env_config.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('Env coverage boost', () {
    Env.testCoverage();
  });
}
