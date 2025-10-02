import 'dart:convert';
import 'dart:io';

import 'package:build_test/build_test.dart';
import 'package:mockito/mockito.dart';
import 'package:openapi_generator/src/gen_on_spec_changes.dart';
import 'package:openapi_generator/src/models/generator_arguments.dart';
import 'package:openapi_generator/src/utils.dart';
import 'package:openapi_generator_annotations/openapi_generator_annotations.dart';
import 'package:source_gen/source_gen.dart' hide Generator;
import 'package:test/expect.dart';
import 'package:test/scaffolding.dart';

import 'utils.dart';
import 'utils.mocks.dart';

/// We test the build runner by mocking the specs and then checking the output
/// content for the expected generate command.
void main() {
  group('dio generator', () {
    test('to generate appropriate openapi cli command', () async {
      var annotation = Openapi(
          additionalProperties: DioProperties(
              pubName: 'petstore_api', pubAuthor: 'Johnny dep...'),
          inputSpec: InputSpec(path: '../openapi-spec.yaml'),
          typeMappings: {'Pet': 'ExamplePet'},
          generatorName: Generator.dio,
          runSourceGenOnOutput: true,
          outputDirectory: 'api/petstore_api');

      final args = await getArguments(annotation);
      expect(
          args.jarArgs.join(' '),
          equals('generate -o=api/petstore_api -i=../openapi-spec.yaml '
              '-g=dart-dio --type-mappings=Pet=ExamplePet --additional-properties=allowUnicodeIdentifiers=false,'
              'ensureUniqueParams=true,useEnumExtension=true,enumUnknownDefaultCase=false,prependFormOrBodyParameters=false,pubAuthor=Johnny dep...,pubName=petstore_api,legacyDiscriminatorBehavior=true,sortModelPropertiesByRequiredFlag=true,sortParamsByRequiredFlag=true,wrapper=none'));
    });

    test('to generate command with import and type mappings', () async {
      final annotations = Openapi(
        inputSpec: InputSpec(path: '../openapi-spec.yaml'),
        typeMappings: {'int-or-string': 'IntOrString'},
        importMappings: {'IntOrString': './int_or_string.dart'},
        generatorName: Generator.dio,
        outputDirectory: '${testSpecPath}output',
      );
      final args = await getArguments(annotations);
      expect(
          args.jarArgs.join(' '),
          contains(
              'generate -o=${testSpecPath}output -i=../openapi-spec.yaml -g=dart-dio --import-mappings=IntOrString=./int_or_string.dart --type-mappings=int-or-string=IntOrString'));
    });

    test('to generate command with inline schema mappings', () async {
      final annotation = Openapi(
        inputSpec: InputSpec(path: '../openapi-spec.yaml'),
        typeMappings: {'int-or-string': 'IntOrString'},
        inlineSchemaNameMappings: {
          'inline_object_2': 'SomethingMapped',
          'inline_object_4': 'nothing_new'
        },
        generatorName: Generator.dio,
        outputDirectory: '${testSpecPath}output',
      );
      final args = await getArguments(annotation);
      expect(
          args.jarArgs.join(' '),
          equals('''
              generate -o=${testSpecPath}output -i=../openapi-spec.yaml -g=dart-dio --inline-schema-name-mappings=inline_object_2=SomethingMapped,inline_object_4=nothing_new --type-mappings=int-or-string=IntOrString
              '''
              .trim()));
    });

    test('to generate command with enum name mappings', () async {
      final annotation = Openapi(
        inputSpec: InputSpec(path: '../openapi-spec.yaml'),
        typeMappings: {'int-or-string': 'IntOrString'},
        inlineSchemaNameMappings: {
          'inline_object_2': 'SomethingMapped',
          'inline_object_4': 'nothing_new'
        },
        enumNameMappings: {'name': 'name_', 'inline_object_4': 'nothing_new'},
        generatorName: Generator.dio,
        outputDirectory: '${testSpecPath}output',
      );
      final args = await getArguments(annotation);
      expect(
          args.jarArgs,
          contains(
              '--enum-name-mappings=name=name_,inline_object_4=nothing_new'));
    });
  });

  group('generator dioAlt', () {
    test('to generate appropriate openapi cli command', () async {
      final definition = '''
library test_lib;

import 'package:openapi_generator_annotations/openapi_generator_annotations.dart';

 @Openapi(
          additionalProperties:
              DioProperties(pubName: 'petstore_api', pubAuthor: 'Johnny dep...'),
          inputSpec: InputSpec(path: '../openapi-spec.yaml'),
          typeMappings: {'Pet': 'ExamplePet'},
          generatorName: Generator.dio,
          runSourceGenOnOutput: true,
          alwaysRun: true,
          outputDirectory: 'api/petstore_api')
class TestClassConfig extends OpenapiGeneratorConfig {}
                    ''';
      final annotations = await getConstantReader(
          definition: definition,
          libraryName: 'test_lib',
          className: 'TestClassConfig');
      final args = GeneratorArguments(annotations: annotations);
      expect(
          args.jarArgs.join(' '),
          contains('''
              generate -o=api/petstore_api -i=../openapi-spec.yaml -g=dart-dio --type-mappings=Pet=ExamplePet --additional-properties=allowUnicodeIdentifiers=false,ensureUniqueParams=true,useEnumExtension=true,enumUnknownDefaultCase=false,prependFormOrBodyParameters=false,pubAuthor=Johnny dep...,pubName=petstore_api,legacyDiscriminatorBehavior=true,sortModelPropertiesByRequiredFlag=true,sortParamsByRequiredFlag=true,wrapper=none
          '''
              .trim()));
    });

    test('to generate command with import and type mappings for dioAlt',
        () async {
      var annot = Openapi(
        inputSpec: InputSpec(path: '../openapi-spec.yaml'),
        typeMappings: {'int-or-string': 'IntOrString'},
        importMappings: {'IntOrString': './int_or_string.dart'},
        generatorName: Generator.dioAlt,
        outputDirectory: '${testSpecPath}output',
      );
      var args = await getArguments(annot);
      expect(
          args.jarArgs.join(' '),
          equals(
              'generate -o=${testSpecPath}output -i=../openapi-spec.yaml -g=dart2-api --import-mappings=IntOrString=./int_or_string.dart --type-mappings=int-or-string=IntOrString'));
    });
  });

  group('NextGen', () {
    late String generatedOutput;
    final specPath =
        'https://raw.githubusercontent.com/Nexushunter/tagmine-api/main/openapi.yaml';
    final basePath = '${testSpecPath}output-nextgen/';
    final openapiSpecCache = File('${basePath}cache.json');
    tearDownAll(() {
      if (openapiSpecCache.existsSync()) {
        openapiSpecCache.deleteSync();
      }
      final b = Directory(basePath);
      if (b.existsSync()) b.deleteSync(recursive: true);
    });

    group('runs', () {
      var mockProcess = MockProcessRunner();
      setUpAll(() {
        if (!openapiSpecCache.existsSync()) {
          openapiSpecCache.createSync(recursive: true);
        }
        openapiSpecCache.writeAsStringSync('{}');
        when(mockProcess.run(any, any))
            .thenAnswer((_) async => ProcessResult(0, 0, 'stdout', 'stderr'));
      });
      tearDown(() {
        if (openapiSpecCache.existsSync()) {
          openapiSpecCache.deleteSync();
        }
        reset(mockProcess);
      });
      test('Logs warning when using remote spec', () async {
        generatedOutput = await generateFromSource('''
        @Openapi(
            inputSpecFile: '$specPath',
            inputSpec: RemoteSpec(path: '$specPath'),
            typeMappings: {'int-or-string':'IntOrString'},
            importMappings: {'IntOrString':'./int_or_string.dart'},
            generatorName: Generator.dioAlt,
            useNextGen: true,
            outputDirectory: '${openapiSpecCache.parent.path}/logs-when-remote'
            )
      ''');

        expect(
            generatedOutput,
            contains(
                'Using a remote specification, a cache will still be created but may be outdated.'));
      });

      test('when the spec is dirty', () async {
        var annotation = Openapi(
            generatorName: Generator.dart,
            inputSpec: RemoteSpec(path: specPath),
            cachePath: openapiSpecCache.path,
            outputDirectory:
                '${openapiSpecCache.parent.path}/when-spec-is-dirty');

        final annotations = await readAnnotation(annotation);
        final args = GeneratorArguments(annotations: annotations);

        await generateFromSource(annotation.toString(), process: mockProcess);

        verify(mockProcess.run(
                'dart', ['run', 'openapi_generator_cli:main', ...args.jarArgs],
                runInShell: Platform.isWindows,
                workingDirectory: Directory.current.path))
            .called(1);

        verify(mockProcess.run('dart', ['pub', 'get'],
                runInShell: Platform.isWindows,
                workingDirectory: args.outputDirectory))
            .called(1);
      });

      test('and terminates early when there is no diff', () async {
        openapiSpecCache.writeAsStringSync(
            jsonEncode(await loadSpec(specConfig: RemoteSpec(path: specPath))));
        var annotation = Openapi(
            generatorName: Generator.dart,
            inputSpec: RemoteSpec(path: specPath),
            cachePath: openapiSpecCache.path,
            outputDirectory: '${openapiSpecCache.parent.path}/early-term');

        final annotations = await readAnnotation(annotation);
        final args = GeneratorArguments(annotations: annotations);

        await generateFromSource(annotation.toString(), process: mockProcess);

        verifyNever(mockProcess.run(
            'dart', ['run', 'openapi_generator_cli:main', ...args.jarArgs],
            runInShell: Platform.isWindows,
            workingDirectory: Directory.current.path));
      }, skip: true);

      test('openApiJar with expected args', () async {
        openapiSpecCache
            .writeAsStringSync(jsonEncode({'someKey': 'someValue'}));
        var filePath = '$testSpecPath/next_gen_builder_test_config.dart';
        final annotations = await getConstantReaderForPath(
            file: File(filePath), className: 'TestClassConfig');
        final args = GeneratorArguments(annotations: annotations);
        generatedOutput =
            await generateFromPath(filePath, process: mockProcess);

        verify(mockProcess.run(
                any, ['run', 'openapi_generator_cli:main', ...args.jarArgs],
                runInShell: Platform.isWindows,
                workingDirectory: Directory.current.path))
            .called(1);
      });

      test('does not add generated comment by default', () async {
        openapiSpecCache
            .writeAsStringSync(jsonEncode({'someKey': 'someValue'}));
        var annotationFilePath =
            '$testSpecPath/next_gen_builder_test_config.dart';
        final contents = File(annotationFilePath).readAsStringSync();
        final copy =
            File('./test/specs/next_gen_builder_test_config_copy.dart');
        copy.writeAsStringSync(contents, flush: true);
        var generatedCommentExists =
            copy.readAsLinesSync().first.contains(lastRunPlaceHolder);
        expect(generatedCommentExists, isFalse);
        await generateFromPath(copy.path, path: copy.path);

        var hasGeneratedComment =
            copy.readAsLinesSync().first.contains(lastRunPlaceHolder);
        expect(hasGeneratedComment, isFalse);
        copy.deleteSync();
      });

      test('skip updating annotated file', () async {
        // create the cached spec
        openapiSpecCache
            .writeAsStringSync(jsonEncode({'someKey': 'someValue'}));
        // Read the contents of the annotation we want to test
        var annotatedFile =
            File('$testSpecPath/skip_update_annotated_file_test_config.dart');
        final contents = annotatedFile.readAsStringSync();
        final copy = File(
            './test/specs/skip_update_annotated_file_test_config_copy.dart');
        copy.writeAsStringSync(contents, flush: true);

        var generatedCommentExists =
            copy.readAsLinesSync().first.contains(lastRunPlaceHolder);
        expect(generatedCommentExists, isFalse);
        await generateFromPath(copy.path, path: copy.path);

        var hasGeneratedComment =
            copy.readAsLinesSync().first.contains(lastRunPlaceHolder);
        expect(hasGeneratedComment, isFalse);
        copy.deleteSync();
      });

      group('source gen', () {
        group('uses Flutter', () {
          group('with wrapper', () {
            test('fvm', () async {
              var annotation = Openapi(
                inputSpec: RemoteSpec(path: specPath),
                generatorName: Generator.dio,
                cachePath: openapiSpecCache.path,
                outputDirectory: '${openapiSpecCache.parent.path}/fvm',
                forceAlwaysRun: false,
                additionalProperties: AdditionalProperties(
                  wrapper: Wrapper.fvm,
                ),
              );
              var arguments = await getArguments(annotation);
              await generateFromAnnotation(annotation, process: mockProcess);
              verify(mockProcess.run('fvm', ['pub', 'get'],
                      runInShell: Platform.isWindows,
                      workingDirectory: arguments.outputDirectory))
                  .called(1);
              verify(mockProcess.run(
                      'fvm',
                      [
                        'pub',
                        'run',
                        'build_runner',
                        'build',
                        '--delete-conflicting-outputs'
                      ],
                      runInShell: Platform.isWindows,
                      workingDirectory: arguments.outputDirectory))
                  .called(1);
            });
            test('flutterw', () async {
              var annotation = Openapi(
                inputSpec: RemoteSpec(path: specPath),
                generatorName: Generator.dio,
                cachePath: openapiSpecCache.path,
                outputDirectory: '${openapiSpecCache.parent.path}/flutterw',
                additionalProperties: AdditionalProperties(
                  wrapper: Wrapper.flutterw,
                ),
              );
              var arguments = await getArguments(annotation);
              var generatorOutput = await generateFromAnnotation(annotation,
                  process: mockProcess);
              verify(mockProcess.run('./flutterw', ['pub', 'get'],
                      runInShell: Platform.isWindows,
                      workingDirectory: arguments.outputDirectory))
                  .called(1);
              verify(mockProcess.run(
                      './flutterw',
                      [
                        'pub',
                        'run',
                        'build_runner',
                        'build',
                        '--delete-conflicting-outputs'
                      ],
                      runInShell: Platform.isWindows,
                      workingDirectory: arguments.outputDirectory))
                  .called(1);
              printOnFailure(generatorOutput);
            });
          });
          test('without wrapper', () async {
            var annotation = Openapi(
                inputSpec: RemoteSpec(
                    path:
                        'https://raw.githubusercontent.com/Nexushunter/tagmine-api/main/openapi.yaml'),
                generatorName: Generator.dio,
                cachePath: openapiSpecCache.path,
                outputDirectory: '${openapiSpecCache.parent.path}/flutter',
                projectPubspecPath: 'test/specs/flutter_pubspec.test.yaml');
            final args = await getArguments(annotation);
            var output =
                await generateFromAnnotation(annotation, process: mockProcess);

            expect(args.wrapper, Wrapper.none);

            printOnFailure(output);
            verify(mockProcess.run(
                    any, ['run', 'openapi_generator_cli:main', ...args.jarArgs],
                    runInShell: Platform.isWindows,
                    workingDirectory: Directory.current.path))
                .called(1);
            verify(mockProcess.run('flutter', ['pub', 'get'],
                    runInShell: Platform.isWindows,
                    workingDirectory: args.outputDirectory))
                .called(1);
            verify(mockProcess.run(
                    'flutter',
                    [
                      'pub',
                      'run',
                      'build_runner',
                      'build',
                      '--delete-conflicting-outputs'
                    ],
                    runInShell: Platform.isWindows,
                    workingDirectory: args.outputDirectory))
                .called(1);
          });
        });
        test('uses dart', () async {
          final definition =
              File('$testSpecPath/next_gen_builder_test_config.dart');
          final annotations = await getConstantReaderForPath(
              file: definition,
              libraryName: 'test_lib',
              className: 'TestClassConfig');
          final args = GeneratorArguments(annotations: annotations);

          generatedOutput =
              await generateFromPath(definition.path, process: mockProcess);

          expect(args.wrapper, Wrapper.none);

          verify(mockProcess.run(
                  'dart',
                  [
                    'pub',
                    'run',
                    'build_runner',
                    'build',
                    '--delete-conflicting-outputs'
                  ],
                  runInShell: Platform.isWindows,
                  workingDirectory: args.outputDirectory))
              .called(1);
        });
        group('except when', () {
          test('flag is set', () async {
            final definition = '''
library test_lib;

import 'package:openapi_generator_annotations/openapi_generator_annotations.dart';

@Openapi(
  inputSpecFile:
      'https://raw.githubusercontent.com/Nexushunter/tagmine-api/main/openapi.yaml',
  inputSpec: RemoteSpec(path: '$specPath'),
  generatorName: Generator.dio,
  useNextGen: true,
  cachePath: '${openapiSpecCache.path}',
  outputDirectory: '${openapiSpecCache.parent.path}/no-src',
  runSourceGenOnOutput: false,
)
class TestClassConfig extends OpenapiGeneratorConfig {}
                    ''';
            final annotations = await getConstantReader(
                definition: definition,
                libraryName: 'test_lib',
                className: 'TestClassConfig');
            final args = GeneratorArguments(annotations: annotations);

            expect(args.runSourceGen, isFalse);
            generatedOutput = await generateFromSource('''
@Openapi(
  inputSpec: RemoteSpec(path: '$specPath'),
  generatorName: Generator.dio,
  useNextGen: true,
  cachePath: '${openapiSpecCache.path}',
  outputDirectory: '${openapiSpecCache.parent.path}/no-src',
  runSourceGenOnOutput: false,
)
            ''');
            expect(generatedOutput,
                contains('Skipping source gen step due to flag being set.'));
          });
          test('generator is dart', () async {
            var annotation = Openapi(
                inputSpec: RemoteSpec(path: specPath),
                generatorName: Generator.dart,
                cachePath: openapiSpecCache.path,
                outputDirectory: '${openapiSpecCache.parent.path}/dart-gen');

            final arguments = await getArguments(annotation);
            expect(arguments.runSourceGen, isTrue);
            generatedOutput =
                await generateFromAnnotation(annotation, process: mockProcess);

            verify(mockProcess.run('dart', ['pub', 'get'],
                    runInShell: Platform.isWindows,
                    workingDirectory: arguments.outputDirectory))
                .called(1);
            verifyNever(mockProcess.run(
                'dart',
                [
                  'pub',
                  'run',
                  'build_runner',
                  'build',
                  '--delete-conflicting-outputs'
                ],
                runInShell: Platform.isWindows,
                workingDirectory: arguments.outputDirectory));
          });
        });
        test('logs when successful', () async {
          generatedOutput = await generateFromAnnotation(
              Openapi(
                inputSpec: RemoteSpec(path: '$specPath'),
                generatorName: Generator.dio,
                cachePath: '${openapiSpecCache.path}',
                outputDirectory: '${openapiSpecCache.parent.path}/success',
                projectPubspecPath: './test/specs/dart_pubspec.test.yaml',
              ),
              process: mockProcess);
          verify(mockProcess.run(
                  'dart',
                  [
                    'pub',
                    'run',
                    'build_runner',
                    'build',
                    '--delete-conflicting-outputs'
                  ],
                  runInShell: Platform.isWindows,
                  workingDirectory: '${openapiSpecCache.parent.path}/success'))
              .called(1);
        });
      });
      group('fetch dependencies', () {
        test('except when flag is present', () async {
          generatedOutput = await generateFromSource('''
@Openapi(
  inputSpec: RemoteSpec(path: '$specPath'),
  generatorName: Generator.dio,
  useNextGen: true,
  cachePath: '${openapiSpecCache.path}',
  outputDirectory: '${openapiSpecCache.parent.path}/no-fetch',
  projectPubspecPath: './test/specs/dart_pubspec.test.yaml',
  fetchDependencies: false,
)
          ''');
          expect(generatedOutput,
              contains('Skipping install step because flag was set.'));
        });
        test('succeeds', () async {
          generatedOutput = await generateFromAnnotation(
              Openapi(
                inputSpec: RemoteSpec(path: '$specPath'),
                generatorName: Generator.dio,
                cachePath: '${openapiSpecCache.path}',
                outputDirectory: '${openapiSpecCache.parent.path}/no-fetch',
                projectPubspecPath: './test/specs/dart_pubspec.test.yaml',
              ),
              process: mockProcess);
          verify(mockProcess.run(
                  'dart',
                  [
                    'pub',
                    'get',
                  ],
                  runInShell: Platform.isWindows,
                  workingDirectory: '${openapiSpecCache.parent.path}/no-fetch'))
              .called(1);
        });
      });
      group('update cache', () {
        final src = '''
        @Openapi(
            inputSpec: RemoteSpec(path: '$specPath'),
            useNextGen: true,
            cachePath: '${openapiSpecCache.path}',
            outputDirectory: '${openapiSpecCache.parent.path}/update-cache',
            )
      ''';

        test('creating a cache file when not found', () async {
          // Ensure that other tests don't make this available;
          if (openapiSpecCache.existsSync()) {
            openapiSpecCache.deleteSync();
          }
          expect(openapiSpecCache.existsSync(), isFalse);
          generatedOutput = await generateFromAnnotation(Openapi(
            inputSpec: RemoteSpec(path: specPath),
            generatorName: Generator.dio,
            cachePath: openapiSpecCache.path,
            outputDirectory: '${openapiSpecCache.parent.path}/update-cache',
          ));
          expect(openapiSpecCache.existsSync(), isTrue);
          expect(jsonDecode(openapiSpecCache.readAsStringSync()),
              await loadSpec(specConfig: RemoteSpec(path: specPath)));
        });
        test('updates the cache file when found', () async {
          openapiSpecCache
              .writeAsStringSync(jsonEncode({'someKey': 'someValue'}));
          expect(openapiSpecCache.existsSync(), isTrue);
          generatedOutput = await generateFromSource(src);
          final expectedSpec =
              await loadSpec(specConfig: RemoteSpec(path: specPath));
          final actualSpec = jsonDecode(openapiSpecCache.readAsStringSync());
          expect(actualSpec, expectedSpec);
        });
        test('logs when successful', () async {
          openapiSpecCache
              .writeAsStringSync(jsonEncode({'someKey': 'someValue'}));
          generatedOutput = await generateFromSource(src);
          expect(
              generatedOutput, contains('Successfully cached spec changes.'));
        });
      }, skip: true);
    });
  });
}
