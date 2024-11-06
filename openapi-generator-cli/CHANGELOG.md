## [5.0.2](https://github.com/gibahjoe/openapi-generator-dart/compare/v5.0.0...v5.0.2) (2024-01-16)

### Bug Fixes

* fixed spec diff tracking

## [6.0.0](https://github.com/gibahjoe/openapi-generator-dart/compare/v5.0.3...v6.0.0) (2024-11-06)


### ⚠ BREAKING CHANGES

* `forceAlwaysRun` is used to represent if the library should run  everytime `build_runner` is executed. This is done by modifying the annotated file after `build_runner` completes. Previous versions of this library did not have this flag but they had the equivalent of `true`. However, this now defaults to `false`. To keep previous behavior, set this flag to `true`.

### Features

* added fields `skipIfSpecUnchanged` and `forceAlwaysRun` ([d5555dd](https://github.com/gibahjoe/openapi-generator-dart/commit/d5555dda4281091102342ade5c0103c9757ac3c4))
* Changing to a config based approach for obtaining the official openapi generator jar. ([05d61f7](https://github.com/gibahjoe/openapi-generator-dart/commit/05d61f7f323479af971dbfc3c07377cc57ce6792))
* **cli:** bumped official generator version to 7.7 ([d8b9de1](https://github.com/gibahjoe/openapi-generator-dart/commit/d8b9de1a948ea5958ecfe85bcf228b97e0f2a8fd))
* **cli:** bumped unofficial generator version to 8.1 ([2fdd022](https://github.com/gibahjoe/openapi-generator-dart/commit/2fdd022bbcca07dc03bd743e378dbc10b9f0503f))
* **cli:** removed jar binary from library and made the jar downloadable by auto generated config ([8131e8e](https://github.com/gibahjoe/openapi-generator-dart/commit/8131e8eedcd3d9ba853b5b45fafd9f4c6c0fe1d7)), closes [#153](https://github.com/gibahjoe/openapi-generator-dart/issues/153)

## [5.0.1](https://github.com/gibahjoe/openapi-generator-dart/compare/v5.0.0...v5.0.1) (2024-01-16)

### Bug Fixes

* **annotation:** fixed
  formatting ([b21a177](https://github.com/gibahjoe/openapi-generator-dart/commit/b21a1778ee27fc965c6ba092da63582ce6563f75))

## [5.0.0](https://github.com/gibahjoe/openapi-generator-dart/compare/v4.13.1...v5.0.0) (2024-01-16)

### ⚠ BREAKING CHANGES

* **cli:** removed various deprecated methods and properties such as inputSpecFile

### Features

* **annotation:** removed deprecated properties from
  annotation ([51d3683](https://github.com/gibahjoe/openapi-generator-dart/commit/51d3683bb83dc3e8f0f05d9d4913e11d3cc82b0f))
* **cli:** bumped official generator version to
  7.2 ([51d3683](https://github.com/gibahjoe/openapi-generator-dart/commit/51d3683bb83dc3e8f0f05d9d4913e11d3cc82b0f))
* **generator:** moved completely to
  newgen ([51d3683](https://github.com/gibahjoe/openapi-generator-dart/commit/51d3683bb83dc3e8f0f05d9d4913e11d3cc82b0f))

## [4.13.0](https://github.com/gibahjoe/openapi-generator-dart/compare/4.12.0...v4.13.0) (2023-09-02)


### Features

* Bumped versions to match ([506689c](https://github.com/gibahjoe/openapi-generator-dart/commit/506689c960491962c56cbb4418fc86dafc1a4c2e))

## [4.13.1](https://github.com/gibahjoe/openapi-generator-dart/compare/v4.13.0...v4.13.1) (2023-09-04)


### Bug Fixes

* Trigger version bump for CLI ([996f328](https://github.com/gibahjoe/openapi-generator-dart/commit/996f3281cad0bdaf58a3d0bbdc4df7dbdc7b135f))

## 4.12.0

- Bumped version to match annotations and core.

## 4.11.0

- Bumped dart-ogurets (_dioAlt_) generator to 7.2
  with [changes](https://github.com/dart-ogurets/dart-openapi-maven#changelog)
- Bumped official openapi generator to 6.6.0.
  See [change log](https://github.com/OpenAPITools/openapi-generator/releases/tag/v6.6.0)
- fix endpoints returning null [#15433](https://github.com/OpenAPITools/openapi-generator/pull/15433)
- Drop default value when unnecessary [#15368](https://github.com/OpenAPITools/openapi-generator/pull/15368)

## 4.10.0

- Bumped dart-ogurets (_dioAlt_) generator to 7.1
  with [changes](https://github.com/dart-ogurets/dart-openapi-maven#changelog)
- Bumped official openapi generator to 6.4.0.
  See [change log](https://github.com/OpenAPITools/openapi-generator/releases/tag/v6.4.0)

## 4.0.0

- Bumped dart-ogurets (_dioAlt_) generator to 5.13
  with [changes](https://github.com/dart-ogurets/dart-openapi-maven#changelog)
- Bumped official openapi generator to 6.0.0.
  See [change log](https://github.com/OpenAPITools/openapi-generator/releases/tag/v6.0.0)

## 3.3.0

- Bumped dart-ogurets (_dioAlt_) generator to 5.11
  with [changes](https://github.com/dart-ogurets/dart-openapi-maven#changelog)
- Bumped official openapi generator to 5.3/0.
  See [change log](https://github.com/OpenAPITools/openapi-generator/releases/tag/v5.3.0)

## 3.2.1

- Bumped dart-ogurets (_dioAlt_) generator to 5.9
  with [changes](https://github.com/dart-ogurets/dart-openapi-maven#changelog)
- Bumped official openapi generator to 5.2.1.
  See [change log](https://github.com/OpenAPITools/openapi-generator/releases/tag/v5.2.1)

## 3.2.0

- Bumped dart-ogurets (_dioAlt_) generator to 5.8
  with [changes](https://github.com/dart-ogurets/dart-openapi-maven#changelog)
- Bumped official openapi generator to 5.2.0.
  See [change log](https://github.com/OpenAPITools/openapi-generator/releases/tag/v5.2.0)

## 3.1.3
- Bumped dart-ogurets (_dioAlt_) generator to 5.3 with [changes](https://github.com/dart-ogurets/dart-openapi-maven#changelog)
- Bumped official openapi generator to 5.1.1. See [change log](https://github.com/OpenAPITools/openapi-generator/releases/tag/v5.1.1)

## 3.1.0
- **BREAKING CHANGES**
- Bumped dart-ogurets (_dioAlt_) generator to 5.0 with [breaking changes](https://github.com/dart-ogurets/dart-openapi-maven#changelog)
- Bumped official openapi generator to 5.1.0. See [change log](https://github.com/OpenAPITools/openapi-generator/releases/tag/v5.1.0)

## 3.0.2
- Bumped dart-ogurets generator to 4.2 with [breaking changes](https://github.com/dart-ogurets/dart-openapi-maven#changelog)
- Bumped official openapi generator to 5.0.1. See [change log](https://github.com/OpenAPITools/openapi-generator/releases/tag/v5.0.1)

## 2.2.0

- Bumped dart-ogurets generator to 4.1 with [breaking changes](https://github.com/dart-ogurets/dart-openapi-maven#changelog)

## 3.0.0-nullsafety.1

- Bumped null safety version

## 2.0.0

- Bumped generator version to 5.0.0. This has some breaking changes. [Click here](https://github.com/OpenAPITools/openapi-generator/releases/tag/v5.0.0) to view changes

## 2.0.0-nullsafety.0

- Added null safety

## 1.1.4

- Updated dart_2 api to version 3.10

## 1.1.3

- Updated dart_2 api to latest
- Added support for reservedWordsMapping

## 1.1.2

- Updated Dart2-api support

## 1.1.0

- Added support for **_dart2-api_** from [dart-ogurets](https://github.com/dart-ogurets/dart-openapi-maven) 
thanks to [Robert Csakany](https://github.com/robertcsakany)

## 1.0.8

- Updated Generator to 4.3.1 [Check here for details](https://github.com/OpenAPITools/openapi-generator)

## 1.0.5

- Updated openapi to 4.3.0

## 1.0.1

- Updated docs

## 1.0.0

- Updated readme

## 0.0.3

- Support for inclusion of JAVA arguments

## 0.0.1

- Initial version
