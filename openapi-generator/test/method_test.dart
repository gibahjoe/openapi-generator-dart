import 'package:openapi_generator/src/utils.dart';
import 'package:test/test.dart';

void main() {
  group('convertToPropertyKey()', () {
    test('convert "nullSafeArrayDefault"', () {
      expect(convertToPropertyKey('nullSafeArrayDefault'),
          equals('nullSafe-array-default'));
    });

    test('convert "pubspecDependencies"', () {
      expect(convertToPropertyKey('pubspecDependencies'),
          equals('pubspec-dependencies'));
    });

    test('convert "pubspecDevDependencies"', () {
      expect(convertToPropertyKey('pubspecDevDependencies'),
          equals('pubspec-dev-dependencies'));
    });

    test('convert "inlineSchemaOptions.arrayItemSuffix"', () {
      expect(
          convertToPropertyKey('arrayItemSuffix'), equals('ARRAY_ITEM_SUFFIX'));
    });

    test('convert "inlineSchemaOptions.mapItemSuffix"', () {
      expect(convertToPropertyKey('mapItemSuffix'), equals('MAP_ITEM_SUFFIX'));
    });

    test('convert "inlineSchemaOptions.skipSchemaReuse"', () {
      expect(
          convertToPropertyKey('skipSchemaReuse'), equals('SKIP_SCHEMA_REUSE'));
    });

    test('convert "inlineSchemaOptions.refactorAllofInlineSchemas"', () {
      expect(convertToPropertyKey('refactorAllofInlineSchemas'),
          equals('REFACTOR_ALLOF_INLINE_SCHEMAS'));
    });

    test('convert "inlineSchemaOptions.resolveInlineEnums"', () {
      expect(convertToPropertyKey('resolveInlineEnums'),
          equals('RESOLVE_INLINE_ENUMS'));
    });
  });
}
