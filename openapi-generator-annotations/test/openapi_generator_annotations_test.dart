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
      expect(props.enumNameMappings, isNull);
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
    group(
      'Stringify ',
      () {
        group('Openapi.toString', () {
          test('should include additionalProperties when set', () {
            final openapi = Openapi(
              additionalProperties: AdditionalProperties(pubName: 'test'),
              inputSpec: InputSpec(path: 'example_path'),
              generatorName: Generator.dart,
            );
            expect(openapi.toString(),
                contains('additionalProperties: AdditionalProperties'));
          });

          test('should include apiPackage when set', () {
            final openapi = Openapi(
              apiPackage: 'lib.api',
              inputSpec: InputSpec(path: 'example_path'),
              generatorName: Generator.dart,
            );
            expect(openapi.toString(), contains('apiPackage: "lib.api"'));
          });

          test('should include inputSpec when set', () {
            final openapi = Openapi(
              inputSpec: InputSpec(path: 'example_path'),
              generatorName: Generator.dart,
            );
            expect(openapi.toString().replaceAll('\n', ''),
                contains('inputSpec: InputSpec(  path: "example_path")'));
          });

          test('should include templateDirectory when set', () {
            final openapi = Openapi(
              templateDirectory: 'templates',
              inputSpec: InputSpec(path: 'example_path'),
              generatorName: Generator.dart,
            );
            expect(
                openapi.toString(), contains('templateDirectory: "templates"'));
          });

          test('should include generatorName when set', () {
            final openapi = Openapi(
              generatorName: Generator.dart,
              inputSpec: InputSpec(path: 'example_path'),
            );
            expect(
                openapi.toString(), contains('generatorName: Generator.dart'));
          });

          test('should include outputDirectory when set', () {
            final openapi = Openapi(
              outputDirectory: 'output',
              inputSpec: InputSpec(path: 'example_path'),
              generatorName: Generator.dart,
            );
            expect(openapi.toString(), contains('outputDirectory: "output"'));
          });

          test('should include cleanSubOutputDirectory when set', () {
            final openapi = Openapi(
              cleanSubOutputDirectory: ['lib/src'],
              inputSpec: InputSpec(path: 'example_path'),
              generatorName: Generator.dart,
            );
            expect(openapi.toString(),
                contains('cleanSubOutputDirectory: [lib/src]'));
          });

          test('should include skipSpecValidation when set', () {
            final openapi = Openapi(
              skipSpecValidation: true,
              inputSpec: InputSpec(path: 'example_path'),
              generatorName: Generator.dart,
            );
            expect(openapi.toString(), contains('skipSpecValidation: true'));
          });

          test('should include reservedWordsMappings when set', () {
            final openapi = Openapi(
              reservedWordsMappings: {'reserved': 'mapped'},
              inputSpec: InputSpec(path: 'example_path'),
              generatorName: Generator.dart,
            );
            expect(openapi.toString(),
                contains('reservedWordsMappings: {reserved: mapped}'));
          });

          test('should include fetchDependencies when set', () {
            final openapi = Openapi(
              fetchDependencies: true,
              inputSpec: InputSpec(path: 'example_path'),
              generatorName: Generator.dart,
            );
            expect(openapi.toString(), contains('fetchDependencies: true'));
          });

          test('should include runSourceGenOnOutput when set', () {
            final openapi = Openapi(
              runSourceGenOnOutput: true,
              inputSpec: InputSpec(path: 'example_path'),
              generatorName: Generator.dart,
            );
            expect(openapi.toString(), contains('runSourceGenOnOutput: true'));
          });

          test('should include typeMappings when set', () {
            final openapi = Openapi(
              typeMappings: {"String": "MyString"},
              inputSpec: InputSpec(path: 'example_path'),
              generatorName: Generator.dart,
            );
            expect(openapi.toString().replaceAll('\n', ''),
                contains('typeMappings: {\'String\':\'MyString\'}'));
          });

          test('should include nameMappings when set', () {
            final openapi = Openapi(
              nameMappings: {'name': 'customName'},
              inputSpec: InputSpec(path: 'example_path'),
              generatorName: Generator.dart,
            );
            expect(openapi.toString().replaceAll('\n', ''),
                contains('nameMappings: {\'name\':\'customName\'}'));
          });

          test('should include enumNameMappings when set', () {
            final openapi = Openapi(
              enumNameMappings: {'name': 'customName'},
              inputSpec: InputSpec(path: 'example_path'),
              generatorName: Generator.dart,
            );
            expect(openapi.toString().replaceAll('\n', ''),
                contains('enumNameMappings: {\'name\':\'customName\'}'));
          });

          test('should include importMappings when set', () {
            final openapi = Openapi(
              importMappings: {
                'OffsetDate': 'package:time_machine/time_machine.dart'
              },
              inputSpec: InputSpec(path: 'example_path'),
              generatorName: Generator.dart,
            );
            expect(
                openapi.toString().replaceAll('\n', ''),
                contains(
                    "importMappings: {'OffsetDate':'package:time_machine/time_machine.dart'}"));
          });

          test('should include inlineSchemaNameMappings when set', () {
            final openapi = Openapi(
              inlineSchemaNameMappings: {'inline_object_2': 'MappedObject'},
              inputSpec: InputSpec(path: 'example_path'),
              generatorName: Generator.dart,
            );
            expect(
                openapi.toString().removeln(),
                contains(
                    "inlineSchemaNameMappings: {'inline_object_2':'MappedObject'}"));
          });

          test('should include cachePath when set', () {
            final openapi = Openapi(
              cachePath: '.dart_tool/spec/specA.json',
              inputSpec: InputSpec(path: 'example_path'),
              generatorName: Generator.dart,
            );
            expect(openapi.toString(),
                contains('cachePath: ".dart_tool/spec/specA.json"'));
          });

          test('should include projectPubspecPath when set', () {
            final openapi = Openapi(
              projectPubspecPath: 'pubspec.yaml',
              inputSpec: InputSpec(path: 'example_path'),
              generatorName: Generator.dart,
            );
            expect(openapi.toString(),
                contains('projectPubspecPath: "pubspec.yaml"'));
          });

          test('should include debugLogging when set', () {
            final openapi = Openapi(
              debugLogging: true,
              inputSpec: InputSpec(path: 'example_path'),
              generatorName: Generator.dart,
            );
            expect(openapi.toString(), contains('debugLogging: true'));
          });

          test('should include forceAlwaysRun when set', () {
            final openapi = Openapi(
              forceAlwaysRun: true,
              inputSpec: InputSpec(path: 'example_path'),
              generatorName: Generator.dart,
            );
            expect(openapi.toString(), contains('forceAlwaysRun: true'));
          });

          test('should include skipIfSpecIsUnchanged when set', () {
            final openapi = Openapi(
              skipIfSpecIsUnchanged: true,
              inputSpec: InputSpec(path: 'example_path'),
              generatorName: Generator.dart,
            );
            expect(openapi.toString(), contains('skipIfSpecIsUnchanged: true'));
          });
        });

        group('InputSpec.toString', () {
          test('should include path when set', () {
            final inputSpec = InputSpec(path: 'openapi.json');
            expect(inputSpec.toString(), contains('path: "openapi.json"'));
          });
        });

        group('RemoteSpec.toString', () {
          test('should include path when set', () {
            final remoteSpec = RemoteSpec(path: 'http://localhost:8080/');
            expect(remoteSpec.toString(),
                contains('path: "http://localhost:8080/"'));
          });

          test('should include headerDelegate when set', () {
            final remoteSpec = RemoteSpec(
              path: 'http://localhost:8080/',
              headerDelegate: RemoteSpecHeaderDelegate(),
            );
            expect(remoteSpec.toString(),
                contains('headerDelegate: RemoteSpecHeaderDelegate()'));
          });
        });

        // group('AWSRemoteSpecHeaderDelegate.toString', () {
        //   test('should include bucket when set', () {
        //     final awsHeaderDelegate =
        //         AWSRemoteSpecHeaderDelegate(bucket: 'my_bucket');
        //     expect(
        //         awsHeaderDelegate.toString().removeln(), contains('bucket: "my_bucket"'));
        //   });
        //
        //   test('should include accessKeyId when set', () {
        //     final awsHeaderDelegate = AWSRemoteSpecHeaderDelegate(
        //         bucket: 'my_bucket', accessKeyId: 'my_access_key');
        //     expect(awsHeaderDelegate.toString(),
        //         contains('accessKeyId: "my_access_key"'));
        //   });
        //
        //   test('should include secretAccessKey when set', () {
        //     final awsHeaderDelegate = AWSRemoteSpecHeaderDelegate(
        //         bucket: 'my_bucket', secretAccessKey: 'my_secret_key');
        //     expect(awsHeaderDelegate.toString(),
        //         contains('secretAccessKey: "my_secret_key"'));
        //   });
        // });
        group('AdditionalProperties.toString', () {
          test('should include allowUnicodeIdentifiers when set', () {
            final additionalProperties =
                AdditionalProperties(allowUnicodeIdentifiers: true);
            expect(additionalProperties.toString(),
                contains('allowUnicodeIdentifiers: true'));
          });

          test('should include ensureUniqueParams when set', () {
            final additionalProperties =
                AdditionalProperties(ensureUniqueParams: false);
            expect(additionalProperties.toString(),
                contains('ensureUniqueParams: false'));
          });

          test('should include prependFormOrBodyParameters when set', () {
            final additionalProperties =
                AdditionalProperties(prependFormOrBodyParameters: true);
            expect(additionalProperties.toString(),
                contains('prependFormOrBodyParameters: true'));
          });

          test('should include pubAuthor when set', () {
            final additionalProperties =
                AdditionalProperties(pubAuthor: 'Author Name');
            expect(additionalProperties.toString(),
                contains('pubAuthor: "Author Name"'));
          });

          test('should include pubAuthorEmail when set', () {
            final additionalProperties =
                AdditionalProperties(pubAuthorEmail: 'author@example.com');
            expect(additionalProperties.toString(),
                contains('pubAuthorEmail: "author@example.com"'));
          });

          test('should include pubDescription when set', () {
            final additionalProperties =
                AdditionalProperties(pubDescription: 'Sample description');
            expect(additionalProperties.toString(),
                contains('pubDescription: "Sample description"'));
          });

          test('should include pubHomepage when set', () {
            final additionalProperties =
                AdditionalProperties(pubHomepage: 'https://example.com');
            expect(additionalProperties.toString(),
                contains('pubHomepage: "https://example.com"'));
          });

          test('should include pubName when set', () {
            final additionalProperties =
                AdditionalProperties(pubName: 'ExampleName');
            expect(additionalProperties.toString(),
                contains('pubName: "ExampleName"'));
          });

          test('should include pubVersion when set', () {
            final additionalProperties =
                AdditionalProperties(pubVersion: '1.0.0');
            expect(additionalProperties.toString(),
                contains('pubVersion: "1.0.0"'));
          });

          test('should include sortModelPropertiesByRequiredFlag when set', () {
            final additionalProperties =
                AdditionalProperties(sortModelPropertiesByRequiredFlag: false);
            expect(additionalProperties.toString(),
                contains('sortModelPropertiesByRequiredFlag: false'));
          });

          test('should include sortParamsByRequiredFlag when set', () {
            final additionalProperties =
                AdditionalProperties(sortParamsByRequiredFlag: false);
            expect(additionalProperties.toString(),
                contains('sortParamsByRequiredFlag: false'));
          });

          test('should include sourceFolder when set', () {
            final additionalProperties =
                AdditionalProperties(sourceFolder: 'src');
            expect(additionalProperties.toString(),
                contains('sourceFolder: "src"'));
          });

          test('should include useEnumExtension when set', () {
            final additionalProperties =
                AdditionalProperties(useEnumExtension: true);
            expect(additionalProperties.toString(),
                contains('useEnumExtension: true'));
          });

          test('should include enumUnknownDefaultCase when set', () {
            final additionalProperties =
                AdditionalProperties(enumUnknownDefaultCase: true);
            expect(additionalProperties.toString(),
                contains('enumUnknownDefaultCase: true'));
          });

          test('should include wrapper when set', () {
            final additionalProperties =
                AdditionalProperties(wrapper: Wrapper.fvm);
            expect(additionalProperties.toString(),
                contains('wrapper: Wrapper.fvm'));
          });

          test('should include legacyDiscriminatorBehavior when set', () {
            final additionalProperties =
                AdditionalProperties(legacyDiscriminatorBehavior: false);
            expect(additionalProperties.toString(),
                contains('legacyDiscriminatorBehavior: false'));
          });
        });

        group('DioProperties.toString', () {
          test('should include dateLibrary when set', () {
            final dioProperties =
                DioProperties(dateLibrary: DioDateLibrary.timemachine);
            expect(dioProperties.toString(),
                contains('dateLibrary: DioDateLibrary.timemachine'));
          });

          test('should include nullableFields when set', () {
            final dioProperties = DioProperties(nullableFields: true);
            expect(dioProperties.toString(), contains('nullableFields: true'));
          });

          test('should include serializationLibrary when set', () {
            final dioProperties = DioProperties(
                serializationLibrary: DioSerializationLibrary.jsonSerializable);
            expect(
                dioProperties.toString(),
                contains(
                    'serializationLibrary: DioSerializationLibrary.jsonSerializable'));
          });

          test('should include inherited allowUnicodeIdentifiers when set', () {
            final dioProperties = DioProperties(allowUnicodeIdentifiers: true);
            expect(dioProperties.toString(),
                contains('allowUnicodeIdentifiers: true'));
          });

          test('should include inherited pubAuthor when set', () {
            final dioProperties = DioProperties(pubAuthor: 'Author Name');
            expect(
                dioProperties.toString(), contains('pubAuthor: "Author Name"'));
          });

          // Add more inherited fields from AdditionalProperties here as needed
        });

        group('DioAltProperties.toString', () {
          test('should include listAnyOf when set', () {
            final dioAltProperties = DioAltProperties(listAnyOf: true);
            expect(dioAltProperties.toString(), contains('listAnyOf: true'));
          });

          test('should include pubspecDependencies when set', () {
            final dioAltProperties =
                DioAltProperties(pubspecDependencies: 'example_dependency');
            expect(dioAltProperties.toString(),
                contains('pubspecDependencies: "example_dependency"'));
          });

          test('should include pubspecDevDependencies when set', () {
            final dioAltProperties = DioAltProperties(
                pubspecDevDependencies: 'example_dev_dependency');
            expect(dioAltProperties.toString(),
                contains('pubspecDevDependencies: "example_dev_dependency"'));
          });

          test('should include inherited allowUnicodeIdentifiers when set', () {
            final dioAltProperties =
                DioAltProperties(allowUnicodeIdentifiers: true);
            expect(dioAltProperties.toString(),
                contains('allowUnicodeIdentifiers: true'));
          });

          test('should include inherited pubAuthor when set', () {
            final dioAltProperties = DioAltProperties(pubAuthor: 'Author Name');
            expect(dioAltProperties.toString(),
                contains('pubAuthor: "Author Name"'));
          });
        });
      },
    );
  });
}

extension StringExtension on String {
  String removeln() {
    return this.replaceAll('\n', '');
  }
}
