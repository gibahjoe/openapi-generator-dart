Generator library for dart/flutter implementation of openapi client code generation.
To be used together with [openapi-generator-annotations](https://pub.dev/packages/openapi_generator_annotations)

[license](https://github.com/gibahjoe/openapi-generator-dart/blob/master/openapi-generator-annotations/LICENSE).

## Usage

Include [openapi-generator-annotations](https://pub.dev/packages/openapi_generator_annotations) as a dependency in the dependencies section of your pubspec.yaml file :

```yaml
dependencies:
  openapi_generator_annotations: ^1.0.5
```


Add [openapi-generator](https://pub.dev/packages/openapi_generator) in the dev dependencies section of your pubspec.yaml file:

```yaml
dev_dependencies:
  openapi_generator: ^1.0.5
```


Annotate a dart class with @Openapi() annotation

```dart
@Openapi(
    additionalProperties:
    AdditionalProperties(pubName: 'petstore_api', pubAuthor: 'Johnny dep'),
    inputSpecFile: 'example/openapi-spec.yaml',
    generatorName: 'dart-jaguar',
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
