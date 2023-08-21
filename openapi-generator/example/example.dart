import 'package:openapi_generator_annotations/openapi_generator_annotations.dart';

@Openapi(
  additionalProperties:
      AdditionalProperties(pubName: 'petstore_api', pubAuthor: 'Johnny dep...'),
  inputSpecFile: 'https://google.com',
  generatorName: Generator.dio,
  outputDirectory: 'api/petstore_api',
)
class Example extends OpenapiGeneratorConfig {}
