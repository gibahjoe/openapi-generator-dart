library test_lib;

import 'package:openapi_generator_annotations/openapi_generator_annotations.dart';

@Openapi(
  inputSpec: InputSpec(path: './test/specs/openapi.test.yaml'),
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
  additionalProperties: DioProperties(
      wrapper: Wrapper.fvm,
      useEnumExtension: true,
      pubAuthor: 'test author',
      dateLibrary: DioDateLibrary.core,
      serializationLibrary: DioSerializationLibrary.jsonSerializable,
      nullableFields: true),
  inlineSchemaNameMappings: {'200resp': 'OkResp'},
  projectPubspecPath: './test/specs/dart_pubspec.test.yaml',
  updateAnnotatedFile: true,
)
class DioPropertiesTestConfig {}
