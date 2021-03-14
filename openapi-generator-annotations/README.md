
[![pub package](https://img.shields.io/pub/v/openapi_generator_annotations.svg)](https://pub.dev/packages/openapi_generator)


This library is the dart/flutter implementation of openapi client sdk code generation.

With this library, you can generate openapi client sdk libraries from your openapi specification right in your flutter/dart projects. (see example)

To be used together with [openapi-generator](https://pub.dev/packages/openapi_generator)

[license](https://github.com/gibahjoe/openapi-generator-dart/blob/master/openapi-generator-annotations/LICENSE).

## Usage

Include [openapi-generator-annotations](https://pub.dev/packages/openapi_generator_annotations) as a dependency in the dependencies section of your pubspec.yaml file :

```yaml
dependencies:
  openapi_generator_annotations: ^2.2.0
```


Add [openapi-generator](https://pub.dev/packages/openapi_generator) in the dev dependencies section of your pubspec.yaml file:

```yaml
dev_dependencies:
  openapi_generator: ^2.2.0
```


Annotate a dart class with @Openapi() annotation

```dart
@Openapi(
    additionalProperties:
    AdditionalProperties(pubName: 'petstore_api', pubAuthor: 'Johnny depp'),
    inputSpecFile: 'example/openapi-spec.yaml',
    generatorName: Genrator.dart,
    outputDirectory: 'api/petstore_api')
class Example extends OpenapiGeneratorConfig {}
```

Run command below to generate open api client sdk from spec file specified in annotation. 
```cmd
flutter pub run build_runner build --delete-conflicting-outputs
```

The api sdk will be generated in the folder specified in the annotation. See examples for more details

Give a thumbs up if you like this library


## Known Issues
### Dependency issues/conflicts
This is not an issue with this library but with flutter/dart in general. If you are having issues with dependencies, what
you can do is make use of dependency overrides. This is added to the pubspec.yaml of the generated package and then the pubspec
must be added to the .openapi-generator-ignore of the generated package.
For example, let's assume you want to override the analyzer package for the generated source

in generatedsource/pubspec.yaml add the following
```yaml
dependency_overrides:
    analyzer: 1.0.0
```
Then in generatedsources/.openapi-generator-ignore, add the below so that the pubspec is not overwritten next time you run source gen
```.gitignore
pubspec.yaml
```
The above steps are usefull when you have issues with dependency conflicts, clashes. You can even use it to upgrade the library packages in the generated source.


## Features and bugs

Please file feature requests and bugs at the [issue tracker][tracker].

[tracker]: https://github.com/gibahjoe/openapi-generator-dart/issues
