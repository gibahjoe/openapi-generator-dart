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
          '',
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

      if (!(annotations.read('useNextGen').literalValue as bool)) {
        if (annotations.read('cachePath').literalValue != null) {
          throw InvalidGenerationSourceError(
            'useNextGen must be set when using cachePath',
            todo:
                'Either set useNextGen: true on the annotation or remove the custom cachePath',
          );
        }
      }

      // Transform the annotations.
      final args = GeneratorArguments(annotations: annotations);

      // Determine if the project has a dependency on the flutter sdk or not.
      final baseCommand = await checkPubspecAndWrapperForFlutterSupport(
              wrapper: args.wrapper, providedPubspecPath: args.pubspecPath)
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
                    '- :: Library exists definition at [$path] exists and configuration is annotated with alwaysRun: [${args.alwaysRun}]. This option will be removed in a future version. ::',
                level: Level.WARNING,
              ),
            );
            return '';
          }
        }
      } else {
        // If the flag to use the next generation of the generator is applied
        // use the new functionality.
        return generatorV2(args: args, baseCommand: baseCommand);
      }

      await runOpenApiJar(arguments: args.jarArgs);
      await generateSources(baseCommand: baseCommand, args: args);
      await fetchDependencies(baseCommand: baseCommand, args: args);
    } catch (e, st) {
      late OutputMessage communication;
      if (e is! OutputMessage) {
        communication = OutputMessage(
            message: '- :: There was an error generating the spec. ::',
            level: Level.SEVERE,
            additionalContext: e,
            stackTrace: st);
      } else {
        communication = e;
      }

      logOutputMessage(log: log, communication: communication);
    } finally {
      logOutputMessage(
          log: log,
          communication: OutputMessage(
              message: ' - :::::::::::::::::::::::::::::::::::::::::::'));
    }
    return '';
  }

  /// Runs the OpenAPI compiler with the given [args].
  Future<void> runOpenApiJar(
      {required FutureOr<List<String>> arguments}) async {
    final args = await arguments;
    logOutputMessage(
      log: log,
      communication: OutputMessage(
        message: 'OpenapiGenerator :: [ ${args.join(' ')} ]',
      ),
    );

    var binPath = (await Isolate.resolvePackageUri(
            Uri.parse('package:openapi_generator_cli/openapi-generator.jar')))!
        .toFilePath(windows: Platform.isWindows);

    // Include java environment variables in openApiCliCommand
    var javaOpts = Platform.environment['JAVA_OPTS'] ?? '';

    final result = await Process.run('java', [
      if (javaOpts.isNotEmpty) javaOpts,
      '-jar',
      "${"$binPath"}",
      ...args,
    ]);

    if (result.exitCode != 0) {
      return Future.error(
        OutputMessage(
          message: ' - :: Codegen Failed. Generator output: ::',
          level: Level.SEVERE,
          additionalContext: result.stderr,
          stackTrace: StackTrace.current,
        ),
      );
    } else {
      logOutputMessage(
        log: log,
        communication: OutputMessage(
          message: [result.stdout, ' - :: Codegen completed successfully. ::']
              .join('\n'),
        ),
      );
    }
  }

  /// Next-gen of the generation.
  ///
  /// Proposal for reworking how to generated the user's changes based on spec
  /// changes vs flags. This will allow for incremental changes to be generated
  /// in the specification instead of only running when the configuration file
  /// changes as it should be relatively stable.
  FutureOr<String> generatorV2(
      {required GeneratorArguments args, required String baseCommand}) async {
    if (args.isRemote) {
      logOutputMessage(
          log: log,
          communication: OutputMessage(
              message:
                  ' - :: Using a remote specification, a cache will still be create but may be outdated. ::',
              level: Level.WARNING));
    }
    try {
      if (await hasDiff(
        cachedPath: args.cachePath,
        loadPath: await args.inputFileOrFetch,
      )) {
        logOutputMessage(
            log: log,
            communication: OutputMessage(
                message: ' - :: Dirty Spec found. Running generation. ::'));
        await runOpenApiJar(arguments: args.jarArgs);
        await generateSources(baseCommand: baseCommand, args: args);
        await fetchDependencies(baseCommand: baseCommand, args: args);
        if (!args.hasLocalCache) {
          logOutputMessage(
              log: log,
              communication: OutputMessage(
                  message: ' - :: No local cache found. Creating one. ::'));
        } else {
          logOutputMessage(
              log: log,
              communication: OutputMessage(
                  message:
                      ' - :: Local cache found. Overwriting existing one. ::'));
        }
        await cacheSpec(
            outputLocation: args.cachePath,
            spec: await loadSpec(specPath: await args.inputFileOrFetch));
        logOutputMessage(
          log: log,
          communication: OutputMessage(
            message: '- :: Successfully cached spec changes. ::',
            // TODO: include spec as additional context?
          ),
        );
      } else {
        logOutputMessage(
          log: log,
          communication: OutputMessage(
            message:
                ' - :: No diff between versions, not running generator. ::',
          ),
        );
      }
    } catch (e, st) {
      logOutputMessage(
        log: log,
        communication: OutputMessage(
          message: ' - :: Failed to generate content. ::',
          additionalContext: e,
          stackTrace: st,
          level: Level.SEVERE,
        ),
      );
    }
    return '';
  }

  /// Load both specs into memory and verify if there is a diff between them.
  FutureOr<bool> hasDiff(
      {required String cachedPath,
      required String loadPath,
      String? providedPubspecPath}) async {
    final cachedSpec = await loadSpec(specPath: cachedPath, isCached: true);
    final loadedSpec = await loadSpec(specPath: loadPath);
    return isSpecDirty(cachedSpec: cachedSpec, loadedSpec: loadedSpec);
  }

  /// Conditionally generates the new sources based on the [args.runSourceGen] &
  /// [args.generator].
  FutureOr<void> generateSources(
      {required String baseCommand, required GeneratorArguments args}) async {
    if (!args.runSourceGen) {
      logOutputMessage(
        log: log,
        communication: OutputMessage(
            message: ' - :: Skipping source gen step due to flag being set. ::',
            level: Level.WARNING),
      );
    } else if (!args.shouldGenerateSources) {
      logOutputMessage(
          log: log,
          communication: OutputMessage(
              message:
                  ' - :: Skipping source gen because generator does not need it. ::'));
    } else {
      return runSourceGen(baseCommand: baseCommand, args: args).then(
        (_) => logOutputMessage(
          log: log,
          communication: OutputMessage(
              message: ' - :: Sources generated successfully. ::'),
        ),
        onError: (e, st) => Future.error(
          OutputMessage(
            message: ' - :: Could not complete source generation ::',
            additionalContext: e,
            stackTrace: st,
            level: Level.SEVERE,
          ),
        ),
      );
    }
  }

  /// Runs build_runner on the newly generated library in [args.outputDirectory].
  Future<void> runSourceGen(
      {required String baseCommand, required GeneratorArguments args}) async {
    logOutputMessage(
        log: log,
        communication:
            OutputMessage(message: ' - :: Running source code generation. ::'));
    final command = Command(
        executable: baseCommand,
        arguments: 'pub run build_runner build --delete-conflicting-outputs'
            .split(' ')
            .toList(),
        wrapper: args.wrapper);

    logOutputMessage(
      log: log,
      communication: OutputMessage(
        message:
            ' - :: ${command.executable} ${command.arguments.join(' ')} ::',
      ),
    );

    final results = await Process.run(
      command.executable,
      command.arguments,
      runInShell: Platform.isWindows,
      workingDirectory: args.outputDirectory,
    );

    if (results.exitCode != 0) {
      return Future.error(
        OutputMessage(
          message:
              ' - :: Failed to generate source code. Build Command output: ::',
          level: Level.SEVERE,
          additionalContext: results.stderr,
          stackTrace: StackTrace.current,
        ),
      );
    } else {
      logOutputMessage(
        log: log,
        communication: OutputMessage(
          message: ' - :: Codegen completed successfully. ::',
        ),
      );
    }
  }

  /// Conditionally fetches the dependencies in the newly generate library.
  FutureOr<void> fetchDependencies(
      {required String baseCommand, required GeneratorArguments args}) async {
    if (!args.shouldFetchDependencies) {
      logOutputMessage(
          log: log,
          communication: OutputMessage(
              message: ' - :: Skipping install step because flag was set. ::',
              level: Level.WARNING));
    } else {
      final command = Command(
          executable: baseCommand,
          arguments: ['pub', 'get'],
          wrapper: args.wrapper);

      logOutputMessage(
        log: log,
        communication: OutputMessage(
          message: ' - :: Installing dependencies with generated source. ::',
          additionalContext:
              ' - :: ${command.executable} ${command.arguments.join(' ')} ::',
        ),
      );

      final result = await Process.run(command.executable, command.arguments,
          runInShell: Platform.isWindows,
          workingDirectory: args.outputDirectory);
      if (result.exitCode != 0) {
        return Future.error(
          OutputMessage(
            message: ' - :: Install within generated sources failed. ::',
            level: Level.SEVERE,
            additionalContext: result.stderr,
            stackTrace: StackTrace.current,
          ),
        );
      } else {
        logOutputMessage(
          log: log,
          communication: OutputMessage(
            message: [
              result.stdout,
              ' - :: Install completed successfully. ::',
            ].join('\n'),
          ),
        );
      }
    }
  }

  /// Update the currently cached spec with the [updatedSpec].
  Future<void> updateCachedSpec({
    required Map<String, dynamic> updatedSpec,
    required String cachedPath,
  }) async =>
      cacheSpec(spec: updatedSpec, outputLocation: cachedPath);
}
