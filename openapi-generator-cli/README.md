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
