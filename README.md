This codebase houses the dart/flutter implementations of the openapi client sdk code generation libraries.

With this project, you can generate openapi client sdk libraries for your openapi specification right in your flutter/dart projects. (see example)

[license](https://github.com/gibahjoe/openapi-generator-dart/blob/master/openapi-generator-annotations/LICENSE).


This repo contains the following dart libraries

| Library       | Description | latest version |
|---------------|-------------|---------------|
| openapi-generator |Dev dependency for generating openapi sdk via dart source gen [see here for usage](https://pub.dev/packages/openapi_generator)| [![pub package](https://img.shields.io/pub/v/openapi_generator.svg)](https://pub.dev/packages/openapi_generator)|
| openapi-generator-annotations|Annotations for annotating dart class with instructions for generating openapi sdk [see here for usage](https://pub.dev/packages/openapi_generator_annotations)|[![pub package](https://img.shields.io/pub/v/openapi_generator_annotations.svg)](https://pub.dev/packages/openapi_generator)|
| openapi-generator-cli |Cli code openapi sdk generator for dart [see here for usage](https://pub.dev/packages/openapi_generator_cli)|[![pub package](https://img.shields.io/pub/v/openapi_generator_cli.svg)](https://pub.dev/packages/openapi_generator_cli)|



## Usage

Include [openapi-generator-annotations](https://pub.dev/packages/openapi_generator_annotations) as a dependency in the dependencies section of your pubspec.yaml file :

```yaml
dependencies:
  openapi_generator_annotations: ^[latest-version]
```
For testing out the beta features in openapi generator, use the beta branch like below. This is not recommended for production builds
```yaml
dependencies:
  openapi_generator_annotations: 
    git:
      url: https://github.com/gibahjoe/openapi-generator-dart.git
      ref: beta
      path: openapi-generator-annotations
```


Add [openapi-generator](https://pub.dev/packages/openapi_generator) in the dev dependencies section of your pubspec.yaml file:

```yaml
dev_dependencies:
  openapi_generator: ^[latest version]
```
For testing out the beta features in openapi generator, use the beta branch like below. This is not recommended for production builds
```yaml
dev_dependencies:
  openapi_generator: 
    git:
      url: https://github.com/gibahjoe/openapi-generator-dart.git
      ref: beta
      path: openapi-generator
```

Annotate a dart class with @Openapi() annotation

```dart
@Openapi(
    additionalProperties:
    AdditionalProperties(pubName: 'petstore_api', pubAuthor: 'Johnny dep'),
    inputSpecFile: 'example/openapi-spec.yaml',
    generatorName: Generator.dart,
    outputDirectory: 'api/petstore_api')
class Example extends OpenapiGeneratorConfig {}
```

Run 
```cmd
flutter pub run build_runner build --delete-conflicting-outputs
```
to generate open api client sdk from spec file specified in annotation. 
The api sdk will be generated in the folder specified in the annotation. See examples for more details



## Features and bugs

Please file feature requests and bugs at the [issue tracker][tracker].

[tracker]: https://github.com/gibahjoe/openapi-generator-dart/issues
