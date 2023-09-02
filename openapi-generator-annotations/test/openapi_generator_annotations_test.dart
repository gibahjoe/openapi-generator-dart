import 'dart:io';

import 'package:openapi_generator_annotations/src/openapi_generator_annotations_base.dart';
import 'package:test/test.dart';

import 'utils.dart';

void main() {
  group('OpenApi', () {
    test('defaults', () {
      final props = Openapi(
        inputSpecFile: InputSpec.empty().path,
        inputSpec: InputSpec.empty(),
        generatorName: Generator.dart,
      );
      expect(props.additionalProperties, isNull);
      expect(props.overwriteExistingFiles, isNull);
      expect(props.skipSpecValidation, false);
      expect(props.inputSpecFile, InputSpec.empty().path);
      expect(props.inputSpec!.path, InputSpec.empty().path);
      expect(props.templateDirectory, isNull);
      expect(props.generatorName, Generator.dart);
      expect(props.outputDirectory, isNull);
      expect(props.typeMappings, isNull);
      expect(props.importMappings, isNull);
      expect(props.reservedWordsMappings, isNull);
      expect(props.inlineSchemaNameMappings, isNull);
      expect(props.apiPackage, isNull);
      expect(props.fetchDependencies, true);
      expect(props.runSourceGenOnOutput, true);
      expect(props.alwaysRun, false);
      expect(props.cachePath, isNull);
      expect(props.useNextGen, false);
      expect(props.projectPubspecPath, isNull);
      expect(props.debugLogging, isFalse);
    });
    group('NextGen', () {
      test('Sets cachePath', () {
        final api = Openapi(
            inputSpecFile: InputSpec.empty().path,
            generatorName: Generator.dart,
            cachePath: 'somePath');
        expect(api.cachePath, 'somePath');
      });
      test('Sets useNextGenFlag', () {
        final api = Openapi(
            inputSpecFile: InputSpec.empty().path,
            generatorName: Generator.dart,
            useNextGen: true);
        expect(api.useNextGen, isTrue);
      });
      test('Sets projectPubspecPath', () {
        final api = Openapi(
            inputSpecFile: InputSpec.empty().path,
            generatorName: Generator.dart,
            projectPubspecPath: 'test');
        expect(api.projectPubspecPath, 'test');
      });
      test('Set debug logging', () {
        final api = Openapi(
            inputSpecFile: InputSpec.empty().path,
            inputSpec: InputSpec.empty(),
            generatorName: Generator.dart,
            debugLogging: true);
        expect(api.debugLogging, isTrue);
      });
      group('InputSpec', () {
        group('local spec', () {
          test('provides default yaml path', () {
            expect(InputSpec.empty().path, 'openapi.yaml');
            expect(InputSpec.empty().defaultYaml, isTrue);
            expect(InputSpec.empty().useYml, isFalse);
          });
          test('provides default yml path', () {
            expect(InputSpec.emptyYml().path, 'openapi.yml');
            expect(InputSpec.emptyYml().defaultYaml, isTrue);
            expect(InputSpec.emptyYml().useYml, isTrue);
          });
          test('provides default json path', () {
            expect(InputSpec.emptyJson().path, 'openapi.json');
            expect(InputSpec.emptyJson().defaultYaml, isFalse);
            expect(InputSpec.emptyJson().useYml, isFalse);
          });
          test('uses path', () {
            expect(InputSpec(path: 'path').path, 'path');
          });
        });
        group('Remote Spec', () {
          test('defaults', () {
            final remote = RemoteSpec.empty();
            expect(remote.path, 'http://localhost:8080/');
            expect(remote.headerDelegate, isA<RemoteSpecHeaderDelegate>());
          });
          test('uses path', () {
            final remote = RemoteSpec(path: 'https://example.com/path');
            expect(remote.path, 'https://example.com/path');
          });
          test('accepts a delegate', () {
            final remote = RemoteSpec(
                path: 'https://example.com/path',
                headerDelegate: AWSRemoteSpecHeaderDelegate(bucket: 'bucket'));
            expect(remote.headerDelegate, isA<AWSRemoteSpecHeaderDelegate>());
          });
          group('RemoteSpecHeaderDelegates', () {
            test('has empty headers', () {
              expect(RemoteSpecHeaderDelegate().header(), isNull);
            });
          });
          group('AWSRemoteSpecHeaderDelegate', () {
            final delegate = AWSRemoteSpecHeaderDelegate(
              bucket: 'bucket',
              accessKeyId: 'test',
              secretAccessKey: 'test',
            );

            test('signs the url correctly', () {
              final now = DateTime.now();
              final actual = delegate.authHeaderContent(
                  now: now,
                  bucket: 'bucket',
                  path: 'openapi.yaml',
                  accessKeyId: 'test',
                  secretAccessKey: 'test');
              expect(actual,
                  awsSign('test', 'test', 'bucket', 'openapi.yaml', now));
            });
            group('header throws when', () {
              final missingPathAssertion =
                  AssertionError('The path to the OAS spec should be provided');
              test('path is null', () {
                try {
                  delegate.header();
                } catch (e, _) {
                  expect(e, isA<AssertionError>());
                  expect(e.toString(), missingPathAssertion.toString());
                }
              });
              test('path is empty', () {
                try {
                  delegate.header(path: '');
                } catch (e, _) {
                  expect(e, isA<AssertionError>());
                  expect(e.toString(), missingPathAssertion.toString());
                }
              });
              test('creds are empty', () {
                final thrown = AssertionError(
                    'AWS_SECRET_KEY_ID & AWS_SECRET_ACCESS_KEY should be defined and not empty or they should be provided in the delegate constructor.');
                try {
                  final delegate = AWSRemoteSpecHeaderDelegate(
                      bucket: 'bucket', accessKeyId: '', secretAccessKey: '');
                  delegate.header(path: 'openapi.yaml');
                } catch (e, _) {
                  expect(e, isA<AssertionError>());
                  expect(e.toString(), thrown.toString());
                }
              });
            });
            test('generates headers when path is provided', () {
              try {
                final actualHeaders = delegate.header(path: 'openapi.yaml');
                expect(actualHeaders, isNotNull);

                expect(actualHeaders!['x-amz-date'], isNotNull);
                final dateTimeUsed =
                    DateTime.parse(actualHeaders['x-amz-date']!);
                final expectedAuthHeader = awsSign(
                    delegate.accessKeyId!,
                    delegate.secretAccessKey!,
                    delegate.bucket,
                    'openapi.yaml',
                    dateTimeUsed);
                expect(actualHeaders['Authorization'], expectedAuthHeader);
              } catch (e, _) {
                fail('should not fail when provided the required values');
              }
            });
            test('uses the provided environment', () async {
              final result = Process.runSync(
                'dart',
                [
                  'test',
                  'test/remote_spec_header_delegates/aws_delegate_with_env_test.dart'
                ],
                environment: {
                  'AWS_ACCESS_KEY_ID': 'test',
                  'AWS_SECRET_ACCESS_KEY': 'test'
                },
                workingDirectory: Directory.current.path,
              );
              if (result.exitCode != 0) {
                print(result.stderr);
                fail('Tests returned a non 0 exit code.');
              }
            });
          });
        });
      });
    });
  });
}
