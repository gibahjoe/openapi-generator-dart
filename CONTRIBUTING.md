# How to become a contributor

## Development Setup

Before you begin making changes to the repository, ensure you have the following tools and have run the setup commands:

### Prerequisites
- [Dart SDK](https://dart.dev/get-dart) (latest stable version)
- [Flutter SDK](https://flutter.dev/docs/get-started/install) (if working with Flutter examples)
- [Java](https://adoptium.net/) (version 8 or higher) - required for OpenAPI Generator CLI

### Setup Steps

1. **Activate Melos globally** (for monorepo management):
   ```bash
   dart pub global activate melos
   ```

2. **Bootstrap the workspace** (links local packages and sets up dependencies):
   ```bash
   melos bootstrap
   ```

3. **Get dependencies** for all packages:
   ```bash
   melos exec dart pub get
   ```

4. **Format code** before committing:
   ```bash
   melos format
   ```

## Before submitting an issue

- Search the [open issue](https://github.com/gibahjoe/openapi-generator-dart/issues)
  and [closed issue](https://github.com/openapitools/openapi-generator/issues?q=is%3Aissue+is%3Aclosed) to ensure no one
  else has reported something similar before.
- File an [issue ticket](https://github.com/gibahjoe/openapi-generator-dart/issues/new) by providing all the required
  information. Failure to provide enough detail may result in slow response from the community.
- You can also make a suggestion or ask a question by opening an "issue".

## Contributing A Patch

1. Submit an issue describing your proposed change to the repo in question.
1. The repo owner will respond to your issue promptly.
1. If your proposed change is accepted, fork the desired repo, develop and test your code changes.
1. Ensure that your code adheres to the existing style in the code to which
   you are contributing.
1. Ensure that your code has an appropriate set of tests which all pass.
1. **Always run `melos format` before committing** to ensure consistent code formatting across the repository.
1. **Title your pull request as well as all your commits
   following [Conventional Commits](https://www.conventionalcommits.org/) styling.**
1. Submit a pull request.

# Note

It is important that all your commits as well as your PR follow
the [Conventional Commits](https://www.conventionalcommits.org/) styling.
