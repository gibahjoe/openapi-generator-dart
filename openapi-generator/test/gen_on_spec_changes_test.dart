import 'dart:convert';
import 'dart:io';

import 'package:openapi_generator/src/gen_on_spec_changes.dart';
import 'package:test/test.dart';
import 'package:yaml/yaml.dart';

final testDirPath = '${Directory.current.path}${Platform.pathSeparator}test';

final supportedExtensions = <String, String>{
  'json':
      '$testDirPath${Platform.pathSeparator}specs${Platform.pathSeparator}openapi.test.json',
  'yaml':
      '$testDirPath${Platform.pathSeparator}specs${Platform.pathSeparator}openapi.test.yaml',
  'yml':
      '$testDirPath${Platform.pathSeparator}specs${Platform.pathSeparator}openapi.test.yml'
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
          expect(e as String, 'Invalid spec format');
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
      });
    });
    group('verifies dirty status', () {
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
                cachedSpec: {}, loadedSpec: {'someExtraKey': 'content'}),
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
      test('returns a map from yaml', () async {
        expect(await loadSpec(specPath: supportedExtensions['yaml']!),
            jsonSpecFile);
      });
      test('returns a map from yml', () async {
        expect(await loadSpec(specPath: supportedExtensions['yml']!),
            jsonSpecFile);
      });
      test('converts scalars', () {
        expect(convertYamlMapToDartMap(yamlMap: YamlMap.wrap({'scalar': 5})),
            {'scalar': 5});
      });
      test('converts list', () {
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
            convertYamlMapToDartMap(
                yamlMap: YamlMap.wrap({'scalar': YamlList.wrap(listContent)})),
            {'scalar': listContentExpected});
      });
    });
  });
}
