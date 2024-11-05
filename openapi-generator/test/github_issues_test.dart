import 'dart:io';

import 'package:openapi_generator/src/process_runner.dart';
import 'package:path/path.dart' as path;
import 'package:test/expect.dart';
import 'package:test/scaffolding.dart';

import 'utils.dart';

/// We test the build runner by mocking the specs and then checking the output
/// content for the expected generate command.
void main() {
  // we do not use mock process runner for github issues because we want to test
  // that generated code compiles
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

        expect(generatedOutput,
            contains('Skipping source gen because generator does not need it.'),
            reason: generatedOutput);
        expect(generatedOutput, contains('Successfully formatted code.'),
            reason: generatedOutput);
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

          expect(
              generatedOutput,
              contains(
                  'pub run build_runner build --delete-conflicting-outputs'),
              reason: generatedOutput);
          expect(generatedOutput, contains('Successfully formatted code.'),
              reason: generatedOutput);
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

        expect(generatedOutput,
            contains('Skipping source gen because generator does not need it.'),
            reason: generatedOutput);
        expect(generatedOutput, contains('Successfully formatted code.'),
            reason: generatedOutput);
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

          expect(
              generatedOutput,
              contains(
                  'pub run build_runner build --delete-conflicting-outputs'),
              reason: generatedOutput);
          expect(generatedOutput, contains('Successfully formatted code.'),
              reason: generatedOutput);
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

        expect(generatedOutput,
            contains('Skipping source gen because generator does not need it.'),
            reason: generatedOutput);
        expect(generatedOutput, contains('Successfully formatted code.'),
            reason: generatedOutput);
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

          expect(generatedOutput, contains('Successfully formatted code.'),
              reason: generatedOutput);
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
  });
}
