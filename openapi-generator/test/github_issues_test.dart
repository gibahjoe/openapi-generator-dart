import 'dart:io';

import 'package:path/path.dart' as path;
import 'package:test/expect.dart';
import 'package:test/scaffolding.dart';

import 'utils.dart';

/// We test the build runner by mocking the specs and then checking the output
/// content for the expected generate command.
void main() {
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
    group('#137', () {
      var parentFolder = path.join(testSpecPath, 'issue', '137');
      var workingDirectory = path.join(parentFolder, 'output');
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
        var annotatedFileContents = annotatedFile.readAsStringSync();
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
        var generatedOutput = await generateForSource(annotatedFile.path,
            openapiSpecFilePath: inputSpecFile.path);

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
          'Test that code generation succeeds on OpenAPI 3.1.0 API definition with dart generator',
          () async {
        var annotatedFile =
            File('$parentFolder/github_issue_135_dart_test_config.dart');
        var annotatedFileContents = annotatedFile.readAsStringSync();
        var inputSpecFile = File('$parentFolder/github_issue_#135.json');

        var generatedOutput = await generateForSource(annotatedFile.path,
            openapiSpecFilePath: inputSpecFile.path);

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
        'Test that code generation succeeds on OpenAPI 3.1.0 API definition with dio generator',
        () async {
          var annotatedFile =
              File('$parentFolder/github_issue_135_dio_test_config.dart');
          var annotatedFileContents = annotatedFile.readAsStringSync();
          var inputSpecFile = File('$parentFolder/github_issue_#135.json');

          var generatedOutput = await generateForSource(annotatedFile.path,
              openapiSpecFilePath: inputSpecFile.path);

          // expect(generatedOutput, contains('Skipping source gen because generator does not need it.'),reason:generatedOutput);
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
  });
}

void cleanup(String path) async {
  final directory = Directory(path);

  if (await directory.exists()) {
    await directory.delete(recursive: true);
    print('Folder deleted successfully.');
  } else {
    print('Folder does not exist.');
  }
}
