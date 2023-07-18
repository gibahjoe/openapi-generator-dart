import 'package:openapi_generator/src/openapi_generator_runner.dart';
import 'package:openapi_generator_annotations/openapi_generator_annotations.dart'
    as n;
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

    test('convert "inlineSchemaOptions.arrayItemSuffix"', () {
      expect(generator.convertToPropertyKey('arrayItemSuffix'),
          equals('ARRAY_ITEM_SUFFIX'));
    });

    test('convert "inlineSchemaOptions.mapItemSuffix"', () {
      expect(generator.convertToPropertyKey('mapItemSuffix'),
          equals('MAP_ITEM_SUFFIX'));
    });

    test('convert "inlineSchemaOptions.skipSchemaReuse"', () {
      expect(generator.convertToPropertyKey('skipSchemaReuse'),
          equals('SKIP_SCHEMA_REUSE'));
    });

    test('convert "inlineSchemaOptions.refactorAllofInlineSchemas"', () {
      expect(generator.convertToPropertyKey('refactorAllofInlineSchemas'),
          equals('REFACTOR_ALLOF_INLINE_SCHEMAS'));
    });

    test('convert "inlineSchemaOptions.resolveInlineEnums"', () {
      expect(generator.convertToPropertyKey('resolveInlineEnums'),
          equals('RESOLVE_INLINE_ENUMS'));
    });
  });

  group('getGeneratorNameFromEnum()', () {
    final generator = OpenapiGenerator();
    test('convert "Generator.dio"', () {
      expect(generator.getGeneratorNameFromEnum(n.Generator.dio),
          equals('dart-dio'));
    });
    test('convert "Generator.dioAlt"', () {
      expect(generator.getGeneratorNameFromEnum(n.Generator.dioAlt),
          equals('dart2-api'));
    });
    test('convert "Generator.dart"', () {
      expect(
          generator.getGeneratorNameFromEnum(n.Generator.dart), equals('dart'));
    });
  });
}
