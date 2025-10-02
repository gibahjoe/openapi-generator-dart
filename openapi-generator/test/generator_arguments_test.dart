import 'dart:io';

import 'package:build_test/build_test.dart';
import 'package:openapi_generator/src/models/generator_arguments.dart';
import 'package:openapi_generator/src/utils.dart';
import 'package:openapi_generator_annotations/openapi_generator_annotations.dart';
import 'package:path/path.dart';
import 'package:source_gen/source_gen.dart' as src_gen;
import 'package:test/test.dart';

import 'utils.dart';

void main() {
  group('GeneratorArguments', () {
    group('defaults', () {
      late GeneratorArguments args;
      setUpAll(() =>
          args = GeneratorArguments(annotations: src_gen.ConstantReader(null)));
      test('cachePath', () => expect(args.cachePath, defaultCachedPath));
      test('outputDirectory', () => expect(args.outputDirectory, isNull));
      test('runSourceGen', () => expect(args.runSourceGen, isTrue));
      test('shouldFetchDependencies',
          () => expect(args.shouldFetchDependencies, isTrue));
      test('skipValidation', () => expect(args.skipValidation, isFalse));
      test('updateAnnotatedFile', () => expect(args.forceAlwaysRun, isFalse));
      test(
          'pubspecPath',
          () => expect(
              args.pubspecPath, '${Directory.current.path}/pubspec.yaml'));
      group('inputFile', () {
        test('updates path when one is found', () async {
          final f = File(
              Directory.current.path + '${Platform.pathSeparator}openapi.json');
          f.createSync();
          f.writeAsStringSync('');
          final p = args.inputFileOrFetch;
          expect(f.path.endsWith(p), isTrue);
          f.deleteSync();
        });
      });
      test('templateDirectory', () => expect(args.templateDirectory, isNull));
      test('generator', () => expect(args.generator, Generator.dart));

      test('importMappings', () => expect(args.importMappings, isNull));
      test('typeMappings', () => expect(args.typeMappings, isNull));
      test('reservedWordsMappings',
          () => expect(args.reservedWordsMappings, isNull));
      test('inlineSchemaNameMappings',
          () => expect(args.inlineSchemaNameMappings, isNull));

      test('generatorName', () => expect(args.generatorName, 'dart'));
      test('shouldGenerateSources',
          () => expect(args.shouldGenerateSources, isFalse));
      test('isRemote', () => expect(args.isRemote, isFalse));
      test('additionalProperties',
          () => expect(args.additionalProperties, isNull));
      test(
          'wrapper defaults to none', () => expect(args.wrapper, Wrapper.none));
      test('inlineSchemaOptions',
          () => expect(args.inlineSchemaOptions, isNull));
      test('jarArgs', () async {
        final f = File(
            Directory.current.path + '${Platform.pathSeparator}openapi.json');
        f.createSync();
        f.writeAsStringSync('');
        expect(args.jarArgs, [
          'generate',
          '-i=${args.inputFileOrFetch}',
          '-g=${args.generatorName}',
        ]);
        f.deleteSync();
      });
    });
    // group('accepts overrides', () {
    //   final annos = src_gen.ConstantReader(null);
    //   final args = GeneratorArguments(
    //     annotations: annos,
    //     alwaysRun: true,
    //     useNextGen: true,
    //     cachePath: 'test',
    //     outputDirectory: 'path',
    //     templateDirectory: 'template',
    //     runSourceGen: false,
    //     generator: Generator.dioAlt,
    //     skipValidation: true,
    //     fetchDependencies: false,
    //     inputSpec: InputSpec(path: 'test/specs/openapi.test.yaml'),
    //     importMapping: {'key': 'value'},
    //     typeMapping: {'package': 'type'},
    //     reservedWordsMapping: {'const': 'final'},
    //     inlineSchemaNameMapping: {'L': 'R'},
    //     additionalProperties: AdditionalProperties(wrapper: Wrapper.fvm),
    //     pubspecPath: 'testing/pubspec.yaml',
    //   );
    //   test('cachePath', () => expect(args.cachePath, 'test'));
    //   test('outputDirectory', () => expect(args.outputDirectory, 'path'));
    //   test('runSourceGen', () => expect(args.runSourceGen, isFalse));
    //   test('shouldFetchDependencies',
    //       () => expect(args.shouldFetchDependencies, isFalse));
    //   test('skipValidation', () => expect(args.skipValidation, isTrue));
    //   test(
    //       'inputFile',
    //       () async => expect(
    //           await args.inputFileOrFetch, 'test/specs/openapi.test.yaml'));
    //   test('templateDirectory',
    //       () => expect(args.templateDirectory, 'template'));
    //   test('generator', () => expect(args.generator, Generator.dioAlt));
    //   test('wrapper', () => expect(args.wrapper, Wrapper.fvm));
    //   test('importMappings',
    //       () => expect(args.importMappings, {'key': 'value'}));
    //   test(
    //       'typeMappings', () => expect(args.typeMappings, {'package': 'type'}));
    //   test('reservedWordsMappings',
    //       () => expect(args.reservedWordsMappings, {'const': 'final'}));
    //   test('inlineSchemaNameMappings',
    //       () => expect(args.inlineSchemaNameMappings, {'L': 'R'}));
    //   test('isRemote', () => expect(args.isRemote, isFalse));
    //   test('generatorName', () => expect(args.generatorName, 'dart2-api'));
    //   test('shouldGenerateSources',
    //       () => expect(args.shouldGenerateSources, isTrue));
    //   test('pubspecPath',
    //       () => expect(args.pubspecPath, 'testing/pubspec.yaml'));
    //   test(
    //     'jarArgs',
    //     () async => expect(
    //       await args.jarArgs,
    //       [
    //         'generate',
    //         '-o=${args.outputDirectory}',
    //         '-i=${await args.inputFileOrFetch}',
    //         '-t=${args.templateDirectory}',
    //         '-g=${args.generatorName}',
    //         '--skip-validate-spec',
    //         '--reserved-words-mappings=${args.reservedWordsMappings.entries.fold('', foldStringMap())}',
    //         '--inline-schema-name-mappings=${args.inlineSchemaNameMappings.entries.fold('', foldStringMap())}',
    //         '--import-mappings=${args.importMappings.entries.fold('', foldStringMap())}',
    //         '--type-mappings=${args.typeMappings.entries.fold('', foldStringMap())}',
    //         '--additional-properties=${args.additionalProperties?.toMap().entries.fold('', foldStringMap(keyModifier: convertToPropertyKey))}'
    //       ],
    //     ),
    //   );
    // });
    group('annotation specification', () {
      // https://github.com/gibahjoe/openapi-generator-dart/issues/110
      test('Processes annotations correctly', () async {
        var testFile =
            join(Directory.current.path, 'test', 'specs', 'test_config.dart');
        final config = File(testFile).readAsStringSync();
        final annotations = await getConstantReader(
            definition: config,
            libraryName: 'test_lib',
            className: 'TestClassConfig');

        final args = GeneratorArguments(annotations: annotations);
        expect(args.cachePath, './test/specs/output/cache.json');
        expect(args.outputDirectory, './test/specs/output');
        expect(args.runSourceGen, isTrue);
        expect(args.shouldFetchDependencies, isTrue);
        expect(args.skipValidation, isFalse);
        expect(args.inputFileOrFetch, './test/specs/openapi.test.yaml');
        expect(args.templateDirectory, 'template');
        expect(args.generator, Generator.dio);
        expect(args.wrapper, Wrapper.fvm);
        expect(args.importMappings, {'package': 'test'});
        expect(args.typeMappings, {'key': 'value'});
        expect(args.reservedWordsMappings, {'const': 'final'});
        expect(args.inlineSchemaNameMappings, {'200resp': 'OkResp'});
        expect(args.pubspecPath, './test/specs/dart_pubspec.test.yaml');
        expect(args.isRemote, isFalse);
        expect(args.generatorName, 'dart-dio');
        expect(args.shouldGenerateSources, isTrue);
        expect(args.forceAlwaysRun, isTrue);
        expect(args.additionalProperties?.useEnumExtension, isTrue);
        expect(args.additionalProperties?.pubAuthor, 'test author');
        expect(args.jarArgs, [
          'generate',
          '-o=${args.outputDirectory}',
          '-i=${args.inputFileOrFetch}',
          '-t=${args.templateDirectory}',
          '-g=${args.generatorName}',
          if (args.reservedWordsMappings?.isNotEmpty ?? false)
            '--reserved-words-mappings=${args.reservedWordsMappings?.entries.fold('', foldStringMap())}',
          if (args.inlineSchemaNameMappings?.isNotEmpty ?? false)
            '--inline-schema-name-mappings=${args.inlineSchemaNameMappings!.entries.fold('', foldStringMap())}',
          if (args.importMappings?.isNotEmpty ?? false)
            '--import-mappings=${args.importMappings!.entries.fold('', foldStringMap())}',
          if (args.typeMappings?.isNotEmpty ?? false)
            '--type-mappings=${args.typeMappings!.entries.fold('', foldStringMap())}',
          if (args.additionalProperties != null)
            '--additional-properties=${args.additionalProperties!.toMap().entries.fold('', foldStringMap(keyModifier: convertToPropertyKey))}'
        ]);
      });
      test('Processes annotation with DioProperties correctly', () async {
        final config = File(
                '${Directory.current.path}${Platform.pathSeparator}test${Platform.pathSeparator}specs${Platform.pathSeparator}dio_properties_test_config.dart')
            .readAsStringSync();
        final annotations = await getConstantReader(
            definition: config,
            libraryName: 'test_lib',
            className: 'DioPropertiesTestConfig');
        final args = GeneratorArguments(annotations: annotations);
        expect(args.cachePath, './test/specs/output/cache.json');
        expect(args.outputDirectory, './test/specs/output');
        expect(args.runSourceGen, isTrue);
        expect(args.shouldFetchDependencies, isTrue);
        expect(args.skipValidation, isFalse);
        expect(args.inputFileOrFetch, './test/specs/openapi.test.yaml');
        expect(args.templateDirectory, 'template');
        expect(args.generator, Generator.dio);
        expect(args.wrapper, Wrapper.fvm);
        expect(args.importMappings, {'package': 'test'});
        expect(args.typeMappings, {'key': 'value'});
        expect(args.reservedWordsMappings, {'const': 'final'});
        expect(args.inlineSchemaNameMappings, {'200resp': 'OkResp'});
        expect(args.pubspecPath, './test/specs/dart_pubspec.test.yaml');
        expect(args.isRemote, isFalse);
        expect(args.generatorName, 'dart-dio');
        expect(args.shouldGenerateSources, isTrue);
        expect(args.forceAlwaysRun, isTrue);
        expect(args.additionalProperties?.useEnumExtension, isTrue);
        expect((args.additionalProperties as DioProperties?)?.nullableFields,
            isTrue);
        expect((args.additionalProperties as DioProperties).dateLibrary,
            DioDateLibrary.core);
        expect(
            (args.additionalProperties as DioProperties).serializationLibrary,
            DioSerializationLibrary.jsonSerializable);

        expect(args.jarArgs, [
          'generate',
          '-o=${args.outputDirectory}',
          '-i=${args.inputFileOrFetch}',
          '-t=${args.templateDirectory}',
          '-g=${args.generatorName}',
          if (args.reservedWordsMappings?.isNotEmpty ?? false)
            '--reserved-words-mappings=${args.reservedWordsMappings?.entries.fold('', foldStringMap())}',
          if (args.inlineSchemaNameMappings?.isNotEmpty ?? false)
            '--inline-schema-name-mappings=${args.inlineSchemaNameMappings!.entries.fold('', foldStringMap())}',
          if (args.importMappings?.isNotEmpty ?? false)
            '--import-mappings=${args.importMappings!.entries.fold('', foldStringMap())}',
          if (args.typeMappings?.isNotEmpty ?? false)
            '--type-mappings=${args.typeMappings!.entries.fold('', foldStringMap())}',
          if (args.additionalProperties != null)
            '--additional-properties=${args.additionalProperties!.toMap().entries.fold('', foldStringMap(keyModifier: convertToPropertyKey))}'
        ]);
      });
      test('Processes annotation with DioAltProperties correctly', () async {
        final config = File(
                '${Directory.current.path}${Platform.pathSeparator}test${Platform.pathSeparator}specs${Platform.pathSeparator}dio_alt_properties_test_config.dart')
            .readAsStringSync();
        final annotations = await getConstantReader(
            definition: config,
            libraryName: 'test_lib',
            className: 'DioAltPropertiesTestConfig');
        final args = GeneratorArguments(annotations: annotations);
        expect(args.cachePath, './test/specs/output/cache.json');
        expect(args.outputDirectory, './test/specs/output');
        expect(args.runSourceGen, isTrue);
        expect(args.shouldFetchDependencies, isTrue);
        expect(args.skipValidation, isFalse);
        expect(args.inputFileOrFetch, './test/specs/openapi.test.yaml');
        expect(args.templateDirectory, 'template');
        expect(args.generator, Generator.dio);
        expect(args.wrapper, Wrapper.fvm);
        expect(args.importMappings, {'package': 'test'});
        expect(args.typeMappings, {'key': 'value'});
        expect(args.reservedWordsMappings, {'const': 'final'});
        expect(args.inlineSchemaNameMappings, {'200resp': 'OkResp'});
        expect(args.pubspecPath, './test/specs/dart_pubspec.test.yaml');
        expect(args.isRemote, isFalse);
        expect(args.generatorName, 'dart-dio');
        expect(args.shouldGenerateSources, isTrue);
        expect(args.forceAlwaysRun, isTrue);
        expect(args.additionalProperties?.useEnumExtension, isTrue);
        expect(
            (args.additionalProperties as DioAltProperties).pubspecDependencies,
            'path: 1.0.0');
        expect(
            (args.additionalProperties as DioAltProperties)
                .pubspecDevDependencies,
            'pedantic: 1.0.0');
        expect((args.jarArgs).last, contains('path: 1.0.0'));
        expect((args.jarArgs).last, contains('pedantic: 1.0.0'));
        expect(args.additionalProperties.runtimeType, DioAltProperties);

        expect(args.jarArgs, [
          'generate',
          '-o=${args.outputDirectory}',
          '-i=${args.inputFileOrFetch}',
          '-t=${args.templateDirectory}',
          '-g=${args.generatorName}',
          if (args.reservedWordsMappings?.isNotEmpty ?? false)
            '--reserved-words-mappings=${args.reservedWordsMappings?.entries.fold('', foldStringMap())}',
          if (args.inlineSchemaNameMappings?.isNotEmpty ?? false)
            '--inline-schema-name-mappings=${args.inlineSchemaNameMappings!.entries.fold('', foldStringMap())}',
          if (args.importMappings?.isNotEmpty ?? false)
            '--import-mappings=${args.importMappings!.entries.fold('', foldStringMap())}',
          if (args.typeMappings?.isNotEmpty ?? false)
            '--type-mappings=${args.typeMappings!.entries.fold('', foldStringMap())}',
          if (args.additionalProperties != null) ...[
            '--additional-properties=${(args.additionalProperties as DioAltProperties).toMap().entries.fold('', foldStringMap(keyModifier: convertToPropertyKey))}'
          ]
        ]);
      });
      test(
          'Processes annotation with inputSpecFile that contains url correctly',
          () async {
        final config = File(join(Directory.current.path, 'test', 'specs',
                'input_remote_properties_test_config.dart'));
        final annotations = await getConstantReaderForPath(
            file: config,
            libraryName: 'test_lib',
            className: 'DioAltPropertiesTestConfig');
        final args = GeneratorArguments(annotations: annotations);
        expect(args.cachePath, './test/specs/output/cache.json');
        expect(args.outputDirectory, './test/specs/output');
        expect(args.runSourceGen, isTrue);
        expect(args.shouldFetchDependencies, isTrue);
        expect(args.skipValidation, isFalse);
        expect(args.inputFileOrFetch,
            'https://petstore3.swagger.io/api/v3/openapi.json');
        expect(args.templateDirectory, 'template');
        expect(args.generator, Generator.dio);
        expect(args.wrapper, Wrapper.fvm);
        expect(args.importMappings, {'package': 'test'});
        expect(args.typeMappings, {'key': 'value'});
        expect(args.reservedWordsMappings, {'const': 'final'});
        expect(args.inlineSchemaNameMappings, {'200resp': 'OkResp'});
        expect(args.pubspecPath, './test/specs/dart_pubspec.test.yaml');
        expect(args.isRemote, isTrue);
        expect(args.inputSpec.path,
            'https://petstore3.swagger.io/api/v3/openapi.json');
        expect(args.generatorName, 'dart-dio');
        expect(args.shouldGenerateSources, isTrue);
        expect(args.forceAlwaysRun, isTrue);
        expect(args.additionalProperties?.useEnumExtension, isTrue);
      });
    });
  });
}
