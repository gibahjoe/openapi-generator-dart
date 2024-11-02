import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:path/path.dart' as p;

const baseDownloadUrl =
    'https://repo1.maven.org/maven2/org/openapitools/openapi-generator-cli';

/// Default configuration values
class ConfigDefaults {
  static const openapiGeneratorVersion = '7.9.0';
  static const additionalCommands = '';
  static const downloadUrlOverride = null;
  static const jarCacheDir = '.dart_tool/openapi_generator_cache';
  static const customGeneratorUrls = <String>[
    'https://repo1.maven.org/maven2/com/bluetrainsoftware/maven/openapi-dart-generator/7.2/openapi-dart-generator-7.2.jar'
  ];
}

/// Configuration keys as static constants
class ConfigKeys {
  static const openapiGeneratorVersion = 'openapiGeneratorVersion';
  static const additionalCommands = 'additionalCommands';
  static const downloadUrlOverride = 'downloadUrlOverride';
  static const jarCachePath = 'jarCacheDir';
  static const customGeneratorUrls = 'customGeneratorUrls';
}

/// Resolves a given path to an absolute path, handling both relative and absolute inputs
String resolvePath(String path) {
  return p.isAbsolute(path) ? path : p.absolute(Directory.current.path, path);
}

/// Loads configuration from JSON file or creates it with default values if not found
Future<Map<String, dynamic>> loadOrCreateConfig(String configPath) async {
  _logOutput('[info] Loading config $configPath');
  configPath = resolvePath(configPath);
  final configFile = File(configPath);
  if (await configFile.exists()) {
    final contents = await configFile.readAsString();
    return jsonDecode(contents);
  } else {
    _logOutput('[info] Config $configPath not found. Creating...');
    final defaultConfig = {
      ConfigKeys.openapiGeneratorVersion:
          ConfigDefaults.openapiGeneratorVersion,
      ConfigKeys.additionalCommands: ConfigDefaults.additionalCommands,
      ConfigKeys.downloadUrlOverride: ConfigDefaults.downloadUrlOverride,
      ConfigKeys.jarCachePath: ConfigDefaults.jarCacheDir,
      ConfigKeys.customGeneratorUrls: ConfigDefaults.customGeneratorUrls,
    };
    final encoder = JsonEncoder.withIndent('  ');
    final beautifiedJson = encoder.convert(defaultConfig);
    await configFile.writeAsString(beautifiedJson);
    return defaultConfig;
  }
}

void _logOutput(String message) {
  stdout.writeln(message);
  print(message);
}

/// Constructs the default OpenAPI Generator JAR file download URL based on the version
String constructJarUrl(String version) {
  return '$baseDownloadUrl/$version/openapi-generator-cli-$version.jar';
}

/// Downloads a JAR file to the specified output path if it doesn't already exist
Future<void> downloadJar(String url, String outputPath) async {
  outputPath = resolvePath(outputPath);
  final file = File(outputPath);
  if (!await file.exists()) {
    _logOutput('Downloading $url...');

    final request = http.Request('GET', Uri.parse(url));
    final response = await request.send();

    if (response.statusCode == 200) {
      final contentLength = response.contentLength ?? 0;
      final output = file.openWrite();
      var downloadedBytes = 0;

      // Listen to the stream and write to the file in smaller chunks
      await response.stream.listen(
        (chunk) {
          downloadedBytes += chunk.length;
          output.add(chunk);

          // Display progress if content length is known
          if (contentLength != 0) {
            final progress = (downloadedBytes / contentLength) * 100;
            stdout.write('\rProgress: ${progress.toStringAsFixed(2)}%');
          }
        },
        onDone: () async {
          await output.close();
          print('\nDownloaded to $outputPath\n');
        },
        onError: (e) {
          print('\nDownload failed: $e\n');
        },
        cancelOnError: true,
      ).asFuture();
    } else {
      throw Exception(
          'Failed to download $url. Status code: ${response.statusCode}');
    }
  } else {
    print('[info] $outputPath found. No need to download');
  }
}

/// Executes the OpenAPI Generator using all JARs in the classpath
Future<void> executeWithClasspath(
    List<String> jarPaths, List<String> arguments) async {
  final javaOpts = Platform.environment['JAVA_OPTS'] ?? '';
  final classpath = jarPaths.join(Platform.isWindows ? ';' : ':');
  final commands = [
    '-cp',
    classpath,
    'org.openapitools.codegen.OpenAPIGenerator',
    ...arguments,
  ];

  if (javaOpts.isNotEmpty) {
    commands.insert(0, javaOpts);
  }

  final result = await Process.run('java', commands);
  print(result.stdout);
  print(result.stderr);
}

/// Main function handling config loading, JAR downloading, and command execution
Future<void> main(List<String> arguments) async {
  exitCode = 0; // presume success

  // Determine config path from arguments or default to 'openapi_generator_config.json'
  final configArgIndex = arguments.indexOf('--config');
  final configFilePath =
      (configArgIndex != -1 && configArgIndex + 1 < arguments.length)
          ? arguments[configArgIndex + 1]
          : 'openapi_generator_config.json';

  print('Using config file: $configFilePath');

  final config = await loadOrCreateConfig(configFilePath);
  final String version = (config[ConfigKeys.openapiGeneratorVersion] ??
      ConfigDefaults.openapiGeneratorVersion);
  final String additionalCommands = config[ConfigKeys.additionalCommands] ??
      ConfigDefaults.additionalCommands;
  final String? overrideUrl = config[ConfigKeys.downloadUrlOverride];
  final cachePath = resolvePath(
      config[ConfigKeys.jarCachePath] ?? ConfigDefaults.jarCacheDir);

  final customGeneratorUrls = List<String>.from(
      config[ConfigKeys.customGeneratorUrls] ??
          ConfigDefaults.customGeneratorUrls);
  try {
    // Load or create configuration

    // Ensure the cache directory exists
    await Directory(cachePath).create(recursive: true);

    // Define paths for the OpenAPI Generator JAR and custom generator JARs
    final openapiJarPath = '$cachePath/openapi-generator-cli-$version.jar';
    final customJarPaths = <String>[];

    // Download the OpenAPI Generator JAR if it doesn't exist
    await downloadJar(overrideUrl ?? constructJarUrl(version), openapiJarPath);

    // Download each custom generator JAR if it doesn't exist and store in `customJarPaths`
    for (var i = 0; i < customGeneratorUrls.length; i++) {
      final customJarUrl = customGeneratorUrls[i];
      final originalFileName = customJarUrl.split('/').last;
      final customJarPath = '$cachePath/custom-$originalFileName';
      await downloadJar(customJarUrl, customJarPath);
      customJarPaths.add(customJarPath);
    }

    // Combine all JAR paths (OpenAPI Generator + custom generators) for the classpath
    final jarPaths = [openapiJarPath, ...customJarPaths];

    // Prepare additional arguments, excluding the --config flag and its value
    final filteredArguments = <String>[
      ...additionalCommands.split(' '),
      ...arguments.where((arg) => arg != '--config' && arg != configFilePath),
    ];

    // Execute using all JARs in the classpath
    await executeWithClasspath(
        jarPaths,
        filteredArguments
            .map(
              (e) => e.trim(),
            )
            .where(
              (element) => element.isNotEmpty,
            )
            .toList());
  } catch (e) {
    _logOutput('Error: $e');
    exitCode = 1;
  }
}
