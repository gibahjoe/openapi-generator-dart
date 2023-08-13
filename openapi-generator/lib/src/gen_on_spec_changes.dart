import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:logging/logging.dart';
import 'package:openapi_generator/src/models/output_message.dart';
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
    {required String specPath, bool isCached = false}) async {
  // If the spec file doesn't match any of the currently supported spec formats
  // reject the request.
  if (!_supportedRegexes.any((fileEnding) => fileEnding.hasMatch(specPath))) {
    return Future.error(
      OutputMessage(
        message: 'Invalid spec file format.',
        level: Level.SEVERE,
        stackTrace: StackTrace.current,
      ),
    );
  }

  final isRemote = RegExp(r'^https?://').hasMatch(specPath);
  if (!isRemote) {
    final file = File(specPath);
    if (file.existsSync()) {
      final contents = await file.readAsString();
      late Map<String, dynamic> spec;
      if (yamlRegex.hasMatch(specPath)) {
        // Load yaml and convert to file
        spec = convertYamlMapToDartMap(yamlMap: loadYaml(contents));
      } else {
        // Convert to json map via json.decode
        spec = jsonDecode(contents);
      }

      return spec;
    }
  } else {
    // TODO: Support custom headers?
    final url = Uri.parse(specPath);
    final resp = await http.get(url);
    if (resp.statusCode == 200) {
      if (yamlRegex.hasMatch(specPath)) {
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
      OutputMessage(message: 'Unable to find spec file $specPath'));
}

/// Verify if the [loadedSpec] has a diff compared to the [cachedSpec].
///
/// Returns true when the number of root keys is different.
bool isSpecDirty({
  required Map<String, dynamic> cachedSpec,
  required Map<String, dynamic> loadedSpec,
}) {
  // The spec always needs to be updated if the cached spec is empty, unless
  // the loaded spec is also empty.
  if (cachedSpec.isEmpty) {
    return true && loadedSpec.isNotEmpty;
  }
  // TODO: Should this be a future? This way the errors can be bubbled up?
  if (loadedSpec.keys.length == cachedSpec.keys.length) {
    for (final entry in cachedSpec.entries) {
      if (!loadedSpec.containsKey(entry.key)) {
        // The original key was removed / renamed in the new map.
        // This will likely occur within the paths map.
        return true;
      }
      final lEntry = loadedSpec[entry.key];
      // Naive assumption that each of the values are the same
      // TODO: Stop assuming the values are of the same type.
      if (entry.value is Map) {
        final v = entry.value as Map<String, dynamic>;
        final l = lEntry as Map<String, dynamic>;
        return isSpecDirty(cachedSpec: v, loadedSpec: l);
      } else if (entry.value is List) {
        // Cast both entries to a list of entries
        var v = entry.value as List;
        var l = lEntry as List;

        if (v.length != l.length) {
          return true;
        }

        try {
          // Cast the list into it's typed variants
          if (v.every((element) => element is num)) {
            if (v.every((element) => element is int)) {
              v = v.cast<int>();
              l = l.cast<int>();
            } else if (v.every((element) => element is double)) {
              v = v.cast<double>();
              l = l.cast<double>();
            }
          } else if (v.every((element) => element is String)) {
            v = v.cast<String>();
            l = l.cast<String>();
          } else if (v.every((element) => element is bool)) {
            v = v.cast<bool>();
            l = l.cast<bool>();
          }
        } on TypeError catch (e, st) {
          log('Failed to cast entry, this may be due to an API change',
              stackTrace: st, error: e);
          // If there is an error casting this is likely due to the type of L not
          // matching which could indicate that the type of the loaded spec may
          // have changed.
          return true;
        }

        // Loop through each of the entries, this now means ordering matters.
        // TODO: Verify if this is desired behaviour.
        for (var i = 0; i < v.length; i++) {
          if (v[i] != l[i]) {
            return true;
          }
        }

        return false;
      } else {
        try {
          // The value is a scalar value
          var v = entry.value;
          var l = lEntry;

          if (v is num) {
            if (v is int) {
              return v != (l as int);
            } else {
              return v != (l as double);
            }
          } else if (v is bool) {
            return v != (l as bool);
          } else if (v is String) {
            return v != (l as String);
          } else {
            // Enums are represented as lists
            return false;
          }
        } catch (e, st) {
          // TODO: This is likely a poor assumption to make
          log('Failed to parse value, likely do to type change',
              stackTrace: st, error: e);
          return true;
        }
      }
    }
    return false;
  }
  return true;
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

  return await outputFile.writeAsString(jsonEncode(spec)).then(
    (_) => log('Successfully wrote cache.'),
    onError: (e, st) {
      log(
        'Failed to write cache',
        error: e,
        stackTrace: st,
      );
      return Future.error('Failed to write cache');
    },
  );
}
