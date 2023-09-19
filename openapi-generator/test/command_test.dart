import 'dart:io';

import 'package:openapi_generator/src/models/command.dart';
import 'package:openapi_generator_annotations/openapi_generator_annotations.dart';
import 'package:test/test.dart';

import 'utils.dart';

void main() {
  group('Command', () {
    final testArgs = ['pub', 'get'];
    group('handles flutter wrapping', () {
      test('Wrapper.flutterw', () {
        final command = Command(
            executable: 'flutter',
            arguments: testArgs,
            wrapper: Wrapper.flutterw);
        expect(command.arguments, testArgs);
        expect(command.executable, './flutterw');
      });
      test('Wrapper.fvw', () {
        final command = Command(
            executable: 'flutter', arguments: testArgs, wrapper: Wrapper.fvm);
        expect(command.arguments, testArgs);
        expect(command.executable, 'fvm');
      });
      test('doesn\'t wrap Wrapper.none', () {
        final command = Command(executable: 'flutter', arguments: testArgs);
        expect(command.arguments, testArgs);
        expect(command.executable, 'flutter');
      });
    });
    test('wraps doesn\'t dart', () {
      final command = Command(executable: 'dart', arguments: testArgs);
      expect(command.arguments, testArgs);
      expect(command.executable, 'dart');
    });
  });

  group('CommandRunner', () {
    final runner = CommandRunner();
    test(
      'runCommand returns a process',
      () async => expect(
        await runner.runCommand(
            command: Command(executable: 'dart', arguments: ['--version']),
            workingDirectory: './'),
        isA<ProcessResult>(),
      ),
    );
    test('loads an annotated file', () async {
      expect(
        await runner.loadAnnotatedFile(
            path: '$testSpecPath/next_gen_builder_test_config.dart'),
        '''library test_lib;

import 'package:openapi_generator_annotations/openapi_generator_annotations.dart';

@Openapi(
    inputSpecFile:
        'https://raw.githubusercontent.com/Nexushunter/tagmine-api/main/openapi.yaml',
    inputSpec: RemoteSpec(
      path:
          'https://raw.githubusercontent.com/Nexushunter/tagmine-api/main/openapi.yaml',
    ),
    generatorName: Generator.dio,
    useNextGen: true,
    cachePath: './test/specs/output-nextgen/expected-args/cache.json',
    outputDirectory: './test/specs/output-nextgen/expected-args')
class TestClassConfig {}'''
            .split('\n'),
      );
    });
    test(
        'writes annotation file',
        () async => expect(
            runner.writeAnnotatedFile(
                path: '$testSpecPath/next_gen_builder_test_config.dart',
                content: '''library test_lib;

import 'package:openapi_generator_annotations/openapi_generator_annotations.dart';

@Openapi(
    inputSpecFile:
        'https://raw.githubusercontent.com/Nexushunter/tagmine-api/main/openapi.yaml',
    inputSpec: RemoteSpec(
      path:
          'https://raw.githubusercontent.com/Nexushunter/tagmine-api/main/openapi.yaml',
    ),
    generatorName: Generator.dio,
    useNextGen: true,
    cachePath: './test/specs/output-nextgen/expected-args/cache.json',
    outputDirectory: './test/specs/output-nextgen/expected-args')
class TestClassConfig {}'''
                    .split('\n')),
            completes));
    test(
        'writes cache spec file',
        () async => expect(
            runner.cacheSpecFile(
                updatedSpec: {},
                cachedPath: '$testSpecPath/commands-cache.json'),
            completes));
    test(
        'checks for flutter environment',
        () async => expect(
            await runner.checkForFlutterEnvironemt(wrapper: Wrapper.fvm),
            isTrue));
    test(
        'checks spec dirty status',
        () async => expect(
            await runner.isSpecFileDirty(cachedSpec: {}, loadedSpec: {}),
            isFalse));
  });
}
