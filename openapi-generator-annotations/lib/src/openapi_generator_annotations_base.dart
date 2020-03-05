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
}

class Openapi {
  final String baseUrl;

  final AdditionalProperties additionalProperties;
  final String inputSpecFile;

  /// generator to use (see list command for list)
  /// -g, --generator-name
  final String generatorName;

  ///  where to write the generated files (current dir by default)
  ///  -o, --output
  final String outputDirectory;

  ///  specifies if the existing files should be overwritten during the generation
  ///  -s, --skip-overwrite
  final bool overwriteExistingFiles;

  /// Skips the default behavior of validating an input specification.
  /// --skip-validate-spec
  final bool validateSpec;

  const Openapi(
      {this.additionalProperties,
      this.overwriteExistingFiles,
      this.validateSpec = true,
      this.inputSpecFile,
      this.generatorName,
      this.outputDirectory,
      this.baseUrl});
}

class AdditionalProperties {
  ///  toggles whether unicode identifiers are allowed in names or not, default is false
  final bool allowUnicodeIdentifiers;

  /// Whether to ensure parameter names are unique in an operation (rename parameters that are not).
  final bool ensureUniqueParams;

  /// Add form or body parameters to the beginning of the parameter list.
  final bool prependFormOrBodyParameters;

  ///	Author name in generated pubspec
  final String pubAuthor;

  /// 	Email address of the author in generated pubspec
  final String pubAuthorEmail;

  ///	Description in generated pubspec
  final String pubDescription;

  ///	Homepage in generated pubspec
  final String pubHomepage;

  ///	Name in generated pubspec
  final String pubName;

  /// Version in generated pubspec
  final String pubVersion;

  /// Sort model properties to place required parameters before optional parameters.
  final bool sortModelPropertiesByRequiredFlag;

  /// Sort method arguments to place required parameters before optional parameters.
  final bool sortParamsByRequiredFlag;

  /// Source folder for generated code
  final bool sourceFolder;

  const AdditionalProperties(
      {this.allowUnicodeIdentifiers = false,
      this.ensureUniqueParams = true,
      this.prependFormOrBodyParameters = false,
      this.pubAuthor,
      this.pubAuthorEmail,
      this.pubDescription,
      this.pubHomepage,
      this.pubName,
      this.pubVersion,
      this.sortModelPropertiesByRequiredFlag = true,
      this.sortParamsByRequiredFlag = true,
      this.sourceFolder});

  String _append(String base, String str) {
    return '$base,$str';
  }
}
