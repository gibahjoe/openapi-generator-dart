import 'package:openapi_generator_annotations/openapi_generator_annotations.dart';

@Openapi(
    inputSpec: InputSpec(
      path: './test/specs/issue/114/github_issue_#{{issueNumber}}.json',
    ),
    updateAnnotatedFile: false,
    nameMappings: {'package_': 'otherPackage'},
    additionalProperties:
        AdditionalProperties(pubName: 'salad_api_client', pubAuthor: 'Google'),
    generatorName: Generator.dart,
    cleanSubOutputDirectory: ['./test/specs/issue/{{issueNumber}}/output'],
    cachePath: './test/specs/issue/{{issueNumber}}/output/cache.json',
    outputDirectory: './test/specs/issue/{{issueNumber}}/output')
class GithubIssue135 {}
