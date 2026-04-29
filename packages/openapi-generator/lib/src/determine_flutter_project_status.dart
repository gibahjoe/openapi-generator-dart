import 'dart:async';
import 'dart:io';

import 'package:openapi_generator_annotations/openapi_generator_annotations.dart';
import 'package:yaml/yaml.dart';

/// Determines whether a project has a dependency on the Flutter sdk.
///
/// If a wrapper annotation is provided that is not null or [Wrapper.none] and
/// is one of [Wrapper.flutterw] or [Wrapper.fvm] it is safe to assume the project
/// requires the Flutter sdk.
///
/// As a fallback we check the pubspec at the root of the current directory, which
/// will be where the build_runner command will have been called from, and check
/// the Pubspec's dependency list for the 'flutter' key.
///
/// Note: This has support for providing a custom path to a pubspec but there isn't
/// any current implementation to receive it via the generator itself.
FutureOr<bool> checkPubspecAndWrapperForFlutterSupport(
    {Wrapper? wrapper = Wrapper.none, String? providedPubspecPath}) async {
  if ([Wrapper.flutterw, Wrapper.fvm].contains(wrapper)) {
    return true;
  } else {
    // Use the path provided or default the directory the command was called from.
    final pubspecPath = providedPubspecPath ??
        '${Directory.current.path}${Platform.pathSeparator}pubspec.yaml';

    final pubspecFile = File(pubspecPath);

    if (!pubspecFile.existsSync()) {
      return Future.error('Pubspec doesn\'t exist at path: $pubspecPath');
    }

    final contents = await pubspecFile.readAsString();
    if (contents.isEmpty) {
      return Future.error('Invalid pubspec.yaml');
    }

    final pubspec = loadYaml(contents) as YamlMap;

    return pubspec.containsKey('dependencies') &&
        (pubspec.nodes['dependencies'] as YamlMap).containsKey('flutter');
  }
}
