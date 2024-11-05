library test_lib;

import 'package:openapi_generator_annotations/openapi_generator_annotations.dart';

@Openapi(
  inputSpec:
      RemoteSpec(path: 'https://petstore3.swagger.io/api/v3/openapi.json'),
  generatorName: Generator.dio,
  cachePath: './test/specs/output/cache.json',
  typeMappings: {'key': 'value'},
  templateDirectory: 'template',
  outputDirectory: './test/specs/output',
  runSourceGenOnOutput: true,
  apiPackage: 'test',
  skipSpecValidation: false,
  importMappings: {'package': 'test'},
  reservedWordsMappings: {'const': 'final'},
  additionalProperties: DioAltProperties(
      wrapper: Wrapper.fvm, useEnumExtension: true, pubAuthor: 'test author'),
  inlineSchemaNameMappings: {'200resp': 'OkResp'},
  projectPubspecPath: './test/specs/dart_pubspec.test.yaml',
  forceAlwaysRun: true,
)
class DioAltPropertiesTestConfig {}
