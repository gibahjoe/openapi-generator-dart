import 'dart:async';
import 'dart:io';
import 'dart:isolate';

import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/dart/element/type.dart';
import 'package:build/build.dart';
import 'package:build/src/builder/build_step.dart';
import 'package:openapi_generator_annotations/openapi_generator_annotations.dart';
import 'package:path/path.dart' as path;
import 'package:source_gen/source_gen.dart';

class OpenapiGenerator extends GeneratorForAnnotation<Openapi> {
  @override
  FutureOr<String> generateForAnnotatedElement(
      Element element, ConstantReader annotation, BuildStep buildStep) async {
    if (element is! ClassElement) {
      final friendlyName = element.displayName;
      throw InvalidGenerationSourceError(
        'Generator cannot target `$friendlyName`.',
        todo: 'Remove the [Openapi] annotation from `$friendlyName`.',
      );
    }

    var classElement = (element as ClassElement);
    if (classElement.allSupertypes.any(_extendsOpenapiConfig) == false) {
      final friendlyName = element.displayName;
      throw InvalidGenerationSourceError(
        'Generator cannot target `$friendlyName`.',
        todo: '`$friendlyName` need to extends the [OpenapiConfig] class.',
      );
    }
    String separator='?*?';
    String command = 'generate';
    String inputFile = annotation.read('inputSpecFile').stringValue ?? '';
    if (inputFile.isNotEmpty) {
      if (path.isAbsolute(inputFile)) {
        throw InvalidGenerationSourceError(
          'Please specify a relative path to your source directory $inputFile.',
        );
      }
//      inputFile = path.absolute( Directory.current.path,inputFile);
      if (!await FileSystemEntity.isFile(inputFile)) {
        throw InvalidGenerationSourceError(
          'Please specify a file that exists for inputSpecFile $inputFile.',
        );
      }
      command = '$command$separator-i$separator${inputFile}';
    }

    var generator = annotation.read('generator').stringValue ?? 'dart';
    command = '$command$separator-g$separator$generator';

    var outputDirectory = annotation.read('outputDirectory').stringValue ?? '';
    if (outputDirectory.isNotEmpty) {
      if (path.isAbsolute(outputDirectory)) {
        throw InvalidGenerationSourceError(
          'Please specify a relative path to your output directory $outputDirectory.',
        );
      }
//      outputDirectory = path.absolute( Directory.current.path,outputDirectory);
      if (!await FileSystemEntity.isDirectory(outputDirectory)) {
        new Directory(outputDirectory).create(recursive: true)
        // The created directory is returned as a Future.
            .then((Directory directory) {
          print(directory.path);
        });
      }
      command = '$command$separator-o$separator${outputDirectory}';
    }
    var additionalProperties = annotation.read('additionalProperties').mapValue;
    if (additionalProperties != null) {
      command =
          '$command$separator--additional-properties=${additionalProperties.entries.map((entry) => '${entry.key.toStringValue()}=${entry.value.toStringValue()}').join(',')}';
    }
    command='$command$separator-Dcolor';

    print(command);
    var binPath = await Isolate.resolvePackageUri(
        Uri.parse('package:openapi_generator/openapi-generator.jar'));
    var JAVA_OPTS = Platform.environment['JAVA_OPTS'] ?? '';
//    var command = '${JAVA_OPTS} -jar "" ${arguments.join(' ')}';

    print(
        "${FileSystemEntity.isFileSync(binPath.toFilePath(windows: Platform.isWindows))} exists ===>");

    Process.run('java', [
      '-jar',
      "${"${binPath.path}"}",
      ...command.split(separator).toList(),
    ]).then((ProcessResult pr) {
      print(pr.exitCode);
      print(pr.stdout);
      print(pr.stderr);
    });
//    String arguments=command.split(" ")
//    var binPath = 'openapi-generator.jar';
//    var JAVA_OPTS = Platform.environment['JAVA_OPTS'] ?? '';
//    var consoleCommand = '${JAVA_OPTS} -jar "" ${arguments.join(' ')}';
//    Process.run('java', ["-jar", "${"${binPath}"}", ...arguments],
//        workingDirectory: 'bin')
//        .then((ProcessResult pr) {
//      print(pr.exitCode);
//      print(pr.stdout);
//      print(pr.stderr);
//    });
    return '';
  }

  bool _extendsOpenapiConfig(InterfaceType t) =>
      _typeChecker(OpenapiGeneratorConfig).isExactlyType(t);

  TypeChecker _typeChecker(Type type) => TypeChecker.fromRuntime(type);

  String getMapAsString(Map<dynamic, dynamic> data) {
    return data.entries.map((entry) => '${entry.key}=${entry.value}').join(',');
  }
}
