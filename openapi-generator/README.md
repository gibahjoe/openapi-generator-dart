[![pub package](https://img.shields.io/pub/v/openapi_generator.svg)](https://pub.dev/packages/openapi_generator)

This library is the dart/flutter implementation of openapi client sdk code generation.

With this library, you can generate openapi client sdk libraries from your openapi specification right in your
flutter/dart projects. (see example)

To be used together with [openapi-generator-annotations](https://pub.dev/packages/openapi_generator_annotations)

## Usage

Include [openapi-generator-annotations](https://pub.dev/packages/openapi_generator_annotations) as a dependency in the
dependencies section of your pubspec.yaml file :

```yaml
dependencies:
  openapi_generator_annotations: ^4.11.0
```

Add [openapi-generator](https://pub.dev/packages/openapi_generator) in the dev dependencies section of your pubspec.yaml
file:

```yaml
dev_dependencies:
  openapi_generator: ^4.11.0
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

Run command below to generate open api client sdk from spec file specified in annotation.

```cmd
flutter pub run build_runner build --delete-conflicting-outputs
```

The api sdk will be generated in the folder specified in the annotation. See examples for more details

## Known Issues

### Dependency issues/conflicts

This is not an issue with this library but with flutter/dart in general. If you are having issues with dependencies,
what
you can do is make use of dependency overrides. This is added to the pubspec.yaml of the generated package and then the
pubspec
must be added to the .openapi-generator-ignore of the generated package.
For example, let's assume you want to override the analyzer package for the generated source

in generatedsource/pubspec.yaml add the following

```yaml
dependency_overrides:
  analyzer: 1.0.0
```

Then in generatedsources/.openapi-generator-ignore, add the below so that the pubspec is not overwritten next time you
run source gen

```.gitignore
pubspec.yaml
```

The above steps are useful when you have issues with dependency conflicts, clashes. You can even use it to upgrade the
library packages in the generated source.

## FAQ

Q: I run source gen (`flutter pub run build_runner build --delete-conflicting-outputs`), The api generator does not run.

A: The source generator of flutter only runs when there are changes to the file that has the annotation. If this ever
happens, just go to the file that has the `@openapi` annotation and edit something in the file.

Q: How do I prevent files from being generated e.g tests

A: To prevent any files from being generated, you need to add it to ```.openapi-generator-ignore```. This file is in the
root of the generated code. For example, to prevent generating tests, add ```test/*``` to the file.

## Features and bugs

Please file feature requests and bugs at the [issue tracker][tracker].

[tracker]: https://github.com/gibahjoe/openapi-generator-dart/issues

## Running Tests

Requirements:

- [Docker](https://www.docker.com/products/docker-desktop/)

<a href="https://www.buymeacoffee.com/gibahjoe" target="_blank"><img src="https://bmc-cdn.nyc3.digitaloceanspaces.com/BMC-button-images/custom_images/orange_img.png" alt="Buy Me A Coffee" style="height: auto !important;width: auto !important;" ></a>
