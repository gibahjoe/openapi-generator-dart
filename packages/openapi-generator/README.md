# openapi-generator-dart

[![pub package](https://img.shields.io/pub/v/openapi_generator.svg)](https://pub.dev/packages/openapi_generator)
[![Pub Likes](https://img.shields.io/pub/likes/openapi_generator?)](https://pub.dev/packages/openapi_generator)
[![Pub Points](https://img.shields.io/pub/points/openapi_generator)](https://pub.dev/packages/openapi_generator)
[![Pub Popularity](https://img.shields.io/pub/popularity/openapi_generator)](https://pub.dev/packages/openapi_generator)
[![GitHub Repo stars](https://img.shields.io/github/stars/gibahjoe/openapi-generator-dart)](https://github.com/gibahjoe/openapi-generator-dart)
[![codecov](https://codecov.io/gh/gibahjoe/openapi-generator-dart/graph/badge.svg?token=MF8SDQJMGP)](https://codecov.io/gh/gibahjoe/openapi-generator-dart)

> **Like this library?** Give us a star or a like!

---

## ⚠️ Java Requirement

> **Java is required to use this library.**  
> The OpenAPI Generator CLI is a Java application.  
> Please ensure you have Java (version 8 or higher) installed and available in your system PATH.  
> You can check your Java installation with:
>
> ```sh
> java -version
> ```
>
> If you do not have Java installed, download it from [Adoptium](https://adoptium.net/) or [Oracle](https://www.oracle.com/java/technologies/downloads/).

---

## ⚠️ Deprecation & Breaking Change Notice

### `skipIfSpecIsUnchanged` is Deprecated

- The `skipIfSpecIsUnchanged` option is now **deprecated** and will be removed in the next major release.
- **Local OpenAPI specs** are now automatically watched for changes.  
  - If your spec file is in the `lib/` folder, this works out of the box.
  - If your spec file is outside `lib/`, you must update or add a `build.yaml` to include your spec file as a source.  
    Example:
    ```yaml
    targets:
      $default:
        sources:
          - $package$
          - lib/**
          - openapi.yaml # or your spec file path
    ```
- **Remote specs:**  
  Use the `forceAlwaysRun` (defaults to false) option to ensure the generator always runs.  
  - This option is ignored for local specs.
  - When enabled, it modifies the annotated file to force regeneration. This might cause issues such as merge conflicts

---

## Overview

This repository provides Dart/Flutter libraries for generating OpenAPI client SDKs directly from your OpenAPI specification. Inspired by [Openapi Generator Cli (npm)](https://www.npmjs.com/package/@openapitools/openapi-generator-cli), it enables seamless integration into Dart and Flutter projects.

### Libraries

| Library                       | Description                                                                                                                      | Latest Version                                                                                                               |
|-------------------------------|----------------------------------------------------------------------------------------------------------------------------------|------------------------------------------------------------------------------------------------------------------------------|
| openapi-generator             | Dev dependency for generating OpenAPI client SDK via Dart source gen ([usage](https://pub.dev/packages/openapi_generator))        | [![pub package](https://img.shields.io/pub/v/openapi_generator.svg)](https://pub.dev/packages/openapi_generator)             |
| openapi-generator-annotations | Annotations for configuring OpenAPI client SDK generation ([usage](https://pub.dev/packages/openapi_generator_annotations))        | [![pub package](https://img.shields.io/pub/v/openapi_generator_annotations.svg)](https://pub.dev/packages/openapi_generator_annotations) |
| openapi-generator-cli         | CLI wrapper for OpenAPI code generation ([usage](https://pub.dev/packages/openapi_generator_cli))                                 | [![pub package](https://img.shields.io/pub/v/openapi_generator_cli.svg)](https://pub.dev/packages/openapi_generator_cli)     |

---

## Quick Start

### 1. Add Dependencies

Add the annotations package to your `pubspec.yaml`:

```yaml
dependencies:
  openapi_generator_annotations: ^<latest-version>
```

Add the generator as a dev dependency:

```yaml
dev_dependencies:
  openapi_generator: ^<latest-version>
```

> **Beta Features:**  
> For beta features, use the `beta` branch:
>
> ```yaml
> dependencies:
>   openapi_generator_annotations:
>     git:
>       url: https://github.com/gibahjoe/openapi-generator-dart.git
>       ref: beta
>       path: openapi-generator-annotations
>
> dev_dependencies:
>   openapi_generator:
>     git:
>       url: https://github.com/gibahjoe/openapi-generator-dart.git
>       ref: beta
>       path: openapi-generator
> ```

### 2. Annotate Your Dart Class

Annotate a Dart class with `@Openapi()` to configure code generation:

```dart
import 'package:openapi_generator_annotations/openapi_generator_annotations.dart';

@Openapi(
  additionalProperties: DioProperties(pubName: 'petstore_api', pubAuthor: 'Johnny Depp'),
  inputSpec: RemoteSpec(path: 'https://petstore3.swagger.io/api/v3/openapi.json'),
  typeMappings: {'Pet': 'ExamplePet'},
  generatorName: Generator.dio,
  runSourceGenOnOutput: true,
  outputDirectory: 'api/petstore_api',
)
class Example {}
```

### 3. Generate the SDK

Run the build command:

```sh
dart run build_runner build --delete-conflicting-outputs
# or, for Flutter projects:
flutter pub run build_runner build --delete-conflicting-outputs
```

The generated SDK will appear in the specified output directory.

---

## Next Generation Features (v5.0+)

- **Spec Caching:** Automatically caches your OpenAPI spec for faster incremental builds.
- **Remote Spec Support:** Pulls and caches remote specs; always fetches the latest version unless using a local copy.
- **Smart Generation:** Skips code generation if there are no changes in the spec or based on flags.
- **All previous features remain available.**

**Example:**

```dart
@Openapi(
  additionalProperties: DioProperties(pubName: 'petstore_api', pubAuthor: 'Johnny Depp'),
  inputSpec: RemoteSpec(path: 'https://petstore3.swagger.io/api/v3/openapi.json'),
  typeMappings: {'Pet': 'ExamplePet'},
  generatorName: Generator.dio,
  runSourceGenOnOutput: true,
  outputDirectory: 'api/petstore_api',
)
class Example {}
```

---

## Advanced Configuration

If you are having issues with the generated code, this is not an problem with this package and creating an issue here will not help solve it. Its best to [create the issue in the base OpenApi library](https://github.com/OpenAPITools/openapi-generator/issues) since this package is a wrapper around that library for ease of use with Flutter/dart.

Below are some advanced configurations you may try.

- **Custom Templates:**  
  Use the `templateDirectory` parameter to specify a custom code generation template.

- **Type & Import Mappings:**  
  Use `typeMappings` and `importMappings` to control how OpenAPI types and models are mapped in Dart.

- **Reserved Words:**  
  Use `reservedWordsMappings` to avoid conflicts with Dart reserved words.

**Example:**

```dart
@Openapi(
  additionalProperties: DioProperties(pubName: 'custom_api', pubAuthor: 'Jane Doe'),
  inputSpec: InputSpec(path: 'openapi-spec.yaml'),
  generatorName: Generator.dio,
  templateDirectory: 'templates/dart',
  typeMappings: {'date': 'DateTime'},
  importMappings: {'DateTime': 'package:my_project/date_time.dart'},
  reservedWordsMappings: {'class': 'clazz'},
  outputDirectory: 'api/custom_api',
)
class CustomApi {}
```

---

## Troubleshooting

### Common Issues

- **Dependency Conflicts:**  
  Use `dependency_overrides` in the generated package's `pubspec.yaml` and add `pubspec.yaml` to `.openapi-generator-ignore` to prevent overwrites.

- **Incorrect Generated Code:**  
  - Fix your OpenAPI spec (preferred).
  - Manually edit the generated code and add the files to `.openapi-generator-ignore` to prevent them from being overwritten.

**.openapi-generator-ignore Example:**

```gitignore
# Ignore all test files
test/*
# Ignore pubspec.yaml to preserve manual changes
pubspec.yaml
```

- **Mockito / `@GenerateMocks` fails on first run in CI:**  
  `mockito:mockBuilder` resolves types at the start of the build. On a fresh checkout the
  generated API package does not yet exist, so `mockito` cannot resolve the classes listed
  in `@GenerateMocks` and fails with *"unknown type"*.

  `openapi_generator` is already configured to run before `mockito:mockBuilder`, but
  because the generated code lives in a **separate package**, `build_runner` cannot make
  those types visible to `mockito` within the same build invocation.

  **CI workaround — run `build_runner` twice:**

  ```yaml
  # GitHub Actions example
  - name: Generate API (first pass)
    run: dart run build_runner build --delete-conflicting-outputs || true
  - name: Re-sync dependencies
    run: dart pub get
  - name: Generate mocks (second pass)
    run: dart run build_runner build --delete-conflicting-outputs
  ```

  The first pass generates the API package; `dart pub get` registers it with the
  resolver; the second pass finds the types and generates the mocks successfully.