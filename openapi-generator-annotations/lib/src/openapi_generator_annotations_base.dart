/// Config base class
/// Your annotated class must extend this config class
abstract class OpenapiGeneratorConfig {}

class Openapi {
  /// Additional properties to pass to tge compiler (CSV)
  ///
  /// --additional-properties
  final AdditionalProperties additionalProperties;

  /// relative path or url to spec file
  ///
  /// -i
  final String inputSpecFile;

  /// Generator to use (see list command for list)
  ///
  /// -g, --generator-name
  final String generatorName;

  ///  Where to write the generated files (current dir by default)
  ///
  ///  -o, --output
  final String outputDirectory;

  ///  Specifies if the existing files should be overwritten during the generation
  ///
  ///  -s, --skip-overwrite
  final bool overwriteExistingFiles;

  /// Skips the default behavior of validating an input specification.
  ///
  /// --skip-validate-spec
  final bool skipValidateSpec;

  /// Tells openapi-generator to always run during the build process
  /// if set to false (the default), openapi-generator will skip processing if the [outputDirectory] already exists
  final bool alwaysRun;

  const Openapi(
      {this.additionalProperties,
      this.overwriteExistingFiles,
      this.skipValidateSpec = false,
      this.inputSpecFile,
      this.generatorName,
      this.outputDirectory,
      this.alwaysRun = false});
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
