import 'dart:io';

import 'package:analyzer/dart/analysis/session.dart';
import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/dart/element/type.dart';
import 'package:analyzer/src/generated/engine.dart';
import 'package:analyzer/src/generated/source.dart';
import 'package:build_test/build_test.dart';
import 'package:logging/logging.dart';
import 'package:mockito/mockito.dart';
import 'package:openapi_generator/src/models/generator_arguments.dart';
import 'package:openapi_generator/src/models/output_message.dart';
import 'package:openapi_generator/src/openapi_generator_runner.dart';
import 'package:pub_semver/src/version.dart';
import 'package:source_gen/source_gen.dart';
import 'package:test/test.dart';

import 'mocks.mocks.dart';
import 'utils.dart';

void main() {
  group('OpenApiGenerator', () {
    group('NextGen', () {
      late MockConstantReader mockedAnnotations;
      late ConstantReader defaultAnnotations;
      late MockOpenapiGenerator generator;
      late GeneratorArguments realArguments;
      setUpAll(() async {
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
        generator = MockOpenapiGenerator();
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

      group('runOpenApiJar', () {
        test('returns an error when the jar command fails', () async {
          when(
            generator.runExternalProcess(
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
            await generator.runOpenApiJar(arguments: realArguments);
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
