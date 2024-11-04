import 'package:openapi_generator_annotations/openapi_generator_annotations.dart';

@Openapi(
    inputSpec: InputSpec(
      path: './test/specs/issue/135/github_issue_#135.json',
    ),
    updateAnnotatedFile: false,
    additionalProperties:
        AdditionalProperties(pubName: 'salad_api_client', pubAuthor: 'Google'),
    generatorName: Generator.dio,
    cleanSubOutputDirectory: ['./test/specs/issue/135/output'],
    cachePath: './test/specs/issue/135/output/cache.json',
    outputDirectory: './test/specs/issue/135/output')
class GithubIssue135 {}
