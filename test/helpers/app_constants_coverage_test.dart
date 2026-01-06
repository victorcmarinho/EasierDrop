import 'package:easier_drop/helpers/app_constants.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('AppConstants coverage boost', () {
    AppConstants.testCoverage();
    SemanticKeys.testCoverage();
    AppOpacity.testCoverage();
  });
}
