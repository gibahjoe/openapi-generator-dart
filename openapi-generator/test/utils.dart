import 'dart:io';

import 'package:build/build.dart';
import 'package:build_test/build_test.dart';
import 'package:openapi_generator/src/models/output_message.dart';
import 'package:openapi_generator/src/openapi_generator_runner.dart';
import 'package:openapi_generator/src/process_runner.dart';
import 'package:path/path.dart' as path;
import 'package:source_gen/source_gen.dart';
import 'package:test_process/test_process.dart';

final String pkgName = 'openapi_generator';

final Builder builder = LibraryBuilder(
    OpenapiGenerator(ProcessRunnerForTests()),
    generatedExtension: '.openapi_generator');
final testSpecPath = path.join(Directory.current.path, 'test', 'specs/');

/// Runs an in memory test variant of the generator with the given [source].
///
/// [path] available so an override for the adds generated comment test can
/// compare the output.
///
///
Future<String> generateForSource(String annotatedFilePath,
    {String path = 'lib/myapp.dart',
    String? openapiSpecFilePath,
    String Function(String annotatedFileContent)? preProcessor,
    Map<String, String>? additionalSources}) async {
  final spec = File(openapiSpecFilePath ?? '${testSpecPath}openapi.test.yaml')
      .readAsStringSync();
  final annotatedContent = File(annotatedFilePath).readAsStringSync();
  var srcs = <String, String>{
    'openapi_generator|$path':
        preProcessor?.call(annotatedContent) ?? annotatedContent,
    'openapi_generator|openapi-spec.yaml': spec,
    if (additionalSources?.isNotEmpty == true) ...additionalSources!,
  };

  // Capture any message from generation; if there is one, return that instead of
  // the generated output.
  String? logMessage;
  void captureLog(dynamic logRecord) {
    if (logRecord is OutputMessage) {
      logMessage =
          '${logMessage ?? ''}\n${logRecord.level} ${logRecord.message} \n ${logRecord.additionalContext} \n ${logRecord.stackTrace}';
    } else {
      logMessage =
          '${logMessage ?? ''}\n${logRecord.message ?? ''}\n${logRecord.error ?? ''}\n${logRecord.stackTrace ?? ''}';
    }
  }

  var writer = InMemoryAssetWriter();
  await testBuilder(builder, srcs,
      reader: await PackageAssetReader.currentIsolate(),
      rootPackage: pkgName,
      writer: writer,
      onLog: captureLog);
  return logMessage ??
      String.fromCharCodes(
          writer.assets[AssetId(pkgName, 'lib/value.g.dart')] ?? []);
}

/// Runs an in memory test variant of the generator with the given [source].
///
/// [path] available so an override for the adds generated comment test can
/// compare the output.
///
@Deprecated('Use generateForSource instead')
Future<String> generate(String source, {String path = 'lib/myapp.dart'}) async {
  final spec = File('${testSpecPath}openapi.test.yaml').readAsStringSync();
  var srcs = <String, String>{
    'openapi_generator_annotations|lib/src/openapi_generator_annotations_base.dart':
        File('../openapi-generator-annotations/lib/src/openapi_generator_annotations_base.dart')
            .readAsStringSync(),
    'openapi_generator|$path': '''
    import 'package:openapi_generator_annotations/src/openapi_generator_annotations_base.dart';
    $source
    class MyApp {
    }  
    ''',
    'openapi_generator|openapi-spec.yaml': spec
  };

  // Capture any message from generation; if there is one, return that instead of
  // the generated output.
  String? logMessage;
  void captureLog(dynamic logRecord) {
    if (logRecord is OutputMessage) {
      logMessage =
          '${logMessage ?? ''}\n${logRecord.level} ${logRecord.message} \n ${logRecord.additionalContext} \n ${logRecord.stackTrace}';
    } else {
      logMessage =
          '${logMessage ?? ''}\n${logRecord.message ?? ''}\n${logRecord.error ?? ''}\n${logRecord.stackTrace ?? ''}';
    }
  }

  var writer = InMemoryAssetWriter();
  await testBuilder(builder, srcs,
      rootPackage: pkgName, writer: writer, onLog: captureLog);
  return logMessage ??
      String.fromCharCodes(
          writer.assets[AssetId(pkgName, 'lib/value.g.dart')] ?? []);
}

class ProcessRunnerForTests extends ProcessRunner {
  @override
  Future<ProcessResult> run(String executable, List<String> arguments,
      {Map<String, String>? environment,
      String? workingDirectory,
      bool runInShell = false}) {
    return TestProcess.start(executable, arguments,
            environment: environment,
            workingDirectory: workingDirectory,
            runInShell: runInShell)
        .then(
      (value) async => ProcessResult(
          value.pid, await value.exitCode, value.stdout, value.stderr),
    );
  }
}
