import 'dart:io';

class ProcessRunner {
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
