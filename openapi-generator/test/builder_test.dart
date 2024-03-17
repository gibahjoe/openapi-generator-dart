import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:build_test/build_test.dart';
import 'package:openapi_generator/src/gen_on_spec_changes.dart';
import 'package:openapi_generator/src/models/generator_arguments.dart';
import 'package:openapi_generator/src/utils.dart';
import 'package:openapi_generator_annotations/openapi_generator_annotations.dart';
import 'package:source_gen/source_gen.dart';
import 'package:test/expect.dart';
import 'package:test/scaffolding.dart';

import 'utils.dart';

/// We test the build runner by mocking the specs and then checking the output
/// content for the expected generate command.
void main() {
  group('dio generator', () {
    test('to generate appropriate openapi cli command', () async {
      final annotations = await getReaderForAnnotation('''
@Openapi(
          additionalProperties:
              DioProperties(pubName: 'petstore_api', pubAuthor: 'Johnny dep...'),
          inputSpec: InputSpec(path: '../openapi-spec.yaml'),
          typeMappings: {'Pet': 'ExamplePet'},
          generatorName: Generator.dio,
          runSourceGenOnOutput: true,
          alwaysRun: true,
          outputDirectory: 'api/petstore_api')
          ''');
      final args = GeneratorArguments(annotations: annotations);
      expect(
          (await args.jarArgs).join(' '),
          contains(
              'generate -o=api/petstore_api -i=../openapi-spec.yaml -g=dart-dio --type-mappings=Pet=ExamplePet --additional-properties=allowUnicodeIdentifiers=false,ensureUniqueParams=true,useEnumExtension=true,enumUnknownDefaultCase=false,prependFormOrBodyParameters=false,pubAuthor=Johnny dep...,pubName=petstore_api,legacyDiscriminatorBehavior=true,sortModelPropertiesByRequiredFlag=true,sortParamsByRequiredFlag=true,wrapper=none'));
    });

    test('to generate command with import and type mappings', () async {
      final annotations = await getReaderForAnnotation('''
@Openapi(
          inputSpec: InputSpec(path: '../openapi-spec.yaml'),
          typeMappings: {'int-or-string':'IntOrString'},
          importMappings: {'IntOrString':'./int_or_string.dart'},
          generatorName: Generator.dio,
          outputDirectory: '${testSpecPath}output',
          )
          ''');
      final args = GeneratorArguments(annotations: annotations);
      expect(
          (await args.jarArgs).join(' '),
          contains(
              'generate -o=${testSpecPath}output -i=../openapi-spec.yaml -g=dart-dio --import-mappings=IntOrString=./int_or_string.dart --type-mappings=int-or-string=IntOrString'));
    });

    test('to generate command with inline schema mappings', () async {
      final annotations = await getReaderForAnnotation('''
@Openapi(
          inputSpec: InputSpec(path: '../openapi-spec.yaml'),
          typeMappings: {'int-or-string':'IntOrString'},
          inlineSchemaNameMappings: {'inline_object_2':'SomethingMapped','inline_object_4':'nothing_new'},
          generatorName: Generator.dio,
          outputDirectory: '${testSpecPath}output',
          )
          ''');
      final args = GeneratorArguments(annotations: annotations);
      expect(
          (await args.jarArgs).join(' '),
          equals('''
              generate -o=${testSpecPath}output -i=../openapi-spec.yaml -g=dart-dio --inline-schema-name-mappings=inline_object_2=SomethingMapped,inline_object_4=nothing_new --type-mappings=int-or-string=IntOrString
              '''
              .trim()));
    });
  });

  group('generator dioAlt', () {
    test('to generate appropriate openapi cli command', () async {
      final annotations = (await resolveSource(
              '''
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
                    ''',
              (resolver) async =>
                  (await resolver.findLibraryByName('test_lib'))!))
          .getClass('TestClassConfig')!
          .metadata
          .map((e) => ConstantReader(e.computeConstantValue()!))
          .first;
      final args = GeneratorArguments(annotations: annotations);
      expect(
          (await args.jarArgs).join(' '),
          contains('''
              generate -o=api/petstore_api -i=../openapi-spec.yaml -g=dart-dio --type-mappings=Pet=ExamplePet --additional-properties=allowUnicodeIdentifiers=false,ensureUniqueParams=true,useEnumExtension=true,enumUnknownDefaultCase=false,prependFormOrBodyParameters=false,pubAuthor=Johnny dep...,pubName=petstore_api,legacyDiscriminatorBehavior=true,sortModelPropertiesByRequiredFlag=true,sortParamsByRequiredFlag=true,wrapper=none
          '''
              .trim()));
    });

    test('to generate command with import and type mappings for dioAlt',
        () async {
      var annots = await getReaderForAnnotation('''
       @Openapi(
            inputSpec: InputSpec(path:'../openapi-spec.yaml'),
            typeMappings: {'int-or-string':'IntOrString'},
            importMappings: {'IntOrString':'./int_or_string.dart'},
            generatorName: Generator.dioAlt,
            outputDirectory: '${testSpecPath}output',
            )
      ''');
      var args = GeneratorArguments(annotations: annots);
      expect(
          (await args.jarArgs).join(' '),
          equals(
              'generate -o=${testSpecPath}output -i=../openapi-spec.yaml -g=dart2-api --import-mappings=IntOrString=./int_or_string.dart --type-mappings=int-or-string=IntOrString'));
    });
  });

  group('NextGen', () {
    late String generatedOutput;
    final specPath =
        'https://raw.githubusercontent.com/Nexushunter/tagmine-api/main/openapi.yaml';
    final basePath = '${testSpecPath}output-nextgen/';
    final f = File('${basePath}cache.json');
    tearDownAll(() {
      final b = Directory(basePath);
      if (b.existsSync()) b.deleteSync(recursive: true);
    });

    group('runs', () {
      setUpAll(() {
        if (!f.existsSync()) {
          f.createSync(recursive: true);
        }
        f.writeAsStringSync('{}');
      });
      tearDown(() {
        if (f.existsSync()) {
          f.deleteSync();
        }
      });
      test('Logs warning when using remote spec', () async {
        generatedOutput = await generate('''
        @Openapi(
            inputSpecFile: '$specPath',
            inputSpec: RemoteSpec(path: '$specPath'),
            typeMappings: {'int-or-string':'IntOrString'},
            importMappings: {'IntOrString':'./int_or_string.dart'},
            generatorName: Generator.dioAlt,
            useNextGen: true,
            outputDirectory: '${f.parent.path}/logs-when-remote'
            )
      ''');
        expect(
            generatedOutput,
            contains(
                'Using a remote specification, a cache will still be create but may be outdated.'));
      });
      test('when the spec is dirty', () async {
        final src = '''
        @Openapi(
            inputSpecFile: '$specPath',
            inputSpec: RemoteSpec(path: '$specPath'),
            useNextGen: true,
            cachePath: '${f.path}',
            outputDirectory: '${f.parent.path}/when-spec-is-dirty'
            )
      ''';
        generatedOutput = await generate(src);
        expect(
            generatedOutput, contains('Dirty Spec found. Running generation.'));
      });
      test('and terminates early when there is no diff', () async {
        f.writeAsStringSync(
            jsonEncode(await loadSpec(specConfig: RemoteSpec(path: specPath))));
        final src = '''
        @Openapi(
            inputSpecFile: '$specPath',
            inputSpec: RemoteSpec(path: '$specPath'),
            useNextGen: true,
            cachePath: '${f.path}',
            outputDirectory: '${f.parent.path}/early-term'
            )
      ''';
        generatedOutput = await generate(src);
        expect(generatedOutput,
            contains('No diff between versions, not running generator.'));
      });
      test('openApiJar with expected args', () async {
        f.writeAsStringSync(jsonEncode({'someKey': 'someValue'}));
        final annotations = (await resolveSource(
                File('$testSpecPath/next_gen_builder_test_config.dart')
                    .readAsStringSync(),
                (resolver) async =>
                    (await resolver.findLibraryByName('test_lib'))!))
            .getClass('TestClassConfig')!
            .metadata
            .map((e) => ConstantReader(e.computeConstantValue()!))
            .first;
        final args = GeneratorArguments(annotations: annotations);
        generatedOutput = await generate('''
        @Openapi(
  inputSpecFile:
      'https://raw.githubusercontent.com/Nexushunter/tagmine-api/main/openapi.yaml',
  inputSpec: RemoteSpec(path: '$specPath'),
  generatorName: Generator.dio,
  useNextGen: true,
  cachePath: '${f.path}',
  outputDirectory: './test/specs/output-nextgen/expected-args'
)
        ''');
        expect(
            generatedOutput, contains('[ ${(await args.jarArgs).join(' ')} ]'));
      });
      test('adds generated comment', () async {
        f.writeAsStringSync(jsonEncode({'someKey': 'someValue'}));
        final contents = File('$testSpecPath/next_gen_builder_test_config.dart')
            .readAsStringSync();
        final copy =
            File('./test/specs/next_gen_builder_test_config_copy.dart');
        copy.writeAsStringSync(contents, flush: true);
        generatedOutput = await generate('''
        @Openapi(
  inputSpecFile:
      'https://raw.githubusercontent.com/Nexushunter/tagmine-api/main/openapi.yaml',
  inputSpec: RemoteSpec(path: '$specPath'),
  generatorName: Generator.dio,
  useNextGen: true,
  cachePath: '${f.path}',
  outputDirectory: './test/specs/output-nextgen/add-generated-comment'
)
        ''', path: copy.path);

        var hasOutput = copy.readAsStringSync().contains(lastRunPlaceHolder);
        expect(generatedOutput, contains('Creating generated timestamp with '));

        generatedOutput = await generate('''
        @Openapi(
  inputSpecFile:
      'https://raw.githubusercontent.com/Nexushunter/tagmine-api/main/openapi.yaml',
  inputSpec: RemoteSpec(path: '$specPath'),
  generatorName: Generator.dio,
  useNextGen: true,
  cachePath: '${f.path}',
  outputDirectory: './test/specs/output-nextgen/add-generated-comment'
)
        ''', path: copy.path);

        hasOutput = copy.readAsStringSync().contains(lastRunPlaceHolder);
        expect(generatedOutput,
            contains('Found generated timestamp. Updating with'));

        copy.deleteSync();
        expect(hasOutput, isTrue);
      });
      test('skip updating annotated file', () async {
        final annotatedFile = File(
            '.${Platform.pathSeparator}test${Platform.pathSeparator}specs${Platform.pathSeparator}output-nextgen${Platform.pathSeparator}annotated_file.dart');
        final annotetedFileContent = '\n';
        await annotatedFile.writeAsString(annotetedFileContent, flush: true);

        generatedOutput = await generate('''
@Openapi(
  inputSpecFile: '$specPath',
  inputSpec: RemoteSpec(path: '$specPath'),
  useNextGen: true,
  cachePath: '${f.path}',
  updateAnnotatedFile: false,
)
          ''', path: annotatedFile.path);
        expect(
            generatedOutput,
            contains(
                'Skipped updating annotated file step because flag was set.'));
        expect(annotatedFile.readAsStringSync(), equals(annotetedFileContent));
      });
      group('source gen', () {
        group('uses Flutter', () {
          group('with wrapper', () {
            test('fvm', () async {
              generatedOutput = await generate('''
@Openapi(
  inputSpecFile:
      'https://raw.githubusercontent.com/Nexushunter/tagmine-api/main/openapi.yaml',
  inputSpec: RemoteSpec(path: '$specPath'),
  generatorName: Generator.dio,
  useNextGen: true,
  cachePath: '${f.path}',
  outputDirectory: '${f.parent.path}/fvm',
  additionalProperties: AdditionalProperties(
    wrapper: Wrapper.fvm,
  ),
)
          ''');
              expect(
                  generatedOutput, contains('Running source code generation.'));
              expect(
                  generatedOutput,
                  contains(
                      'fvm pub run build_runner build --delete-conflicting-outputs'));
            });
            test('flutterw', () async {
              generatedOutput = await generate('''
@Openapi(
  inputSpecFile:
      'https://raw.githubusercontent.com/Nexushunter/tagmine-api/main/openapi.yaml',
  inputSpec: RemoteSpec(path: '$specPath'),
  generatorName: Generator.dio,
  useNextGen: true,
  cachePath: '${f.path}',
  outputDirectory: '${f.parent.path}/flutterw',
  additionalProperties: AdditionalProperties(
    wrapper: Wrapper.flutterw,
  ),
)
          ''');
              expect(
                  generatedOutput, contains('Running source code generation.'));
              expect(
                  generatedOutput,
                  contains(
                      './flutterw pub run build_runner build --delete-conflicting-outputs'));
            });
          });
          test('without wrapper', () async {
            final annotations = (await resolveSource(
                    File('$testSpecPath/next_gen_builder_flutter_test_config.dart')
                        .readAsStringSync(),
                    (resolver) async =>
                        (await resolver.findLibraryByName('test_lib'))!))
                .getClass('TestClassConfig')!
                .metadata
                .map((e) => ConstantReader(e.computeConstantValue()!))
                .first;
            final args = GeneratorArguments(annotations: annotations);
            generatedOutput = await generate('''
@Openapi(
  inputSpecFile:
      'https://raw.githubusercontent.com/Nexushunter/tagmine-api/main/openapi.yaml',
  inputSpec: RemoteSpec(path: '$specPath'),
  generatorName: Generator.dio,
  useNextGen: true,
  cachePath: '${f.path}',
  outputDirectory: '${f.parent.path}/flutter',
  projectPubspecPath: './test/specs/flutter_pubspec.test.yaml',
)
          ''');

            expect(args.wrapper, Wrapper.none);
            expect(
                generatedOutput, contains('Running source code generation.'));
            expect(
                generatedOutput,
                contains(
                    'flutter pub run build_runner build --delete-conflicting-outputs'));
          });
        });
        test('uses dart', () async {
          final annotations = (await resolveSource(
                  File('$testSpecPath/next_gen_builder_test_config.dart')
                      .readAsStringSync(),
                  (resolver) async =>
                      (await resolver.findLibraryByName('test_lib'))!))
              .getClass('TestClassConfig')!
              .metadata
              .map((e) => ConstantReader(e.computeConstantValue()!))
              .first;
          final args = GeneratorArguments(annotations: annotations);
          generatedOutput = await generate('''
@Openapi(
  inputSpecFile:
      'https://raw.githubusercontent.com/Nexushunter/tagmine-api/main/openapi.yaml',
  inputSpec: RemoteSpec(path: '$specPath'),
  generatorName: Generator.dio,
  useNextGen: true,
  cachePath: '${f.path}',
  outputDirectory: '${f.parent.path}/dart',
  projectPubspecPath: './test/specs/dart_pubspec.test.yaml',
)
          ''');

          expect(args.wrapper, Wrapper.none);
          expect(generatedOutput, contains('Running source code generation.'));
          expect(
              generatedOutput,
              contains(
                  'dart pub run build_runner build --delete-conflicting-outputs'));
        });
        group('except when', () {
          test('flag is set', () async {
            final annotations = (await resolveSource(
                    '''
library test_lib;

import 'package:openapi_generator_annotations/openapi_generator_annotations.dart';

@Openapi(
  inputSpecFile:
      'https://raw.githubusercontent.com/Nexushunter/tagmine-api/main/openapi.yaml',
  inputSpec: RemoteSpec(path: '$specPath'),
  generatorName: Generator.dio,
  useNextGen: true,
  cachePath: '${f.path}',
  outputDirectory: '${f.parent.path}/no-src',
  runSourceGenOnOutput: false,
)
class TestClassConfig extends OpenapiGeneratorConfig {}
                    ''',
                    (resolver) async =>
                        (await resolver.findLibraryByName('test_lib'))!))
                .getClass('TestClassConfig')!
                .metadata
                .map((e) => ConstantReader(e.computeConstantValue()!))
                .first;
            final args = GeneratorArguments(annotations: annotations);

            expect(args.runSourceGen, isFalse);
            generatedOutput = await generate('''
@Openapi(
  inputSpec: RemoteSpec(path: '$specPath'),
  generatorName: Generator.dio,
  useNextGen: true,
  cachePath: '${f.path}',
  outputDirectory: '${f.parent.path}/no-src',
  runSourceGenOnOutput: false,
)
            ''');
            expect(generatedOutput,
                contains('Skipping source gen step due to flag being set.'));
          });
          test('generator is dart', () async {
            final annotations = (await resolveSource(
                    '''
library test_lib;

import 'package:openapi_generator_annotations/openapi_generator_annotations.dart';

@Openapi(
  inputSpecFile:
      'https://raw.githubusercontent.com/Nexushunter/tagmine-api/main/openapi.yaml',
  inputSpec: RemoteSpec(path: '$specPath'),
  generatorName: Generator.dart,
  useNextGen: true,
  cachePath: '${f.path}',
  outputDirectory: '${f.parent.path}/dart-gen'
)
class TestClassConfig extends OpenapiGeneratorConfig {}
                    ''',
                    (resolver) async =>
                        (await resolver.findLibraryByName('test_lib'))!))
                .getClass('TestClassConfig')!
                .metadata
                .map((e) => ConstantReader(e.computeConstantValue()!))
                .first;
            final args = GeneratorArguments(annotations: annotations);
            expect(args.runSourceGen, isTrue);
            generatedOutput = await generate('''
@Openapi(
  inputSpec: RemoteSpec(path: '$specPath'),
  generatorName: Generator.dart,
  useNextGen: true,
  cachePath: '${f.path}',
  outputDirectory: '${f.parent.path}/dart-gen'
)
            ''');
            expect(
                generatedOutput,
                contains(
                    'Skipping source gen because generator does not need it.'));
          });
        });
        test('logs when successful', () async {
          generatedOutput = await generate('''
@Openapi(
  inputSpec: RemoteSpec(path: '$specPath'),
  generatorName: Generator.dio,
  useNextGen: true,
  cachePath: '${f.path}',
  outputDirectory: '${f.parent.path}/success',
  projectPubspecPath: './test/specs/dart_pubspec.test.yaml',
)
          ''');
          expect(generatedOutput, contains('Codegen completed successfully.'));
          expect(generatedOutput, contains('Sources generated successfully.'));
        });
      });
      group('fetch dependencies', () {
        test('except when flag is present', () async {
          generatedOutput = await generate('''
@Openapi(
  inputSpec: RemoteSpec(path: '$specPath'),
  generatorName: Generator.dio,
  useNextGen: true,
  cachePath: '${f.path}',
  outputDirectory: '${f.parent.path}/no-fetch',
  projectPubspecPath: './test/specs/dart_pubspec.test.yaml',
  fetchDependencies: false,
)
          ''');
          expect(generatedOutput,
              contains('Skipping install step because flag was set.'));
        });
        test('succeeds', () async {
          generatedOutput = await generate('''
@Openapi(
  inputSpec: RemoteSpec(path: '$specPath'),
  generatorName: Generator.dio,
  useNextGen: true,
  cachePath: '${f.path}',
  outputDirectory: '${f.parent.path}/no-fetch',
  projectPubspecPath: './test/specs/dart_pubspec.test.yaml',
)
          ''');
          expect(generatedOutput,
              contains('Installing dependencies with generated source.'));
          expect(generatedOutput, contains('Install completed successfully.'));
        });
      });
      group('update cache', () {
        final src = '''
        @Openapi(
            inputSpec: RemoteSpec(path: '$specPath'),
            useNextGen: true,
            cachePath: '${f.path}',
            outputDirectory: '${f.parent.path}/update-cache',
            )
      ''';

        test('creating a cache file when not found', () async {
          // Ensure that other tests don't make this available;
          if (f.existsSync()) {
            f.deleteSync();
          }
          expect(f.existsSync(), isFalse);
          generatedOutput = await generate(src);
          expect(f.existsSync(), isTrue);
          expect(jsonDecode(f.readAsStringSync()),
              await loadSpec(specConfig: RemoteSpec(path: specPath)));
        });
        test('updates the cache file when found', () async {
          f.writeAsStringSync(jsonEncode({'someKey': 'someValue'}));
          expect(f.existsSync(), isTrue);
          generatedOutput = await generate(src);
          final expectedSpec =
              await loadSpec(specConfig: RemoteSpec(path: specPath));
          final actualSpec = jsonDecode(f.readAsStringSync());
          expect(actualSpec, expectedSpec);
        });
        test('logs when successful', () async {
          f.writeAsStringSync(jsonEncode({'someKey': 'someValue'}));
          generatedOutput = await generate(src);
          expect(
              generatedOutput, contains('Successfully cached spec changes.'));
        });
      });
    });
  });
}

Future<ConstantReader> getReaderForAnnotation(String annotationDef) async {
  final annotations = (await resolveSource('''
library test_lib;
import 'package:openapi_generator_annotations/openapi_generator_annotations.dart';

$annotationDef
class TestClassConfig {}
                    ''',
          (resolver) async => (await resolver.findLibraryByName('test_lib'))!))
      .getClass('TestClassConfig')!
      .metadata
      .map((e) => ConstantReader(e.computeConstantValue()!))
      .first;
  return annotations;
}
