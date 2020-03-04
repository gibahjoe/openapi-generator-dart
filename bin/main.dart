import 'dart:io';

import 'package:openapi_generator/openapi_generator.dart' as openapi_generator;

void main(List<String> arguments) {
  print('Hello world: ${openapi_generator.calculate()}!');
  var binPath = 'openapi-generator.jar';
  var JAVA_OPTS = Platform.environment['JAVA_OPTS'] ?? '';
  exitCode = 0; // presume success
//  final parser = ArgParser()
//    ..addFlag(lineNumber, negatable: false, abbr: 'n');
//
//  argResults = parser.parse(arguments);
//  final paths = argResults.rest;
  var command = '${JAVA_OPTS} -jar "" ${arguments.join(' ')}';
  Process.run('java', ["-jar", "${"${binPath}"}", ...arguments],
          workingDirectory: 'bin')
      .then((ProcessResult pr) {
    print(pr.exitCode);
    print(pr.stdout);
    print(pr.stderr);
  });
}
