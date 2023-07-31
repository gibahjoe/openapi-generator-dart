import 'dart:async';
import 'dart:io';
import 'dart:isolate';

import 'package:analyzer/dart/constant/value.dart';
import 'package:analyzer/dart/element/element.dart';
import 'package:build/build.dart';
import 'package:openapi_generator_annotations/openapi_generator_annotations.dart'
    as annots;
import 'package:path/path.dart' as path;
import 'package:source_gen/source_gen.dart';

import 'extensions/type_methods.dart';

class OpenapiGenerator extends GeneratorForAnnotation<annots.Openapi> {
  final bool testMode;

  OpenapiGenerator({this.testMode = false});

  @override
  FutureOr<String> generateForAnnotatedElement(
      Element element, ConstantReader annotation, BuildStep buildStep) async {
    var line1 = ' - :::::::::::::::::::::::::::::::::::::::::::';
    var line2 = ' - ::      Openapi generator for dart       ::';
    var line3 = ' - :::::::::::::::::::::::::::::::::::::::::::';
    print('$line1\n$line2\n$line3');

    try {
      if (element is! ClassElement) {
        final friendlyName = element.displayName;
        throw InvalidGenerationSourceError(
          'Generator cannot target `$friendlyName`.',
          todo: 'Remove the [Openapi] annotation from `$friendlyName`.',
        );
      }
      var separator = '?*?';
      var openApiCliCommand = 'generate';

      openApiCliCommand =
          appendInputFileCommandArgs(annotation, openApiCliCommand, separator);

      openApiCliCommand = appendTemplateDirCommandArgs(
          annotation, openApiCliCommand, separator);

      var generatorName =
          annotation.peek('generatorName')?.enumValue<annots.Generator>();
      var generator = getGeneratorNameFromEnum(generatorName!);
      openApiCliCommand = '$openApiCliCommand$separator-g$separator$generator';

      var outputDirectory =
          _readFieldValueAsString(annotation, 'outputDirectory', '');
      if (outputDirectory.isNotEmpty) {
        var alwaysRun = _readFieldValueAsBool(annotation, 'alwaysRun', false)!;
        var filePath = path.join(outputDirectory, 'lib/api.dart');
        if (!alwaysRun && await File(filePath).exists()) {
          print(
              'OpenapiGenerator :: Codegen skipped because alwaysRun is set to [$alwaysRun] and $filePath already exists');
          return '';
        }
        openApiCliCommand =
            '$openApiCliCommand$separator-o$separator$outputDirectory';
      }

      openApiCliCommand = appendTypeMappingCommandArgs(
          annotation, openApiCliCommand, separator);

      openApiCliCommand = appendImportMappingCommandArgs(
          annotation, openApiCliCommand, separator);

      openApiCliCommand = appendReservedWordsMappingCommandArgs(
          annotation, openApiCliCommand, separator);

      openApiCliCommand = appendInlineSchemaNameMappingCommandArgs(
          annotation, openApiCliCommand, separator);

      openApiCliCommand = appendAdditionalPropertiesCommandArgs(
          annotation, openApiCliCommand, separator);

      // openApiCliCommand = appendInlineSchemeOptionsCommandArgs(
      //     annotation, openApiCliCommand, separator);

      openApiCliCommand = appendSkipValidateSpecCommandArgs(
          annotation, openApiCliCommand, separator);

      log.info(
          'OpenapiGenerator :: [${openApiCliCommand.replaceAll(separator, ' ')}]');

      var binPath = (await Isolate.resolvePackageUri(Uri.parse(
              'package:openapi_generator_cli/openapi-generator.jar')))!
          .toFilePath(windows: Platform.isWindows);

      // Include java environment variables in openApiCliCommand
      var javaOpts = Platform.environment['JAVA_OPTS'] ?? '';

      var arguments = [
        '-jar',
        "${"$binPath"}",
        ...openApiCliCommand.split(separator).toList(),
      ];
      if (javaOpts.isNotEmpty) {
        arguments.insert(0, javaOpts);
      }

      var exitCode = 0;
      var pr = await Process.run('java', arguments);
      if (pr.exitCode != 0) {
        log.severe(pr.stderr);
      }

      log.info(
          ' - :: Codegen ${pr.exitCode != 0 ? 'Failed' : 'completed successfully'}');
      exitCode = pr.exitCode;

      if (!_readFieldValueAsBool(annotation, 'fetchDependencies')!) {
        log.warning(' - :: Skipping install step because you said so...');
        return '';
      }

      if (exitCode == 0) {
        final command =
            _getCommandWithWrapper('flutter', ['pub', 'get'], annotation);
        var installOutput = await Process.run(
            command.executable, command.arguments,
            runInShell: Platform.isWindows,
            workingDirectory: '$outputDirectory');

        if (installOutput.exitCode != 0) {
          log.severe(installOutput.stderr);
        }
        print(' :: Install exited with code ${installOutput.exitCode}');
        exitCode = installOutput.exitCode;
      }

      if (!_readFieldValueAsBool(annotation, 'runSourceGenOnOutput')!) {
        log.warning(' :: Skipping source gen step because you said so...');
        return '';
      }

      if (exitCode == 0) {
        //run buildrunner to generate files
        switch (generatorName) {
          case annots.Generator.dart:
            log.info(
                ' :: skipping source gen because generator does not need it ::');
            break;
          case annots.Generator.dio:
          case annots.Generator.dioAlt:
            try {
              var runnerOutput =
                  await runSourceGen(annotation, outputDirectory);
              if (runnerOutput.exitCode != 0) {
                log.severe(runnerOutput.stderr);
                log.severe(
                    ' :: build runner exited with code ${runnerOutput.exitCode} ::');
              } else {
                log.info(
                    ' :: build runner exited with code ${runnerOutput.exitCode} ::');
              }
            } catch (e) {
              log.severe(e);
              log.severe(' :: could not complete source gen ::');
            }
            break;
        }
      }
    } catch (e) {
      log.severe('Error generating spec $e');
      rethrow;
    }
    return '';
  }

  Future<ProcessResult> runSourceGen(
      ConstantReader annotation, String outputDirectory) async {
    log.info(':: running source code generation ::');
    var c = 'pub run build_runner build --delete-conflicting-outputs';
    final command =
        _getCommandWithWrapper('flutter', c.split(' ').toList(), annotation);
    ProcessResult runnerOutput;
    runnerOutput = await Process.run(command.executable, command.arguments,
        runInShell: Platform.isWindows, workingDirectory: '$outputDirectory');
    return runnerOutput;
  }

  String appendAdditionalPropertiesCommandArgs(
      ConstantReader annotation, String command, String separator) {
    var additionalProperties = '';
    var reader = annotation.read('additionalProperties');
    if (!reader.isNull) {
      reader.revive().namedArguments.entries.forEach((entry) => {
            additionalProperties =
                '$additionalProperties${additionalProperties.isEmpty ? '' : ','}${convertToPropertyKey(entry.key)}=${convertToPropertyValue(entry.value)}'
          });
    }

    if (additionalProperties.isNotEmpty) {
      command =
          '$command$separator--additional-properties=$additionalProperties';
    }
    return command;
  }

  String appendInlineSchemeOptionsCommandArgs(
      ConstantReader annotation, String command, String separator) {
    var inlineSchemaOptions = '';
    var reader = annotation.read('inlineSchemaOptions');
    if (!reader.isNull) {
      reader.revive().namedArguments.entries.forEach((entry) => {
            inlineSchemaOptions =
                '$inlineSchemaOptions${inlineSchemaOptions.isEmpty ? '' : ','}${convertToPropertyKey(entry.key)}=${convertToPropertyValue(entry.value)}'
          });
    }

    if (inlineSchemaOptions.isNotEmpty) {
      command =
          '$command$separator--inline-schema-options $inlineSchemaOptions';
    }
    return command;
  }

  String appendTypeMappingCommandArgs(
      ConstantReader annotation, String command, String separator) {
    var typeMappingsMap = _readFieldValueAsMap(annotation, 'typeMappings', {})!;
    if (typeMappingsMap.isNotEmpty) {
      command =
          '$command$separator--type-mappings=${getMapAsString(typeMappingsMap)}';
    }
    return command;
  }

  String appendImportMappingCommandArgs(
      ConstantReader annotation, String command, String separator) {
    var importMappings =
        _readFieldValueAsMap(annotation, 'importMappings', {})!;
    if (importMappings.isNotEmpty) {
      command =
          '$command$separator--import-mappings=${getMapAsString(importMappings)}';
    }
    return command;
  }

  String appendReservedWordsMappingCommandArgs(
      ConstantReader annotation, String command, String separator) {
    var reservedWordsMappingsMap =
        _readFieldValueAsMap(annotation, 'reservedWordsMappings', {})!;
    if (reservedWordsMappingsMap.isNotEmpty) {
      command =
          '$command$separator--reserved-words-mappings=${getMapAsString(reservedWordsMappingsMap)}';
    }
    return command;
  }

  String appendInlineSchemaNameMappingCommandArgs(
      ConstantReader annotation, String command, String separator) {
    var inlineSchemaNameMappings =
        _readFieldValueAsMap(annotation, 'inlineSchemaNameMappings', {})!;
    if (inlineSchemaNameMappings.isNotEmpty) {
      command =
          '$command$separator--inline-schema-name-mappings=${getMapAsString(inlineSchemaNameMappings)}';
    }
    return command;
  }

  String getGeneratorNameFromEnum(annots.Generator generator) {
    var genName = 'dart';
    switch (generator) {
      case annots.Generator.dart:
        break;
      case annots.Generator.dio:
        genName = 'dart-dio';
        break;
      case annots.Generator.dioAlt:
        genName = 'dart2-api';
        break;
      default:
        throw InvalidGenerationSourceError(
          'Generator name must be any of ${annots.Generator.values}.',
        );
    }
    return genName;
  }

  String appendTemplateDirCommandArgs(
      ConstantReader annotation, String command, String separator) {
    var templateDir =
        _readFieldValueAsString(annotation, 'templateDirectory', '');
    if (templateDir.isNotEmpty) {
      command = '$command$separator-t$separator$templateDir';
    }
    return command;
  }

  String appendInputFileCommandArgs(
      ConstantReader annotation, String command, String separator) {
    var inputFile = _readFieldValueAsString(annotation, 'inputSpecFile', '');
    if (inputFile.isNotEmpty) {
      command = '$command$separator-i$separator$inputFile';
    }
    return command;
  }

  String appendSkipValidateSpecCommandArgs(
      ConstantReader annotation, String command, String separator) {
    var skipSpecValidation =
        _readFieldValueAsBool(annotation, 'skipSpecValidation', false)!;
    if (skipSpecValidation) {
      command = '$command$separator--skip-validate-spec';
    }
    return command;
  }

  String getMapAsString(Map<dynamic, dynamic> data) {
    return data.entries
        .map((entry) =>
            '${entry.key.toStringValue()}=${entry.value.toStringValue()}')
        .join(',');
  }

  Command _getCommandWithWrapper(
      String command, List<String> arguments, ConstantReader annotation) {
    final wrapper = annotation
        .read('additionalProperties')
        .read('wrapper')
        .enumValue<annots.Wrapper>();
    switch (wrapper) {
      case annots.Wrapper.flutterw:
        return Command('./flutterw', arguments);
      case annots.Wrapper.fvm:
        return Command('fvm', [command, ...arguments]);
      case annots.Wrapper.none:
      default:
        return Command(command, arguments);
    }
  }

  String _readFieldValueAsString(
      ConstantReader annotation, String fieldName, String defaultValue) {
    var reader = annotation.read(fieldName);

    return reader.isNull ? defaultValue : reader.stringValue;
  }

  Map? _readFieldValueAsMap(ConstantReader annotation, String fieldName,
      [Map? defaultValue]) {
    var reader = annotation.read(fieldName);

    return reader.isNull ? defaultValue : reader.mapValue;
  }

  bool? _readFieldValueAsBool(ConstantReader annotation, String fieldName,
      [bool? defaultValue]) {
    var reader = annotation.read(fieldName);

    return reader.isNull ? defaultValue : reader.boolValue;
  }

  String convertToPropertyKey(String key) {
    switch (key) {
      case 'nullSafeArrayDefault':
        return 'nullSafe-array-default';
      case 'pubspecDependencies':
        return 'pubspec-dependencies';
      case 'pubspecDevDependencies':
        return 'pubspec-dev-dependencies';
      case 'arrayItemSuffix':
        return 'ARRAY_ITEM_SUFFIX';
      case 'mapItemSuffix':
        return 'MAP_ITEM_SUFFIX';
      case 'skipSchemaReuse':
        return 'SKIP_SCHEMA_REUSE';
      case 'refactorAllofInlineSchemas':
        return 'REFACTOR_ALLOF_INLINE_SCHEMAS';
      case 'resolveInlineEnums':
        return 'RESOLVE_INLINE_ENUMS';
    }
    return key;
  }

  String convertToPropertyValue(DartObject value) {
    if (value.isNull) {
      return '';
    }
    return value.toStringValue() ??
        value.toBoolValue()?.toString() ??
        value.toIntValue()?.toString() ??
        value.getField('_name')?.toStringValue() ??
        '';
  }
}

class Command {
  final String executable;
  final List<String> arguments;

  Command(this.executable, this.arguments);
}
