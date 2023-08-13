import 'package:openapi_generator_annotations/src/openapi_generator_annotations_base.dart';
import 'package:test/test.dart';

void main() {
  group('OpenApi', () {
    group('NextGen', () {
      test('Sets cachePath', () {
        final api = Openapi(
            inputSpecFile: '',
            generatorName: Generator.dart,
            cachePath: 'somePath');
        expect(api.cachePath, 'somePath');
      });
      test('Sets useNextGenFlag', () {
        final api = Openapi(
            inputSpecFile: '', generatorName: Generator.dart, useNextGen: true);
        expect(api.useNextGen, isTrue);
      });
    });
  });
}
