import 'dart:io';

import 'package:build_test/build_test.dart';
import 'package:openapi_generator/src/models/generator_arguments.dart';
import 'package:openapi_generator/src/models/output_message.dart';
import 'package:openapi_generator/src/utils.dart';
import 'package:openapi_generator_annotations/openapi_generator_annotations.dart';
import 'package:source_gen/source_gen.dart' as src_gen;
import 'package:test/test.dart';

void main() {
  group('GeneratorArguments', () {
    group('defaults', () {
      late GeneratorArguments args;
      setUpAll(() =>
          args = GeneratorArguments(annotations: src_gen.ConstantReader(null)));
      test('alwaysRun', () => expect(args.alwaysRun, isFalse));
      test('useNextGen', () => expect(args.useNextGen, isFalse));
      test('cachePath', () => expect(args.cachePath, defaultCachedPath));
      test('outputDirectory',
          () => expect(args.outputDirectory, Directory.current.path));
      test('runSourceGen', () => expect(args.runSourceGen, isTrue));
      test('shouldFetchDependencies',
          () => expect(args.shouldFetchDependencies, isTrue));
      test('skipValidation', () => expect(args.skipValidation, isFalse));
      group('inputFile', () {
        test('errors when no spec is found', () async {
          await args.inputFileOrFetch.onError((e, __) {
            expect((e as OutputMessage).message,
                'No spec file found. One must be present in the project or hosted remotely.');
            return '';
          });
        });

        test('updates path when one is found', () async {
          final f = File(
              Directory.current.path + '${Platform.pathSeparator}openapi.json');
          f.createSync();
          f.writeAsStringSync('');
          final p = await args.inputFileOrFetch;
          expect(p, f.path);
          expect(await args.inputFileOrFetch, f.path);
          f.deleteSync();
        });
      });
      test('templateDirectory', () => expect(args.templateDirectory, isEmpty));
      test('generator', () => expect(args.generator, Generator.dart));
      test('wrapper', () => expect(args.wrapper, Wrapper.none));
      test('importMappings', () => expect(args.importMappings, isEmpty));
      test('typeMappings', () => expect(args.typeMappings, isEmpty));
      test('reservedWordsMappings',
          () => expect(args.reservedWordsMappings, isEmpty));
      test('inlineSchemaNameMappings',
          () => expect(args.inlineSchemaNameMappings, isEmpty));

      test('generatorName', () => expect(args.generatorName, 'dart'));
      test('shouldGenerateSources',
          () => expect(args.shouldGenerateSources, isFalse));
      test('isRemote', () => expect(args.isRemote, isFalse));
      test('jarArgs', () async {
        final f = File(
            Directory.current.path + '${Platform.pathSeparator}openapi.json');
        f.createSync();
        f.writeAsStringSync('');
        expect(await args.jarArgs, [
          'generate',
          '-o ${Directory.current.path}',
          '-i ${await args.inputFileOrFetch}',
          '-g ${args.generatorName}'
        ]);
        f.deleteSync();
      });
    });
    group('accepts overrides', () {
      final annos = src_gen.ConstantReader(null);
      final args = GeneratorArguments(
          annotations: annos,
          alwaysRun: true,
          useNextGen: true,
          cachePath: 'test',
          outputDirectory: 'path',
          templateDirectory: 'template',
          runSourceGen: false,
          generator: Generator.dioAlt,
          skipValidation: true,
          fetchDependencies: false,
          inputSpecFile: 'test.yaml',
          importMapping: {'key': 'value'},
          typeMapping: {'package': 'type'},
          reservedWordsMapping: {'const': 'final'},
          inlineSchemaNameMapping: {'L': 'R'},
          additionalProperties: AdditionalProperties(wrapper: Wrapper.fvm));
      test('alwaysRun', () => expect(args.alwaysRun, isTrue));
      test('useNextGen', () => expect(args.useNextGen, isTrue));
      test('cachePath', () => expect(args.cachePath, 'test'));
      test('outputDirectory', () => expect(args.outputDirectory, 'path'));
      test('runSourceGen', () => expect(args.runSourceGen, isFalse));
      test('shouldFetchDependencies',
          () => expect(args.shouldFetchDependencies, isFalse));
      test('skipValidation', () => expect(args.skipValidation, isTrue));
      test('inputFile',
          () async => expect(await args.inputFileOrFetch, 'test.yaml'));
      test('templateDirectory',
          () => expect(args.templateDirectory, 'template'));
      test('generator', () => expect(args.generator, Generator.dioAlt));
      test('wrapper', () => expect(args.wrapper, Wrapper.fvm));
      test('importMappings',
          () => expect(args.importMappings, {'key': 'value'}));
      test(
          'typeMappings', () => expect(args.typeMappings, {'package': 'type'}));
      test('reservedWordsMappings',
          () => expect(args.reservedWordsMappings, {'const': 'final'}));
      test('inlineSchemaNameMappings',
          () => expect(args.inlineSchemaNameMappings, {'L': 'R'}));
      test('isRemote', () => expect(args.isRemote, isFalse));
      test('generatorName', () => expect(args.generatorName, 'dart2-api'));
      test('shouldGenerateSources',
          () => expect(args.shouldGenerateSources, isTrue));
      test(
          'jarArgs',
          () async => expect(await args.jarArgs, [
                'generate',
                '-o ${args.outputDirectory}',
                '-i ${await args.inputFileOrFetch}',
                '-t ${args.templateDirectory}',
                '-g ${args.generatorName}',
                '--skip-validate-spec',
                '--reserved-words-mappings=${args.reservedWordsMappings.entries.fold('', foldStringMap)}',
                '--inline-schema-name-mappings=${args.inlineSchemaNameMappings.entries.fold('', foldStringMap)}',
                '--import-mappings=${args.importMappings.entries.fold('', foldStringMap)}',
                '--type-mappings=${args.typeMappings.entries.fold('', foldStringMap)}'
              ]));
    });
    test('uses config', () async {
      final config = File(
              '${Directory.current.path}${Platform.pathSeparator}test${Platform.pathSeparator}specs${Platform.pathSeparator}test_config.dart')
          .readAsStringSync();
      final annotations = (await resolveSource(
              config,
              (resolver) async =>
                  (await resolver.findLibraryByName('test_lib'))!))
          .getClass('TestClassConfig')!
          .metadata
          .map((e) => src_gen.ConstantReader(e.computeConstantValue()!))
          .first;
      final args = GeneratorArguments(annotations: annotations);
      expect(args.alwaysRun, isTrue);
      expect(args.useNextGen, isTrue);
      expect(args.cachePath, './');
      expect(args.outputDirectory, 'output');
      expect(args.runSourceGen, isTrue);
      expect(args.shouldFetchDependencies, isTrue);
      expect(args.skipValidation, isFalse);
      expect(await args.inputFileOrFetch, './openapi.test.yaml');
      expect(args.templateDirectory, 'template');
      expect(args.generator, Generator.dio);
      expect(args.wrapper, Wrapper.fvm);
      expect(args.importMappings, {'package': 'test'});
      expect(args.typeMappings, {'key': 'value'});
      expect(args.reservedWordsMappings, {'const': 'final'});
      expect(args.inlineSchemaNameMappings, {'200resp': 'OkResp'});

      expect(args.isRemote, isFalse);
      expect(args.generatorName, 'dart-dio');
      expect(args.shouldGenerateSources, isTrue);
      expect(await args.jarArgs, [
        'generate',
        '-o ${args.outputDirectory}',
        '-i ${await args.inputFileOrFetch}',
        '-t ${args.templateDirectory}',
        '-g ${args.generatorName}',
        '--reserved-words-mappings=${args.reservedWordsMappings.entries.fold('', foldStringMap)}',
        '--inline-schema-name-mappings=${args.inlineSchemaNameMappings.entries.fold('', foldStringMap)}',
        '--import-mappings=${args.importMappings.entries.fold('', foldStringMap)}',
        '--type-mappings=${args.typeMappings.entries.fold('', foldStringMap)}'
      ]);
    });
  });
}
