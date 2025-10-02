import 'dart:io';

import 'package:build/build.dart';
import 'package:build_test/build_test.dart';
import 'package:mockito/annotations.dart';
import 'package:openapi_generator/src/models/generator_arguments.dart';
import 'package:openapi_generator/src/models/output_message.dart';
import 'package:openapi_generator/src/openapi_generator_runner.dart';
import 'package:openapi_generator/src/process_runner.dart';
import 'package:openapi_generator_annotations/openapi_generator_annotations.dart';
import 'package:path/path.dart' as path;
import 'package:source_gen/source_gen.dart';
import 'package:source_gen_test/source_gen_test.dart';
import 'package:test/expect.dart';
import 'package:test/scaffolding.dart';

@GenerateNiceMocks([MockSpec<ProcessRunner>()])
import 'utils.mocks.dart';

final String pkgName = 'openapi_generator';

final testSpecPath = path.join(Directory.current.path, 'test', 'specs/');

/// Runs an in memory test variant of the generator with the given [source].
///
/// [path] available so an override for the adds generated comment test can
/// compare the output.
///
///
Future<String> generateFromPath(
  String annotatedFilePath, {
  ProcessRunner? process,
  String path = 'lib/myapp.dart',
  String? openapiSpecFilePath,
  String Function(String annotatedFileContent)? preProcessor,
  Map<String, String>? additionalSources,
}) async {
  process ??= MockProcessRunner();
  final spec = File(openapiSpecFilePath ?? '${testSpecPath}openapi.test.yaml')
      .readAsStringSync();
  final annotatedContent = File(annotatedFilePath).readAsStringSync();
  var sources = <String, String>{
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

  final readerWriter = TestReaderWriter(rootPackage: 'openapi_generator');
  await readerWriter.testing.loadIsolateSources();

  final Builder builder = LibraryBuilder(OpenapiGenerator(process),
      generatedExtension: '.openapi_generator');
  // Run the builder in test mode; it returns a TestBuilderResult
  await testBuilder(
    builder,
    sources,
    rootPackage: pkgName,
    packageConfig: (await PackageAssetReader.currentIsolate()).packageConfig,
    onLog: captureLog,
    readerWriter: readerWriter,
  );

  printOnFailure('Generated files: $logMessage');
  // Fallback to empty
  final output = logMessage ?? '';

  return output;
}

Future<String> generateFromAnnotation(Openapi openapi,
    {ProcessRunner? process, String path = 'lib/myapp.dart'}) {
  String? specPath = null;
  if (openapi.inputSpec is! RemoteSpec) {
    specPath = openapi.inputSpec.path;
  }
  return generateFromSource(openapi.toString(),
      process: process, openapiSpecFilePath: specPath, path: path);
}

/// Runs an in memory test variant of the generator with the given [source].
///
/// [path] available so an override for the adds generated comment test can
/// compare the output.
Future<String> generateFromSource(String source,
    {ProcessRunner? process,
    String path = 'lib/myapp.dart',
    String? openapiSpecFilePath}) async {
  process ??= MockProcessRunner();
  final spec = File(openapiSpecFilePath ?? '${testSpecPath}openapi.test.yaml')
      .readAsStringSync();
  var sources = <String, String>{
    'openapi_generator|$path': '''
    import 'package:openapi_generator_annotations/openapi_generator_annotations.dart';
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

  final readerWriter = TestReaderWriter(rootPackage: 'openapi_generator');
  await readerWriter.testing.loadIsolateSources();

  final Builder builder = LibraryBuilder(OpenapiGenerator(process),
      generatedExtension: '.openapi_generator');
  // Run the builder in test mode; it returns a TestBuilderResult
  await testBuilder(
    builder,
    sources,
    rootPackage: pkgName,
    packageConfig: (await PackageAssetReader.currentIsolate()).packageConfig,
    onLog: captureLog,
    readerWriter: readerWriter,
  );

  printOnFailure('Generation log: ${logMessage}');
  // Fallback to empty
  final output = logMessage ?? '';

  return output;
}

// Future<ConstantReader> readAnnotation(String source)async{
//   return (await resolveSource('''library test_lib;
//   import 'package:openapi_generator_annotations/openapi_generator_annotations.dart';
//   $source
//   class MyClass{}
//   ''',
//   (resolver) async =>
//   (await resolver.findLibraryByName('test_lib'))!))
//       .getClass('MyClass')!
//       .metadata
//       .map((e) => ConstantReader(e.computeConstantValue()!))
//   .first;
// }
Future<GeneratorArguments> getArguments(Openapi annotation) async {
  var openapi = await readAnnotation(annotation);
  return GeneratorArguments(annotations: openapi);
}

Future<GeneratorArguments> getArgumentsFromFile(
    {required String path,
    String libraryName = 'test_lib',
    String className = 'TestClass'}) async {
  var openapi = await getConstantReaderForPath(
      file: File(path), libraryName: libraryName, className: className);
  return GeneratorArguments(annotations: openapi);
}

Future<ConstantReader> readAnnotation(Openapi annotation) async {
  var annotatedClass = '''library test_lib;
  import 'package:openapi_generator_annotations/openapi_generator_annotations.dart';
  ${annotation.toString()}
  class MyClass{}
  ''';
  printOnFailure(
    '''
    == Annotated class =>\n$annotatedClass
    ''',
  );
  return await getConstantReader(
      definition: annotatedClass,
      libraryName: 'test_lib',
      className: 'MyClass');
}

void cleanup(String path) async {
  final directory = Directory(path);

  if (await directory.exists()) {
    await directory.delete(recursive: true);
    print('Folder deleted successfully.');
  } else {
    print('Folder does not exist.');
  }
}

Future<ConstantReader> getConstantReader(
    {required String definition,
    String libraryName = 'test_lib',
    String className = 'TestClassConfig'}) async {
  var libraryReader =
      await initializeLibraryReader({'test.dart': definition}, 'test.dart');
  var classElement = libraryReader.classes.first;

  var element = classElement.metadata.annotations.first;
  var constantValue = element.computeConstantValue();
  return ConstantReader(constantValue);
}

Future<ConstantReader> getConstantReaderForPath(
    {required File file,
    String libraryName = 'test_lib',
    String className = 'TestClassConfig'}) async {
  var libraryReader = await initializeLibraryReaderForDirectory(
    file.parent.path,
    file.uri.pathSegments.last,
  );

  var classElement = libraryReader.classes.first;

  var element = classElement.metadata.annotations.first;
  var constantValue = element.computeConstantValue();

  return ConstantReader(constantValue);
}

// Test Expectations
void expectSourceGenSkipped(Directory outputDir) {
  expect(
    outputDir
        .listSync(recursive: true)
        .where((f) =>
            f.path.contains('lib/src/model') && f.path.endsWith('.g.dart'))
        .isEmpty,
    true,
    reason:
        'No .g.dart files found in lib/src/model, generation might have failed.',
  );
}

void expectCodeFormattedSuccessfully(Directory outputDir) {
  // run dart format --set-exit-if-changed . on the output directory
  final result = Process.runSync(
      'dart', ['format', '--set-exit-if-changed', '.'],
      workingDirectory: outputDir.path);
  expect(result.exitCode, 0,
      reason:
          'Code formatting failed. Please run "dart format ." on the output directory.\n${result.stdout}\n${result.stderr}');
}

void expectSourceGenRun(Directory outputDir) {
  expect(
    outputDir
        .listSync(recursive: true)
        .where((f) =>
            f.path.contains('lib/src/model') && f.path.endsWith('.g.dart'))
        .isNotEmpty,
    true,
    reason:
        'No .g.dart files found in lib/src/model, generation might have failed.',
  );
}
