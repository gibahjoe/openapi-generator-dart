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

    var separator = '?*?';
    var command = 'generate';

    var inputFile = _readFieldValueAsString(annotation, 'inputSpecFile', '');
    if (inputFile.isNotEmpty) {
      command = '$command$separator-i$separator${inputFile}';
    }

    var templateDir =
        _readFieldValueAsString(annotation, 'templateDirectory', '');
    if (templateDir.isNotEmpty) {
      command = '$command$separator-t$separator${templateDir}';
    }

    var generator =
        _readFieldValueAsString(annotation, 'generatorName', 'dart');
    if (generator != 'dart' &&
        generator != 'dart-dio' &&
        generator != 'dart-jaguar') {
      throw InvalidGenerationSourceError(
        'Generator name must be any of dart, dart-dio, dart-jaguar.',
      );
    }
    command = '$command$separator-g$separator$generator';

    var outputDirectory =
        _readFieldValueAsString(annotation, 'outputDirectory', '');
    if (outputDirectory.isNotEmpty) {
//      if (path.isAbsolute(outputDirectory)) {
//        throw InvalidGenerationSourceError(
//          'Please specify a relative path to your output directory $outputDirectory.',
//        );
//      }
      if (!await Directory(outputDirectory).exists()) {
        await Directory(outputDirectory)
            .create(recursive: true)
            // The created directory is returned as a Future.
            .then((Directory directory) {});
      } else {
        var alwaysRun = _readFieldValueAsBool(annotation, 'alwaysRun', false);
        var filePath = path.join(outputDirectory, 'lib/api.dart');
        if (!alwaysRun && await File(filePath).exists()) {
          print(
              'OpenapiGenerator :: Codegen skipped because alwaysRun is set to [$alwaysRun] and $filePath already exists');
          return '';
        }
      }

      if (!await FileSystemEntity.isDirectory(outputDirectory)) {
        throw InvalidGenerationSourceError(
          '$outputDirectory is not a directory.',
        );
      }
      command = '$command$separator-o$separator${outputDirectory}';
    }

    var additionalProperties = '';
    annotation
        .read('additionalProperties')
        .revive()
        .namedArguments
        .entries
        .forEach((entry) => {
              additionalProperties =
                  '$additionalProperties${additionalProperties.isEmpty ? '' : ','}${entry.key}=${entry.value.toStringValue()}'
            });

    if (additionalProperties != null && additionalProperties.isNotEmpty) {
      command =
          '$command$separator--additional-properties=${additionalProperties}';
    }

    print('OpenapiGenerator :: [${command.replaceAll(separator, ' ')}]');

    var binPath = (await Isolate.resolvePackageUri(
            Uri.parse('package:openapi_generator_cli/openapi-generator.jar')))
        .toFilePath(windows: Platform.isWindows);

    // Include java environment variables in command
    var JAVA_OPTS = Platform.environment['JAVA_OPTS'] ?? '';

    var arguments = [
      '-jar',
      "${"${binPath}"}",
      ...command.split(separator).toList(),
    ];
    if (JAVA_OPTS.isNotEmpty) {
      arguments.insert(0, JAVA_OPTS);
    }
    var exitCode = 0;
    var pr = await Process.run('java', arguments);
//    print(pr.stdout);
    print(pr.stderr);
    print(
        'OpenapiGenerator :: Codegen ${pr.exitCode != 0 ? 'Failed' : 'completed successfully'}');
    exitCode = pr.exitCode;

    if (exitCode == 0) {
      // Install dependencies if last command was successfull
      var installOutput = await Process.run('flutter', ['pub', 'get'],
          workingDirectory: '$outputDirectory');
//      print(installOutput.stdout);
      print(installOutput.stderr);
      print(
          'OpenapiGenerator :: Install exited with code ${installOutput.exitCode}');
      exitCode = installOutput.exitCode;
    }

    if (exitCode == 0 &&
        (generator.contains('jaguar') || generator.contains('dio'))) {
      //run buildrunner to generate files
      var c = 'pub run build_runner build --delete-conflicting-outputs';
      var runnerOutput = await Process.run('flutter', c.split(' ').toList(),
          workingDirectory: '$outputDirectory');
//      print(runnerOutput.stdout);
      print(runnerOutput.stderr);
      print(
          'OpenapiGenerator :: buildrunner exited with code ${runnerOutput.exitCode}');
    }
    return '';
  }

  bool _extendsOpenapiConfig(InterfaceType t) =>
      _typeChecker(OpenapiGeneratorConfig).isExactlyType(t);

  TypeChecker _typeChecker(Type type) => TypeChecker.fromRuntime(type);

  String getMapAsString(Map<dynamic, dynamic> data) {
    return data.entries.map((entry) => '${entry.key}=${entry.value}').join(',');
  }

  String _readFieldValueAsString(ConstantReader annotation, String fieldName,
      [String defaultValue]) {
    var reader = annotation.read(fieldName);

    return reader.isNull ? defaultValue : reader.stringValue ?? defaultValue;
  }

  bool _readFieldValueAsBool(ConstantReader annotation, String fieldName,
      [bool defaultValue]) {
    var reader = annotation.read(fieldName);

    return reader.isNull ? defaultValue : reader.boolValue ?? defaultValue;
  }
}

//abstract class RevivableInstance implements ConstantReader {
//  Uri get uri;
//  String get name;
//  String get constructor;
//  List<ConstantReader> get positionalArguments;
//  Map<String, ConstantReader> get namedArguments;
//}
