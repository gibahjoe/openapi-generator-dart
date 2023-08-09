import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:yaml/yaml.dart';

// .json
final jsonRegex = RegExp(r'.*.json$');
// .yml & .yaml
final yamlRegex = RegExp(r'.*(.ya?ml)$');

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
FutureOr<Map<String, dynamic>> loadSpec({required String specPath}) async {
  // If the spec file doesn't match any of the currently supported spec formats
  // reject the request.
  if (!_supportedRegexes.any((fileEnding) => fileEnding.hasMatch(specPath))) {
    return Future.error('Invalid spec format');
  }

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

  return Future.error('Unable to find spec file $specPath');
}

/// Verify if the [loadedSpec] has a diff compared to the [cachedSpec].
///
/// Returns true when the number of root keys is different.
bool isSpecDirty({
  required Map<String, dynamic> cachedSpec,
  required Map<String, dynamic> loadedSpec,
}) {
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
///
/// Currently this makes the assumption that [YamlList] node shouldn't be a valid
/// child entry within another [YamlList] and ignores the contents.
Map<String, dynamic> convertYamlMapToDartMap({required YamlMap yamlMap}) {
  final transformed = <String, dynamic>{};

  yamlMap.forEach((key, value) {
    late dynamic content;
    if (value is YamlList) {
      // Parse list entries
      content = [];
      value.forEach((element) {
        if (element is YamlList) {
          // TODO: Is this a potential case.
          log('Found a YamlList within a YamlList');
        } else if (element is YamlMap) {
          content.add(convertYamlMapToDartMap(yamlMap: element));
        } else {
          content.add(element);
        }
      });
    } else if (value is YamlMap) {
      // Parse the sub mapyamlParsedMap
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

Future<void> cacheSpec({
  required String outputDirectory,
  required Map<String, dynamic> spec,
}) async {}
