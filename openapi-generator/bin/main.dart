import 'dart:io';
import 'dart:isolate';

void main(List<String> arguments) async{
  exitCode = 0; // presume success

  var binPath = (await Isolate.resolvePackageUri(Uri.parse('package:openapi_generator/openapi-generator.jar'))).toFilePath(windows: Platform.isWindows);
  var JAVA_OPTS = Platform.environment['JAVA_OPTS'] ?? '';
  var command = '${JAVA_OPTS} -jar "" ${arguments.join(' ')}';
  if(FileSystemEntity.isFileSync(binPath)){
    print("$binPath exists ===>");
  }
  print(Platform.resolvedExecutable);
  await Process.run('java', ['-jar', "${"${binPath}"}",  ...arguments,])
      .then((ProcessResult pr) {
    print(pr.exitCode);
    print(pr.stdout);
    print(pr.stderr);
  });
}
