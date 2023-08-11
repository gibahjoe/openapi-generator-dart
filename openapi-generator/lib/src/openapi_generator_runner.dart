import 'dart:async';
import 'dart:io';
import 'dart:isolate';

import 'package:analyzer/dart/element/element.dart';
import 'package:build/build.dart';
import 'package:logging/logging.dart';
import 'package:openapi_generator/src/determine_flutter_project_status.dart';
import 'package:openapi_generator/src/gen_on_spec_changes.dart';
import 'package:openapi_generator/src/models/output_message.dart';
import 'package:openapi_generator/src/utils.dart';
import 'package:openapi_generator_annotations/openapi_generator_annotations.dart'
    as annots;
import 'package:source_gen/source_gen.dart';

import 'models/command.dart';
import 'models/generator_arguments.dart';

class OpenapiGenerator extends GeneratorForAnnotation<annots.Openapi> {
  final bool testMode;

  OpenapiGenerator({this.testMode = false});

  @override
  FutureOr<String> generateForAnnotatedElement(
      Element element, ConstantReader annotations, BuildStep buildStep) async {
    logOutputMessage(
        log: log,
        communication: OutputMessage(
            message: [
          ' - :::::::::::::::::::::::::::::::::::::::::::',
          ' - ::      Openapi generator for dart       ::',
          ' - :::::::::::::::::::::::::::::::::::::::::::',
        ].join('\n')));

    try {
      if (element is! ClassElement) {
        final friendlyName = element.displayName;

        throw InvalidGenerationSourceError(
          'Generator cannot target `$friendlyName`.',
          todo: 'Remove the [Openapi] annotation from `$friendlyName`.',
        );
      }

      // Transform the annotations.
      final args = GeneratorArguments(annotations: annotations);

      // Determine if the project has a dependency on the flutter sdk or not.
      final baseCommand =
          await checkPubspecAndWrapperForFlutterSupport(wrapper: args.wrapper)
              ? 'flutter'
              : 'dart';

      if (!args.useNextGen) {
        final path =
            '${args.outputDirectory}${Platform.pathSeparator}lib${Platform.pathSeparator}api.dart';
        if (await File(path).exists()) {
          if (!args.alwaysRun) {
            logOutputMessage(
              log: log,
              communication: OutputMessage(
                message:
                    'Library exists definition at [$path] exists and configuration is annotated with alwaysRun: [${args.alwaysRun}]. This option will be removed in a future version.',
                level: Level.WARNING,
              ),
            );
            return '';
          }
        }
      } else {
        // If the flag to use the next generation of the generator is applied
        // use the new functionality.
        return generatorV2(args: args);
      }

      await runOpenApiJar(arguments: args.jarArgs);
      await generateSources(baseCommand: baseCommand, args: args);
      await fetchDependencies(baseCommand: baseCommand, args: args);
    } catch (e, st) {
      late OutputMessage communication;
      if (e is! OutputMessage) {
        communication = OutputMessage(
            message: 'There was an error generating the spec',
            level: Level.SEVERE,
            error: e,
            stackTrace: st);
      } else {
        communication = e;
      }

      logOutputMessage(log: log, communication: communication);

      rethrow;
    }
    return '';
  }

  /// Conditionally generates the new sources based on the [args.runSourceGen] &
  /// [args.generator].
  FutureOr<void> generateSources(
      {required String baseCommand, required GeneratorArguments args}) async {
    if (!args.runSourceGen) {
      logOutputMessage(
        log: log,
        communication: OutputMessage(
            message: ' :: Skipping source gen step because you said so...',
            level: Level.WARNING),
      );
    } else if (!args.shouldGenerateSources) {
      logOutputMessage(
          log: log,
          communication: OutputMessage(
              message:
                  ' :: Skipping source gen because generator does not need it ::'));
    } else {
      return runSourceGen(baseCommand: baseCommand, args: args).then(
        (_) => logOutputMessage(
          log: log,
          communication:
              OutputMessage(message: ' :: Source generated successfully. ::'),
        ),
        onError: (e, st) => Future.error(
          OutputMessage(
            message: ' :: could not complete source gen ::',
            error: e,
            stackTrace: st,
            level: Level.SEVERE,
          ),
        ),
      );
    }
  }

  /// Conditionally fetches the dependencies in the newly generate library.
  FutureOr<void> fetchDependencies(
      {required String baseCommand, required GeneratorArguments args}) async {
    if (!args.shouldFetchDependencies) {
      return Future.error(OutputMessage(
          message: ' - :: Skipping install step because you said so...',
          level: Level.WARNING));
    }
    final command = Command(
        executable: baseCommand,
        arguments: ['pub', 'get'],
        wrapper: args.wrapper);
    return await Process.run(command.executable, command.arguments,
            runInShell: Platform.isWindows,
            workingDirectory: args.outputDirectory)
        .then(
      (v) => logOutputMessage(
        log: log,
        communication: OutputMessage(
          message: [v.stdout + ' :: Install completed successfully'].join('\n'),
        ),
      ),
      onError: (e, st) => Future.error(
        OutputMessage(
            message: ' :: Install of dependencies failed',
            level: Level.SEVERE,
            error: e,
            stackTrace: st),
      ),
    );
  }

  /// Runs the OpenAPI compiler with the given [args].
  Future<void> runOpenApiJar({required List<String> arguments}) async {
    logOutputMessage(
        log: log,
        communication: OutputMessage(
            message: 'OpenapiGenerator :: [${arguments.join(' ')}]'));

    var binPath = (await Isolate.resolvePackageUri(
            Uri.parse('package:openapi_generator_cli/openapi-generator.jar')))!
        .toFilePath(windows: Platform.isWindows);

    // Include java environment variables in openApiCliCommand
    var javaOpts = Platform.environment['JAVA_OPTS'] ?? '';

    return await Process.run('java', [
      if (javaOpts.isNotEmpty) javaOpts,
      '-jar',
      "${"$binPath"}",
      ...arguments,
    ]).then(
      (value) => logOutputMessage(
        log: log,
        communication: OutputMessage(
          message: [value.stdout + ' - :: Codegen completed successfully']
              .join('\n'),
        ),
      ),
      onError: (e, st) => Future.error(
        Future.error(
          OutputMessage(
            message: ' - :: Codegen Failed',
            level: Level.SEVERE,
            error: e,
            stackTrace: st,
          ),
        ),
      ),
    );
  }

  /// Next-gen of the generation.
  ///
  /// Proposal for reworking how to generated the user's changes based on spec
  /// changes vs flags. This will allow for incremental changes to be generated
  /// in the specification instead of only running when the configuration file
  /// changes as it should be relatively stable.
  FutureOr<String> generatorV2({required GeneratorArguments args}) async {
    if (await hasDiff(
      loadPath: args.inputFile.startsWith(r'\.\/')
          ? args.inputFile.replaceFirst(
              r'\.\/', '${Directory.current.path}${Platform.pathSeparator}')
          : args.inputFile,
    )) {}
    return '';
  }

  /// Load both specs into memory and verify if there is a diff between them.
  FutureOr<bool> hasDiff(
      {String? cachedPath,
      required String loadPath,
      String? providedPubspecPath}) async {
    final cachedSpec = await loadSpec(
        specPath: cachedPath ?? defaultCachedPath, isCached: true);
    final loadedSpec = await loadSpec(specPath: loadPath);
    return isSpecDirty(cachedSpec: cachedSpec, loadedSpec: loadedSpec);
  }

  /// Update the currently cached spec with the [updatedSpec].
  Future<void> updateCachedSpec({
    required Map<String, dynamic> updatedSpec,
    required String cachedPath,
  }) async =>
      cacheSpec(spec: updatedSpec, outputLocation: cachedPath);

  /// Runs build_runner on the newly generated library in [args.outputDirectory].
  Future<void> runSourceGen(
      {required String baseCommand, required GeneratorArguments args}) async {
    logOutputMessage(
        log: log,
        communication:
            OutputMessage(message: ':: running source code generation ::'));
    final command = Command(
        executable: baseCommand,
        arguments: 'pub run build_runner build --delete-conflicting-outputs'
            .split(' ')
            .toList(),
        wrapper: args.wrapper);

    return await Process.run(command.executable, command.arguments,
            runInShell: Platform.isWindows,
            workingDirectory: args.outputDirectory)
        .then(
      (v) => logOutputMessage(
        log: log,
        communication: OutputMessage(
          message: ' - :: Codegen completed successfully',
        ),
      ),
      onError: (e, st) {
        return Future.error(
          OutputMessage(
            message: ':: Failed to generate source code ::',
            level: Level.SEVERE,
            error: e,
            stackTrace: st,
          ),
        );
      },
    );
  }
}
