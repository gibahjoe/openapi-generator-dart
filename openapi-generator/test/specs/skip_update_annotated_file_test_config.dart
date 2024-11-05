import 'package:openapi_generator_annotations/openapi_generator_annotations.dart';

@Openapi(
    inputSpec: RemoteSpec(
      path:
          'https://raw.githubusercontent.com/Nexushunter/tagmine-api/main/openapi.yaml',
    ),
    generatorName: Generator.dio,
    forceAlwaysRun: false,
    cachePath: './test/specs/output-nextgen/expected-args/cache.json',
    outputDirectory: './test/specs/output-nextgen/expected-args')
class TestClassConfig {}
