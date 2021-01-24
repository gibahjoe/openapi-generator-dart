[![pub package](https://img.shields.io/pub/v/openapi_generator_cli.svg)](https://pub.dev/packages/openapi_generator_cli)

CLI generator wrapper for dart/flutter implementation of openapi client code generation.

OpenAPI Generator allows generation of API client libraries (SDK generation), server stubs, 
documentation and configuration automatically given an OpenAPI Spec. 
Please see [OpenAPITools/openapi-generator](https://github.com/OpenAPITools/openapi-generator) for more information

[license](https://github.com/gibahjoe/openapi-generator-dart/blob/master/openapi-generator-annotations/LICENSE).

## Usage

### CLI
Run

```cmd
pub global activate openapi_generator_cli
```

Then you can run the generator using the command below.
```cmd
openapi-generator generate -i http://127.0.0.1:8111/v3/api-docs -g dart
```
See [OpenAPITools/openapi-generator](https://github.com/OpenAPITools/openapi-generator) for more commands

Note:
Pub installs executables into `{flutter sdk dir}/.pub-cache/bin`, which has to be in your `PATH` for the above command to work.

### Dart/Flutter

You can use this package also using the openapi-generator dart plugin that helps you configure the appropriate commands. You can find it [here](https://pub.dev/packages/openapi_generator) 

## Features and bugs

Please file feature requests and bugs at the [issue tracker][tracker].

[tracker]: https://github.com/gibahjoe/openapi-generator-dart/issues
