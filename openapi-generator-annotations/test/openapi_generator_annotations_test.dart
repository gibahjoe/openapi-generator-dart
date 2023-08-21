import 'dart:convert';
import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:openapi_generator_annotations/src/openapi_generator_annotations_base.dart';
import 'package:test/test.dart';

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
          });
          test('provides default json path', () {
            expect(InputSpec.emptyJson().path, 'openapi.json');
            expect(InputSpec.emptyJson().defaultYaml, isFalse);
          });
          test('uses path', () {
            expect(InputSpec(path: 'path').path, 'path');
          });
        });
        group('Remote Spec', () {
          group('AWS', () {
            group('defaults', () {
              final remoteSpec = AwsRemoteSpec(
                region: 'region',
                bucket: 'bucket',
                path: 'path',
              );
              test('has set values', () {
                expect(remoteSpec.bucket, 'bucket');
                expect(remoteSpec.region, 'region');
                expect(remoteSpec.path, 'path');
                expect(remoteSpec.accessKeyId, isNull);
                expect(remoteSpec.secretAccessKey, isNull);
              });
              test('returns empty auth headers when access keys are null', () {
                expect(remoteSpec.authHeaderContent, isEmpty);
              });
              test(
                  'toHeaderMap returns empty when unable to use or find access keys',
                  () {
                expect(remoteSpec.toHeaderMap(), isEmpty);
              });
              // TODO: Find a way to cleanly update environment variables.
              //  Isolate.spawnUri looks like a possible solution but I'm not sure
              //  how to use it.
              test('loadsCredentials', () {
                final remoteSpec = AwsRemoteSpec(
                  region: 'region',
                  bucket: 'bucket',
                  path: 'path',
                );
                expect(remoteSpec.accessKeyId, isNull);
                expect(remoteSpec.secretAccessKey, isNull);
                final map = <String, String>{};
                map['AWS_ACCESS_KEY_ID'] = 'test';
                map['AWS_SECRET_ACCESS_KEY'] = 'test';
                Platform.environment.addAll(map);

                Platform.environment.remove(map);
                expect(remoteSpec.accessKeyId, 'test');
                expect(remoteSpec.secretAccessKey, 'test');
              }, skip: true);
              test('toHeaderMapLoadsCredentials', () {
                final remoteSpec = AwsRemoteSpec(
                  region: 'region',
                  bucket: 'bucket',
                  path: 'path',
                );
                expect(remoteSpec.accessKeyId, isNull);
                expect(remoteSpec.secretAccessKey, isNull);
                Platform.environment['AWS_ACCESS_KEY_ID'] = 'test';
                Platform.environment['AWS_SECRET_ACCESS_KEY'] = 'test';
                final originalNow = remoteSpec.now;
                final map = remoteSpec.toHeaderMap();
                final newNow = remoteSpec.now;
                Platform.environment.remove('AWS_ACCESS_KEY_ID');
                Platform.environment.remove('AWS_SECRET_ACCESS_KEY');
                expect(map['Authorization'], isNotNull);
                expect(map['x-amz-date'], isNotNull);
                expect(originalNow != newNow, isTrue);
              }, skip: true);
            });
            group('with set access keys', () {
              final remoteSpec = AwsRemoteSpec(
                accessKeyId: 'test',
                secretAccessKey: 'test',
                region: 'region',
                bucket: 'bucket',
                path: 'path',
                now: DateTime.now(),
              );
              test('builds auth header', () {
                String toSign = [
                  'GET',
                  '',
                  '',
                  remoteSpec.now,
                  '/bucket/path',
                ].join('\n');

                final utf8AKey = utf8.encode('test');
                final utf8ToSign = utf8.encode(toSign);

                final signature = base64Encode(
                    Hmac(sha1, utf8AKey).convert(utf8ToSign).bytes);

                expect(remoteSpec.authHeaderContent, 'AWS test:$signature');
              });
              test('builds header map', () {
                final map = remoteSpec.toHeaderMap();
                expect(map['Authorization'], remoteSpec.authHeaderContent);
                expect(map['x-amz-date'], remoteSpec.now!.toIso8601String());
              });
            });
          });
          group('Other', () {
            test('uses path', () {
              final remote = RemoteSpec(path: 'https://example.com/path');
              expect(remote.path, 'https://example.com/path');
              expect(remote.authHeaderContent, isNull);
              expect(remote.toHeaderMap(), isEmpty);
            });
            test('provides non-empty head map when authHeaderContent is set',
                () {
              final remote = RemoteSpec(
                  path: 'https://example.com/path',
                  authHeaderContent: 'superSecretValue');
              expect(remote.path, 'https://example.com/path');
              expect(remote.authHeaderContent, 'superSecretValue');
              expect(remote.toHeaderMap(),
                  {'Authorization': 'Bearer superSecretValue'});
            });
            test('empty uses localhost', () {
              final remote = RemoteSpec.empty();
              expect(remote.path, 'http://localhost:8080');
            });
          });
        });
      });
    });
  });
}
