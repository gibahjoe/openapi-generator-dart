import 'package:openapi_generator_annotations/src/openapi_generator_annotations_base.dart';
import 'package:test/test.dart';

void main() {
  group('OpenApi', () {
    test('defaults', () {
      final props = Openapi(inputSpecFile: '', generatorName: Generator.dart);
      expect(props.additionalProperties, isNull);
      expect(props.overwriteExistingFiles, isNull);
      expect(props.skipSpecValidation, false);
      expect(props.inputSpecFile, '');
      expect(props.templateDirectory, isNull);
      expect(props.generatorName, Generator.dart);
      expect(props.outputDirectory, isNull);
      expect(props.typeMappings, isNull);
      expect(props.importMappings, isNull);
      expect(props.reservedWordsMappings, isNull);
      expect(props.inlineSchemaNameMappings, isNull);
      expect(props.apiPackage, isNull);
      expect(props.fetchDependencies, true);
      expect(props.runSourceGenOnOutput, true);
      expect(props.alwaysRun, false);
      expect(props.cachePath, isNull);
      expect(props.useNextGen, false);
      expect(props.projectPubspecPath, isNull);
    });
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
      test('Sets projectPubspecPath', () {
        final api = Openapi(
            inputSpecFile: '',
            generatorName: Generator.dart,
            projectPubspecPath: 'test');
        expect(api.projectPubspecPath, 'test');
      });
    });
  });
}
