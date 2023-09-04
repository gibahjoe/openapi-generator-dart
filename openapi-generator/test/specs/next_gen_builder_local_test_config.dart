library test_lib;

import 'package:openapi_generator_annotations/openapi_generator_annotations.dart';

@Openapi(
    inputSpecFile:
        'https://raw.githubusercontent.com/Nexushunter/tagmine-api/main/openapi.yaml',
    inputSpec: InputSpec(
      path: './test/specs/openapi.test.yaml',
    ),
    generatorName: Generator.dart,
    fetchDependencies: true,
    useNextGen: true,
    cachePath: './test/specs/output-nextgen/expected-args/cache.json',
    outputDirectory: './test/specs/output-nextgen/expected-args')
class TestClassConfig {}
