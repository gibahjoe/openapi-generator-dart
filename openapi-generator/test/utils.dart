import 'dart:io';

import 'package:build/build.dart';
import 'package:build_test/build_test.dart';
import 'package:openapi_generator/src/models/output_message.dart';
import 'package:openapi_generator/src/openapi_generator_runner.dart';
import 'package:source_gen/source_gen.dart';

final String pkgName = 'pkg';

final Builder builder = LibraryBuilder(OpenapiGenerator(testMode: true),
    generatedExtension: '.openapi_generator');
final testSpecPath =
    '${Directory.current.path}${Platform.pathSeparator}test${Platform.pathSeparator}specs${Platform.pathSeparator}';

Future<String> generate(String source) async {
  final spec = File('${testSpecPath}openapi.test.yaml').readAsStringSync();
  var srcs = <String, String>{
    'openapi_generator_annotations|lib/src/openapi_generator_annotations_base.dart':
        File('../openapi-generator-annotations/lib/src/openapi_generator_annotations_base.dart')
            .readAsStringSync(),
    'openapi_generator|lib/myapp.dart': '''
    import 'package:openapi_generator_annotations/src/openapi_generator_annotations_base.dart';
    $source
    class MyApp {
    }  
    ''',
    'openapi_generator|openapi-spec.yaml': spec
  };

  // Capture any error from generation; if there is one, return that instead of
  // the generated output.
  String? error;
  void captureError(dynamic logRecord) {
    // print(logRecord.runtimeType);
    // print(logRecord);
    // if (logRecord.error is InvalidGenerationSourceError) {
    //   if (error != null) throw StateError('Expected at most one error.');
    //   error = logRecord.error.toString();
    // }
    if (logRecord is OutputMessage) {
      error =
          '${error ?? ''}\n${logRecord.level} ${logRecord.message} \n ${logRecord.additionalContext} \n ${logRecord.stackTrace}';
    } else {
      error =
          '${error ?? ''}\n${logRecord.message}\n${logRecord.error}\n${logRecord.stackTrace}';
    }
  }

  var writer = InMemoryAssetWriter();
  await testBuilder(builder, srcs,
      rootPackage: pkgName, writer: writer, onLog: captureError);
  return error ??
      String.fromCharCodes(
          writer.assets[AssetId(pkgName, 'lib/value.g.dart')] ?? []);
}
