import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:logging/logging.dart';
import 'package:openapi_generator/src/models/output_message.dart';
import 'package:openapi_generator_annotations/openapi_generator_annotations.dart';
import 'package:yaml/yaml.dart';

// .json
final jsonRegex = RegExp(r'^.*.json$');
// .yml & .yaml
final yamlRegex = RegExp(r'^.*(.ya?ml)$');

final _supportedRegexes = [jsonRegex, yamlRegex];

/// Load the provided OpenApiSpec from the disk into an in-memory mapping.
///
/// Throws an error when the file extension doesn't match one of the expected
/// extensions:
/// - json
/// - yaml
/// - yml
///
/// It also throws an error when the specification doesn't exist on disk.
///
/// WARNING: THIS DOESN'T VALIDATE THE SPECIFICATION CONTENT
FutureOr<Map<String, dynamic>> loadSpec(
    {required InputSpec specConfig, bool isCached = false}) async {
  // If the spec file doesn't match any of the currently supported spec formats
  // reject the request.
  if (!_supportedRegexes
      .any((fileEnding) => fileEnding.hasMatch(specConfig.path))) {
    return Future.error(
      OutputMessage(
        message: 'Invalid spec file format.',
        level: Level.SEVERE,
        stackTrace: StackTrace.current,
      ),
    );
  }

  if (!(specConfig is RemoteSpec)) {
    final file = File(specConfig.path);
    if (file.existsSync()) {
      final contents = await file.readAsString();
      late Map<String, dynamic> spec;
      if (yamlRegex.hasMatch(specConfig.path)) {
        // Load yaml and convert to file
        spec = convertYamlMapToDartMap(yamlMap: loadYaml(contents));
      } else {
        // Convert to json map via json.decode
        spec = jsonDecode(contents);
      }

      return spec;
    }
  } else {
    Map<String, String>? headers;
    // if (specConfig.headerDelegate is AWSRemoteSpecHeaderDelegate) {
    //   try {
    //     headers = (specConfig.headerDelegate as AWSRemoteSpecHeaderDelegate)
    //         .header(path: specConfig.url.path);
    //   } catch (e, st) {
    //     return Future.error(
    //       OutputMessage(
    //         message: 'failed to generate AWS headers',
    //         additionalContext: e,
    //         stackTrace: st,
    //         level: Level.SEVERE,
    //       ),
    //     );
    //   }
    // } else {
    //   headers = specConfig.headerDelegate.header();
    // }

    final resp = await http.get(specConfig.url, headers: headers);
    if (resp.statusCode == 200) {
      if (yamlRegex.hasMatch(specConfig.path)) {
        return convertYamlMapToDartMap(yamlMap: loadYaml(resp.body));
      } else {
        return jsonDecode(resp.body);
      }
    } else {
      return Future.error(
        OutputMessage(
          message:
              'Unable to request remote spec. Ensure it is public or use a local copy instead.',
          level: Level.SEVERE,
          additionalContext: resp.statusCode,
          stackTrace: StackTrace.current,
        ),
      );
    }
  }

  // In the event that the cached spec isn't found, provide an empty mapping
  // to diff against. This will cause the isSpecDirty check to return true.
  // This can occur on a fresh build / clone.
  if (isCached) {
    return {};
  }

  return Future.error(
    OutputMessage(
        message: 'Unable to find spec file ${specConfig.path}',
        level: Level.WARNING,
        stackTrace: StackTrace.current),
  );
}

/// Verify if the [loadedSpec] has a diff compared to the [cachedSpec].
///
/// Returns true when the number of root keys is different.
bool isSpecDirty({
  required Map<String, dynamic> cachedSpec,
  required Map<String, dynamic> loadedSpec,
}) {
  return jsonEncode(cachedSpec) != jsonEncode(loadedSpec);
}

/// Convert the [YamlMap] to a Dart [Map].
///
/// Converts a [YamlMap] and it's children into a [Map]. This involes expanding
/// [YamlList] & [YamlMap] nodes into their entries. [YamlScalar] values are
/// directly set.
Map<String, dynamic> convertYamlMapToDartMap({required YamlMap yamlMap}) {
  final transformed = <String, dynamic>{};

  yamlMap.forEach((key, value) {
    late dynamic content;
    if (value is YamlList) {
      // Parse list entries
      content = convertYamlListToDartList(yamlList: value);
    } else if (value is YamlMap) {
      // Parse the sub map
      content = convertYamlMapToDartMap(
          yamlMap: YamlMap.internal(value.nodes, value.span, value.style));
    } else if (value is YamlScalar) {
      // Pull the value out of the scalar
      content = value.value;
    } else {
      // Value is a supported dart type
      content = value;
    }
    transformed['$key'] = content;
  });

  return transformed;
}

/// Converts the given [yamlList] into a Dart [List].
///
/// Recursively converts the given [yamlList] to a Dart [List]; converting all
/// nested lists into their constituent values.
List<dynamic> convertYamlListToDartList({required YamlList yamlList}) {
  final converted = [];

  yamlList.forEach((element) {
    if (element is YamlList) {
      converted.add(convertYamlListToDartList(yamlList: element));
    } else if (element is YamlMap) {
      converted.add(convertYamlMapToDartMap(yamlMap: element));
    } else {
      converted.add(element);
    }
  });

  return converted;
}

/// Caches the updated [spec] to disk for use in future comparisons.
///
/// Caches the [spec] to the given [outputLocation]. By default this will be likely
/// be the .dart_tool/openapi-generator-cache.json
Future<void> cacheSpec({
  required String outputLocation,
  required Map<String, dynamic> spec,
}) async {
  final outputPath = outputLocation;
  final outputFile = File(outputPath);
  if (outputFile.existsSync()) {
    log('Found cached asset updating');
  } else {
    log('No previous openapi-generated cache found. Creating cache');
  }

  return await outputFile.writeAsString(jsonEncode(spec), flush: true).then(
        (_) => log('Successfully wrote cache.'),
        onError: (e, st) => Future.error(
          OutputMessage(
            message: 'Failed to write cache',
            additionalContext: e,
            stackTrace: st,
          ),
        ),
      );
}
