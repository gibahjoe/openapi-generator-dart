import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:path/path.dart' as p;
import 'package:test/test.dart';

import '../bin/main.dart';

void main() {
  late Directory tempDir;
  late String configFilePath;
  late String jarFilePath;
  late String customJarFilePath;

  setUp(() async {
    // Set up a temporary directory for testing
    tempDir = await Directory.systemTemp.createTemp('openapi_generator_test');
    configFilePath = p.join(tempDir.path, 'openapi_generator_config.json');
    jarFilePath = p.join(tempDir.path, 'openapi-generator-cli-test.jar');
    customJarFilePath =
        p.join(tempDir.path, 'custom-openapi-dart-generator.jar');
  });

  tearDown(() async {
    // Clean up any files or directories created during tests
    if (await tempDir.exists()) {
      await tempDir.delete(recursive: true);
    }
  });

  test(
      'loadOrCreateConfig creates a config file with default values if not found',
      () async {
    final config = await loadOrCreateConfig(configFilePath);

    // Check that the file was created with default values
    expect(config[ConfigKeys.openapiGeneratorVersion],
        ConfigDefaults.openapiGeneratorVersion);
    expect(config[ConfigKeys.additionalCommands],
        ConfigDefaults.additionalCommands);
    expect(config[ConfigKeys.downloadUrlOverride],
        ConfigDefaults.downloadUrlOverride);
    expect(config[ConfigKeys.jarCachePath], ConfigDefaults.jarCacheDir);

    // Ensure the file exists and contains the correct JSON structure
    final configFile = File(configFilePath);
    expect(await configFile.exists(), isTrue);
    final contents = await configFile.readAsString();
    expect(contents, contains(ConfigDefaults.openapiGeneratorVersion));
  });

  test('downloadJar downloads a JAR file when it does not exist', () async {
    // Mock the HTTP client to avoid real network calls
    final mockClient = MockClient((request) async {
      return http.Response.bytes(
          List<int>.filled(1024, 1), 200); // 1 KB of dummy data
    });
    http.Client client = mockClient;

    await downloadJar(constructJarUrl('test'), jarFilePath, client: client);

    // Verify the file was downloaded
    final jarFile = File(jarFilePath);
    expect(await jarFile.exists(), isTrue);
    expect(await jarFile.length(), greaterThan(0));
  });

  test('downloadJar does not download if file already exists', () async {
    // Create an empty file at the target path
    final file = await File(jarFilePath).create();
    await file.writeAsString('existing file content');
    final mockClient = MockClient((request) async {
      fail('HTTP client should not be called when file exists');
      return http.Response.bytes(
          List<int>.filled(1024, 1), 200); // 1 KB of dummy data
    });
    http.Client client = mockClient;
    await downloadJar(constructJarUrl('test'), jarFilePath, client: client);
    // Verify that the file content was not overwritten
    final content = await file.readAsString();
    expect(content, equals('existing file content'));
  });

  test('executeWithClasspath runs the process with all JARs in the classpath',
      () async {
    // Mock the HTTP client to avoid real network calls
    final mockClient = MockClient((request) async {
      return http.Response.bytes(
          List<int>.filled(1024, 1), 200); // 1 KB of dummy data
    });

    final jarPaths = [jarFilePath, customJarFilePath];
    final args = <String>[];
    final javaOpts = Platform.environment['JAVA_OPTS'] ?? '';
    final classpath = jarPaths.join(Platform.isWindows ? ';' : ':');
    var commands = [
      '-cp',
      classpath,
      'org.openapitools.codegen.OpenAPIGenerator',
      ...args,
    ];
    if (javaOpts.isNotEmpty) {
      commands.insert(0, javaOpts);
    }
    // Run the process with the JARs in the classpath
    await executeWithClasspath(jarPaths, args, TestProcessRunner(
      runDelegate: (executable, arguments,
          {environment, runInShell, workingDirectory}) async {
        expect(executable, 'java');
        expect(arguments, commands);
        expect(runInShell, Platform.isWindows);
        return ProcessResult(1, 0, null, null);
      },
    ));
  });

  test('constructJarUrl constructs the correct URL', () {
    final version = '7.9.0';
    final expectedUrl =
        'https://repo1.maven.org/maven2/org/openapitools/openapi-generator-cli/7.9.0/openapi-generator-cli-7.9.0.jar';
    expect(constructJarUrl(version), equals(expectedUrl));
  });

  test('runMain successfully loads config and calls required methods',
      () async {
    final logBuffer = StringBuffer();
    final mockConfigPath = 'mock_config.json';
    final mockVersion = '1.0.0';
    final mockCacheDir = '.dart_tool/openapi_generator_cache';
    final mockArguments = ['--config', mockConfigPath, 'generate'];

    // Mock functions
    Future<Map<String, dynamic>> mockLoadConfig(String path) async {
      expect(path, mockConfigPath);
      return {
        ConfigKeys.openapiGeneratorVersion: mockVersion,
        ConfigKeys.jarCachePath: mockCacheDir,
        ConfigKeys.customGeneratorUrls: [],
      };
    }

    Future<void> mockDownloadJar(String url, String outputPath) async {
      expect(url, contains(mockVersion)); // Ensure URL is correctly constructed
      expect(outputPath, contains(mockCacheDir)); // Check output path location
    }

    Future<void> mockExecuteWithClasspath(
      List<String> jarPaths,
      List<String> args,
    ) async {
      expect(jarPaths, isNotEmpty); // JARs should be included in classpath
      expect(args, contains('generate')); // Check arguments passed correctly
    }

    void mockLog(String message) {
      logBuffer.writeln(message); // Capture log messages
    }

    // Run the test
    await runMain(
      arguments: mockArguments,
      loadConfig: mockLoadConfig,
      downloadJar: mockDownloadJar,
      executeWithClasspath: mockExecuteWithClasspath,
      log: mockLog,
    );

    // Verify log output
    expect(
        logBuffer.toString(), contains('Using config file: $mockConfigPath'));
  });

  test('runMain handles errors gracefully and sets exitCode to 1', () async {
    final logBuffer = StringBuffer();
    final mockArguments = ['--config', 'nonexistent_config.json'];

    // Mock functions
    Future<Map<String, dynamic>> mockLoadConfig(String path) async {
      throw FileSystemException('File not found', path);
    }

    Future<void> mockDownloadJar(String url, String outputPath) async {
      fail('downloadJar should not be called on error');
    }

    Future<void> mockExecuteWithClasspath(
        List<String> jarPaths, List<String> args) async {
      fail('executeWithClasspath should not be called on error');
    }

    void mockLog(String message) {
      logBuffer.writeln(message);
    }

    // Run the test with error
    await runMain(
      arguments: mockArguments,
      loadConfig: mockLoadConfig,
      downloadJar: mockDownloadJar,
      executeWithClasspath: mockExecuteWithClasspath,
      log: mockLog,
    );

    // Verify the exit code and log output
    expect(exitCode, equals(1));
    expect(logBuffer.toString(), contains('Error: FileSystemException'));
  });
}

class TestProcessRunner extends ProcessRunner {
  Future<ProcessResult> Function(String executable, List<String> arguments,
      {Map<String, String>? environment,
      String? workingDirectory,
      bool? runInShell}) runDelegate;

  TestProcessRunner({required this.runDelegate});

  @override
  Future<ProcessResult> run(String executable, List<String> arguments,
      {Map<String, String>? environment,
      String? workingDirectory,
      bool runInShell = false}) {
    return runDelegate.call(executable, arguments,
        environment: environment,
        workingDirectory: workingDirectory,
        runInShell: runInShell);
  }
}
