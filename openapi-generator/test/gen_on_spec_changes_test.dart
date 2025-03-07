import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:logging/logging.dart';
import 'package:openapi_generator/src/gen_on_spec_changes.dart';
import 'package:openapi_generator/src/models/output_message.dart';
import 'package:openapi_generator_annotations/openapi_generator_annotations.dart';
import 'package:test/test.dart';
import 'package:yaml/yaml.dart';

final testDirPath =
    '${Directory.current.path}${Platform.pathSeparator}test${Platform.pathSeparator}specs';

final supportedExtensions = <String, String>{
  'json': '$testDirPath${Platform.pathSeparator}openapi.test.json',
  'yaml': '$testDirPath${Platform.pathSeparator}openapi.test.yaml',
  'yml': '$testDirPath${Platform.pathSeparator}openapi.test.yml'
};

void main() {
  final Map<String, dynamic> jsonSpecFile =
      jsonDecode(File(supportedExtensions['json']!).readAsStringSync());
  group('Generates on Spec changes', () {
    group('Load Spec', () {
      test('throws an error for unsupported files', () async {
        try {
          await loadSpec(
              specConfig: InputSpec(path: './thisIsSomeInvalidPath.wrong'));
          fail('Should\'ve thrown as not supported file type.');
        } catch (e, _) {
          expect((e as OutputMessage).message, 'Invalid spec file format.');
        }
      });

      test('fails when local file has unsupported extension', () async {
        final specFuture =
            loadSpec(specConfig: InputSpec(path: './invalid.spec'));
        await expectLater(
            specFuture,
            throwsA(isA<OutputMessage>().having((e) => e.message, 'message',
                contains('Invalid spec file format'))));
      });
      test('supports json remote spec without extension', () async {
        final url =
            Uri.parse('https://example.com/api'); // Mock remote spec URL
        final mockResponse = http.Response('{}', 200,
            headers: {'content-type': 'application/json'});

        // Mock HTTP HEAD request
        final client = MockClient((request) async => mockResponse);
        final specFuture = loadSpec(
            specConfig: RemoteSpec(path: url.toString()), client: client);
        await expectLater(specFuture, completion(isNot(throwsA(anything))));
      });
      test('supports remote yaml spec without extension', () async {
        final url =
            Uri.parse('https://example.com/api-yaml'); // Mock remote spec URL
        final mockResponse = http.Response('key: value', 200,
            headers: {'content-type': 'application/x-yaml'});

        // Mock HTTP HEAD request
        final client = MockClient((request) async => mockResponse);
        final specFuture = loadSpec(
            specConfig: RemoteSpec(path: url.toString()), client: client);

        await expectLater(specFuture, completion(isNot(throwsA(anything))));
      });
      test('throws an error for missing config file', () async {
        try {
          await loadSpec(
              specConfig: InputSpec(path: './thisIsSomeInvalidPath.yaml'));
          fail('Should\'ve thrown as not supported file type.');
        } catch (e, _) {
          expect((e as OutputMessage).message,
              'Unable to find spec file ./thisIsSomeInvalidPath.yaml');
        }
      });
      test('returns empty map when cache isn\'t found', () async {
        try {
          final cached = await loadSpec(
              specConfig: InputSpec(path: './nonValidCacheSpecPath.yaml'),
              isCached: true);
          expect(cached, isEmpty);
        } catch (e, _) {
          fail(
              'Should return empty map when spec path is cached spec but not found');
        }
      });
      group('returns a map', () {
        test('json', () async {
          try {
            final mapped = await loadSpec(
                specConfig: InputSpec(path: supportedExtensions['json']!));
            expect(mapped, jsonSpecFile);
          } catch (e, _) {
            print(e);
            fail('should have successfully loaded json spec');
          }
        });
        test('yaml (requires transformation)', () async {
          try {
            final loaded = await loadSpec(
                specConfig: InputSpec(path: supportedExtensions['yaml']!));
            expect(loaded, jsonSpecFile);
          } catch (_, __) {
            fail('Should successfully convert yaml to Map');
          }
        });
        test('yml (requires transformation)', () async {
          try {
            final loaded = await loadSpec(
                specConfig: InputSpec(path: supportedExtensions['yml']!));
            expect(loaded, jsonSpecFile);
          } catch (_, __) {
            fail('Should successfully convert yml to Map');
          }
        });
      });
      group('from remote', () {
        test('successfully returns the spec', () async {
          try {
            final url = Uri.parse(
                'https://raw.githubusercontent.com/Nexushunter/tagmine-api/main/openapi.yaml');
            final resp = await http.get(url);
            final expected =
                convertYamlMapToDartMap(yamlMap: loadYaml(resp.body));
            final spec =
                await loadSpec(specConfig: RemoteSpec(path: url.toString()));
            expect(spec, expected);
          } catch (e, _) {
            fail('Should load remote files successfully');
          }
        });
        // TODO: Add other status codes when? This will mostly impact values
        //  behind authenticated endpoints, which need a custom auth header.
        test('fails when spec is inaccessible', () async {
          try {
            final url = Uri.parse(
                'https://raw.githubusercontent.com/Nexushunter/tagmine-api/main/openapi.yml');
            await loadSpec(specConfig: RemoteSpec(path: url.toString()));
            fail('Should fail when remote files can\'t be found');
          } catch (e, _) {
            final errorMessage = e as OutputMessage;
            expect(errorMessage.level, Level.SEVERE);
            expect(errorMessage.additionalContext, 404);
            expect(errorMessage.message,
                'Unable to request remote spec. Ensure it is public or use a local copy instead.');
          }
        });

        test('fails when HEAD request returns non-200 status', () async {
          final url = Uri.parse('https://example.com/api-invalid');
          final mockResponse = http.Response('', 404);
          final client = MockClient((request) async => mockResponse);
          final specFuture = loadSpec(
              specConfig: RemoteSpec(path: url.toString()), client: client);
          await expectLater(
              specFuture,
              throwsA(isA<OutputMessage>().having((e) => e.message, 'message',
                  contains('Failed to fetch headers'))));
        });

        test('fails when Content-Type is missing', () async {
          final url = Uri.parse('https://example.com/api-no-content-type');
          final mockResponse = http.Response('', 200, headers: {});
          final client = MockClient((request) async => mockResponse);
          final specFuture = loadSpec(
              specConfig: RemoteSpec(path: url.toString()), client: client);
          await expectLater(
              specFuture,
              throwsA(isA<OutputMessage>().having((e) => e.message, 'message',
                  contains('Invalid remote spec file format'))));
        });

        test('fails when Content-Type is not JSON or YAML', () async {
          final url = Uri.parse('https://example.com/api-invalid-type');
          final mockResponse =
              http.Response('', 200, headers: {'content-type': 'text/plain'});
          final client = MockClient((request) async => mockResponse);
          final specFuture = loadSpec(
              specConfig: RemoteSpec(path: url.toString()), client: client);
          await expectLater(
              specFuture,
              throwsA(isA<OutputMessage>().having((e) => e.message, 'message',
                  contains('Invalid remote spec file format'))));
        });
      });
    });
    group('verifies dirty status', () {
      test('is true when the cached spec is empty', () {
        expect(isSpecDirty(cachedSpec: {}, loadedSpec: {'key1': '2'}), isTrue);
      });
      test(
          'is false when the cached spec is empty and loaded spec is also empty',
          () {
        expect(isSpecDirty(cachedSpec: {}, loadedSpec: {}), isFalse);
      });
      test('returns false when specs match', () async {
        final loaded = await loadSpec(
            specConfig: InputSpec(path: supportedExtensions['json']!));
        expect(
            isSpecDirty(cachedSpec: jsonSpecFile, loadedSpec: loaded), isFalse);
      });
      test('returns true when a key is renamed', () {
        expect(
            isSpecDirty(cachedSpec: {
              'rootKey': {'subKey': 'k'}
            }, loadedSpec: {
              'rootKey': {'renamedSubKey': 'k'}
            }),
            isTrue);
      });
      test('returns true when root/sub keys differ in length', () {
        expect(
            isSpecDirty(
                cachedSpec: {'someKey': 1},
                loadedSpec: {'someKey': 1, 'someExtraKey': 'content'}),
            isTrue);

        expect(
            isSpecDirty(cachedSpec: {
              'someExtraKey': {'subKey': 'k', 'subKey1': 4}
            }, loadedSpec: {
              'someExtraKey': {'subKey': 'k'}
            }),
            isTrue);
      });
      group('when sub entry', () {
        group('list', () {
          test('entries change', () {
            expect(
                isSpecDirty(cachedSpec: {
                  'thisIsAList': [1, 2, 4]
                }, loadedSpec: {
                  'thisIsAList': [1, 2, 3]
                }),
                isTrue);
          });
          test('lengths change', () {
            expect(
                isSpecDirty(cachedSpec: {
                  'thisIsAList': [1, 2, 4]
                }, loadedSpec: {
                  'thisIsAList': [1, 2, 3, 4]
                }),
                isTrue);
          });
          test('entries changes order', () {
            expect(
                isSpecDirty(cachedSpec: {
                  'thisIsAList': [2, 1, 5]
                }, loadedSpec: {
                  'thisIsAList': [1, 2, 5]
                }),
                isTrue);
          });
        });
        group('scalar', () {
          test('value changed', () {
            expect(
                isSpecDirty(
                    cachedSpec: {'scalar': 5}, loadedSpec: {'scalar': 12}),
                isTrue);
          });
          test('type changed', () {
            expect(
                isSpecDirty(
                    cachedSpec: {'scalar': 5}, loadedSpec: {'scalar': '12'}),
                isTrue);
          });
        });
      });
    });
    group('transforms yaml to dart map', () {
      test('converts scalars', () {
        expect(convertYamlMapToDartMap(yamlMap: YamlMap.wrap({'scalar': 5})),
            {'scalar': 5});
      });
      group('converts lists', () {
        test('with YamlMaps', () {
          final listContent = [
            1,
            2,
            3,
            4,
            YamlMap.wrap(<String, dynamic>{'entry': 'value'})
          ];
          final listContentExpected = [
            1,
            2,
            3,
            4,
            <String, dynamic>{'entry': 'value'}
          ];
          expect(
              convertYamlListToDartList(yamlList: YamlList.wrap(listContent)),
              listContentExpected);
        });
        test('with nested lists', () {
          final listContent = [
            1,
            2,
            3,
            4,
            YamlList.wrap(
              ['one', 'two', 'three'],
            )
          ];
          final listContentExpected = [
            1,
            2,
            3,
            4,
            ['one', 'two', 'three'],
          ];
          expect(
              convertYamlListToDartList(yamlList: YamlList.wrap(listContent)),
              listContentExpected);
        });
      });
      test('converts submap to map', () {
        final expectedMap = <String, dynamic>{
          'mapWithSubMap': {
            'subMap': {'scalar': 5, 'meh': 'value'},
          }
        };
        expect(
            convertYamlMapToDartMap(
                yamlMap: YamlMap.wrap({
              'mapWithSubMap': YamlMap.wrap(expectedMap['mapWithSubMap'])
            })),
            expectedMap);
      });
    });
    test('cache diff', () async {
      try {
        final path = '$testDirPath${Platform.pathSeparator}test-cached.json';
        await cacheSpec(outputLocation: path, spec: jsonSpecFile);
        expect(File(path).existsSync(), isTrue);
        // Test the rerun succeeds too
        await cacheSpec(outputLocation: path, spec: jsonSpecFile);
        expect(File(path).existsSync(), isTrue);
      } catch (e, _) {
        fail('should\'ve successfully cached diff');
      }
    });
  });
}
