import 'dart:io';
import 'dart:isolate';

/// Proxies commandline ars from openapi-generator to the build [arguments] the commandline arguments to proxy
void main(List<String> arguments) async {
  exitCode = 0; // presume success

  var binPath = (await Isolate.resolvePackageUri(
          Uri.parse('package:openapi_generator_cli/openapi-generator.jar')))!
      .toFilePath(windows: Platform.isWindows);
  var JAVA_OPTS = Platform.environment['JAVA_OPTS'] ?? '';

  var commands = [
    '-jar',
    "${"${binPath}"}",
    ...arguments,
  ];
  if (JAVA_OPTS.isNotEmpty) {
    commands.insert(0, JAVA_OPTS);
  }
  await Process.run('java', commands).then((ProcessResult pr) {
    print(pr.exitCode);
    print(pr.stdout);
    print(pr.stderr);
  });
}
