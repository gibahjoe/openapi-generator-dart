import 'package:openapi_generator/src/openapi_generator_runner.dart';
import 'package:test/test.dart';


void main() {
  group('convertToPropertyKey()', () {
    final generator = OpenapiGenerator();

    test('convert "nullSafeArrayDefault"', () {
      expect(generator.convertToPropertyKey('nullSafeArrayDefault'),
          equals('nullSafe-array-default'));
    });

    test('convert "pubspecDependencies"', () {
      expect(generator.convertToPropertyKey('pubspecDependencies'),
          equals('pubspec-dependencies'));
    });

    test('convert "pubspecDevDependencies"', () {
      expect(generator.convertToPropertyKey('pubspecDevDependencies'),
          equals('pubspec-dev-dependencies'));
    });

    group('convertToPropertyValue()', () {
      // TODO.
    });
  });
}
