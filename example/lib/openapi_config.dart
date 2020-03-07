import 'package:openapi_generator_annotations/openapi_generator_annotations.dart';

@Openapi(
    additionalProperties:
    AdditionalProperties(pubName: 'petstore_api', pubAuthor: 'Johnny depp'),
    inputSpecFile: 'spec/openapi-spec.yaml',
    generatorName: 'dart-jaguar',
    outputDirectory: 'api/petstore_api')
class OpenapiConfig extends OpenapiGeneratorConfig {
}
