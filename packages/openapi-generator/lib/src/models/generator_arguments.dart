import 'dart:io';

import 'package:openapi_generator/src/extensions/type_methods.dart';
import 'package:openapi_generator_annotations/openapi_generator_annotations.dart';
import 'package:source_gen/source_gen.dart' as src_gen;

import '../utils.dart';

/// The default storage location of the cached copy of the specification.
///
/// When the annotation has the [Openapi.cachePath] set this value isn't used.
final defaultCachedPath =
    '${Directory.current.path}${Platform.pathSeparator}.dart_tool${Platform.pathSeparator}openapi-generator-cache.json';

/// Represents the Annotation fields passed to the [OpenapiGenerator].
class GeneratorArguments {
  /// The [cachePath] is the location of the translated copy of the [inputFile]
  /// before modifications.
  ///
  /// The default location is: .dart_tool/openapi-generator-cache.json
  final String cachePath;

  final bool isDebug;

  /// Use a custom pubspec file when generating.
  ///
  /// Defaults to the pubspec at the root of [Directory.current].
  final String? pubspecPath;

  /// The directory where the generated sources will be placed.
  ///
  /// Default: Directory.current.path
  final String? outputDirectory;

  /// Defines whether the output directory should be cleaned up before generating the output.
  final List<dynamic>? cleanSubOutputDirectory;

  /// When `true`, the entire [outputDirectory] is deleted before the JAR runs.
  final bool cleanOutputDirectory;

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

  /// Write the last run placeholder to the annotated file.
  /// This makes changes to the file containing @openapi() annotation
  /// so that it is executed when next build runner is run
  ///
  /// Default: true
  final bool forceAlwaysRun;

  /// Provides an OAS spec file.
  ///
  /// When the [useNextGen] flag is set this should be the spec file configuration
  /// used instead.
  InputSpec inputSpec;

  /// The directory containing the template files.
  final String? templateDirectory;

  /// Informs the generator what kind of library should be generated.
  ///
  /// Default: [Generator.dart]
  final Generator generator;

  /// Informs the generator to use the specified [wrapper] for Flutter commands.
  Wrapper get wrapper => additionalProperties?.wrapper ?? Wrapper.none;

  /// Defines mappings between a class and the import to be used.
  final Map<String, String>? importMappings;

  /// Defines mappings between OpenAPI spec types and generated types.
  final Map<String, String>? typeMappings;

  /// Defines mappings between OpenAPI spec var/param/model and generated code.
  final Map<String, String>? nameMappings;

  final Map<String, String>? enumNameMappings;

  /// Adds reserved words mappings.
  ///
  /// Supported by [Generator.dio] & [Generator.dioAlt] generators.
  final Map<String, String>? reservedWordsMappings;

  /// Additional properties to be passed into the OpenAPI compiler.
  final AdditionalProperties? additionalProperties;

  /// Defines a mapping for nested (inline) schema and the generated name.
  final Map<String, dynamic>? inlineSchemaNameMappings;

  /// Customizes the way inline schema are handled.
  final InlineSchemaOptions? inlineSchemaOptions;

  GeneratorArguments({required src_gen.ConstantReader annotations})
      : templateDirectory = annotations.readPropertyOrNull('templateDirectory'),
        generator =
            annotations.readPropertyOrDefault('generatorName', Generator.dart),
        typeMappings = annotations.readPropertyOrNull('typeMappings'),
        nameMappings = annotations.readPropertyOrNull('nameMappings'),
        enumNameMappings = annotations.readPropertyOrNull('enumNameMappings'),
        importMappings = annotations.readPropertyOrNull('importMappings'),
        reservedWordsMappings =
            annotations.readPropertyOrNull('reservedWordsMappings'),
        inlineSchemaNameMappings =
            annotations.readPropertyOrNull('inlineSchemaNameMappings'),
        additionalProperties =
            annotations.readPropertyOrNull('additionalProperties'),
        inlineSchemaOptions =
            annotations.readPropertyOrNull('inlineSchemaOptions'),
        skipValidation =
            annotations.readPropertyOrDefault('skipSpecValidation', false),
        runSourceGen =
            annotations.readPropertyOrDefault('runSourceGenOnOutput', true),
        shouldFetchDependencies =
            annotations.readPropertyOrDefault('fetchDependencies', true),
        forceAlwaysRun =
            annotations.readPropertyOrDefault('forceAlwaysRun', false),
        outputDirectory = annotations.readPropertyOrNull('outputDirectory'),
        cleanSubOutputDirectory =
            annotations.readPropertyOrNull('cleanSubOutputDirectory'),
        cleanOutputDirectory =
            annotations.readPropertyOrDefault('cleanOutputDirectory', false),
        cachePath =
            annotations.readPropertyOrDefault('cachePath', defaultCachedPath),
        pubspecPath = annotations.readPropertyOrDefault<String>(
            'projectPubspecPath',
            '${Directory.current.path}${Platform.pathSeparator}pubspec.yaml'),
        isDebug = annotations.readPropertyOrDefault('debugLogging', false),
        inputSpec =
            annotations.readPropertyOrDefault('inputSpec', InputSpec.json());

  /// The stringified name of the [Generator].
  String get generatorName => generator == Generator.dart
      ? 'dart'
      : generator == Generator.dio
          ? 'dart-dio'
          : 'dart2-api';

  /// Determines if `build_runner` may be needed to run on the generated client SDK
  ///
  /// This is only false in the case where [generator] is set to [Generator.dart]
  /// as that version of the [Generator] uses the 'dart:http' library as the
  /// networking layer.
  bool get shouldGenerateSources => generator != Generator.dart;

  /// Identifies if the specification is a remote specification.
  ///
  /// Used when the specification is hosted on an external server. This will cause
  /// the compiler to pulls from the remote source. When this is true a cache will
  /// still be created but a warning will be emitted to the user.
  bool get isRemote => (inputSpec is RemoteSpec);

  bool get hasLocalCache => File(cachePath).existsSync();

  /// Looks for a default spec file within [Directory.current] if [_inputFile]
  /// wasn't set.
  ///
  /// Looks for
  /// In the event that a specification file isn't provided look within the
  /// project to see if one of the supported defaults, a file named
  /// openapi.(ya?ml|json), is present.
  ///
  /// Subsequent calls will be able to use the [_inputFile] when successful in
  /// the event that a default is found.
  String get inputFileOrFetch {
    return inputSpec.path;
  }

  /// The arguments to be passed to generator jar file.
  List<String> get jarArgs => [
        'generate',
        if (outputDirectory?.isNotEmpty ?? false) '-o=$outputDirectory',
        '-i=$inputFileOrFetch',
        if (templateDirectory?.isNotEmpty ?? false) '-t=$templateDirectory',
        '-g=$generatorName',
        if (skipValidation) '--skip-validate-spec',
        if (reservedWordsMappings?.isNotEmpty ?? false)
          '--reserved-words-mappings=${reservedWordsMappings!.entries.fold('', foldStringMap())}',
        if (inlineSchemaNameMappings?.isNotEmpty ?? false)
          '--inline-schema-name-mappings=${inlineSchemaNameMappings!.entries.fold('', foldStringMap())}',
        if (importMappings?.isNotEmpty ?? false)
          '--import-mappings=${importMappings!.entries.fold('', foldStringMap())}',
        if (typeMappings?.isNotEmpty ?? false)
          '--type-mappings=${typeMappings!.entries.fold('', foldStringMap())}',
        if (nameMappings?.isNotEmpty ?? false)
          '--name-mappings=${nameMappings!.entries.fold('', foldStringMap())}',
        if (enumNameMappings?.isNotEmpty ?? false)
          '--enum-name-mappings=${enumNameMappings!.entries.fold('', foldStringMap())}',
        if (inlineSchemaOptions != null)
          '--inline-schema-options=${inlineSchemaOptions!.toMap().entries.fold('', foldStringMap(keyModifier: convertToPropertyKey))}',
        if (additionalProperties != null)
          '--additional-properties=${convertAdditionalProperties(additionalProperties!).fold('', foldStringMap(keyModifier: convertToPropertyKey))}'
      ];

  Iterable<MapEntry<String, dynamic>> convertAdditionalProperties(
      AdditionalProperties props) {
    if (props is DioProperties) {
      return props.toMap().entries;
    } else if (props is DioAltProperties) {
      return props.toMap().entries;
    } else {
      return props.toMap().entries;
    }
  }
}
