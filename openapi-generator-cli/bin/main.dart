import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:openapi_generator_cli/src/models.dart';
import 'package:path/path.dart' as p;

const baseDownloadUrl =
    'https://repo1.maven.org/maven2/org/openapitools/openapi-generator-cli';

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
}

/// Constructs the default OpenAPI Generator JAR file download URL based on the version
String constructJarUrl(String version) {
  return '$baseDownloadUrl/$version/openapi-generator-cli-$version.jar';
}

/// Downloads a JAR file to the specified output path if it doesn't already exist
Future<void> downloadJar(
  String url,
  String outputPath, {
  http.Client? client, // Injected HTTP client for testing
  void Function(String message) log =
      _logOutput, // Optional log function for testing
}) async {
  outputPath = resolvePath(outputPath);
  final file = File(outputPath);
  client ??=
      http.Client(); // Use the injected client or default to a new client

  if (!await file.exists()) {
    log('Downloading $url...');

    final request = http.Request('GET', Uri.parse(url));
    final response = await client.send(request);

    if (response.statusCode == 200) {
      final contentLength = response.contentLength ?? 0;
      final output = file.openWrite();
      var downloadedBytes = 0;

      await response.stream.listen(
        (chunk) {
          downloadedBytes += chunk.length;
          output.add(chunk);

          // Display progress if content length is known
          if (contentLength != 0) {
            final progress = (downloadedBytes / contentLength) * 100;
            log('\rProgress: ${progress.toStringAsFixed(2)}%');
          }
        },
        onDone: () async {
          await output.close();
          log('\nDownloaded to $outputPath\n');
        },
        onError: (e) {
          log('\nDownload failed: $e\n');
        },
        cancelOnError: true,
      ).asFuture();
    } else {
      throw Exception(
          'Failed to download $url. Status code: ${response.statusCode}');
    }
  } else {
    log('[info] $outputPath found. No need to download');
  }
}

/// Executes the OpenAPI Generator using all JARs in the classpath
Future<void> executeWithClasspath(List<String> jarPaths, List<String> arguments,
    [ProcessRunner process = const ProcessRunner()]) async {
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

  final result =
      await process.run('java', commands, runInShell: Platform.isWindows);
  print(result.stdout);
  print(result.stderr);
}

Future<void> main(List<String> arguments) async {
  await runMain(
    arguments: arguments,
    loadConfig: loadOrCreateConfig,
    downloadJar: downloadJar,
    executeWithClasspath: executeWithClasspath,
    log: _logOutput,
  );
}

Future<void> runMain({
  required List<String> arguments,
  required Future<Map<String, dynamic>> Function(String) loadConfig,
  required Future<void> Function(String, String) downloadJar,
  required Future<void> Function(List<String>, List<String>)
      executeWithClasspath,
  required void Function(String) log,
}) async {
  exitCode = 0;

  // Determine config path from arguments or default to 'openapi_generator_config.json'
  final configArgIndex = arguments.indexOf('--config');
  final configFilePath =
      (configArgIndex != -1 && configArgIndex + 1 < arguments.length)
          ? arguments[configArgIndex + 1]
          : 'openapi_generator_config.json';

  log('Using config file: $configFilePath');

  try {
    final config = await loadConfig(configFilePath);
    final version = config[ConfigKeys.openapiGeneratorVersion] ??
        ConfigDefaults.openapiGeneratorVersion;
    final additionalCommands = config[ConfigKeys.additionalCommands] ??
        ConfigDefaults.additionalCommands;
    final overrideUrl = config[ConfigKeys.downloadUrlOverride];
    final cachePath = resolvePath(
        config[ConfigKeys.jarCachePath] ?? ConfigDefaults.jarCacheDir);

    final customGeneratorUrls = List<String>.from(
        config[ConfigKeys.customGeneratorUrls] ??
            ConfigDefaults.customGeneratorUrls);

    // Ensure the cache directory exists
    await Directory(cachePath).create(recursive: true);

    // Define paths for the OpenAPI Generator JAR and custom generator JARs
    final openapiJarPath = '$cachePath/openapi-generator-cli-$version.jar';
    final customJarPaths = <String>[];

    // Download the OpenAPI Generator JAR if it doesn't exist
    await downloadJar(overrideUrl ?? constructJarUrl(version), openapiJarPath);

    // Download each custom generator JAR if it doesn't exist and store in `customJarPaths`
    for (var customJarUrl in customGeneratorUrls) {
      final originalFileName = customJarUrl.split('/').last;
      final customJarPath = '$cachePath/custom-$originalFileName';
      await downloadJar(customJarUrl, customJarPath);
      customJarPaths.add(customJarPath);
    }

    // Combine all JAR paths for the classpath
    final jarPaths = [openapiJarPath, ...customJarPaths];

    // Prepare additional arguments, excluding the --config flag and its value
    final filteredArguments = <String>[
      ...arguments.where((arg) => arg != '--config' && arg != configFilePath),
      additionalCommands,
    ];

    // Execute with classpath
    await executeWithClasspath(
      jarPaths,
      filteredArguments
          .map((e) => e.trim())
          .where((e) => e.isNotEmpty)
          .toList(),
    );
  } catch (e) {
    log('Error: $e');
    exitCode = 1;
  }
}

class ProcessRunner {
  const ProcessRunner();

  Future<ProcessResult> run(String executable, List<String> arguments,
      {Map<String, String>? environment,
      String? workingDirectory,
      bool runInShell = false}) {
    return Process.run(executable, arguments,
        environment: environment,
        workingDirectory: workingDirectory,
        runInShell: runInShell);
  }
}
