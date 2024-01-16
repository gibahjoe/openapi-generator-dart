## [4.13.0](https://github.com/gibahjoe/openapi-generator-dart/compare/v4.12.0...v4.13.0) (2023-09-02)


### Features

* Add headers options for requests (nextGen only) ([bc4a170](https://github.com/gibahjoe/openapi-generator-dart/commit/bc4a170be1c011ca3e2843cf05a92a39965bcc29))
* Bumped versions to match ([506689c](https://github.com/gibahjoe/openapi-generator-dart/commit/506689c960491962c56cbb4418fc86dafc1a4c2e))


### Bug Fixes

* move to delegate, add tests, revert version requirement ([6a32542](https://github.com/gibahjoe/openapi-generator-dart/commit/6a32542cc7e09558db837d0313c4029951dc48ba))
* remove duplicate run test, fix failing tests ([677a318](https://github.com/gibahjoe/openapi-generator-dart/commit/677a3189d4f694c999d3ea1cf0075543649e40c1))
* repair the docker run command, update the type_methods to expand out the remote delegate ([c00b334](https://github.com/gibahjoe/openapi-generator-dart/commit/c00b3345d934e2f1508ba1129a3a769f86a85017))

## [4.13.2](https://github.com/gibahjoe/openapi-generator-dart/compare/v4.13.1...v4.13.2) (2024-01-16)


### Bug Fixes

* Consume testing version of the source_gen branch to simplify testing. ([37af696](https://github.com/gibahjoe/openapi-generator-dart/commit/37af696ac90f27e47c31f87bb5c60c952bf56230))
* Correct most of the tests while using the newest verison of the source gen changes ([4156d9a](https://github.com/gibahjoe/openapi-generator-dart/commit/4156d9a18bf83337e608219315d19abbe08f8bd8))
* dep overrides v2 ([ea76ec8](https://github.com/gibahjoe/openapi-generator-dart/commit/ea76ec8c12dc302b64060059f21b38fd75c45c93))

## [4.13.1](https://github.com/gibahjoe/openapi-generator-dart/compare/v4.13.0...v4.13.1) (2023-09-04)


### Bug Fixes

* **dependencies:** added required dependencies to pubspec ([7738439](https://github.com/gibahjoe/openapi-generator-dart/commit/7738439a89637bb1226f6586a0c9d311053e1702))
* fixes useEnumExtension and other non string additional properties fields throwing error ([53b711a](https://github.com/gibahjoe/openapi-generator-dart/commit/53b711a3c9319e31ec0b159edfc76674b62feb19))

## 4.12.0

- Added spec diff tracking. This means you Openapi generator now tracks changes to your spec and only regenerates the
  code if there are changes. This is useful if you have a large spec and you want to avoid regenerating the code every
  time you run your build. This is enabled by default. You can read more about it [here](../README.md#next-generation).
  Credits - [@Nexushunter](https://github.com/Nexushunter)
- Improved test coverage

## 4.11.0

- Bumped dart-ogurets (_dioAlt_) generator to 7.2
  with [changes](https://github.com/dart-ogurets/dart-openapi-maven#changelog)
- Bumped official openapi generator to 6.6.0.
  See [change log](https://github.com/OpenAPITools/openapi-generator/releases/tag/v6.4.0)
- fix endpoints returning null [#15433](https://github.com/OpenAPITools/openapi-generator/pull/15433)
- Drop default value when unnecessary [#15368](https://github.com/OpenAPITools/openapi-generator/pull/15368)

## 4.10.0

- Bumped dart-ogurets (_dioAlt_) generator to 7.1
  with [changes](https://github.com/dart-ogurets/dart-openapi-maven#changelog)
- Bumped official openapi generator to 6.4.0.
  See [change log](https://github.com/OpenAPITools/openapi-generator/releases/tag/v6.4.0)

## 4.0.0

- **BREAKING CHANGES**
  - `dioNext` (replaced with `dio`) and `jaguar` generators are removed.

- Bumped dart-ogurets (_dioAlt_) generator to 5.13
  with [changes](https://github.com/dart-ogurets/dart-openapi-maven#changelog)
- Bumped official openapi generator to 6.0.0.
  See [change log](https://github.com/OpenAPITools/openapi-generator/releases/tag/v6.0.0)

## 3.3.2

- Fix the enum value retrieval error

## 3.3.0

- Bumped dart-ogurets (_dioAlt_) generator to 5.11
  with [changes](https://github.com/dart-ogurets/dart-openapi-maven#changelog)
- Bumped official openapi generator to 5.3.0.
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
- Added support for nullSafe for _dioAlt_ generator
- Added support for import mappings

## 3.1.3
- Bumped dart-ogurets (_dioAlt_) generator to 5.3 with [changes](https://github.com/dart-ogurets/dart-openapi-maven#changelog)
- Bumped official openapi generator to 5.1.1. See [change log](https://github.com/OpenAPITools/openapi-generator/releases/tag/v5.1.1)

## 3.1.2
**NEW DART GENERATOR::**
A new dart generator has been added (_dioNext_). However, be careful because its **xperimental** and might be removed, renamed in the future or it might not even work well. You can read more about it here https://github.com/OpenAPITools/openapi-generator/pull/8869

## 3.1.0
- **BREAKING CHANGES**
- Bumped dart-ogurets (_dioAlt_) generator to 5.0 with [breaking changes](https://github.com/dart-ogurets/dart-openapi-maven#changelog)
- Bumped official openapi generator to 5.1.0. See [change log](https://github.com/OpenAPITools/openapi-generator/releases/tag/v5.1.0)

## 3.0.2
- ###BREAKING CHANGE -> Updated generator enums to camelCase and removed old ones.

## 3.0.0-nullsafety.1

- Bumped generator version to 5.0.0. This has some breaking changes. [Click here](https://github.com/OpenAPITools/openapi-generator/releases/tag/v5.0.0) to view changes
- bumped null safety

## 2.2.0

- Added support for flutter wrappers
- Bumped dart-ogurets generator to 4.1 with [breaking changes](https://github.com/dart-ogurets/dart-openapi-maven#changelog)

## 2.0.0

- Bumped generator version to 5.0.0. This has some breaking changes. [Click here](https://github.com/OpenAPITools/openapi-generator/releases/tag/v5.0.0) to view changes

## 2.0.0-nullsafety.0

- Added null safety

## 1.1.4

- Updated dart_2 api to version 3.10
- Added pubname to DioProperties

## 1.1.3

- Updated dart_2 api to latest
- Added support for reservedWordsMapping

## 1.1.2

- Added support for skipping post build actions

## 1.1.1

- Fixed build issue

## 1.1.0

- Added support for **_dart2-api_** from [dart-ogurets](https://github.com/dart-ogurets/dart-openapi-maven) 
thanks to [Robert Csakany](https://github.com/robertcsakany)
- [Breaking change] - Changed generator name to enum

## 1.0.8

- fixed typo

## 1.0.7

- Added support for specifying template directory using -t

## 1.0.5

- Improved support for dart-jaguar

## 1.0.2

- Updated documentation

## 0.0.2-dev

- Changed version to dev since this package is still in active development

## 0.0.1

- Initial version
