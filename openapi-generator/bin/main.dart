import 'dart:io';
import 'dart:isolate';

void main(List<String> arguments) async {
  exitCode = 0; // presume success

  var binPath = (await Isolate.resolvePackageUri(
          Uri.parse('package:openapi_generator/openapi-generator.jar')))
      .toFilePath(windows: Platform.isWindows);
  var JAVA_OPTS = Platform.environment['JAVA_OPTS'] ?? '';

  await Process.run('java', [
    '-jar',
    JAVA_OPTS,
    "${"${binPath}"}",
    ...arguments,
  ]).then((ProcessResult pr) {
    print(pr.exitCode);
    print(pr.stdout);
    print(pr.stderr);
  });
}
