import 'dart:io';

import 'package:analyzer/dart/element/type.dart';
import 'package:build_test/build_test.dart';
import 'package:logging/logging.dart';
import 'package:mockito/mockito.dart';
import 'package:openapi_generator/src/models/command.dart';
import 'package:openapi_generator/src/models/generator_arguments.dart';
import 'package:openapi_generator/src/models/output_message.dart';
import 'package:openapi_generator/src/openapi_generator_runner.dart';
import 'package:openapi_generator/src/utils.dart';
import 'package:openapi_generator_annotations/openapi_generator_annotations.dart';
import 'package:source_gen/source_gen.dart';
import 'package:test/test.dart';

import 'mocks.mocks.dart';
import 'utils.dart';

void main() {
  group('OpenApiGenerator', () {
    group('NextGen', () {
      late MockConstantReader mockedAnnotations;
      late ConstantReader defaultAnnotations;
      late GeneratorArguments realArguments;
      late MockGeneratorArguments mockedArgs;
      late MockCommandRunner mockRunner;
      final logger = Logger('TestOpenApiGenerator');
      setUpAll(() async {
        resetMockitoState();
        mockedArgs = MockGeneratorArguments();
        mockRunner = MockCommandRunner();
        mockedAnnotations = MockConstantReader();
        defaultAnnotations = (await resolveSource(
                File('$testSpecPath/next_gen_builder_test_config.dart')
                    .readAsStringSync(),
                (resolver) async =>
                    (await resolver.findLibraryByName('test_lib'))!))
            .getClass('TestClassConfig')!
            .metadata
            .map((e) => ConstantReader(e.computeConstantValue()!))
            .first;
        realArguments = GeneratorArguments(annotations: defaultAnnotations);
      });

      test('should have banner logger', () async {
        final logs = <LogRecord>[];
        logger.onRecord.listen(logs.add);
        try {
          await OpenapiGenerator(logger: logger).generateForAnnotatedElement(
              MockMethodElement(), defaultAnnotations, MockBuildStep());
          fail('Should throw when not ClassElement');
        } catch (_, __) {
          expect(logs.length, 1);
          expect(
              logs[0].message,
              contains([
                ':::::::::::::::::::::::::::::::::::::::::::',
                '::      Openapi generator for dart       ::',
                ':::::::::::::::::::::::::::::::::::::::::::',
              ].join('\n')));
          expect(logs[0].level, Level.INFO);
        }
      });

      test('throws InvalidGenerationSourceError when not a class', () async {
        try {
          await OpenapiGenerator().generateForAnnotatedElement(
              MockMethodElement(), defaultAnnotations, MockBuildStep());
          fail('Should throw when not ClassElement');
        } catch (e, _) {
          expect(e, isA<InvalidGenerationSourceError>());
          e as InvalidGenerationSourceError;
          expect(e.message, 'Generator cannot target ``.');
          expect(e.todo, 'Remove the [Openapi] annotation from ``.');
        }
      });

      test('throws AssertionError when useCache is set but useNextGen is not',
          () async {
        final mockedUseNextGen = MockConstantReader();
        when(mockedUseNextGen.literalValue).thenReturn(false);

        final mockedUseCachePath = MockConstantReader();
        when(mockedUseCachePath.literalValue).thenReturn('something');

        when(mockedAnnotations.read('useNextGen')).thenReturn(mockedUseNextGen);
        when(mockedAnnotations.read('cachePath'))
            .thenReturn(mockedUseCachePath);

        try {
          await OpenapiGenerator().generateForAnnotatedElement(
              MockClassElement(), mockedAnnotations, MockBuildStep());
          fail('Should throw when useNextGen is false and cache path is set.');
        } catch (e, _) {
          expect(e, isA<AssertionError>());
          e as AssertionError;
          expect(e.message, 'useNextGen must be set when using cachePath');
        }
      });

      group('logs which enviroment being used', () {
        setUpAll(() => resetMockitoState());
        test('dart when wrapper is none', () async {
          final logs = <LogRecord>[];
          logger.onRecord.listen(logs.add);
          when(mockRunner.checkForFlutterEnvironemt(
                  wrapper: anyNamed('wrapper'),
                  providedPubspecPath: anyNamed('providedPubspecPath')))
              .thenAnswer((_) async => false);

          await OpenapiGenerator(logger: logger, runner: mockRunner)
              .generateForAnnotatedElement(
                  MockClassElement(), defaultAnnotations, MockBuildStep());

          expect(logs[1].message, 'Using dart environemnt');
        });
        test('flutter when wrapper is fvm', () async {
          final logs = <LogRecord>[];
          logger.onRecord.listen(logs.add);
          final annotations = (await resolveSource(
                  File('$testSpecPath/next_gen_builder_fvm_test_config.dart')
                      .readAsStringSync(),
                  (resolver) async =>
                      (await resolver.findLibraryByName('test_lib'))!))
              .getClass('TestClassConfig')!
              .metadata
              .map((e) => ConstantReader(e.computeConstantValue()!))
              .first;

          when(mockRunner.checkForFlutterEnvironemt(
                  wrapper: argThat(
                    TypeMatcher<Wrapper>()
                        .having((e) => e, 'name', Wrapper.fvm),
                    named: 'wrapper',
                  ),
                  providedPubspecPath: anyNamed('providedPubspecPath')))
              .thenAnswer((_) async => true);

          await OpenapiGenerator(logger: logger, runner: mockRunner)
              .generateForAnnotatedElement(
                  MockClassElement(), annotations, MockBuildStep());

          expect(logs[1].message, 'Using flutter environemnt');
        });
        test('flutter when wrapper is ./flutter', () async {
          final logs = <LogRecord>[];
          logger.onRecord.listen(logs.add);
          final annotations = (await resolveSource(
                  File('$testSpecPath/next_gen_builder_flutterw_test_config.dart')
                      .readAsStringSync(),
                  (resolver) async =>
                      (await resolver.findLibraryByName('test_lib'))!))
              .getClass('TestClassConfig')!
              .metadata
              .map((e) => ConstantReader(e.computeConstantValue()!))
              .first;

          when(mockRunner.checkForFlutterEnvironemt(
                  wrapper: argThat(
                    TypeMatcher<Wrapper>()
                        .having((e) => e, 'name', Wrapper.flutterw),
                    named: 'wrapper',
                  ),
                  providedPubspecPath: anyNamed('providedPubspecPath')))
              .thenAnswer((_) async => true);

          await OpenapiGenerator(logger: logger, runner: mockRunner)
              .generateForAnnotatedElement(
                  MockClassElement(), annotations, MockBuildStep());

          expect(logs[1].message, 'Using flutter environemnt');
        });
        test('when defined in pubspec', () async {
          final logs = <LogRecord>[];
          logger.onRecord.listen(logs.add);
          final annotations = (await resolveSource(
                  File('$testSpecPath/next_gen_builder_flutter_test_config.dart')
                      .readAsStringSync(),
                  (resolver) async =>
                      (await resolver.findLibraryByName('test_lib'))!))
              .getClass('TestClassConfig')!
              .metadata
              .map((e) => ConstantReader(e.computeConstantValue()!))
              .first;

          when(
            mockRunner.checkForFlutterEnvironemt(
              wrapper: anyNamed('wrapper'),
              providedPubspecPath: argThat(
                contains('./test/specs/flutter_pubspec.test.yaml'),
                named: 'providedPubspecPath',
              ),
            ),
          ).thenAnswer((_) async => true);

          await OpenapiGenerator(logger: logger, runner: mockRunner)
              .generateForAnnotatedElement(
                  MockClassElement(), annotations, MockBuildStep());

          expect(logs[1].message, 'Using flutter environemnt');
        });
      });

      group('generatorV2', () {
        group('completes successfully', () {
          late OpenapiGenerator generator;
          setUpAll(() {
            resetMockitoState();
            generator = OpenapiGenerator(logger: logger, runner: mockRunner);
            when(mockRunner.runCommand(
                    command: anyNamed('command'),
                    workingDirectory: anyNamed('workingDirectory')))
                .thenAnswer((realInvocation) =>
                    Future.value(ProcessResult(999, 0, 'success', '')));
            when(mockRunner.writeAnnotatedFile(
                    path: anyNamed('path'), content: anyNamed('content')))
                .thenAnswer((realInvocation) => Future.value());
          });

          test('no diff', () async {
            final logs = <LogRecord>[];
            logger.onRecord.listen(logs.add);
            when(mockRunner.loadSpecFile(
                    specConfig: anyNamed('specConfig'), isCached: true))
                .thenAnswer((realInvocation) => Future.value({}));
            when(mockRunner.loadSpecFile(specConfig: anyNamed('specConfig')))
                .thenAnswer((realInvocation) => Future.value({}));
            when(mockRunner.isSpecFileDirty(
                    cachedSpec: anyNamed('cachedSpec'),
                    loadedSpec: anyNamed('loadedSpec')))
                .thenAnswer((realInvocation) => Future.value(false));
            when(mockedArgs.isRemote).thenReturn(false);
            try {
              await generator.generatorV2(
                  args: mockedArgs,
                  baseCommand: 'dart',
                  annotatedPath: 'annotatedPath');
              expect(logs.length, 4);
              expect(logs[1].message,
                  'No diff between versions, not running generator.');
              expect(logs[1].level, Level.INFO);
            } catch (e, _) {
              fail('should not have thrown.');
            }
          });
          test('has diff', () async {
            // setup
            final logs = <LogRecord>[];
            logger.onRecord.listen(logs.add);
            when(mockRunner.loadSpecFile(
                    specConfig: anyNamed('specConfig'), isCached: true))
                .thenAnswer((realInvocation) => Future.value({}));
            when(mockRunner.loadSpecFile(specConfig: anyNamed('specConfig')))
                .thenAnswer((realInvocation) => Future.value({}));
            when(mockRunner.isSpecFileDirty(
                    cachedSpec: anyNamed('cachedSpec'),
                    loadedSpec: anyNamed('loadedSpec')))
                .thenAnswer((realInvocation) => Future.value(true));
            when(mockedArgs.isRemote).thenReturn(false);
            when(mockedArgs.runSourceGen).thenReturn(true);
            when(mockedArgs.shouldGenerateSources).thenReturn(true);
            when(mockedArgs.shouldFetchDependencies).thenReturn(true);
            when(mockRunner.cacheSpecFile(
                    updatedSpec: anyNamed('updatedSpec'),
                    cachedPath: anyNamed('cachedPath')))
                .thenAnswer((_) => Future.value(VoidType));
            when(mockRunner.runCommand(
                    command: anyNamed('command'),
                    workingDirectory: anyNamed('workingDirectory')))
                .thenAnswer((realInvocation) =>
                    Future.value(ProcessResult(999, 0, 'success', '')));

            when(mockRunner.loadAnnotatedFile(path: anyNamed('path')))
                .thenAnswer((realInvocation) =>
                    Future.value(['cant be empty or throws']));
            when(mockRunner.writeAnnotatedFile(
                    path: anyNamed('path'), content: anyNamed('content')))
                .thenAnswer((realInvocation) => Future.value(VoidType));

            // execution
            await generator.generatorV2(
                args: mockedArgs,
                baseCommand: 'dart',
                annotatedPath: 'annotatedPath');
            expect(logs.length, 15);
          });
        });
        group('logs', () {
          late OpenapiGenerator generator;
          setUpAll(() {
            resetMockitoState();
            generator = OpenapiGenerator(logger: logger, runner: mockRunner);
          });
          test('warning when using remote spec', () async {
            final logs = <LogRecord>[];
            logger.onRecord.listen(logs.add);
            when(mockRunner.loadSpecFile(
                    specConfig: anyNamed('specConfig'), isCached: true))
                .thenAnswer((realInvocation) => Future.value({}));
            when(mockRunner.loadSpecFile(specConfig: anyNamed('specConfig')))
                .thenAnswer((realInvocation) => Future.value({}));
            when(mockRunner.isSpecFileDirty(
                    cachedSpec: anyNamed('cachedSpec'),
                    loadedSpec: anyNamed('loadedSpec')))
                .thenAnswer((realInvocation) => Future.value(false));
            when(mockedArgs.isRemote).thenReturn(true);
            when(mockRunner.runCommand(
                    command: anyNamed('command'),
                    workingDirectory: anyNamed('workingDirectory')))
                .thenAnswer((realInvocation) =>
                    Future.value(ProcessResult(999, 0, 'success', '')));
            when(mockRunner.writeAnnotatedFile(
                    path: anyNamed('path'), content: anyNamed('content')))
                .thenAnswer((realInvocation) => Future.value());
            try {
              await generator.generatorV2(
                  args: mockedArgs,
                  baseCommand: 'dart',
                  annotatedPath: 'annotatedPath');
              expect(logs.length, 6);
              expect(logs[0].message,
                  'Using a remote specification, a cache will still be create but may be outdated.');
              expect(logs[0].level, Level.WARNING);
            } catch (e, _) {
              print(e);
              fail('should not have thrown.');
            }
          });
          test('when no cache is found', () async {
            // setup
            final logs = <LogRecord>[];
            logger.onRecord.listen(logs.add);
            when(mockRunner.loadSpecFile(
                    specConfig: anyNamed('specConfig'), isCached: true))
                .thenAnswer((realInvocation) => Future.value({}));
            when(mockRunner.loadSpecFile(specConfig: anyNamed('specConfig')))
                .thenAnswer((realInvocation) => Future.value({}));
            when(mockRunner.isSpecFileDirty(
                    cachedSpec: anyNamed('cachedSpec'),
                    loadedSpec: anyNamed('loadedSpec')))
                .thenAnswer((realInvocation) => Future.value(true));
            when(mockedArgs.isRemote).thenReturn(false);
            when(mockedArgs.hasLocalCache).thenReturn(false);
            when(mockRunner.runCommand(
                    command: anyNamed('command'),
                    workingDirectory: anyNamed('workingDirectory')))
                .thenAnswer((realInvocation) =>
                    Future.value(ProcessResult(999, 0, 'success', '')));

            when(mockRunner.loadAnnotatedFile(path: anyNamed('path')))
                .thenAnswer((realInvocation) =>
                    Future.value(['cant be empty or throws']));
            when(mockRunner.writeAnnotatedFile(
                    path: anyNamed('path'), content: anyNamed('content')))
                .thenAnswer((realInvocation) => Future.value(VoidType));

            // execution
            await generator.generatorV2(
                args: mockedArgs,
                baseCommand: 'dart',
                annotatedPath: 'annotatedPath');
            expect(logs.length, 15);

            final recordIndex = logs.indexWhere((element) =>
                element.message == 'No local cache found. Creating one.');
            expect(recordIndex, greaterThan(-1));
            expect(logs[recordIndex].level, Level.INFO);
          });
          test('when cache is found', () async {
            // setup
            final logs = <LogRecord>[];
            logger.onRecord.listen(logs.add);
            when(mockRunner.loadSpecFile(
                    specConfig: anyNamed('specConfig'), isCached: true))
                .thenAnswer((realInvocation) => Future.value({}));
            when(mockRunner.loadSpecFile(specConfig: anyNamed('specConfig')))
                .thenAnswer((realInvocation) => Future.value({}));
            when(mockRunner.isSpecFileDirty(
                    cachedSpec: anyNamed('cachedSpec'),
                    loadedSpec: anyNamed('loadedSpec')))
                .thenAnswer((realInvocation) => Future.value(true));
            when(mockedArgs.isRemote).thenReturn(false);
            when(mockedArgs.hasLocalCache).thenReturn(true);
            when(mockRunner.runCommand(
                    command: anyNamed('command'),
                    workingDirectory: anyNamed('workingDirectory')))
                .thenAnswer((realInvocation) =>
                    Future.value(ProcessResult(999, 0, 'success', '')));

            when(mockRunner.loadAnnotatedFile(path: anyNamed('path')))
                .thenAnswer((realInvocation) =>
                    Future.value(['cant be empty or throws']));
            when(mockRunner.writeAnnotatedFile(
                    path: anyNamed('path'), content: anyNamed('content')))
                .thenAnswer((realInvocation) => Future.value(VoidType));

            // execution
            await generator.generatorV2(
                args: mockedArgs,
                baseCommand: 'dart',
                annotatedPath: 'annotatedPath');
            expect(logs.length, 15);

            final recordIndex = logs.indexWhere((element) =>
                element.message ==
                'Local cache found. Overwriting existing one.');
            expect(recordIndex, greaterThan(-1));
            expect(logs[recordIndex].level, Level.INFO);
          });
          group('on failure', () {
            test('has diff', () async {
              // setup
              final logs = <LogRecord>[];
              logger.onRecord.listen(logs.add);
              when(mockRunner.loadSpecFile(
                      specConfig: anyNamed('specConfig'), isCached: true))
                  .thenAnswer((realInvocation) => Future.value({}));
              when(mockRunner.loadSpecFile(specConfig: anyNamed('specConfig')))
                  .thenAnswer((realInvocation) => Future.value({}));
              when(mockRunner.isSpecFileDirty(
                      cachedSpec: anyNamed('cachedSpec'),
                      loadedSpec: anyNamed('loadedSpec')))
                  .thenThrow('uh oh');
              when(mockedArgs.isRemote).thenReturn(false);
              when(mockedArgs.runSourceGen).thenReturn(true);
              when(mockedArgs.shouldGenerateSources).thenReturn(true);
              when(mockedArgs.shouldFetchDependencies).thenReturn(true);
              when(mockRunner.cacheSpecFile(
                      updatedSpec: anyNamed('updatedSpec'),
                      cachedPath: anyNamed('cachedPath')))
                  .thenAnswer((_) => Future.value(VoidType));
              when(mockRunner.runCommand(
                      command: anyNamed('command'),
                      workingDirectory: anyNamed('workingDirectory')))
                  .thenAnswer((realInvocation) =>
                      Future.value(ProcessResult(999, 0, 'success', '')));

              when(mockRunner.loadAnnotatedFile(path: anyNamed('path')))
                  .thenAnswer((realInvocation) =>
                      Future.value(['cant be empty or throws']));
              when(mockRunner.writeAnnotatedFile(
                      path: anyNamed('path'), content: anyNamed('content')))
                  .thenAnswer((realInvocation) => Future.value(VoidType));

              // execution
              await generator.generatorV2(
                  args: mockedArgs,
                  baseCommand: 'dart',
                  annotatedPath: 'annotatedPath');
              expect(logs.length, 5);
              expect(logs[1].message, 'Failed to generate content.');
              expect(logs[1].level, Level.SEVERE);
            });
            test('fails to format', () async {
              // setup
              final logs = <LogRecord>[];
              logger.onRecord.listen(logs.add);
              when(mockRunner.loadSpecFile(
                      specConfig: anyNamed('specConfig'), isCached: true))
                  .thenAnswer((realInvocation) => Future.value({}));
              when(mockRunner.loadSpecFile(specConfig: anyNamed('specConfig')))
                  .thenAnswer((realInvocation) => Future.value({}));
              when(mockRunner.isSpecFileDirty(
                      cachedSpec: anyNamed('cachedSpec'),
                      loadedSpec: anyNamed('loadedSpec')))
                  .thenAnswer((realInvocation) => Future.value(true));
              when(mockedArgs.isRemote).thenReturn(false);
              when(mockedArgs.runSourceGen).thenReturn(true);
              when(mockedArgs.shouldGenerateSources).thenReturn(true);
              when(mockedArgs.shouldFetchDependencies).thenReturn(true);
              when(mockRunner.cacheSpecFile(
                      updatedSpec: anyNamed('updatedSpec'),
                      cachedPath: anyNamed('cachedPath')))
                  .thenAnswer((_) => Future.value(VoidType));
              when(mockedArgs.outputDirectory).thenReturn('pwd');
              when(mockRunner.runCommand(
                      command: anyNamed('command'),
                      workingDirectory: anyNamed('workingDirectory')))
                  .thenAnswer((_) =>
                      Future.value(ProcessResult(999, 0, 'success', '')));
              when(mockRunner.runCommand(
                command: argThat(
                  TypeMatcher<Command>()
                      .having((c) => c.executable, 'executable', 'dart')
                      .having(
                          (c) => c.arguments, 'arguments', ['format', './']),
                  named: 'command',
                ),
                workingDirectory:
                    argThat(contains('pwd'), named: 'workingDirectory'),
              )).thenAnswer((realInvocation) =>
                  Future.value(ProcessResult(999, 1, '', 'err')));

              when(mockRunner.loadAnnotatedFile(path: anyNamed('path')))
                  .thenAnswer((realInvocation) =>
                      Future.value(['cant be empty or throws']));
              when(mockRunner.writeAnnotatedFile(
                      path: anyNamed('path'), content: anyNamed('content')))
                  .thenAnswer((realInvocation) => Future.value(VoidType));

              // execution
              await generator.generatorV2(
                  args: mockedArgs,
                  baseCommand: 'dart',
                  annotatedPath: 'annotatedPath');
              expect(logs.length, 15);
              expect(logs[12].message, 'Failed to format generated code.');
              expect(logs[12].level, Level.SEVERE);
            });
          });
        });
      });

      group('hasDiff', () {
        test('succeeds', () async {
          final logs = <LogRecord>[];
          logger.onRecord.listen(logs.add);
          when(mockRunner.loadSpecFile(
                  specConfig: anyNamed('specConfig'), isCached: true))
              .thenAnswer(
                  (realInvocation) => Future.value(<String, dynamic>{}));
          when(mockRunner.loadSpecFile(specConfig: anyNamed('specConfig')))
              .thenAnswer(
                  (realInvocation) => Future.value(<String, dynamic>{}));
          when(mockRunner.isSpecFileDirty(
                  cachedSpec: anyNamed('cachedSpec'),
                  loadedSpec: anyNamed('loadedSpec')))
              .thenAnswer((realInvocation) => Future.value(true));
          try {
            expect(
                await OpenapiGenerator(runner: mockRunner)
                    .hasDiff(args: realArguments),
                isTrue);
            expect(logs.length, 1);
            expect(logs[0].message, 'Loaded cached and current spec files.');
          } catch (_, __) {
            fail('should have completed successfully');
          }
        });
        test('debug logs', () async {
          final logs = <LogRecord>[];
          logger.onRecord.listen(logs.add);
          when(mockedArgs.isDebug).thenReturn(true);
          when(mockRunner.loadSpecFile(
                  specConfig: anyNamed('specConfig'), isCached: true))
              .thenAnswer(
                  (realInvocation) => Future.value(<String, dynamic>{}));
          when(mockRunner.loadSpecFile(specConfig: anyNamed('specConfig')))
              .thenAnswer(
                  (realInvocation) => Future.value(<String, dynamic>{}));
          when(mockRunner.isSpecFileDirty(
                  cachedSpec: anyNamed('cachedSpec'),
                  loadedSpec: anyNamed('loadedSpec')))
              .thenAnswer((realInvocation) => Future.value(true));
          try {
            expect(
                await OpenapiGenerator(runner: mockRunner)
                    .hasDiff(args: mockedArgs),
                isTrue);
            expect(logs.length, 1);
            expect(logs[0].message,
                'Loaded cached and current spec files.\n{}\n{}');
          } catch (_, __) {
            fail('should have completed successfully');
          }
        });
        test('fails', () async {
          when(mockRunner.loadSpecFile(
                  specConfig: anyNamed('specConfig'), isCached: true))
              .thenAnswer(
                  (realInvocation) => Future.value(<String, dynamic>{}));
          when(mockRunner.loadSpecFile(specConfig: anyNamed('specConfig')))
              .thenAnswer(
                  (realInvocation) => Future.value(<String, dynamic>{}));
          when(mockRunner.isSpecFileDirty(
                  cachedSpec: anyNamed('cachedSpec'),
                  loadedSpec: anyNamed('loadedSpec')))
              .thenThrow('uh oh');
          try {
            await OpenapiGenerator(runner: mockRunner)
                .hasDiff(args: realArguments);
            fail('should have thrown');
          } catch (e, _) {
            expect(e, isA<OutputMessage>());
            e as OutputMessage;
            expect(e.message, 'Failed to check diff status.');
            expect(e.additionalContext, 'uh oh');
            expect(e.level, Level.SEVERE);
            expect(e.stackTrace, isNotNull);
          }
        });
      });
      group('fetchDependencies', () {
        test('returns successfully', () async {
          when(mockedArgs.shouldFetchDependencies).thenReturn(true);
          when(mockRunner.runCommand(
                  command: anyNamed('command'),
                  workingDirectory: anyNamed('workingDirectory')))
              .thenAnswer(
                  (_) => Future.value(ProcessResult(999, 0, 'yes', '')));
          try {
            await OpenapiGenerator(runner: mockRunner)
                .fetchDependencies(baseCommand: 'cmd', args: mockedArgs);
          } catch (e, _) {
            fail('should have completed successfully');
          }
        });
        test('fails and returns an OutputMessage', () async {
          when(mockedArgs.shouldFetchDependencies).thenReturn(true);
          when(mockRunner.runCommand(
                  command: anyNamed('command'),
                  workingDirectory: anyNamed('workingDirectory')))
              .thenAnswer(
                  (_) => Future.value(ProcessResult(999, 1, '', 'uh oh')));
          try {
            await OpenapiGenerator(runner: mockRunner)
                .fetchDependencies(baseCommand: 'cmd', args: mockedArgs);
            fail('should returned an error');
          } catch (e, _) {
            expect(e, isA<OutputMessage>());
            e as OutputMessage;
            expect(e.level, Level.SEVERE);
            expect(e.message, 'Install within generated sources failed.');
            expect(e.additionalContext, 'uh oh');
            expect(e.stackTrace, isNotNull);
          }
        });
        group('logs', () {
          tearDownAll(() => resetMockitoState());
          test('skips dependency fetch when flag is set', () async {
            final logs = <LogRecord>[];
            logger.onRecord.listen(logs.add);
            when(mockedArgs.shouldFetchDependencies).thenReturn(false);

            await OpenapiGenerator(logger: logger)
                .fetchDependencies(baseCommand: 'cmd', args: mockedArgs);

            expect(logs.length, 1);
            expect(logs[0].toString(),
                contains('Skipping install step because flag was set.'));
            expect(logs[0].level, Level.WARNING);
          });
          test('debug', () async {
            final logs = <LogRecord>[];
            logger.onRecord.listen(logs.add);
            when(mockedArgs.shouldFetchDependencies).thenReturn(true);
            when(mockedArgs.isDebug).thenReturn(true);
            when(mockRunner.runCommand(
                    command: anyNamed('command'),
                    workingDirectory: anyNamed('workingDirectory')))
                .thenAnswer(
                    (_) => Future.value(ProcessResult(999, 0, 'yes', '')));

            await OpenapiGenerator(logger: logger, runner: mockRunner)
                .fetchDependencies(baseCommand: 'dart', args: mockedArgs);

            expect(logs.length, 2);
            expect(
                logs[0].message,
                contains(
                    'Installing dependencies with generated source. dart pub get'));
            expect(logs[1].message, contains('yes'));
            expect(
                logs[1].message, contains('Install completed successfully.'));
            expect(logs[0].level, Level.INFO);
            expect(logs[1].level, Level.INFO);
          });
          test('normal', () async {
            final logs = <LogRecord>[];
            logger.onRecord.listen(logs.add);
            when(mockedArgs.shouldFetchDependencies).thenReturn(true);
            when(mockedArgs.isDebug).thenReturn(false);
            when(mockRunner.runCommand(
                    command: anyNamed('command'),
                    workingDirectory: anyNamed('workingDirectory')))
                .thenAnswer(
                    (_) => Future.value(ProcessResult(999, 0, 'yes', '')));

            await OpenapiGenerator(logger: logger, runner: mockRunner)
                .fetchDependencies(baseCommand: 'dart', args: mockedArgs);

            expect(logs.length, 2);
            expect(
                logs[0].message,
                contains(
                    'Installing dependencies with generated source. dart pub get'));
            expect(logs[1].message.contains('yes'), isFalse);
            expect(
                logs[1].message, contains('Install completed successfully.'));
            expect(logs[0].level, Level.INFO);
            expect(logs[1].level, Level.INFO);
          });
        });
      });
      group('runSourceGen', () {
        test('fails and returns an OutputMessage', () async {
          when(mockRunner.runCommand(
                  command: anyNamed('command'),
                  workingDirectory: anyNamed('workingDirectory')))
              .thenAnswer(
                  (_) => Future.value(ProcessResult(999, 1, '', 'uh oh')));
          try {
            await OpenapiGenerator(runner: mockRunner)
                .runSourceGen(baseCommand: 'dart', args: mockedArgs);
            fail('should returned an error');
          } catch (e, _) {
            expect(e, isA<OutputMessage>());
            e as OutputMessage;
            expect(e.level, Level.SEVERE);
            expect(e.message,
                'Failed to generate source code. Build Command output:');
            expect(e.additionalContext, 'uh oh');
            expect(e.stackTrace, isNotNull);
          }
        });
        test('runs successfully', () async {
          final logs = <LogRecord>[];
          logger.onRecord.listen(logs.add);
          when(mockRunner.runCommand(
                  command: anyNamed('command'),
                  workingDirectory: anyNamed('workingDirectory')))
              .thenAnswer((_) => Future.value(ProcessResult(999, 0, '', '')));
          try {
            await OpenapiGenerator(runner: mockRunner)
                .runSourceGen(baseCommand: 'dart', args: mockedArgs);
            expect(logs.length, 3);
            expect(logs[0].message, 'Running source code generation.');
            expect(logs[1].message,
                'dart pub run build_runner build --delete-conflicting-outputs');
            expect(logs[2].message, 'Codegen completed successfully.');
            for (final log in logs) {
              expect(log.level, Level.INFO);
            }
          } catch (e, _) {
            fail('should have completed normally');
          }
        });
      });
      group('generateSources', () {
        test('skips when flag is set', () async {
          final logs = <LogRecord>[];
          logger.onRecord.listen(logs.add);
          when(mockedArgs.runSourceGen).thenReturn(false);
          try {
            await OpenapiGenerator(runner: mockRunner)
                .generateSources(baseCommand: 'dart', args: mockedArgs);
            expect(logs.length, 1);
            expect(logs[0].message,
                'Skipping source gen step due to flag being set.');
            expect(logs[0].level, Level.WARNING);
          } catch (e, _) {
            fail('should have completed normally');
          }
        });
        test('skips when not needed', () async {
          final logs = <LogRecord>[];
          logger.onRecord.listen(logs.add);
          when(mockedArgs.runSourceGen).thenReturn(true);
          when(mockedArgs.shouldGenerateSources).thenReturn(false);
          try {
            await OpenapiGenerator(runner: mockRunner)
                .generateSources(baseCommand: 'dart', args: mockedArgs);
            expect(logs.length, 1);
            expect(logs[0].message,
                'Skipping source gen because generator does not need it.');
            expect(logs[0].level, Level.INFO);
          } catch (e, _) {
            fail('should have completed normally');
          }
        });
        test('completes successfully', () async {
          final logs = <LogRecord>[];
          logger.onRecord.listen(logs.add);
          when(mockedArgs.runSourceGen).thenReturn(true);
          when(mockedArgs.shouldGenerateSources).thenReturn(true);
          when(mockRunner.runCommand(
                  command: anyNamed('command'),
                  workingDirectory: anyNamed('workingDirectory')))
              .thenAnswer((_) => Future.value(ProcessResult(999, 0, '', '')));
          try {
            await OpenapiGenerator(runner: mockRunner)
                .generateSources(baseCommand: 'dart', args: mockedArgs);
            expect(logs.length, 4);
            expect(logs[3].message, 'Sources generated successfully.');
            expect(logs[3].level, Level.INFO);
          } catch (e, _) {
            fail('should have completed normally');
          }
        });
        test('fails', () async {
          final logs = <LogRecord>[];
          logger.onRecord.listen(logs.add);
          when(mockedArgs.runSourceGen).thenReturn(true);
          when(mockedArgs.shouldGenerateSources).thenReturn(true);
          when(mockRunner.runCommand(
                  command: anyNamed('command'),
                  workingDirectory: anyNamed('workingDirectory')))
              .thenAnswer(
                  (_) => Future.value(ProcessResult(999, 1, '', 'uh oh')));
          try {
            await OpenapiGenerator(runner: mockRunner)
                .generateSources(baseCommand: 'dart', args: mockedArgs);
            fail('should have failed');
          } catch (e, _) {
            expect(e, isA<OutputMessage>());
            e as OutputMessage;
            expect(e.message, 'Could not complete source generation');
            expect(e.level, Level.SEVERE);
            expect(e.additionalContext, isA<OutputMessage>());
            expect(e.stackTrace, isNotNull);
          }
        });
      });
      group('updateAnnotatedFile', () {
        test('fails', () async {
          when(mockRunner.loadAnnotatedFile(path: 'annotatedPath'))
              .thenAnswer((realInvocation) => Future.error('uh'));
          try {
            await OpenapiGenerator(runner: mockRunner)
                .updateAnnotatedFile(annotatedPath: 'annotatedPath');
            fail('should have thrown an error');
          } catch (e, _) {
            expect(e, isA<OutputMessage>());
            e as OutputMessage;
            expect(e.message, 'Failed to update the annotated class file.');
            expect(e.level, Level.SEVERE);
            expect(e.additionalContext, 'uh');
            expect(e.stackTrace, isNotNull);
          }
        });
        test('finds timestamp', () async {
          final logs = <LogRecord>[];
          logger.onRecord.listen(logs.add);
          when(mockRunner.loadAnnotatedFile(path: 'annotatedPath')).thenAnswer(
              (realInvocation) =>
                  Future.value(['$lastRunPlaceHolder: something', 'more']));
          when(mockRunner.writeAnnotatedFile(
                  path: 'annotatedPath', content: anyNamed('content')))
              .thenAnswer((realInvocation) => Future.value());
          try {
            await OpenapiGenerator(runner: mockRunner)
                .updateAnnotatedFile(annotatedPath: 'annotatedPath');
            expect(logs.length, 1);
            expect(logs[0].message,
                contains('Found generated timestamp. Updating with '));
          } catch (_, __) {
            fail('should have completed successfully');
          }
        });
        test('does not find timestamp', () async {
          final logs = <LogRecord>[];
          logger.onRecord.listen(logs.add);
          when(mockRunner.loadAnnotatedFile(path: 'annotatedPath'))
              .thenAnswer((realInvocation) => Future.value(['more']));
          when(mockRunner.writeAnnotatedFile(
                  path: 'annotatedPath', content: anyNamed('content')))
              .thenAnswer((realInvocation) => Future.value());
          try {
            await OpenapiGenerator(runner: mockRunner)
                .updateAnnotatedFile(annotatedPath: 'annotatedPath');
            expect(logs.length, 1);
            expect(logs[0].message,
                contains('Creating generated timestamp with '));
          } catch (_, __) {
            fail('should have completed successfully');
          }
        });
      });
      group('formatCode', () {
        test('logs on success', () async {
          final logs = <LogRecord>[];
          logger.onRecord.listen(logs.add);
          when(mockRunner.runCommand(
                  command: anyNamed('command'),
                  workingDirectory: anyNamed('workingDirectory')))
              .thenAnswer((_) => Future.value(ProcessResult(999, 0, '', '')));
          try {
            await OpenapiGenerator(runner: mockRunner, logger: logger)
                .formatCode(args: mockedArgs);
            expect(logs.length, 1);
            expect(logs[0].message, 'Successfully formatted code.');
            expect(logs[0].level, Level.INFO);
          } catch (e, _) {
            fail('should complete successfully');
          }
        });
        test('fails and returns an OutputMessage', () async {
          when(mockRunner.runCommand(
                  command: anyNamed('command'),
                  workingDirectory: anyNamed('workingDirectory')))
              .thenAnswer(
                  (_) => Future.value(ProcessResult(999, 1, '', 'uh oh')));
          try {
            await OpenapiGenerator(runner: mockRunner)
                .formatCode(args: mockedArgs);
            fail('should returned an error');
          } catch (e, _) {
            expect(e, isA<OutputMessage>());
            e as OutputMessage;
            expect(e.level, Level.SEVERE);
            expect(e.message, 'Failed to format generated code.');
            expect(e.additionalContext, 'uh oh');
            expect(e.stackTrace, isNotNull);
          }
        });
      });
      group('runOpenApiJar', () {
        group('logs', () {
          tearDownAll(() => resetMockitoState());
          test('normal', () async {
            final logs = <LogRecord>[];
            logger.onRecord.listen(logs.add);
            when(
              mockRunner.runCommand(
                command: anyNamed('command'),
                workingDirectory: anyNamed(
                  'workingDirectory',
                ),
              ),
            ).thenAnswer(
              (realInvocation) => Future.value(
                ProcessResult(999, 0, 'jar successful', ''),
              ),
            );

            when(mockedArgs.jarArgs)
                .thenAnswer((realInvocation) => realArguments.jarArgs);
            when(mockedArgs.isDebug).thenReturn(false);
            await OpenapiGenerator(runner: mockRunner, logger: logger)
                .runOpenApiJar(arguments: mockedArgs);
            expect(logs.length, 2);
            expect(
                logs[0].message,
                contains(
                    'Running following command to generate openapi client - [ ${(await realArguments.jarArgs).join(' ')} ]'));
            expect(logs[1].message.contains('jar successful'), isFalse);
            expect(logs[1].message,
                contains('Openapi generator completed successfully.'));
            for (final log in logs) {
              expect(log.level, Level.INFO);
            }
          });

          test('debug', () async {
            final logs = <LogRecord>[];
            logger.onRecord.listen(logs.add);
            when(
              mockRunner.runCommand(
                command: anyNamed('command'),
                workingDirectory: anyNamed(
                  'workingDirectory',
                ),
              ),
            ).thenAnswer(
              (realInvocation) => Future.value(
                ProcessResult(999, 0, 'jar successful', ''),
              ),
            );

            when(mockedArgs.jarArgs)
                .thenAnswer((realInvocation) => realArguments.jarArgs);
            when(mockedArgs.isDebug).thenReturn(true);
            await OpenapiGenerator(runner: mockRunner, logger: logger)
                .runOpenApiJar(arguments: mockedArgs);
            expect(logs.length, 2);
            expect(
                logs[0].message,
                contains(
                    'Running following command to generate openapi client - [ ${(await realArguments.jarArgs).join(' ')} ]'));
            expect(logs[1].message, contains('jar successful'));
            expect(logs[1].message,
                contains('Openapi generator completed successfully.'));
            for (final log in logs) {
              expect(log.level, Level.INFO);
            }
          });
        });
        test('returns successfully', () async {
          when(
            mockRunner.runCommand(
              command: anyNamed('command'),
              workingDirectory: anyNamed(
                'workingDirectory',
              ),
            ),
          ).thenAnswer(
            (realInvocation) => Future.value(
              ProcessResult(999, 0, 'completed successfully', ''),
            ),
          );
          try {
            await OpenapiGenerator(runner: mockRunner)
                .runOpenApiJar(arguments: realArguments);
          } catch (e, _) {
            fail('should have completed successfully.');
          }
        });
        test('returns an error when the jar command fails', () async {
          when(
            mockRunner.runCommand(
              command: anyNamed('command'),
              workingDirectory: anyNamed(
                'workingDirectory',
              ),
            ),
          ).thenAnswer(
            (realInvocation) => Future.value(
              ProcessResult(999, 1, '', 'something went wrong'),
            ),
          );

          try {
            await OpenapiGenerator(runner: mockRunner)
                .runOpenApiJar(arguments: realArguments);
            fail(
              'should have returned an error log.',
            );
          } catch (e, _) {
            expect(e, isA<OutputMessage>());
            e as OutputMessage;
            expect(e.level, Level.SEVERE);
            expect(e.message, 'Codegen Failed. Generator output:');
            expect(e.additionalContext, 'something went wrong');
            expect(e.stackTrace, isNotNull);
          }
        });
      });
    });
  });
}
