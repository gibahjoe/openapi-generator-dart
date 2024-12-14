import 'package:args/command_runner.dart';
import 'package:openapi_generator_cli/src/models.dart';

class GenerateCommand extends Command {
  // The [name] and [description] properties must be defined by every
  // subclass.
  final name = "generate";
  final description = "Record changes to the repository.";

  CommitCommand() {
    // Add options based on ConfigDefaults and ConfigKeys
    argParser.addOption(ConfigKeys.openapiGeneratorVersion,
        help: 'The version of the OpenAPI generator to use.',
        defaultsTo: ConfigDefaults.openapiGeneratorVersion);

    argParser.addOption(ConfigKeys.additionalCommands,
        help:
            'Additional commands to pass to the generator. This command will be appended at the end of the commands pas',
        defaultsTo: ConfigDefaults.additionalCommands);

    argParser.addOption(ConfigKeys.downloadUrlOverride,
        help: 'A custom URL to override the default download location.',
        defaultsTo: ConfigDefaults.downloadUrlOverride);

    argParser.addOption(ConfigKeys.jarCachePath,
        help: 'The directory where the JAR cache will be stored.',
        defaultsTo: ConfigDefaults.jarCacheDir);

    argParser.addMultiOption(ConfigKeys.customGeneratorUrls,
        help:
            'Urls for the jars of additional OpenAPI generators to combine with the official one.',
        defaultsTo: ConfigDefaults.customGeneratorUrls);
  }

  // [run] may also return a Future.
  void run() {
    // [argResults] is set before [run()] is called and contains the flags/options
    // passed to this command.
    print(argResults?.option('all'));
  }
}
