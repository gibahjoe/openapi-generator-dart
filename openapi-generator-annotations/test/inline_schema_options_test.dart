import 'package:openapi_generator_annotations/openapi_generator_annotations.dart';
import 'package:test/test.dart';

void main() {
  group('InlineSchemaOptions', () {
    test('defaults', () {
      final options = InlineSchemaOptions();
      expect(options.skipSchemaReuse, isTrue);
      expect(options.refactorAllofInlineSchemas, isTrue);
      expect(options.resolveInlineEnums, isTrue);

      [options.arrayItemSuffix, options.mapItemSuffix]
          .forEach((element) => expect(element, isNull));
    });
    test('toMap', () {
      final options = InlineSchemaOptions();
      final map = options.toMap();

      expect(map['skipSchemaReuse'], isTrue);
      expect(map['refactorAllofInlineSchemas'], isTrue);
      expect(map['resolveInlineEnums'], isTrue);

      ['arrayItemSuffix', 'mapItemSuffix']
          .forEach((element) => expect(map.containsKey(element), isFalse));
    });
    test('fromMap', () {
      final options =
          InlineSchemaOptions(arrayItemSuffix: 'test', mapItemSuffix: 'test');
      final map = {
        'arrayItemSuffix': 'test',
        'mapItemSuffix': 'test',
        'skipSchemaReuse': true,
        'refactorAllofInlineSchemas': true,
        'resolveInlineEnums': true,
      };

      final actual = InlineSchemaOptions.fromMap(map);
      expect(actual.skipSchemaReuse, options.skipSchemaReuse);
      expect(actual.refactorAllofInlineSchemas,
          options.refactorAllofInlineSchemas);
      expect(actual.resolveInlineEnums, options.resolveInlineEnums);
      expect(actual.arrayItemSuffix, options.arrayItemSuffix);
      expect(actual.mapItemSuffix, options.mapItemSuffix);
    });
  });
}
