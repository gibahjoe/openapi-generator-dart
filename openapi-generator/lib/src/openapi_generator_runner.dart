import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:isolate';

import 'package:analyzer/dart/element/element.dart';
import 'package:build/build.dart';
import 'package:logging/logging.dart';
import 'package:openapi_generator/src/determine_flutter_project_status.dart';
import 'package:openapi_generator/src/gen_on_spec_changes.dart';
import 'package:openapi_generator/src/models/output_message.dart';
import 'package:openapi_generator/src/process_runner.dart';
import 'package:openapi_generator/src/utils.dart';
import 'package:openapi_generator_annotations/openapi_generator_annotations.dart'
    as annots;
import 'package:source_gen/source_gen.dart';

import 'models/command.dart';
import 'models/generator_arguments.dart';

class OpenapiGenerator extends GeneratorForAnnotation<annots.Openapi> {
  final ProcessRunner _processRunner;

  OpenapiGenerator(this._processRunner);

  @override
  FutureOr<String> generateForAnnotatedElement(
      Element element, ConstantReader annotations, BuildStep buildStep) async {
    logOutputMessage(
      log: log,
      communication: OutputMessage(
        message: [
          '\n',
          ':::::::::::::::::::::::::::::::::::::::::::',
          '::      Openapi generator for dart       ::',
          ':::::::::::::::::::::::::::::::::::::::::::',
        ].join('\n'),
      ),
    );

    try {
      if (element is! ClassElement) {
        final friendlyName = element.displayName;

        throw InvalidGenerationSourceError(
          'Generator cannot target `$friendlyName`.',
          todo: 'Remove the [Openapi] annotation from `$friendlyName`.',
        );
      } else {
        // Transform the annotations.
        final args = GeneratorArguments(annotations: annotations);

        // Determine if the project has a dependency on the flutter sdk or not.
        final baseCommand = await checkPubspecAndWrapperForFlutterSupport(
                wrapper: args.wrapper, providedPubspecPath: args.pubspecPath)
            ? 'flutter'
            : 'dart';

        return generatorV2(
            args: args,
            baseCommand: baseCommand,
            annotatedPath: buildStep.inputId.path);
      }
    } catch (e, st) {
      late OutputMessage communication;
      if (e is! OutputMessage) {
        communication = OutputMessage(
          message: '- There was an error generating the spec.',
          level: Level.SEVERE,
          additionalContext: e,
          stackTrace: st,
        );
      } else {
        communication = e;
      }

      logOutputMessage(log: log, communication: communication);
    }
    return '';
  }

  /// Runs the OpenAPI compiler with the given [args].
  Future<void> runOpenApiJar({required GeneratorArguments arguments}) async {
    final args = await arguments.jarArgs;
    logOutputMessage(
      log: log,
      communication: OutputMessage(
        message:
            'Running following command to generate openapi client - [ ${args.join(' ')} ]',
      ),
    );

    var binPath = (await Isolate.resolvePackageUri(
            Uri.parse('package:openapi_generator_cli/openapi-generator.jar')))!
        .toFilePath(windows: Platform.isWindows);

    // Include java environment variables in openApiCliCommand
    var javaOpts = Platform.environment['JAVA_OPTS'] ?? '';

    ProcessResult result;
    result = await _processRunner.run(
      'java',
      [
        if (javaOpts.isNotEmpty) javaOpts,
        '-jar',
        binPath,
        ...args,
      ],
      workingDirectory: Directory.current.path,
      runInShell: Platform.isWindows,
    );

    if (result.exitCode != 0) {
      return Future.error(
        OutputMessage(
          message: 'Codegen Failed. Generator output:',
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
            if (arguments.isDebug) result.stdout,
            'Openapi generator completed successfully.',
          ].join('\n'),
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
      {required GeneratorArguments args,
      required String baseCommand,
      required String annotatedPath}) async {
    if (args.isRemote) {
      logOutputMessage(
        log: log,
        communication: OutputMessage(
          message:
              'Using a remote specification, a cache will still be create but may be outdated.',
          level: Level.WARNING,
        ),
      );
    }
    try {
      if (!await hasDiff(args: args)) {
        logOutputMessage(
          log: log,
          communication: OutputMessage(
            message: 'No diff between versions, not running generator.',
          ),
        );
      } else {
        logOutputMessage(
          log: log,
          communication: OutputMessage(
            message: 'Dirty Spec found. Running generation.',
          ),
        );
        await runOpenApiJar(arguments: args);
        await fetchDependencies(baseCommand: baseCommand, args: args);
        await generateSources(baseCommand: baseCommand, args: args);
        if (!args.hasLocalCache) {
          logOutputMessage(
            log: log,
            communication: OutputMessage(
              message: 'No local cache found. Creating one.',
              level: Level.CONFIG,
            ),
          );
        } else {
          logOutputMessage(
            log: log,
            communication: OutputMessage(
              message: 'Local cache found. Overwriting existing one.',
              level: Level.CONFIG,
            ),
          );
        }
        await cacheSpec(
            outputLocation: args.cachePath,
            spec: await loadSpec(specConfig: args.inputSpec));
        logOutputMessage(
          log: log,
          communication: OutputMessage(
            message: 'Successfully cached spec changes.',
          ),
        );
      }
    } catch (e, st) {
      logOutputMessage(
        log: log,
        communication: OutputMessage(
          message: 'Failed to generate content.',
          additionalContext: e,
          stackTrace: st,
          level: Level.SEVERE,
        ),
      );
    } finally {
      await formatCode(args: args).then(
        (_) {},
        onError: (e, st) => logOutputMessage(
          log: log,
          communication: OutputMessage(
            message: 'Failed to format generated code.',
            additionalContext: e,
            stackTrace: st,
            level: Level.SEVERE,
          ),
        ),
      );
      await updateAnnotatedFile(annotatedPath: annotatedPath).then(
        (_) => logOutputMessage(
          log: log,
          communication: OutputMessage(
            message: 'Successfully updated annotated file.',
            level: Level.CONFIG,
          ),
        ),
        onError: (e, st) => logOutputMessage(
          log: log,
          communication: OutputMessage(
            message: 'Failed to update annotated class file.',
            level: Level.WARNING,
            additionalContext: e,
            stackTrace: st,
          ),
        ),
      );
    }
    return '';
  }

  /// Load both specs into memory and verify if there is a diff between them.
  FutureOr<bool> hasDiff({required GeneratorArguments args}) async {
    try {
      final cachedSpec = await loadSpec(
          specConfig: annots.InputSpec(path: args.cachePath), isCached: true);
      final loadedSpec = await loadSpec(specConfig: args.inputSpec);

      logOutputMessage(
        log: log,
        communication: OutputMessage(
          message: [
            'Loaded cached and current spec files.',
            if (args.isDebug) ...[
              jsonEncode(cachedSpec),
              jsonEncode(loadedSpec)
            ],
          ].join('\n'),
        ),
      );

      return isSpecDirty(cachedSpec: cachedSpec, loadedSpec: loadedSpec);
    } catch (e, st) {
      return Future.error(
        OutputMessage(
          message: 'Failed to check diff status.',
          level: Level.SEVERE,
          additionalContext: e,
          stackTrace: st,
        ),
      );
    }
  }

  /// Conditionally generates the new sources based on the [args.runSourceGen] &
  /// [args.generator].
  FutureOr<void> generateSources(
      {required String baseCommand, required GeneratorArguments args}) async {
    if (!args.runSourceGen) {
      logOutputMessage(
        log: log,
        communication: OutputMessage(
          message: 'Skipping source gen step due to flag being set.',
          level: Level.WARNING,
        ),
      );
    } else if (!args.shouldGenerateSources) {
      logOutputMessage(
        log: log,
        communication: OutputMessage(
          message: 'Skipping source gen because generator does not need it.',
        ),
      );
    } else {
      return await runSourceGen(baseCommand: baseCommand, args: args).then(
        (_) => logOutputMessage(
          log: log,
          communication: OutputMessage(
            message: 'Sources generated successfully.',
          ),
        ),
        onError: (e, st) => Future.error(
          OutputMessage(
            message: 'Could not complete source generation',
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
      communication: OutputMessage(
        message: 'Running source code generation.',
      ),
    );
    final command = Command(
        executable: baseCommand,
        arguments: 'pub run build_runner build --delete-conflicting-outputs'
            .split(' ')
            .toList(),
        wrapper: args.wrapper);

    logOutputMessage(
      log: log,
      communication: OutputMessage(
        message: '${command.executable} ${command.arguments.join(' ')}',
      ),
    );

    ProcessResult results;
    results = await _processRunner.run(
      command.executable,
      command.arguments,
      runInShell: Platform.isWindows,
      workingDirectory: args.outputDirectory,
    );

    if (results.exitCode != 0) {
      return Future.error(
        OutputMessage(
          message: 'Failed to generate source code. Build Command output:',
          level: Level.SEVERE,
          additionalContext: results.stderr,
          stackTrace: StackTrace.current,
        ),
      );
    } else {
      logOutputMessage(
        log: log,
        communication: OutputMessage(
          message: 'Codegen completed successfully.',
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
          message: 'Skipping install step because flag was set.',
          level: Level.WARNING,
        ),
      );
    } else {
      final command = Command(
          executable: baseCommand,
          arguments: ['pub', 'get'],
          wrapper: args.wrapper);

      logOutputMessage(
        log: log,
        communication: OutputMessage(
          message:
              'Installing dependencies with generated source. ${command.executable} ${command.arguments.join(' ')}',
        ),
      );

      ProcessResult results;
      results = await _processRunner.run(
        command.executable,
        command.arguments,
        runInShell: Platform.isWindows,
        workingDirectory: args.outputDirectory,
      );

      if (results.exitCode != 0) {
        return Future.error(
          OutputMessage(
            message: 'Install within generated sources failed.',
            level: Level.SEVERE,
            additionalContext: results.stderr,
            stackTrace: StackTrace.current,
          ),
        );
      } else {
        logOutputMessage(
          log: log,
          communication: OutputMessage(
            message: [
              if (args.isDebug) results.stdout,
              'Install completed successfully.',
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

  Future<void> updateAnnotatedFile({required annotatedPath}) async {
    // The should exist since that is what triggered the build to begin with so
    // there is no point in verifying it exists. It is also a relative file since
    // it exists within the project.
    final f = File(annotatedPath);
    var content = f.readAsLinesSync();
    final now = DateTime.now().toIso8601String();
    final generated = '$lastRunPlaceHolder: $now';
    if (content.first.contains(lastRunPlaceHolder)) {
      content = content.sublist(1);
      logOutputMessage(
        log: log,
        communication: OutputMessage(
          message: 'Found generated timestamp. Updating with $now',
        ),
      );
    } else {
      logOutputMessage(
        log: log,
        communication: OutputMessage(
          message: 'Creating generated timestamp with $now',
        ),
      );
    }
    try {
      content.insert(0, generated);
      f.writeAsStringSync(content.join('\n'), flush: true);
    } catch (e, st) {
      return Future.error(
        OutputMessage(
          message: 'Failed to update the annotated class file.',
          additionalContext: e,
          stackTrace: st,
          level: Level.SEVERE,
        ),
      );
    }
  }

  /// Format the generated code in the output directory.
  Future<void> formatCode({required GeneratorArguments args}) async {
    final command = Command(executable: 'dart', arguments: ['format', './']);
    ProcessResult result;

    result = await _processRunner.run(
      command.executable,
      command.arguments,
      workingDirectory: args.outputDirectory,
      runInShell: Platform.isWindows,
    );

    if (result.exitCode != 0) {
      return Future.error(
        OutputMessage(
          message: 'Failed to format generated code.',
          additionalContext: result.stderr,
          stackTrace: StackTrace.current,
          level: Level.SEVERE,
        ),
      );
    } else {
      logOutputMessage(
          log: log,
          communication:
              OutputMessage(message: 'Successfully formatted code.'));
    }
  }
}
