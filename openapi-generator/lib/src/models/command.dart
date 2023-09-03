import 'dart:io';

import 'package:openapi_generator/src/determine_flutter_project_status.dart';
import 'package:openapi_generator/src/gen_on_spec_changes.dart';
import 'package:openapi_generator_annotations/openapi_generator_annotations.dart';

/// Creates a representation of a cli request for Flutter or Dart.
class Command {
  final String _executable;
  final List<String> _arguments;

  String get executable => _executable;

  List<String> get arguments => _arguments;

  Command._(this._executable, this._arguments);

  /// Provides an in memory representation of the Dart of Flutter cli command.
  ///
  /// If [executable] is the Dart executable or the [wrapper] is [Wrapper.none]
  /// it provides the raw executable. Otherwise it wraps it in the appropriate
  /// wrapper, flutterw and fvm respectively.
  Command({
    Wrapper wrapper = Wrapper.none,
    required String executable,
    required List<String> arguments,
  }) : this._(
          executable == 'dart' || wrapper == Wrapper.none
              ? executable
              : wrapper == Wrapper.flutterw
                  ? './flutterw'
                  : 'fvm',
          arguments,
        );
}

/// CommandRunner provides an abstraction layer to external functions / processes.
class CommandRunner {
  const CommandRunner();

  Future<ProcessResult> runCommand({
    required Command command,
    required String workingDirectory,
  }) async =>
      Process.run(
        command.executable,
        command.arguments,
        workingDirectory: workingDirectory,
        runInShell: Platform.isWindows,
      );

  Future<List<String>> loadAnnotatedFile({required String path}) async {
    final f = File(path);
    return f.readAsLines();
  }

  Future<void> writeAnnotatedFile(
      {required String path, required List<String> content}) async {
    final f = File(path);
    return f.writeAsStringSync(content.join('\n'), flush: true);
  }

  Future<void> cacheSpecFile({
    required Map<String, dynamic> updatedSpec,
    required String cachedPath,
  }) async =>
      cacheSpec(outputLocation: cachedPath, spec: updatedSpec);

  Future<Map<String, dynamic>> loadSpecFile(
          {required InputSpec specConfig, bool isCached = false}) async =>
      loadSpec(specConfig: specConfig);

  Future<bool> isSpecFileDirty({
    required Map<String, dynamic> cachedSpec,
    required Map<String, dynamic> loadedSpec,
  }) async =>
      isSpecDirty(cachedSpec: cachedSpec, loadedSpec: loadedSpec);

  Future<bool> checkForFlutterEnvironemt(
          {Wrapper? wrapper = Wrapper.none,
          String? providedPubspecPath}) async =>
      checkPubspecAndWrapperForFlutterSupport(
          wrapper: wrapper, providedPubspecPath: providedPubspecPath);
}
