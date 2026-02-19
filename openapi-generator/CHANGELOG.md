## [5.0.2](https://github.com/gibahjoe/openapi-generator-dart/compare/v5.0.0...v5.0.2) (2024-01-16)

### Bug Fixes

* fixed spec diff tracking

## [6.2.0](https://github.com/gibahjoe/openapi-generator-dart/compare/v6.1.0...v6.2.0) (2026-02-19)


### Features

* **generator:** add cleanOutputDirectory flag ([#19](https://github.com/gibahjoe/openapi-generator-dart/issues/19)) ([e12f1a1](https://github.com/gibahjoe/openapi-generator-dart/commit/e12f1a1279439758006c1b5c3fc7cef0c787cdc1))


### Bug Fixes

* add support for remote specs without extensions. Closes [#176](https://github.com/gibahjoe/openapi-generator-dart/issues/176) ([c08164d](https://github.com/gibahjoe/openapi-generator-dart/commit/c08164d7db64725ceddd250ab7e18fd8926b9ff7))
* **command:** simplify argument wrapping for fvm wrapper ([1f4da4a](https://github.com/gibahjoe/openapi-generator-dart/commit/1f4da4a34bcf62b66c73396fa5bd45bb7511e498))
* Enhance OpenAPI generator with new features and improvements ([a0a2594](https://github.com/gibahjoe/openapi-generator-dart/commit/a0a2594deaab004e5e4e950413c885c5b666154b))
* **generator:** prepend 'flutter' to fvm args and use runInShell: true ([#129](https://github.com/gibahjoe/openapi-generator-dart/issues/129)) ([99ad2a1](https://github.com/gibahjoe/openapi-generator-dart/commit/99ad2a16804d56c25956cd4f442f004e0e274891))
* **generator:** prevent AssetId crash for spec paths outside package root ([0df1fc0](https://github.com/gibahjoe/openapi-generator-dart/commit/0df1fc033d05e27fedd34b07173f517339520619)), closes [#198](https://github.com/gibahjoe/openapi-generator-dart/issues/198)
* **generator:** use runInShell and auto-create outputDirectory ([#164](https://github.com/gibahjoe/openapi-generator-dart/issues/164)) ([e651c09](https://github.com/gibahjoe/openapi-generator-dart/commit/e651c09a7fb0b1d9f0d1e2933f9a6f424c618f92))
* Notify `build_runner` of dependency on inputSpec ([#187](https://github.com/gibahjoe/openapi-generator-dart/issues/187)) ([b4c15ee](https://github.com/gibahjoe/openapi-generator-dart/commit/b4c15ee23648437c41f8049c6844e1e12ddf7f03))
* Remove deprecated skipIfSpecIsUnchanged and skipSpecDepMessage ([#193](https://github.com/gibahjoe/openapi-generator-dart/issues/193)) ([bc06852](https://github.com/gibahjoe/openapi-generator-dart/commit/bc068529d0f3a572db85cc4efe43e3b94feb9ee2))
* update build_test dependency version to &gt;=2.0.0 &lt;4.0.0 in pubspec files ([5747abf](https://github.com/gibahjoe/openapi-generator-dart/commit/5747abf64ce56896f4837984f240e50140aad6d2))
* update README for clarity and formatting; adjust generator arguments and caching logic ([2c85976](https://github.com/gibahjoe/openapi-generator-dart/commit/2c8597617eb90b1635404bae5ea2c20311d202bd))
* updated analyzer and source_gen dependencies ([7b2b4b7](https://github.com/gibahjoe/openapi-generator-dart/commit/7b2b4b7c2ad63630692cd74be4ca68eda6793b43)), closes [#192](https://github.com/gibahjoe/openapi-generator-dart/issues/192)

## [6.1.0](https://github.com/gibahjoe/openapi-generator-dart/compare/v6.0.0...v6.1.0) (2024-12-15)


### Features

* added `--enum-name-mappings` support ([328c9da](https://github.com/gibahjoe/openapi-generator-dart/commit/328c9da3294719210e11f961baa89d9a1c708ac8))

## [6.0.0](https://github.com/gibahjoe/openapi-generator-dart/compare/v5.0.3...v6.0.0) (2024-11-06)


### ⚠ BREAKING CHANGES

* `forceAlwaysRun` is used to represent if the library should run  everytime `build_runner` is executed. This is done by modifying the annotated file after `build_runner` completes. Previous versions of this library did not have this flag but they had the equivalent of `true`. However, this now defaults to `false`. To keep previous behavior, set this flag to `true`.

### Features

* add --name-mappings param support for generator ([f5c6aed](https://github.com/gibahjoe/openapi-generator-dart/commit/f5c6aed0408de33c8f273f6e21aacb42a34cbbc1))
* added fields `skipIfSpecUnchanged` and `forceAlwaysRun` ([d5555dd](https://github.com/gibahjoe/openapi-generator-dart/commit/d5555dda4281091102342ade5c0103c9757ac3c4))
* annotated file updating made optional by argument ([c108469](https://github.com/gibahjoe/openapi-generator-dart/commit/c108469787da68794dce7ca595387539e009eb50))
* **annotations:** fixed issue with DioSerializationLibrary and updated tests ([c9a179a](https://github.com/gibahjoe/openapi-generator-dart/commit/c9a179ab8271e439c246b47c6fdd43ac272a1137)), closes [#152](https://github.com/gibahjoe/openapi-generator-dart/issues/152)
* Changing to a config based approach for obtaining the official openapi generator jar. ([05d61f7](https://github.com/gibahjoe/openapi-generator-dart/commit/05d61f7f323479af971dbfc3c07377cc57ce6792))


### Bug Fixes

* **annotations:** added doc for --name-mappings and moved some things around ([f2d6c04](https://github.com/gibahjoe/openapi-generator-dart/commit/f2d6c045ab36f4dd5a313b8a7850f38cd98ed0ba)), closes [#114](https://github.com/gibahjoe/openapi-generator-dart/issues/114)
* dart format ([af19a8e](https://github.com/gibahjoe/openapi-generator-dart/commit/af19a8e6f85f6c6b0b144acc3e6e5762641974ae))
* fixed ci ([fe64d7a](https://github.com/gibahjoe/openapi-generator-dart/commit/fe64d7a294ce417d8cec91ee5da4a905e9eb30cc))
* fixed failing tests ([f1c0a1c](https://github.com/gibahjoe/openapi-generator-dart/commit/f1c0a1c8b5f17771ae29dc3f8f11c196c8f8248b))
* fixes some tests ([79c9ce7](https://github.com/gibahjoe/openapi-generator-dart/commit/79c9ce77fb6627797299eb9f1fd3f545b176863f))
* removed unsupported field ([27eb1af](https://github.com/gibahjoe/openapi-generator-dart/commit/27eb1af9abcd7338dd06e8c52f13f9713111ecd0))
* removed unsupported field ([27eb1af](https://github.com/gibahjoe/openapi-generator-dart/commit/27eb1af9abcd7338dd06e8c52f13f9713111ecd0))
* removed unsupported field ([27eb1af](https://github.com/gibahjoe/openapi-generator-dart/commit/27eb1af9abcd7338dd06e8c52f13f9713111ecd0))

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

### Bug Fixes

* Apply types to default empty
  maps ([bfb0ec4](https://github.com/gibahjoe/openapi-generator-dart/commit/bfb0ec4f66296e38d3ad3cb5dac15f532a477def))
* Consume testing version of the source_gen branch to simplify
  testing. ([37af696](https://github.com/gibahjoe/openapi-generator-dart/commit/37af696ac90f27e47c31f87bb5c60c952bf56230))
* Correct most of the tests while using the newest verison of the source gen
  changes ([4156d9a](https://github.com/gibahjoe/openapi-generator-dart/commit/4156d9a18bf83337e608219315d19abbe08f8bd8))
* dep
  override ([8266ab1](https://github.com/gibahjoe/openapi-generator-dart/commit/8266ab1b8d49350205ba5f43d9eefc4404029c59))
* fmt ([e63c9b9](https://github.com/gibahjoe/openapi-generator-dart/commit/e63c9b9b74cf681d1c16fb93f9b055c6f56cf3d4))
* **generator:** fixed bad
  deps ([5d6407a](https://github.com/gibahjoe/openapi-generator-dart/commit/5d6407a05e23480f946a325c35c81bdca04b3bdc))

## [4.13.0](https://github.com/gibahjoe/openapi-generator-dart/compare/v4.12.1...v4.13.0) (2023-09-02)


### Features

* Add a format stage to the end of nextGen ([acac104](https://github.com/gibahjoe/openapi-generator-dart/commit/acac1044cbd6161c5a959a178a120fbf010f5c27))
* Add headers options for requests (nextGen only) ([bc4a170](https://github.com/gibahjoe/openapi-generator-dart/commit/bc4a170be1c011ca3e2843cf05a92a39965bcc29))


### Bug Fixes

* fix incorrect find and replace causing tests to fail ([0016a03](https://github.com/gibahjoe/openapi-generator-dart/commit/0016a031e3a7447f2deab1fa4e49ed228a29dc82))
* move to delegate, add tests, revert version requirement ([6a32542](https://github.com/gibahjoe/openapi-generator-dart/commit/6a32542cc7e09558db837d0313c4029951dc48ba))
* remove duplicate run test, fix failing tests ([677a318](https://github.com/gibahjoe/openapi-generator-dart/commit/677a3189d4f694c999d3ea1cf0075543649e40c1))
* remove unused imports ([4eb64c9](https://github.com/gibahjoe/openapi-generator-dart/commit/4eb64c90c2468a8ce26b79266c0e705be3e979de))
* repair the docker run command, update the type_methods to expand out the remote delegate ([c00b334](https://github.com/gibahjoe/openapi-generator-dart/commit/c00b3345d934e2f1508ba1129a3a769f86a85017))

## [4.13.1](https://github.com/gibahjoe/openapi-generator-dart/compare/v4.13.0...v4.13.1) (2023-09-04)


### Bug Fixes

* **dependencies:** added required dependencies to pubspec ([7738439](https://github.com/gibahjoe/openapi-generator-dart/commit/7738439a89637bb1226f6586a0c9d311053e1702))
* fixes useEnumExtension and other non string additional properties fields throwing error ([53b711a](https://github.com/gibahjoe/openapi-generator-dart/commit/53b711a3c9319e31ec0b159edfc76674b62feb19))
* updated logs ([45af1cf](https://github.com/gibahjoe/openapi-generator-dart/commit/45af1cf21ab1d11b12898b6cb8f2ee9895dca133))

## 4.12.0

- Added spec diff tracking. This means you Openapi generator now tracks changes to your spec and only regenerates the
  code if there are changes. This is useful if you have a large spec and you want to avoid regenerating the code every
  time you run your build. This is enabled by default. You can read more about it [here](../README.md#next-generation).
  Credits - [@Nexushunter](https://github.com/Nexushunter)
- Improved test coverage

## 4.11.1

- Removed ```log.severe``` that shows even though generation is successful
- Updated documentation

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
  - `dioNext` (replaced with `dio`) and `jaguar` generators are removed

- Bumped dart-ogurets (_dioAlt_) generator to 5.13
  with [changes](https://github.com/dart-ogurets/dart-openapi-maven#changelog)
- Bumped official openapi generator to 6.0.0.
  See [change log](https://github.com/OpenAPITools/openapi-generator/releases/tag/v6.0.0)

## 3.3.2

- Fix the enum value retrieval error

## 3.3.1

- Update the _analyzer_ constraint

## 3.3.0+1

- Bumped dart-ogurets (_dioAlt_) generator to 5.11
  with [changes](https://github.com/dart-ogurets/dart-openapi-maven#changelog)
- Bumped official openapi generator to 5.3/0.
  See [change log](https://github.com/OpenAPITools/openapi-generator/releases/tag/v5.3.0)

## 3.2.1

- Bumped dart-ogurets (_dioAlt_) generator to 5.9
  with [changes](https://github.com/dart-ogurets/dart-openapi-maven#changelog)
- Bumped official openapi generator to 5.2.1.
  See [change log](https://github.com/OpenAPITools/openapi-generator/releases/tag/v5.2.1)

## 3.2.0+2

- fixed boolean additional properties returning null

## 3.2.0

- Bumped dart-ogurets (_dioAlt_) generator to 5.8
  with [changes](https://github.com/dart-ogurets/dart-openapi-maven#changelog)
- Bumped official openapi generator to 5.2.0. See [change log](https://github.com/OpenAPITools/openapi-generator/releases/tag/v5.2.0)
- Added support for nullSafe for _dioAlt_ generator
- Added support for import mappings

## 3.1.3
- Bumped dart-ogurets (_dioAlt_) generator to 5.3 with [changes](https://github.com/dart-ogurets/dart-openapi-maven#changelog)
- Bumped official openapi generator to 5.1.1. See [change log](https://github.com/OpenAPITools/openapi-generator/releases/tag/v5.1.1)

## 3.1.2
**NEW DART GENERATOR::**
A new dart generator has been added (_dioNext_). However, be careful because its **xperimental** and might be removed, renamed in the future or it might not even work well. You can read more about it here https://github.com/OpenAPITools/openapi-generator/pull/8869

## 3.1.1-2
- **BREAKING CHANGES**
- Bumped dart-ogurets (_dioAlt_) generator to 5.0 with [breaking changes](https://github.com/dart-ogurets/dart-openapi-maven#changelog)
- Bumped official openapi generator to 5.1.0. See [change log](https://github.com/OpenAPITools/openapi-generator/releases/tag/v5.1.0)

## 3.0.2

- Bumped dart-ogurets generator to 4.2 with [breaking changes](https://github.com/dart-ogurets/dart-openapi-maven#changelog)
- Bumped official openapi generator to 5.0.1. See [change log](https://github.com/OpenAPITools/openapi-generator/releases/tag/v5.0.1)

## 2.2.0

- Added support for flutter wrappers
- Bumped dart-ogurets generator to 4.1 with [breaking changes](https://github.com/dart-ogurets/dart-openapi-maven#changelog)

## 3.0.0-nullsafety.1

- Bumped generator version to 5.0.0. This has some breaking changes. [Click here](https://github.com/OpenAPITools/openapi-generator/releases/tag/v5.0.0) to view changes
- bumped null safety

## 2.0.0

- Bumped generator version to 5.0.0. This has some breaking changes. [Click here](https://github.com/OpenAPITools/openapi-generator/releases/tag/v5.0.0) to view changes

## 2.0.0-nullsafety.0

- Migrated to null safety

## 1.1.4

- Updated dart_2 api to version 3.10
- Added pubname to DioProperties

## 1.1.3

- Updated dart_2 api to latest
- Added support for reservedWordsMapping

## 1.1.2

- Added support for skipping post run steps
- Fixed failing post build steps in windows

## 1.1.1

- Fixed build issue

## 1.1.0

- Added support for **_dart2-api_** from [dart-ogurets](https://github.com/dart-ogurets/dart-openapi-maven)
  thanks to [Robert Csakany](https://github.com/robertcsakany)

## 1.0.8

- fixed issue with wrong path on windows

## 1.0.7

- added support for -t (templateDirectory)
- minor bug fix

## 1.0.5

- Updated generator version to 4.3.0

## 1.0.0

- Updated analyzer to 0.39.4
- removed validation from input spec

## 0.1.2

- Updated docs

## 0.0.1-beta

- Initial version.
