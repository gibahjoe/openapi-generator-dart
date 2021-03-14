/// Config base class
/// Your annotated class must extend this config class
abstract class OpenapiGeneratorConfig {}

class Openapi {
  /// Additional properties to pass to the compiler (CSV)
  ///
  /// --additional-properties
  final AdditionalProperties? additionalProperties;

  /// The package of the api. defaults to lib.api
  ///
  /// --api-package
  final String? apiPackage;

  /// relative path or url to spec file
  ///
  /// -i
  final String inputSpecFile;

  /// folder containing the template files
  ///
  /// -t
  final String? templateDirectory;

  /// Generator to use (dart|dart2-api|dart-jaguar|dart-dio)
  ///
  /// -g, --generator-name
  final Generator generatorName;

  ///  Where to write the generated files (current dir by default)
  ///
  ///  -o, --output
  final String? outputDirectory;

  ///  Specifies if the existing files should be overwritten during the generation
  ///
  ///  -s, --skip-overwrite
  final bool? overwriteExistingFiles;

  /// Skips the default behavior of validating an input specification.
  ///
  /// --skip-validate-spec
  final bool? skipSpecValidation;

  /// Add reserver words mappings as reservedWord=replacement format.
  /// It is supported by the dart2-api and dart-dio generator.
  ///
  /// --reserved-words-mappings
  final Map<String, String>? reservedWordsMappings;

  /// Tells openapi-generator to always run during the build process
  /// if set to false (the default), openapi-generator will skip processing if the [outputDirectory] already exists
  final bool? alwaysRun;

  /// if set to true, flutter pub get will be run on the [outputDirectory] after the code has been generated.
  /// Defaults to true for backwards compatibility
  final bool? fetchDependencies;

  ///if set to true, source gen will be run on the output of openapi-generator
  ///Defaults to true
  final bool? runSourceGenOnOutput;

  final Map<String, String>? typeMappings;

  const Openapi(
      {this.additionalProperties,
      this.overwriteExistingFiles,
      this.skipSpecValidation = false,
      required this.inputSpecFile,
      this.templateDirectory,
      required this.generatorName,
      this.outputDirectory,
      this.typeMappings,
      this.reservedWordsMappings,
      this.apiPackage,
      this.fetchDependencies = true,
      this.runSourceGenOnOutput = true,
      this.alwaysRun = false});
}

class AdditionalProperties {
  ///  toggles whether unicode identifiers are allowed in names or not, default is false
  final bool? allowUnicodeIdentifiers;

  /// Whether to ensure parameter names are unique in an operation (rename parameters that are not).
  final bool? ensureUniqueParams;

  /// Add form or body parameters to the beginning of the parameter list.
  final bool? prependFormOrBodyParameters;

  ///	Author name in generated pubspec
  final String? pubAuthor;

  /// 	Email address of the author in generated pubspec
  final String? pubAuthorEmail;

  ///	Description in generated pubspec
  final String? pubDescription;

  ///	Homepage in generated pubspec
  final String? pubHomepage;

  ///	Name in generated pubspec
  final String? pubName;

  /// Version in generated pubspec
  final String? pubVersion;

  /// Sort model properties to place required parameters before optional parameters.
  final bool? sortModelPropertiesByRequiredFlag;

  /// Sort method arguments to place required parameters before optional parameters.
  final bool? sortParamsByRequiredFlag;

  /// Source folder for generated code
  final String? sourceFolder;

  /// Allow the 'x-enum-values' extension for enums
  final bool? useEnumExtension;

  /// Flutter wrapper to use (none|flutterw|fvm)
  final Wrapper wrapper;

  /// Set to true for generators with better support for discriminators.
  /// (Python, Java, Go, PowerShell, C#have this enabled by default).
  ///
  /// true
  /// The mapping in the discriminator includes descendent schemas that allOf
  /// inherit from self and the discriminator mapping schemas in the OAS document.
  ///
  /// false
  /// The mapping in the discriminator includes any descendent schemas that allOf
  /// inherit from self, any oneOf schemas, any anyOf schemas, any x-discriminator-values,
  /// and the discriminator mapping schemas in the OAS document AND Codegen validates
  /// that oneOf and anyOf schemas contain the required discriminator and throws
  /// an error if the discriminator is missing.
  final bool legacyDiscriminatorBehavior;

  const AdditionalProperties(
      {this.allowUnicodeIdentifiers = false,
      this.ensureUniqueParams = true,
      this.useEnumExtension = false,
      this.prependFormOrBodyParameters = false,
      this.pubAuthor,
      this.pubAuthorEmail,
      this.pubDescription,
      this.pubHomepage,
      this.legacyDiscriminatorBehavior = true,
      this.pubName,
      this.pubVersion,
      this.sortModelPropertiesByRequiredFlag = true,
      this.sortParamsByRequiredFlag = true,
      this.sourceFolder,
      this.wrapper = Wrapper.none});
}

class JaguarProperties extends AdditionalProperties {
  /// Choose serialization format JSON or PROTO is supported
  final SerializationFormat? serialization;

  /// Is the null fields should be in the JSON payload
  final bool? nullableFields;

  const JaguarProperties(
      {this.serialization,
      this.nullableFields,
      bool allowUnicodeIdentifiers = false,
      bool ensureUniqueParams = true,
      bool prependFormOrBodyParameters = false,
      String? pubAuthor,
      String? pubAuthorEmail,
      String? pubDescription,
      String? pubHomepage,
      String? pubName,
      String? pubVersion,
      bool sortModelPropertiesByRequiredFlag = true,
      bool sortParamsByRequiredFlag = true,
      bool useEnumExtension = true,
      String? sourceFolder})
      : super(
            allowUnicodeIdentifiers: allowUnicodeIdentifiers,
            ensureUniqueParams: ensureUniqueParams,
            prependFormOrBodyParameters: prependFormOrBodyParameters,
            pubAuthor: pubAuthor,
            pubAuthorEmail: pubAuthorEmail,
            pubDescription: pubDescription,
            pubHomepage: pubHomepage,
            pubName: pubName,
            pubVersion: pubVersion,
            sortModelPropertiesByRequiredFlag:
                sortModelPropertiesByRequiredFlag,
            sortParamsByRequiredFlag: sortParamsByRequiredFlag,
            sourceFolder: sourceFolder,
            useEnumExtension: useEnumExtension);
}

class DioProperties extends AdditionalProperties {
  /// Choose serialization format JSON or PROTO is supported
  final DioDateLibrary? dateLibrary;

  /// Is the null fields should be in the JSON payload
  final bool? nullableFields;

  const DioProperties(
      {this.dateLibrary,
      this.nullableFields,
      bool allowUnicodeIdentifiers = false,
      bool ensureUniqueParams = true,
      bool prependFormOrBodyParameters = false,
      String? pubAuthor,
      String? pubAuthorEmail,
      String? pubDescription,
      String? pubHomepage,
      String? pubName,
      String? pubVersion,
      bool sortModelPropertiesByRequiredFlag = true,
      bool sortParamsByRequiredFlag = true,
      bool useEnumExtension = true,
      String? sourceFolder})
      : super(
            allowUnicodeIdentifiers: allowUnicodeIdentifiers,
            ensureUniqueParams: ensureUniqueParams,
            prependFormOrBodyParameters: prependFormOrBodyParameters,
            pubAuthor: pubAuthor,
            pubAuthorEmail: pubAuthorEmail,
            pubDescription: pubDescription,
            pubHomepage: pubHomepage,
            pubName: pubName,
            pubVersion: pubVersion,
            sortModelPropertiesByRequiredFlag:
                sortModelPropertiesByRequiredFlag,
            sortParamsByRequiredFlag: sortParamsByRequiredFlag,
            sourceFolder: sourceFolder,
            useEnumExtension: useEnumExtension);
}

enum DioDateLibrary {
  /// Dart core library (DateTime)
  core,

  /// Time Machine is date and time library for Flutter, Web, and Server with
  /// support for timezones, calendars, cultures, formatting and parsing.
  timemachine
}
enum SerializationFormat { JSON, PROTO }

/// The name of the generator to use
enum Generator {
  @Deprecated('Use Generator.dart instead')
  DART,

  @Deprecated('Use Generator.dio instead')
  DART_DIO,

  @Deprecated('Use Generator.dioAlt instead')
  DART2_API,

  @Deprecated('Use Generator.jaguar instead')
  DART_JAGUAR,

  /// This generator uses the default http package that comes with dart
  /// corresponds to dart
  dart,

  /// This generator uses the dio package. Source gen is required after generating code with this generator
  /// corresponds to dart-dio
  ///
  /// A powerful Http client for Dart, which supports Interceptors, Global configuration,
  /// FormData, Request Cancellation, File downloading, Timeout etc
  /// https://pub.flutter-io.cn/packages/dio
  dio,

  /// This uses the generator provided by bluetrainsoftware which internally uses the dio packaget
  ///
  /// You can read more about it here https://github.com/dart-ogurets/dart-openapi-maven
  dioAlt,

  /// This generates code based on the jaguar package Source gen is required
  /// after generating code with this generator
  /// corresponds to dart-jaguar
  ///
  /// An Http Api generator inspired by Retrofit for Dart
  jaguar,
}
enum Wrapper { fvm, flutterw, none }
