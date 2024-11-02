## [5.0.2](https://github.com/gibahjoe/openapi-generator-dart/compare/v5.0.0...v5.0.2) (2024-01-16)

### Bug Fixes

* fixed spec diff tracking

## [6.0.0](https://github.com/gibahjoe/openapi-generator-dart/compare/openapi-generator-v5.0.3...openapi-generator-v6.0.0) (2024-11-02)


### ⚠ BREAKING CHANGES

* **cli:** removed various deprecated methods and properties such as inputSpecFile
* **annotations:** changed Inputspec.emptyYaml to Inputspec.yaml

### Features

* add --name-mappings param support for generator ([f5c6aed](https://github.com/gibahjoe/openapi-generator-dart/commit/f5c6aed0408de33c8f273f6e21aacb42a34cbbc1))
* Add a format stage to the end of nextGen ([acac104](https://github.com/gibahjoe/openapi-generator-dart/commit/acac1044cbd6161c5a959a178a120fbf010f5c27))
* Add headers options for requests (nextGen only) ([bc4a170](https://github.com/gibahjoe/openapi-generator-dart/commit/bc4a170be1c011ca3e2843cf05a92a39965bcc29))
* annotated file updating made optional by argument ([c108469](https://github.com/gibahjoe/openapi-generator-dart/commit/c108469787da68794dce7ca595387539e009eb50))
* **annotation:** removed deprecated properties from annotation ([51d3683](https://github.com/gibahjoe/openapi-generator-dart/commit/51d3683bb83dc3e8f0f05d9d4913e11d3cc82b0f))
* Changing to a config based approach for obtaining the official openapi generator jar. ([a0f3ca2](https://github.com/gibahjoe/openapi-generator-dart/commit/a0f3ca2d24e29ff27d032a1f6dd093c195c7ff83))
* **cli:** bumped official generator version to 7.2 ([51d3683](https://github.com/gibahjoe/openapi-generator-dart/commit/51d3683bb83dc3e8f0f05d9d4913e11d3cc82b0f))
* **generator:** moved completely to newgen ([51d3683](https://github.com/gibahjoe/openapi-generator-dart/commit/51d3683bb83dc3e8f0f05d9d4913e11d3cc82b0f))
* updated generator versions ([4f13112](https://github.com/gibahjoe/openapi-generator-dart/commit/4f13112fc0e8cbb16c17e38bfdfee34d65473291))


### Bug Fixes

* add tests and ensure that the sub processes can be mocked out. ([5822666](https://github.com/gibahjoe/openapi-generator-dart/commit/5822666aad384444827ca6a5aa3028ac3317c443))
* Add work around to be able to always be able to regenerate when run. Add documentation around the usage of useNextGen, add tests ([523f169](https://github.com/gibahjoe/openapi-generator-dart/commit/523f169159a3607487342b71fdd155d5fb50acfe))
* Apply types to default empty maps ([bfb0ec4](https://github.com/gibahjoe/openapi-generator-dart/commit/bfb0ec4f66296e38d3ad3cb5dac15f532a477def))
* bumped generator version ([751369e](https://github.com/gibahjoe/openapi-generator-dart/commit/751369ea6ea4e8dd72a96cec8e5a0f821bf9e3b7))
* Consume testing version of the source_gen branch to simplify testing. ([37af696](https://github.com/gibahjoe/openapi-generator-dart/commit/37af696ac90f27e47c31f87bb5c60c952bf56230))
* Correct most of the tests while using the newest verison of the source gen changes ([4156d9a](https://github.com/gibahjoe/openapi-generator-dart/commit/4156d9a18bf83337e608219315d19abbe08f8bd8))
* dep override ([8266ab1](https://github.com/gibahjoe/openapi-generator-dart/commit/8266ab1b8d49350205ba5f43d9eefc4404029c59))
* **dependencies:** added required dependencies to pubspec ([7738439](https://github.com/gibahjoe/openapi-generator-dart/commit/7738439a89637bb1226f6586a0c9d311053e1702))
* failing test ([feead33](https://github.com/gibahjoe/openapi-generator-dart/commit/feead33bac9ce9ef36d6cbf3ab8dc8dbbfb0a817))
* fix gitignore, readd api/petstore_api/pubspec ([37f862c](https://github.com/gibahjoe/openapi-generator-dart/commit/37f862c81db924a14a8b11beffca51e055c3acec))
* fix incorrect find and replace causing tests to fail ([0016a03](https://github.com/gibahjoe/openapi-generator-dart/commit/0016a031e3a7447f2deab1fa4e49ed228a29dc82))
* fix tests now that the generator is running correctly ([4643a0c](https://github.com/gibahjoe/openapi-generator-dart/commit/4643a0ce57fea053a47a41291c8ba07312390a43))
* fixed spec not caching ([9bd7a80](https://github.com/gibahjoe/openapi-generator-dart/commit/9bd7a8004c8f0f98293f5f4daa70ac4144ba7251))
* fixes useEnumExtension and other non string additional properties fields throwing error ([53b711a](https://github.com/gibahjoe/openapi-generator-dart/commit/53b711a3c9319e31ec0b159edfc76674b62feb19))
* fmt ([e63c9b9](https://github.com/gibahjoe/openapi-generator-dart/commit/e63c9b9b74cf681d1c16fb93f9b055c6f56cf3d4))
* **generator:** fixed bad deps ([5d6407a](https://github.com/gibahjoe/openapi-generator-dart/commit/5d6407a05e23480f946a325c35c81bdca04b3bdc))
* **generator:** updated deps ([09f6039](https://github.com/gibahjoe/openapi-generator-dart/commit/09f603964092d975f4c60722b95867727e66648b))
* Last few tweaks ([12c138a](https://github.com/gibahjoe/openapi-generator-dart/commit/12c138a2fcc99a30305fc2a143dbf85d12f0df7b))
* move to delegate, add tests, revert version requirement ([6a32542](https://github.com/gibahjoe/openapi-generator-dart/commit/6a32542cc7e09558db837d0313c4029951dc48ba))
* remove duplicate run test, fix failing tests ([677a318](https://github.com/gibahjoe/openapi-generator-dart/commit/677a3189d4f694c999d3ea1cf0075543649e40c1))
* remove extra testing infra since it is no longer used, add additional configs, refactor function ([3dd7054](https://github.com/gibahjoe/openapi-generator-dart/commit/3dd705460e5dc09e86e568419c99198ff92b4e4b))
* remove unused import, update paramter name ([d2f5a90](https://github.com/gibahjoe/openapi-generator-dart/commit/d2f5a9001458126e7c315ef89ebdf5b26b7282fc))
* remove unused imports ([4eb64c9](https://github.com/gibahjoe/openapi-generator-dart/commit/4eb64c90c2468a8ce26b79266c0e705be3e979de))
* repair the docker run command, update the type_methods to expand out the remote delegate ([c00b334](https://github.com/gibahjoe/openapi-generator-dart/commit/c00b3345d934e2f1508ba1129a3a769f86a85017))
* tweak gitignore ([f1122d0](https://github.com/gibahjoe/openapi-generator-dart/commit/f1122d007ef47f0849656e5180a78052b9542ec9))
* Tweak the processing of the builder to handle how process.run returns ([90a1b90](https://github.com/gibahjoe/openapi-generator-dart/commit/90a1b90143661c9d9dd02ab6a4481ece99e9a221))
* updated ([5d21f4a](https://github.com/gibahjoe/openapi-generator-dart/commit/5d21f4aa99faf94d22a4958d30c157f9430bdbf3))
* updated logs ([45af1cf](https://github.com/gibahjoe/openapi-generator-dart/commit/45af1cf21ab1d11b12898b6cb8f2ee9895dca133))
* Use Dart 2 API ([8d59613](https://github.com/gibahjoe/openapi-generator-dart/commit/8d596135d4b7700cb37b14134a15904a3b32f049))


### Code Refactoring

* **annotations:** changed inputspec methods to be more descriptive ([84f72df](https://github.com/gibahjoe/openapi-generator-dart/commit/84f72df661cb729ed30a239e4ac856a5ded26111))

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
