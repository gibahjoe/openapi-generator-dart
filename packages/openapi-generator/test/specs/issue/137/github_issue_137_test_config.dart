import 'package:openapi_generator_annotations/openapi_generator_annotations.dart';

@Openapi(
    inputSpec: InputSpec(
      path: './test/specs/issue/137/github_issue_#137.yaml',
    ),
    generatorName: Generator.dart,
    forceAlwaysRun: false,
    cachePath: './test/specs/issue/137/output/cache.json',
    outputDirectory: './test/specs/issue/137/output')
class GithubIssue137 {}
