import 'dart:io';

import 'package:build_test/build_test.dart';
import 'package:source_gen/source_gen.dart';

final testSpecPath =
    '${Directory.current.path}${Platform.pathSeparator}test${Platform.pathSeparator}specs${Platform.pathSeparator}';

Future<ConstantReader> loadAnnoation(String testConfigPath) async =>
    (await resolveSource(
            File('$testSpecPath/$testConfigPath').readAsStringSync(),
            (resolver) async =>
                (await resolver.findLibraryByName('test_lib'))!))
        .getClass('TestClassConfig')!
        .metadata
        .map((e) => ConstantReader(e.computeConstantValue()!))
        .first;
