import 'dart:io';

import 'package:analyzer/dart/constant/value.dart';
import 'package:build/build.dart';
import 'package:build_test/build_test.dart';
import 'package:build_test/builder.dart';
import 'package:openapi_generator/src/models/generator_arguments.dart';
import 'package:openapi_generator/src/openapi_generator_runner.dart';
import 'package:openapi_generator_annotations/openapi_generator_annotations.dart';
import 'package:source_gen/source_gen.dart' as src_gen;
import 'package:test/test.dart';

import 'determine_flutter_projet_status_test.dart';

void main() {
  group('GeneratorArguments', () {
    group('defaults', () {
      final annos = src_gen.ConstantReader(null);
      final args = GeneratorArguments(annotations: annos);
      test('alwaysRun', () => expect(args.alwaysRun, isFalse));
      test('useNextGen', () => expect(args.useNextGen, isFalse));
      test('cachePath', () => expect(args.cachePath, defaultCachedPath));
      test('outputDirectory',
          () => expect(args.outputDirectory, Directory.current.path));
      test('runSourceGen', () => expect(args.runSourceGen, isTrue));
      test('shouldFetchDependencies',
          () => expect(args.shouldFetchDependencies, isTrue));
      test('skipValidation', () => expect(args.skipValidation, isFalse));
      test('inputFile', () => expect(args.inputFile, isEmpty));
      test('templateDirectory', () => expect(args.templateDirectory, isEmpty));
      test('generator', () => expect(args.generator, Generator.dart));
      test('wrapper', () => expect(args.wrapper, Wrapper.none));
      test('importMappings', () => expect(args.importMappings, isEmpty));
      test('typeMappings', () => expect(args.typeMappings, isEmpty));
      test('reservedWordsMappings',
          () => expect(args.reservedWordsMappings, isEmpty));
      test('additionalProperties',
          () => expect(args.additionalProperties, isEmpty));
      test('inlineSchemaNameMappings',
          () => expect(args.inlineSchemaNameMappings, isEmpty));
      test('inlineSchemaOptions',
          () => expect(args.inlineSchemaOptions, isEmpty));

      test('generatorName', () => expect(args.generatorName, 'dart'));
      test('shouldGenerateSources',
          () => expect(args.shouldGenerateSources, isFalse));
      test(
          'jarArgs',
          () => expect(args.jarArgs, [
                'generate',
                '-o ${Directory.current.path}',
                '-g ${args.generatorName}'
              ]));
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
        wrapper: Wrapper.fvm,
        generator: Generator.dioAlt,
        skipValidation: true,
        fetchDependencies: false,
        inputSpecFile: 'test.yaml',
        importMapping: {'key': 'value'},
        typeMapping: {'package': 'type'},
        reservedWordsMapping: {'const': 'final'},
        inlineSchemaNameMapping: {'L': 'R'},
        // TODO: How do I test this?
        // additionalProperties: {'allowNull': false as DartObject},
        // inlineSchemaOptions: {'allowNull': false as DartObject},
      );
      test('alwaysRun', () => expect(args.alwaysRun, isTrue));
      test('useNextGen', () => expect(args.useNextGen, isTrue));
      test('cachePath', () => expect(args.cachePath, 'test'));
      test('outputDirectory', () => expect(args.outputDirectory, 'path'));
      test('runSourceGen', () => expect(args.runSourceGen, isFalse));
      test('shouldFetchDependencies',
          () => expect(args.shouldFetchDependencies, isFalse));
      test('skipValidation', () => expect(args.skipValidation, isTrue));
      test('inputFile', () => expect(args.inputFile, 'test.yaml'));
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
      test(
          'additionalProperties',
          () => expect(
              args.additionalProperties, {'allowNull': false as DartObject}),
          skip: true);
      test(
          'inlineSchemaOptions',
          () => expect(
              args.inlineSchemaOptions, {'allowNull': false as DartObject}),
          skip: true);

      test('generatorName', () => expect(args.generatorName, 'dart2-api'));
      test('shouldGenerateSources',
          () => expect(args.shouldGenerateSources, isTrue));
      test(
          'jarArgs',
          () => expect(args.jarArgs, [
                'generate',
                '-o path',
                '-i test.yaml',
                '-t template',
                '-g dart2-api',
                '--skip-validate-spec',
                '--reserved-words-mappings=const=final',
                '--inline-schema-name-mappings=L=R',
                '--import-mappings=key=value',
                '--type-mappings=package=type'
              ]));
    });
    test('uses config', () async {
      final builder = await generateArgumentBuilder('''
        @Openapi(
  inputSpecFile: './openapi.test.yaml',
  generatorName: Generator.dart,
  useNextGen: true,
  cachePath: './',
  typeMappings: {'key': 'value'},
  templateDirectory: 'template',
  alwaysRun: true,
  outputDirectory: 'output',
  runSourceGenOnOutput: true,
  apiPackage: 'test',
  skipSpecValidation: false,
  importMappings: {'package': 'test'},
  reservedWordsMappings: {'const': 'final'},
  additionalProperties: AdditionalProperties(wrapper: Wrapper.fvm),
  inlineSchemaNameMappings: {'200resp': 'OkResp'},
  overwriteExistingFiles: true,
)
        ''');
      final args = GeneratorArguments(annotations: annos);
      expect(args.alwaysRun, isFalse);
      expect(args.useNextGen, isFalse);
      expect(args.cachePath, defaultCachedPath);
      expect(args.outputDirectory, Directory.current.path);
      expect(args.runSourceGen, isTrue);
      expect(args.shouldFetchDependencies, isTrue);
      expect(args.skipValidation, isFalse);
      expect(args.inputFile, isEmpty);
      expect(args.templateDirectory, isEmpty);
      expect(args.generator, Generator.dart);
      expect(args.wrapper, Wrapper.none);
      expect(args.importMappings, isEmpty);
      expect(args.typeMappings, isEmpty);
      expect(args.reservedWordsMappings, isEmpty);
      expect(args.additionalProperties, isEmpty);
      expect(args.inlineSchemaNameMappings, isEmpty);
      expect(args.inlineSchemaOptions, isEmpty);

      expect(args.generatorName, 'dart');
      expect(args.shouldGenerateSources, isFalse);
      expect(args.jarArgs, [
        'generate',
        '-o ${Directory.current.path}',
        '-g ${args.generatorName}'
      ]);
    });
  });
}

Future<src_gen.ConstantReader> generateConstantReader(String source) async {
  final spec = File(
          '${Directory.current.path}${Platform.pathSeparator}test${Platform.pathSeparator}specs${Platform.pathSeparator}openapi.test.yaml')
      .readAsStringSync();
  var srcs = <String, String>{
    'openapi_generator_annotations|lib/src/openapi_generator_annotations_base.dart':
        File('../openapi-generator-annotations/lib/src/openapi_generator_annotations_base.dart')
            .readAsStringSync(),
    'openapi_generator|lib/myapp.dart': '''
    import 'package:openapi_generator_annotations/src/openapi_generator_annotations_base.dart';
    $source
    class MyApp {
    }  
    ''',
    'openapi_generator|openapi-spec.yaml': spec
  };

  final inputAssetId = AssetId(
      'openapi_generator|generator_arguments', basePath + 'test_config.dart');

  var writer = InMemoryAssetWriter();

  src_gen.ConstantReader


  return constantReader;
}
