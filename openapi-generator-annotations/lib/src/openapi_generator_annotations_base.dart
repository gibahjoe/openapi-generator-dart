// TODO: Put public facing types in this file.
/// Checks if you are awesome. Spoiler: you are.
class Awesome {
  bool get isAwesome => true;
}

abstract class OpenapiGeneratorConfig {
  Map<String, String> additionalProperties;
  String inputSpecFile;
  String generator;
  String outputDirectory;

  ///  specifies if the existing files should be overwritten during the generation
  ///  -s, --skip-overwrite
  bool overwriteExistingFiles;

  /// Skips the default behavior of validating an input specification.
  /// --skip-validate-spec
  bool validateSpec;
}

class Openapi {
  final String baseUrl;
  final Map<String, String> additionalProperties;
  final String inputSpecFile;
  final String generator;
  final String outputDirectory;

  const Openapi(
      {this.additionalProperties,
      this.inputSpecFile,
      this.generator,
      this.outputDirectory,
      this.baseUrl});
}
class AdditionalProperties {
  ///  toggles whether unicode identifiers are allowed in names or not, default is false
  bool allowUnicodeIdentifiers=false;
  /// Whether to ensure parameter names are unique in an operation (rename parameters that are not).
  bool ensureUniqueParams=true;
  /// Add form or body parameters to the beginning of the parameter list.
  bool prependFormOrBodyParameters	=		false;
  ///	Author name in generated pubspec
  String pubAuthor;
  /// 	Email address of the author in generated pubspec
  String pubAuthorEmail	;
  ///	Description in generated pubspec
  String pubDescription;
  ///	Homepage in generated pubspec
  String pubHomepage;
  ///	Name in generated pubspec
  String pubName;
  /// Version in generated pubspec
  String pubVersion;
  /// Sort model properties to place required parameters before optional parameters.
  bool sortModelPropertiesByRequiredFlag=true;
  /// 	Sort method arguments to place required parameters before optional parameters.
  bool sortParamsByRequiredFlag	=	true;
  /// 	Source folder for generated code
  bool sourceFolder;
//  useEnumExtension	Allow the 'x-enum-values' extension for enums		null
}
