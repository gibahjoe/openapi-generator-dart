
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
    generatorName: Generator.dart,
    outputDirectory: 'api/petstore_api')
class Example extends OpenapiGeneratorConfig {}
```

Run command below to generate open api client sdk from spec file specified in annotation. 
```cmd
flutter pub run build_runner build --delete-conflicting-outputs
```

The api sdk will be generated in the folder specified in the annotation. See examples for more details

To use the generated api in your project, import it into your pubspec

Give a thumbs up if you like this library


## Known Issues

Check out the known issues article here [Known Issues](../openapi-generator-annotations/README.md#known-issues)

## Features and bugs

Please file feature requests and bugs at the [issue tracker][tracker].

[tracker]: https://github.com/gibahjoe/openapi-generator-dart/issues


<a href="https://www.buymeacoffee.com/gibahjoe" target="_blank"><img src="https://bmc-cdn.nyc3.digitaloceanspaces.com/BMC-button-images/custom_images/orange_img.png" alt="Buy Me A Coffee" style="height: auto !important;width: auto !important;" ></a>
