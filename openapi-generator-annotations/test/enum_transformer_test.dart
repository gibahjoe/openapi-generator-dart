import 'package:openapi_generator_annotations/openapi_generator_annotations.dart';
import 'package:test/test.dart';

void main() {
  group('EnumTransformer', () {
    group('Transforms name -> value', () {
      group('Wrapper', () {
        test('fvm', () => expect(EnumTransformer.wrapper('fvm'), Wrapper.fvm));
        test(
            'flutterw',
            () =>
                expect(EnumTransformer.wrapper('flutterw'), Wrapper.flutterw));
        test('defaults to none',
            () => expect(EnumTransformer.wrapper('invalid'), Wrapper.none));
        test('none',
            () => expect(EnumTransformer.wrapper('none'), Wrapper.none));
      });
      group('Generator', () {
        test('dart',
            () => expect(EnumTransformer.generator('dart'), Generator.dart));
        test('dio',
            () => expect(EnumTransformer.generator('dio'), Generator.dio));
        test(
            'dioAlt',
            () =>
                expect(EnumTransformer.generator('dioAlt'), Generator.dioAlt));
        test('defaults to dart',
            () => expect(EnumTransformer.generator(null), Generator.dart));
      });
      group('DioDateLibrary', () {
        test(
            'core',
            () => expect(
                EnumTransformer.dioDateLibrary('core'), DioDateLibrary.core));
        test(
            'timemachine',
            () => expect(EnumTransformer.dioDateLibrary('timemachine'),
                DioDateLibrary.timemachine));
        test('defaults to null',
            () => expect(EnumTransformer.dioDateLibrary(null), null));
      });
      group('DioSerializationLibrary', () {
        test(
            'built_value',
            () => expect(EnumTransformer.dioSerializationLibrary('built_value'),
                DioSerializationLibrary.built_value));
        test(
            'json_serializable',
            () => expect(
                EnumTransformer.dioSerializationLibrary('json_serializable'),
                DioSerializationLibrary.json_serializable));
        test('defaults to null',
            () => expect(EnumTransformer.dioSerializationLibrary(null), null));
      });
    });
    group('Transforms value -> name', () {
      group('Wrapper', () {
        test('fvm',
            () => expect(EnumTransformer.wrapperName(Wrapper.fvm), 'fvm'));
        test(
            'flutterw',
            () => expect(
                EnumTransformer.wrapperName(Wrapper.flutterw), 'flutterw'));
        test('defaults to none',
            () => expect(EnumTransformer.wrapperName(Wrapper.none), 'none'));
        test('none',
            () => expect(EnumTransformer.wrapper('none'), Wrapper.none));
      });
      group('Generator', () {
        test(
            'dart',
            () =>
                expect(EnumTransformer.generatorName(Generator.dart), 'dart'));
        test(
            'dio',
            () => expect(
                EnumTransformer.generatorName(Generator.dio), 'dart-dio'));
        test(
            'dioAlt',
            () => expect(
                EnumTransformer.generatorName(Generator.dioAlt), 'dart2-api'));
      });
      group('DioDateLibrary', () {
        test(
            'core',
            () => expect(
                EnumTransformer.dioDateLibraryName(DioDateLibrary.core),
                'core'));
        test(
            'timemachine',
            () => expect(
                EnumTransformer.dioDateLibraryName(DioDateLibrary.timemachine),
                'timemachine'));
      });
      group('DioSerializationLibrary', () {
        test(
            'built_value',
            () => expect(
                EnumTransformer.dioSerializationLibraryName(
                    DioSerializationLibrary.built_value),
                'built_value'));
        test(
            'json_serializable',
            () => expect(
                EnumTransformer.dioSerializationLibraryName(
                    DioSerializationLibrary.json_serializable),
                'json_serializable'));
      });
    });
  });
}
