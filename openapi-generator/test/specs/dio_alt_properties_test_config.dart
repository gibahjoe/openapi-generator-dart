library test_lib;

import 'package:openapi_generator_annotations/openapi_generator_annotations.dart';

@Openapi(
  inputSpecFile: './openapi.test.yaml',
  inputSpec: InputSpec(path: './test/specs/openapi.test.yaml'),
  generatorName: Generator.dio,
  useNextGen: true,
  cachePath: './test/specs/output/cache.json',
  typeMappings: {'key': 'value'},
  templateDirectory: 'template',
  alwaysRun: true,
  outputDirectory: './test/specs/output',
  runSourceGenOnOutput: true,
  apiPackage: 'test',
  skipSpecValidation: false,
  importMappings: {'package': 'test'},
  reservedWordsMappings: {'const': 'final'},
  additionalProperties: DioAltProperties(
      wrapper: Wrapper.fvm,
      useEnumExtension: true,
      pubAuthor: 'test author',
      nullSafe: true,
      nullSafeArrayDefault: true),
  inlineSchemaNameMappings: {'200resp': 'OkResp'},
  overwriteExistingFiles: true,
  projectPubspecPath: './test/specs/dart_pubspec.test.yaml',
)
class DioAltPropertiesTestConfig {}
