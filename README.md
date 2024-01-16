![pub package](https://img.shields.io/pub/v/openapi_generator.svg) ![Pub Likes](https://img.shields.io/pub/likes/openapi_generator?) ![Pub Points](https://img.shields.io/pub/points/openapi_generator) ![Pub Popularity](https://img.shields.io/pub/popularity/openapi_generator) ![GitHub Repo stars](https://img.shields.io/github/stars/gibahjoe/openapi-generator-dart)
[![codecov](https://codecov.io/gh/gibahjoe/openapi-generator-dart/graph/badge.svg?token=MF8SDQJMGP)](https://codecov.io/gh/gibahjoe/openapi-generator-dart)

### Like this library? Give us a star or a like.

This codebase houses the dart/flutter implementations of the openapi client sdk code generation libraries.

## TOC

- [Introduction](#introduction)
- [Usage](#usage)
- [NextGen](#next-generation)
- [Features & Bugs](#features-and-bugs)

## Introduction

With this project, you can generate client libraries from your openapi specification right in your
flutter/dart projects (see example). This library was inspired by the npm
counterpart [Openapi Generator Cli](https://www.npmjs.com/package/@openapitools/openapi-generator-cli)

[license](https://github.com/gibahjoe/openapi-generator-dart/blob/master/openapi-generator-annotations/LICENSE).

This repo contains the following dart libraries

| Library                       | Description                                                                                                                                                            | latest version                                                                                                               |
|-------------------------------|------------------------------------------------------------------------------------------------------------------------------------------------------------------------|------------------------------------------------------------------------------------------------------------------------------|
| openapi-generator             | Dev dependency for generating openapi client sdk via dart source gen [see here for usage](https://pub.dev/packages/openapi_generator)                                  | [![pub package](https://img.shields.io/pub/v/openapi_generator.svg)](https://pub.dev/packages/openapi_generator)             |
| openapi-generator-annotations | Annotations for annotating dart class with instructions for generating openapi client sdk [see here for usage](https://pub.dev/packages/openapi_generator_annotations) | [![pub package](https://img.shields.io/pub/v/openapi_generator_annotations.svg)](https://pub.dev/packages/openapi_generator) |
| openapi-generator-cli         | CLI only generator.  [see here for usage](https://pub.dev/packages/openapi_generator_cli)                                                                              | [![pub package](https://img.shields.io/pub/v/openapi_generator_cli.svg)](https://pub.dev/packages/openapi_generator_cli)     |

## Usage

Include [openapi-generator-annotations](https://pub.dev/packages/openapi_generator_annotations) as a dependency in the
dependencies section of your pubspec.yaml file :

```yaml
dependencies:
  openapi_generator_annotations: ^[latest-version]
```

For testing out the beta features in openapi generator, use the beta branch like below. This is not recommended for
production builds

```yaml
dependencies:
  openapi_generator_annotations:
    git:
      url: https://github.com/gibahjoe/openapi-generator-dart.git
      ref: beta
      path: openapi-generator-annotations
```

Add [openapi-generator](https://pub.dev/packages/openapi_generator) in the dev dependencies section of your pubspec.yaml
file:

```yaml
dev_dependencies:
  openapi_generator: ^[latest version]
```

For testing out the beta features in openapi generator, use the beta branch like below. This is not recommended for
production builds

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
  DioProperties(pubName: 'petstore_api', pubAuthor: 'Johnny dep..'),
  inputSpec:
  RemoteSpec(path: 'https://petstore3.swagger.io/api/v3/openapi.json'),
  typeMappings: {'Pet': 'ExamplePet'},
  generatorName: Generator.dio,
  runSourceGenOnOutput: true,
  outputDirectory: 'api/petstore_api',
)
```

Run

```shell
dart run build_runner build --delete-conflicting-outputs
```

or

```shell
flutter pub run build_runner build --delete-conflicting-outputs
```

to generate open api client sdk from spec file specified in annotation.
The api sdk will be generated in the folder specified in the annotation. See examples for more details

## Next Generation

As of version 5.0 of this library, there is some new functionality slated to be added to the generator. This version
will have the ability to:

- cache changes in the OAS spec
- Rerun when there ares difference in the cached copy and current copy
- Pull from a remote source and cache that.
    - **Note**: This means that your cache could be potentially stale. But in that case this flow will still pull the
      latest and run.
    - While this is a possible usage, if you are actively developing your spec it is preferred you provide a local copy.
- Skip generation based off:
    - Flags
    - No difference between the cache and local
- And all the functionality provided previously.

Your original workflow stay the same but there is a slight difference in the annotations.

New:

```dart
@Openapi(
  additionalProperties:
  DioProperties(pubName: 'petstore_api', pubAuthor: 'Johnny dep..'),
  inputSpec:
  RemoteSpec(path: 'https://petstore3.swagger.io/api/v3/openapi.json'),
  typeMappings: {'Pet': 'ExamplePet'},
  generatorName: Generator.dio,
  runSourceGenOnOutput: true,
  outputDirectory: 'api/petstore_api',
)
class Example {}
```


## Contributing

All contributions are welcome. Please ensure to read through our [contributing guidelines](Contributing.md) before
sending your PRs.

## Features and bugs

Please file feature requests and bugs at the [issue tracker][tracker].

[tracker]: https://github.com/gibahjoe/openapi-generator-dart/issues

<a href="https://www.buymeacoffee.com/gibahjoe" target="_blank"><img src="https://bmc-cdn.nyc3.digitaloceanspaces.com/BMC-button-images/custom_images/orange_img.png" alt="Buy Me A Coffee" style="height: auto !important;width: auto !important;" ></a>
