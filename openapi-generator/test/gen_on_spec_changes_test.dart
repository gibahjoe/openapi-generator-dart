import 'dart:convert';
import 'dart:io';

import 'package:openapi_generator/src/gen_on_spec_changes.dart';
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
          await loadSpec(specPath: './thisIsSomeInvalidPath.wrong');
          fail('Should\'ve thrown as not supported file type.');
        } catch (e, st) {
          expect(e as String, 'Invalid spec file format');
        }
      });
      test('throws an error for missing config file', () async {
        try {
          await loadSpec(specPath: './thisIsSomeInvalidPath.yaml');
          fail('Should\'ve thrown as not supported file type.');
        } catch (e, st) {
          expect(e as String,
              'Unable to find spec file ./thisIsSomeInvalidPath.yaml');
        }
      });
      test('returns empty map when cache isn\'t found', () async {
        try {
          final cached = await loadSpec(
              specPath: './nonValidCacheSpecPath.yaml', isCached: true);
          expect(cached, isEmpty);
        } catch (e, st) {
          fail(
              'Should return empty map when spec path is cached spec but not found');
        }
      });
      group('returns a map', () {
        test('json', () async {
          try {
            final mapped =
                await loadSpec(specPath: supportedExtensions['json']!);
            expect(mapped, jsonSpecFile);
          } catch (e, st) {
            print(e);
            fail('should have successfully loaded json spec');
          }
        });
        test('yaml (requires transformation)', () async {
          try {
            final loaded =
                await loadSpec(specPath: supportedExtensions['yaml']!);
            expect(loaded, jsonSpecFile);
          } catch (_, __) {
            fail('Should successfully convert yaml to Map');
          }
        });
        test('yml (requires transformation)', () async {
          try {
            final loaded =
                await loadSpec(specPath: supportedExtensions['yml']!);
            expect(loaded, jsonSpecFile);
          } catch (_, __) {
            fail('Should successfully convert yml to Map');
          }
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
        final loaded = await loadSpec(specPath: supportedExtensions['json']!);
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
              ["one", "two", "three"],
            )
          ];
          final listContentExpected = [
            1,
            2,
            3,
            4,
            ["one", "two", "three"],
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
      } catch (e, st) {
        fail('should\'ve successfully cached diff');
      }
    });
  });
}
