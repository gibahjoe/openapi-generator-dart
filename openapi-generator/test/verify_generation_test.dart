import 'dart:io';

import 'package:openapi_generator_annotations/openapi_generator_annotations.dart';
import 'package:source_gen_test/source_gen_test.dart';

import 'test_annotations/test_generator.dart';

void main() async {
  final reader = await initializeLibraryReaderForDirectory(
    '${Directory.current.path}${Platform.pathSeparator}test${Platform.pathSeparator}test_annotations',
    'test_configs.dart',
  );

  initializeBuildLogTracking();

  testAnnotatedElements<Openapi>(reader, const TestGenerator());
}
