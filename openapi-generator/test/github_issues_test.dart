import 'dart:io';

import 'package:openapi_generator/src/models/generator_arguments.dart';
import 'package:openapi_generator/src/process_runner.dart';
import 'package:openapi_generator_annotations/openapi_generator_annotations.dart';
import 'package:path/path.dart' as path;
import 'package:test/expect.dart';
import 'package:test/scaffolding.dart';

import 'utils.dart';

/// We test the build runner by mocking the specs and then checking the output
/// content for the expected generate command.
///
/// we do not use mock process runner for github issues because we want to test
/// that generated code compiles.
/// If you do not want to generate the actual code, then you can initialise [MockProcessRunner] in the test
void main() {
  var processRunner = ProcessRunner();
  group('Github Issues', () {
    // setUpAll(() {
    //   if (!f.existsSync()) {
    //     f.createSync(recursive: true);
    //   }
    //   f.writeAsStringSync('{}');
    // });
    // tearDown(() {
    //   if (f.existsSync()) {
    //     f.deleteSync();
    //   }
    // });

    group('#91', () {
      var issueNumber = '91';
      var parentFolder = path.join(testSpecPath, 'issue', issueNumber);
      var workingDirectory = path.join(parentFolder, 'output');
      setUpAll(
        () {
          var workingDirectory = path.join(parentFolder, 'output');
          cleanup(workingDirectory);
        },
      );
      test(
          '[dart] Test that broken code is not generated for OPENAPI tictactoe example',
          () async {
        var inputSpecFile =
            File('$parentFolder/github_issue_#$issueNumber.json');
            var outputDir = Directory('./test/specs/issue/$issueNumber/output');
        var generatedOutput = await generateFromAnnotation(
          Openapi(
              additionalProperties: AdditionalProperties(
                  pubName: 'tictactoe_api',
                  pubAuthor: 'Jon Doe',
                  pubAuthorEmail: 'me@example.com'),
              inputSpec: InputSpec(path: inputSpecFile.path),
              generatorName: Generator.dart,
              cleanSubOutputDirectory: [
                './test/specs/issue/$issueNumber/output'
              ],
              cachePath: './test/specs/issue/$issueNumber/output/cache.json',
              outputDirectory: outputDir.path,),
          process: processRunner,
        );

        expectSourceGenSkipped(outputDir);
        
        expectCodeFormattedSuccessfully(outputDir);
        
        var analyzeResult = await Process.run(
          'dart',
          ['analyze'],
          workingDirectory: workingDirectory,
        );
        printOnFailure(
            'Analysis result: ${analyzeResult.stdout}\n\n${analyzeResult.stderr}');
        expect(analyzeResult.exitCode, 0,
            reason: '${analyzeResult.stdout}\n\n${analyzeResult.stderr}');
            
        cleanup(workingDirectory);
      });
    });

    group('#114', () {
      var issueNumber = '114';
      var parentFolder = path.join(testSpecPath, 'issue', issueNumber);
      var workingDirectory = path.join(parentFolder, 'output');
      setUpAll(
        () {
          var workingDirectory = path.join(parentFolder, 'output');
          cleanup(workingDirectory);
        },
      );
      test(
          '[dart] Test that trailing underscore does not get removed while parsing',
          () async {
        var annotatedFile = File(
            '$parentFolder/github_issue_${issueNumber}_dart_test_config.dart');
        // var annotatedFileContents = annotatedFile.readAsStringSync();
        var inputSpecFile =
            File('$parentFolder/github_issue_#$issueNumber.json');

        var generatedOutput = await generateFromPath(
          annotatedFile.path,
          openapiSpecFilePath: inputSpecFile.path,
          process: processRunner,
          preProcessor: (annotatedFileContent) =>
              annotatedFileContent.replaceAll('{{issueNumber}}', issueNumber),
        );
        var annotation = await getConstantReaderForPath(file: annotatedFile);
        var outputDir = Directory(GeneratorArguments(annotations: annotation)
            .outputDirectory!
            .replaceAll('{{issueNumber}}', issueNumber));
        expectSourceGenSkipped(outputDir);
        expectCodeFormattedSuccessfully(outputDir);

        var analyzeResult = await Process.run(
          'dart',
          ['analyze', '--no-fatal-warnings'],
          workingDirectory: workingDirectory,
        );
        expect(analyzeResult.exitCode, 0,
            reason: '${analyzeResult.stdout}\n\n${analyzeResult.stderr}');
        cleanup(workingDirectory);
      });

      test(
        '[dio] Test that trailing underscore does not get removed while parsing',
        () async {
          var annotatedFile = File(
              '$parentFolder/github_issue_${issueNumber}_dio_test_config.dart');
          // var annotatedFileContents = annotatedFile.readAsStringSync();
          var inputSpecFile =
              File('$parentFolder/github_issue_#$issueNumber.json');

          var generatedOutput = await generateFromPath(
            annotatedFile.path,
            process: processRunner,
            openapiSpecFilePath: inputSpecFile.path,
            preProcessor: (annotatedFileContent) =>
                annotatedFileContent.replaceAll('{{issueNumber}}', issueNumber),
          );

          var annotation = await getConstantReaderForPath(file: annotatedFile);
          var outputDir = Directory(GeneratorArguments(annotations: annotation)
              .outputDirectory!
              .replaceAll('{{issueNumber}}', issueNumber));

          expectSourceGenRun(outputDir);
          expectCodeFormattedSuccessfully(outputDir);
          var workingDirectory = path.join(parentFolder, 'output');
          var analyzeResult = await Process.run(
            'dart',
            ['analyze', '--no-fatal-warnings'],
            workingDirectory: workingDirectory,
          );
          expect(analyzeResult.exitCode, 0,
              reason: '${analyzeResult.stdout}\n\n ${analyzeResult.stderr}');
          cleanup(workingDirectory);
        },
      );
    });

    group('#115', () {
      var issueNumber = '115';
      var parentFolder = path.join(testSpecPath, 'issue', issueNumber);
      var workingDirectory = path.join(parentFolder, 'output');
      setUpAll(
        () {
          var workingDirectory = path.join(parentFolder, 'output');
          cleanup(workingDirectory);
        },
      );
      test(
          '[dart] test that json parsing does not return wrong Set when uniqueItems is enabled',
          () async {
        var annotatedFile = File(
            '$parentFolder/github_issue_${issueNumber}_dart_test_config.dart');
        // var annotatedFileContents = annotatedFile.readAsStringSync();
        var inputSpecFile =
            File('$parentFolder/github_issue_#$issueNumber.json');

        var generatedOutput = await generateFromPath(
          annotatedFile.path,
          process: processRunner,
          openapiSpecFilePath: inputSpecFile.path,
          preProcessor: (annotatedFileContent) =>
              annotatedFileContent.replaceAll('{{issueNumber}}', issueNumber),
        );

        var outputDir = Directory(workingDirectory);
        expectSourceGenSkipped(outputDir);
        expectCodeFormattedSuccessfully(outputDir);
        var analyzeResult = await Process.run(
          'dart',
          ['analyze', '--fatal-warnings'],
          workingDirectory: workingDirectory,
        );
        expect(analyzeResult.exitCode, 0,
            reason: '${analyzeResult.stdout}\n\n${analyzeResult.stderr}');
        cleanup(workingDirectory);
      });

      test(
        '[dio] test that json parsing does not return wrong Set when uniqueItems is enabled',
        () async {
          var annotatedFile = File(
              '$parentFolder/github_issue_${issueNumber}_dio_test_config.dart');
          // var annotatedFileContents = annotatedFile.readAsStringSync();
          var inputSpecFile =
              File('$parentFolder/github_issue_#$issueNumber.json');

          var generatedOutput = await generateFromPath(
            annotatedFile.path,
            process: processRunner,
            openapiSpecFilePath: inputSpecFile.path,
            preProcessor: (annotatedFileContent) =>
                annotatedFileContent.replaceAll('{{issueNumber}}', issueNumber),
          );

          var annotation = await getConstantReaderForPath(file: annotatedFile);
          var outputDir = Directory(GeneratorArguments(annotations: annotation)
              .outputDirectory!
              .replaceAll('{{issueNumber}}', issueNumber));

          expectSourceGenRun(outputDir);
          expectCodeFormattedSuccessfully(outputDir);
          var workingDirectory = path.join(parentFolder, 'output');
          await Process.run(
            'dart',
            ['fix', '--apply'],
            workingDirectory: workingDirectory,
          );
          var analyzeResult = await Process.run(
            'dart',
            ['analyze', '--no-fatal-warnings'],
            workingDirectory: workingDirectory,
          );
          expect(analyzeResult.exitCode, 0,
              reason: '${analyzeResult.stdout}\n\n ${analyzeResult.stderr}');
          cleanup(workingDirectory);
        },
      );
    });

    group('#135', () {
      var parentFolder = path.join(testSpecPath, 'issue', '135');
      var workingDirectory = path.join(parentFolder, 'output');
      setUpAll(
        () {
          var workingDirectory = path.join(parentFolder, 'output');
          cleanup(workingDirectory);
        },
      );
      test(
          '[dart] Test that code generation succeeds on OpenAPI 3.1.0 API definition',
          () async {
        var annotatedFile =
            File('$parentFolder/github_issue_135_dart_test_config.dart');
        // var annotatedFileContents = annotatedFile.readAsStringSync();
        var inputSpecFile = File('$parentFolder/github_issue_#135.json');

        var generatedOutput = await generateFromPath(annotatedFile.path,
            process: processRunner, openapiSpecFilePath: inputSpecFile.path);

        var annotation = await getConstantReaderForPath(file: annotatedFile);

        var outputDir = Directory(
            GeneratorArguments(annotations: annotation).outputDirectory!);

        expectSourceGenSkipped(outputDir);
        expectCodeFormattedSuccessfully(outputDir);
        var analyzeResult = await Process.run(
          'dart',
          ['analyze', '--no-fatal-warnings'],
          workingDirectory: workingDirectory,
        );
        expect(analyzeResult.exitCode, 0,
            reason: '${analyzeResult.stdout}\n\n${analyzeResult.stderr}');
        cleanup(workingDirectory);
      }, skip: true);
      test(
        '[dio] Test that code generation succeeds on OpenAPI 3.1.0 API definition',
        () async {
          var annotatedFile =
              File('$parentFolder/github_issue_135_dio_test_config.dart');
          // var annotatedFileContents = annotatedFile.readAsStringSync();
          var inputSpecFile = File('$parentFolder/github_issue_#135.json');

          var generatedOutput = await generateFromPath(annotatedFile.path,
              process: processRunner, openapiSpecFilePath: inputSpecFile.path);

          var annotation = await getConstantReaderForPath(file: annotatedFile);
          var outputDir = Directory(
              GeneratorArguments(annotations: annotation).outputDirectory!);

          expectSourceGenRun(outputDir);
          expectCodeFormattedSuccessfully(outputDir);
          var workingDirectory = path.join(parentFolder, 'output');
          var analyzeResult = await Process.run(
            'dart',
            ['analyze', '--no-fatal-warnings'],
            workingDirectory: workingDirectory,
          );
          expect(analyzeResult.exitCode, 0,
              reason: '${analyzeResult.stdout}\n\n ${analyzeResult.stderr}');
          cleanup(workingDirectory);
        },
      );
    });

    group('#137', () {
      var parentFolder = path.join(testSpecPath, 'issue', '137');
      setUpAll(
        () {
          var workingDirectory = path.join(parentFolder, 'output');
          cleanup(workingDirectory);
        },
      );
      test('Test that valid model generated via List in additional properties',
          () async {
        var annotatedFile =
            File('$parentFolder/github_issue_137_test_config.dart');
        // var annotatedFileContents = annotatedFile.readAsStringSync();
        var inputSpecFile = File('$parentFolder/github_issue_#137.yaml');
        // final annotations = (await resolveSource(
        //     annotatedFileContents,
        // (resolver) async =>
        // (await resolver.findLibraryByName('test_lib'))!))
        //     .getClass('TestClassConfig')!
        //     .metadata
        //     .map((e) => ConstantReader(e.computeConstantValue()!))
        //     .first;
        // final args = GeneratorArguments(annotations: annotations);
        await generateFromPath(annotatedFile.path,
            process: processRunner, openapiSpecFilePath: inputSpecFile.path);

        var workingDirectory = path.join(parentFolder, 'output');
        var analyzeResult = await Process.run(
          'dart',
          ['analyze', '--fatal-warnings'],
          workingDirectory: workingDirectory,
        );
        expect(analyzeResult.exitCode, 0, reason: '${analyzeResult.stdout}');
        cleanup(workingDirectory);
      }, skip: true);
    });

    group('#164', () {
      var issueNumber = '164';
      var parentFolder = path.join(testSpecPath, 'issue', issueNumber);
      var workingDirectory = path.join(parentFolder, 'output');
      setUpAll(
        () {
          var workingDirectory = path.join(parentFolder, 'output');
          cleanup(workingDirectory);
        },
      );
      test('[dio] Test that generation does not fail', () async {
        var outputDir = Directory('./test/specs/issue/$issueNumber/output');
        var generatedOutput = await generateFromAnnotation(
          Openapi(
              additionalProperties: DioProperties(
                  pubName: 'petstore_api', pubAuthor: 'Johnny_dep'),
              inputSpec: RemoteSpec(
                  path: 'https://petstore3.swagger.io/api/v3/openapi.json'),
              typeMappings: {'Pet': 'ExamplePet'},
              generatorName: Generator.dio,
              runSourceGenOnOutput: true,
              cleanSubOutputDirectory: [
                './test/specs/issue/$issueNumber/output'
              ],
              outputDirectory: outputDir.path),
          process: processRunner,
        );

        expectSourceGenRun(outputDir);
        expectCodeFormattedSuccessfully(outputDir);
        var analyzeResult = await Process.run(
          'dart',
          ['analyze', '--no-fatal-warnings'],
          workingDirectory: workingDirectory,
        );
        expect(analyzeResult.exitCode, 0,
            reason: '${analyzeResult.stdout}\n\n${analyzeResult.stderr}');
        cleanup(workingDirectory);
      });
    });

    group('#167', () {
      var issueNumber = '167';
      var parentFolder = path.join(testSpecPath, 'issue', issueNumber);
      var workingDirectory = path.join(parentFolder, 'output');
      setUpAll(
        () {
          var workingDirectory = path.join(parentFolder, 'output');
          cleanup(workingDirectory);
        },
      );
      test('[dio] Test that generation does not fail', () async {
        var outputDir = Directory('./test/specs/issue/$issueNumber/output');
        var generatedOutput = await generateFromAnnotation(
          Openapi(
              additionalProperties: DioAltProperties(
                pubName: 'issue_api',
              ),
              inputSpec: InputSpec(
                  path:
                      './test/specs/issue/$issueNumber/github_issue_#167.yaml'),
              generatorName: Generator.dio,
              runSourceGenOnOutput: true,
              typeMappings: {'Pet': 'ExamplePet', 'Test': 'ExampleTest'},
              cleanSubOutputDirectory: [
                './test/specs/issue/$issueNumber/output'
              ],
              outputDirectory: outputDir.path),
          process: processRunner,
        );

        expectSourceGenRun(outputDir);
        expectCodeFormattedSuccessfully(outputDir);
        // check the output directory/lib/src/model for the generated files (.g.dart files)

        var analyzeResult = await Process.run(
          'dart',
          ['analyze', '--no-fatal-warnings'],
          workingDirectory: workingDirectory,
        );
        expect(analyzeResult.exitCode, 0,
            reason: '${analyzeResult.stdout}\n\n${analyzeResult.stderr}');

        cleanup(workingDirectory);
      });
    });
  });
}
