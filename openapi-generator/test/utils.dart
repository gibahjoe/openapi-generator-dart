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

  var writer = InMemoryAssetWriter();

  final Builder builder = LibraryBuilder(OpenapiGenerator(process),
      generatedExtension: '.openapi_generator');
  await testBuilder(builder, sources,
      reader: await PackageAssetReader.currentIsolate(),
      rootPackage: pkgName,
      writer: writer,
      onLog: captureLog);
  return logMessage ??
      String.fromCharCodes(
          writer.assets[AssetId(pkgName, 'lib/value.g.dart')] ?? []);
}

Future<String> generateFromAnnotation(Openapi openapi,
    {ProcessRunner? process, String path = 'lib/myapp.dart'}) {
  expect(openapi.inputSpec is RemoteSpec, isFalse,
      reason: 'Please use a local spec for tests.');
  return generateFromSource(openapi.toString(),
      process: process,
      openapiSpecFilePath: openapi.inputSpec.path,
      path: path);
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
  printOnFailure('Generator sources =>\n${sources}');
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
  final Builder builder = LibraryBuilder(OpenapiGenerator(process),
      generatedExtension: '.openapi_generator');
  await testBuilder(builder, sources,
      reader: await PackageAssetReader.currentIsolate(),
      rootPackage: pkgName,
      writer: writer,
      onLog: captureLog);
  return logMessage ??
      String.fromCharCodes(
          writer.assets[AssetId(pkgName, 'lib/value.g.dart')] ?? []);
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
  var openapi = await readAnnotationFromFile(
      path: path, libraryName: libraryName, className: className);
  return GeneratorArguments(annotations: openapi);
}

Future<ConstantReader> readAnnotation(Openapi annotation) async {
  var annotatedClass = '''library test_lib;
  import 'package:openapi_generator_annotations/openapi_generator_annotations.dart';
  ${annotation.toString()}
  class MyClass{}
  ''';
  printOnFailure(annotatedClass);
  return (await resolveSource(annotatedClass,
          (resolver) async => (await resolver.findLibraryByName('test_lib'))!))
      .getClass('MyClass')!
      .metadata
      .map((e) => ConstantReader(e.computeConstantValue()!))
      .first;
}

Future<ConstantReader> readAnnotationFromFile(
    {required String path,
    String libraryName = 'test_lib',
    String className = 'TestClass'}) async {
  return (await resolveSource(
          File('$testSpecPath/next_gen_builder_test_config.dart')
              .readAsStringSync(),
          (resolver) async => (await resolver.findLibraryByName(libraryName))!))
      .getClass(className)!
      .metadata
      .map((e) => ConstantReader(e.computeConstantValue()!))
      .first;
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
