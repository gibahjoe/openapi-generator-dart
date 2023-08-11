import 'dart:io';

import 'package:analyzer/dart/constant/value.dart';
import 'package:openapi_generator/src/extensions/type_methods.dart';
import 'package:openapi_generator_annotations/openapi_generator_annotations.dart';
import 'package:source_gen/source_gen.dart' as src_gen;

import '../utils.dart';

final defaultCachedPath =
    '${Directory.current.path}${Platform.pathSeparator}.dart_tool${Platform.pathSeparator}openapi-generator-cache.json';

/// Represents the Annotation fields passed to the [OpenapiGenerator].
class GeneratorArguments {
  /// Informs the generator to always run on changes.
  ///
  /// WARNING! This will soon be noop. See [useNextGen] for more
  /// details.
  ///
  /// Default: false
  @deprecated
  final bool alwaysRun;

  /// Informs the generator to follow the next generation path way.
  ///
  /// NextGen:
  ///   The next generation of the [OpenapiGenerator] will always run in the
  ///   event there is a change to the Openapi specification. In this version of
  ///   the generator the builder caches an instance of the current [inputFile],
  ///   if one doesn't already exist, this way in the event that are modifications
  ///   to the spec they can be generated. That cached copy is a translated
  ///   JSON copy (see [Yaml library]() about output).
  ///
  /// Default: false
  final bool useNextGen;

  /// The [cachePath] is the location of the translated copy of the [inputFile]
  /// before modifications.
  ///
  /// The default location is: .dart_tool/openapi-generator-cache.json
  final String cachePath;

  /// The directory where the generated sources will be placed.
  ///
  /// Default: Directory.current.path
  final String outputDirectory;

  /// Informs the generator to run source gen on the output.
  ///
  /// Default: true
  final bool runSourceGen;

  /// Informs the generator to fetch dependencies within the new generated API.
  ///
  /// Default: true
  final bool shouldFetchDependencies;

  /// Informs the generator to skip validating the OpenApi specification.
  ///
  /// Default: false
  final bool skipValidation;

  /// Use the provided spec instead of one located in [Directory.current].
  ///
  /// Default: openapi.yaml | openapi.json
  final String inputFile;

  /// The directory containing the template files.
  final String templateDirectory;

  /// Informs the generator what kind of library should be generated.
  ///
  /// Default: [Generator.dart]
  final Generator generator;

  /// Informs the generator to use the specified [wrapper] for Flutter commands.
  final Wrapper wrapper;

  /// Defines mappings between a class and the import to be used.
  final Map<String, String> importMappings;

  /// Defines mappings between OpenAPI spec types and generated types.
  final Map<String, String> typeMappings;

  /// Adds reserved words mappings.
  ///
  /// Supported by [Generator.dio] & [Generator.dioAlt] generators.
  final Map<String, String> reservedWordsMappings;

  // TODO: Use class from annotations base
  /// Additional properties to be passed into the OpenAPI compiler.
  final Map<String, DartObject> additionalProperties;

  /// Defines a mapping for nested (inline) schema and the generated name.
  final Map<String, dynamic> inlineSchemaNameMappings;

  // TODO: Use type from annotations base
  /// Customizes the way inline schema are handled.
  final Map<String, DartObject> inlineSchemaOptions;

  GeneratorArguments({
    required src_gen.ConstantReader annotations,
    bool alwaysRun = false,
    String inputSpecFile = '',
    String templateDirectory = '',
    Generator generator = Generator.dart,
    Map<String, String> typeMapping = const {},
    Map<String, String> importMapping = const {},
    Map<String, String> reservedWordsMapping = const {},
    Map<String, String> inlineSchemaNameMapping = const {},
    Map<String, DartObject> additionalProperties = const {},
    Map<String, DartObject> inlineSchemaOptions = const {},
    bool skipValidation = false,
    bool runSourceGen = true,
    Wrapper wrapper = Wrapper.none,
    String? outputDirectory,
    bool fetchDependencies = true,
    bool useNextGen = false,
    String? cachePath,
  })  : alwaysRun = annotations.readPropertyOrDefault('alwaysRun', alwaysRun),
        inputFile =
            annotations.readPropertyOrDefault('inputSpecFile', inputSpecFile),
        templateDirectory = annotations.readPropertyOrDefault(
            'templateDirectory', templateDirectory),
        generator =
            annotations.readPropertyOrDefault('generatorName', generator),
        typeMappings =
            annotations.readPropertyOrDefault('typeMapping', typeMapping),
        importMappings =
            annotations.readPropertyOrDefault('importMappings', importMapping),
        reservedWordsMappings = annotations.readPropertyOrDefault(
            'reservedWordsMappings', reservedWordsMapping),
        inlineSchemaNameMappings = annotations.readPropertyOrDefault(
            'inlineSchemaNameMappings', inlineSchemaNameMapping),
        additionalProperties = annotations.readPropertyOrDefault(
            'additionalProperties', additionalProperties),
        inlineSchemaOptions = annotations.readPropertyOrDefault(
            'inlineSchemaOptions', inlineSchemaOptions),
        skipValidation = annotations.readPropertyOrDefault(
            'skipSpecValidation', skipValidation),
        runSourceGen = annotations.readPropertyOrDefault(
            'runSourceGenOnOutput', runSourceGen),
        shouldFetchDependencies = annotations.readPropertyOrDefault(
            'fetchDependencies', fetchDependencies),
        wrapper = annotations.readPropertyOrDefault('wrapper', wrapper),
        outputDirectory = annotations.readPropertyOrDefault(
            'outputDirectory', outputDirectory ?? Directory.current.path),
        useNextGen =
            annotations.readPropertyOrDefault('useNextGen', useNextGen),
        cachePath = annotations.readPropertyOrDefault(
            'cachePath', cachePath ?? defaultCachedPath);

  /// The stringified name of the [Generator].
  String get generatorName => generator == Generator.dart
      ? 'dart'
      : generator == Generator.dio
          ? 'dart-dio'
          : 'dart2-api';

  /// Informs the generator to generate source based on the [generator].
  ///
  /// This is only false in the case where [generator] is set to [Generator.dart]
  /// as that verison of the [Generator] uses the 'dart:http' library as the
  /// networking layer.
  bool get shouldGenerateSources => generator != Generator.dart;

  /// The arguments to be passed to generator jar file.
  List<String> get jarArgs => [
        'generate',
        if (outputDirectory.isNotEmpty) '-o $outputDirectory',
        if (inputFile.isNotEmpty) '-i $inputFile',
        if (templateDirectory.isNotEmpty) '-t $templateDirectory',
        '-g $generatorName',
        if (skipValidation) '--skip-validate-spec',
        if (reservedWordsMappings.isNotEmpty)
          '--reserved-words-mappings=${reservedWordsMappings.entries.fold('', (String prev, MapEntry<String, String> curr) => '${prev.isEmpty ? '' : ','}${curr.key}=${curr.value}')}',
        if (inlineSchemaNameMappings.isNotEmpty)
          '--inline-schema-name-mappings=${inlineSchemaNameMappings.entries.fold('', (String prev, MapEntry<String, dynamic> curr) => '${prev.isEmpty ? '' : ','}${curr.key}=${curr.value}')}',
        if (importMappings.isNotEmpty)
          '--import-mappings=${importMappings.entries.fold('', (String prev, MapEntry<String, String> curr) => '${prev.isEmpty ? '' : ','}${curr.key}=${curr.value}')}',
        if (typeMappings.isNotEmpty)
          '--type-mappings=${typeMappings.entries.fold('', (String prev, MapEntry<String, String> curr) => '${prev.isEmpty ? '' : ','}${curr.key}=${curr.value}')}',
        if (inlineSchemaOptions.isNotEmpty)
          '--inline-schema-options=${inlineSchemaOptions.entries.fold('', foldNamedArgsMap)}',
        if (additionalProperties.isNotEmpty)
          '--additional-properties=${additionalProperties.entries.fold('', foldNamedArgsMap)}'
      ];
}
