import 'package:flutter_test/flutter_test.dart';
import 'package:easier_drop/core/utils/result_handler.dart';

void main() {
  group('ResultHandler', () {
    group('safeCall', () {
      test('should return data and null error on success', () async {
        final (data, error) = await safeCall(() async => 'success');
        expect(data, 'success');
        expect(error, isNull);
      });

      test('should return null data and Exception on error', () async {
        final exception = Exception('Something went wrong');
        final (data, error) = await safeCall(() async => throw exception);
        expect(data, isNull);
        expect(error, equals(exception));
      });
      
      test('should return null data and Error on error', () async {
        final ArgumentError err = ArgumentError('Invalid arg');
        final (data, error) = await safeCall(() async => throw err);
        expect(data, isNull);
        expect(error, equals(err));
      });
    });

    group('safeCallSync', () {
      test('should return data and null error on success', () {
        final (data, error) = safeCallSync(() => 'success sync');
        expect(data, 'success sync');
        expect(error, isNull);
      });

      test('should return null data and Exception on error', () {
        final exception = Exception('Something went wrong sync');
        final (data, error) = safeCallSync(() => throw exception);
        expect(data, isNull);
        expect(error, equals(exception));
      });
      
      test('should return null data and Error on error', () {
        final RangeError err = RangeError('Index out of bounds');
        final (data, error) = safeCallSync(() => throw err);
        expect(data, isNull);
        expect(error, equals(err));
      });
    });
  });
}
