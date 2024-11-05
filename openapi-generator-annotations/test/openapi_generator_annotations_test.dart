import 'dart:io';

import 'package:openapi_generator_annotations/src/openapi_generator_annotations_base.dart';
import 'package:test/test.dart';

import 'utils.dart';

void main() {
  group('OpenApi', () {
    test('defaults', () {
      final props = Openapi(
        inputSpec: InputSpec.json(),
        generatorName: Generator.dart,
      );
      expect(props.additionalProperties, isNull);
      expect(props.skipSpecValidation, isFalse);
      expect(props.inputSpec.path, InputSpec.json().path);
      expect(props.templateDirectory, isNull);
      expect(props.generatorName, Generator.dart);
      expect(props.outputDirectory, isNull);
      expect(props.typeMappings, isNull);
      expect(props.importMappings, isNull);
      expect(props.reservedWordsMappings, isNull);
      expect(props.inlineSchemaNameMappings, isNull);
      expect(props.apiPackage, isNull);
      expect(props.fetchDependencies, isTrue);
      expect(props.runSourceGenOnOutput, isTrue);
      expect(props.cachePath, isNull);
      expect(props.projectPubspecPath, isNull);
      expect(props.debugLogging, isFalse);
      expect(props.nameMappings, isNull);
      expect(props.skipIfSpecIsUnchanged, isTrue);
    });
    group('NextGen', () {
      test('Sets cachePath', () {
        final api = Openapi(
            inputSpec: InputSpec.json(),
            generatorName: Generator.dart,
            cachePath: 'somePath');
        expect(api.cachePath, 'somePath');
      });
      test('Sets projectPubspecPath', () {
        final api = Openapi(
            inputSpec: InputSpec.json(),
            generatorName: Generator.dart,
            projectPubspecPath: 'test');
        expect(api.projectPubspecPath, 'test');
      });
      test('Set debug logging', () {
        final api = Openapi(
            inputSpec: InputSpec.json(),
            generatorName: Generator.dart,
            debugLogging: true);
        expect(api.debugLogging, isTrue);
      });
      test('Sets forceAlwaysRun', () {
        final api = Openapi(
            inputSpec: InputSpec.json(),
            generatorName: Generator.dart,
            forceAlwaysRun: false);
        expect(api.forceAlwaysRun, isFalse);
      });
      group('InputSpec', () {
        group('local spec', () {
          test('provides default yaml path', () {
            expect(InputSpec.yaml().path, 'openapi.yaml');
            expect(InputSpec.yaml(shortExtension: true).path, 'openapi.yml');
          });
          test('provides default yml path', () {
            expect(InputSpec.yaml(shortExtension: true).path, 'openapi.yml');
            expect(InputSpec.yaml(shortExtension: false).path, 'openapi.yaml');
          });
          test('provides default json path', () {
            expect(InputSpec.json().path, 'openapi.json');
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
