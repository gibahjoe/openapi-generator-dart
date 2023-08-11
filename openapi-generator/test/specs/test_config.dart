import 'package:openapi_generator_annotations/openapi_generator_annotations.dart';

@Openapi(
  inputSpecFile: './openapi.test.yaml',
  generatorName: Generator.dart,
  useNextGen: true,
  cachePath: './',
  typeMappings: {'key': 'value'},
  templateDirectory: 'template',
  alwaysRun: true,
  outputDirectory: 'output',
  runSourceGenOnOutput: true,
  apiPackage: 'test',
  skipSpecValidation: false,
  importMappings: {'package': 'test'},
  reservedWordsMappings: {'const': 'final'},
  additionalProperties: AdditionalProperties(wrapper: Wrapper.fvm),
  inlineSchemaNameMappings: {'200resp': 'OkResp'},
  overwriteExistingFiles: true,
)
class TestConfig extends OpenapiGeneratorConfig {}
