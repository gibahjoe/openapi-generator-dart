Annotation library for dart/flutter implementation of openapi client code generation.

Created from templates made available by Stagehand under a BSD-style
[license](https://github.com/dart-lang/stagehand/blob/master/LICENSE).

## Usage

A simple usage example:

```dart
@Openapi(
    additionalProperties:
    AdditionalProperties(pubName: 'petstore_api', pubAuthor: 'Johnny dep'),
    inputSpecFile: 'example/openapi-spec.yaml',
    generatorName: 'dart-jaguar',
    outputDirectory: 'api/petstore_api')
class Example extends OpenapiGeneratorConfig {}
```

## Features and bugs

Please file feature requests and bugs at the [issue tracker][tracker].

[tracker]: https://github.com/gibahjoe/openapi-generator-dart/issues
