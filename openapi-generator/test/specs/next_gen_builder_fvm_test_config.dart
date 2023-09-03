library test_lib;

import 'package:openapi_generator_annotations/openapi_generator_annotations.dart';

@Openapi(
    inputSpecFile:
        'https://raw.githubusercontent.com/Nexushunter/tagmine-api/main/openapi.yaml',
    inputSpec: RemoteSpec(
      path:
          'https://raw.githubusercontent.com/Nexushunter/tagmine-api/main/openapi.yaml',
    ),
    generatorName: Generator.dio,
    additionalProperties: AdditionalProperties(
      wrapper: Wrapper.fvm,
    ),
    useNextGen: true,
    cachePath: './test/specs/output-nextgen/expected-args/cache.json',
    outputDirectory: './test/specs/output-nextgen/expected-args')
class TestClassConfig extends OpenapiGeneratorConfig {}
