import 'dart:io';

import 'package:test/expect.dart';
import 'package:test/scaffolding.dart';

import 'utils.dart';

/// We test the build runner by mocking the specs and then checking the output
/// content for the expected generate command.
void main() {
  group('generator dio', () {
    test('to generate appropriate openapi cli command', () async {
      expect(
          await generate('''
      @Openapi(
          additionalProperties:
              DioProperties(pubName: 'petstore_api', pubAuthor: 'Johnny dep...'),
          inputSpecFile: '../openapi-spec.yaml',
          typeMappings: {'Pet': 'ExamplePet'},
          generatorName: Generator.dio,
          runSourceGenOnOutput: true,
          alwaysRun: true,
          outputDirectory: 'api/petstore_api')
      '''),
          contains(
              "generate -o ${Directory.current.path} -i ../openapi-spec.yaml -g dart-dio -o api/petstore_api --additional-properties=pubName=petstore_api,pubAuthor=Johnny dep... --type-mappings=Pet=ExamplePet"));
    });

    test('to generate command with import and type mappings', () async {
      expect(
          await generate('''
      @Openapi(
          inputSpecFile: '../openapi-spec.yaml',
          typeMappings: {'int-or-string':'IntOrString'},
          importMappings: {'IntOrString':'./int_or_string.dart'},
          generatorName: Generator.dio)
      '''),
          contains(
              'generate -o ${Directory.current.path} -i ../openapi-spec.yaml -g dart-dio --import-mappings=IntOrString=./int_or_string.dart --type-mappings=int-or-string=IntOrString'));
    });

    test('to generate command with inline schema mappings', () async {
      expect(
          await generate('''
      @Openapi(
          inputSpecFile: '../openapi-spec.yaml',
          typeMappings: {'int-or-string':'IntOrString'},
          inlineSchemaNameMappings: {'inline_object_2':'SomethingMapped','inline_object_4':'nothing_new'},
          generatorName: Generator.dio)
      '''),
          contains('''
              generate -o ${Directory.current.path} -i ../openapi-spec.yaml -g dart-dio --inline-schema-name-mappings=inline_object_2=SomethingMapped,inline_object_4=nothing_new --type-mappings=int-or-string=IntOrString
              '''
              .trim()));
    });

    // test('to generate command with inline schema options', () async {
    //   expect(await generate('''
    //   @Openapi(
    //       inputSpecFile: '../openapi-spec.yaml',
    //       inlineSchemaOptions: InlineSchemaOptions(skipSchemaReuse: true,refactorAllofInlineSchemas: true,resolveInlineEnums: true),
    //       generatorName: Generator.dio)
    //   '''), contains('''
    //           generate -i ../openapi-spec.yaml -g dart-dio --type-mappings=int-or-string=IntOrString --inline-schema-name-mappings=inline_object_2=SomethingMapped,inline_object_4=nothing_new
    //           '''.trim()));
    // });
  });

  group('generator dioAlt', () {
    test('to generate appropriate openapi cli command', () async {
      expect(
          await generate('''
      @Openapi(
          additionalProperties:
              DioProperties(pubName: 'petstore_api', pubAuthor: 'Johnny dep...'),
          inputSpecFile: '../openapi-spec.yaml',
          typeMappings: {'Pet': 'ExamplePet'},
          generatorName: Generator.dio,
          runSourceGenOnOutput: true,
          alwaysRun: true,
          outputDirectory: 'api/petstore_api')
      '''),
          contains('''
              generate -o ${Directory.current.path} -i ../openapi-spec.yaml -g dart-dio -o api/petstore_api --type-mappings=Pet=ExamplePet --additional-properties=pubName=petstore_api,pubAuthor=Johnny dep... --type-mappings=int-or-string=IntOrString
          '''
              .trim()));
    });

    test('to generate command with import and type mappings for dioAlt',
        () async {
      expect(
          await generate('''
        @Openapi(
            inputSpecFile: '../openapi-spec.yaml',
            typeMappings: {'int-or-string':'IntOrString'},
            importMappings: {'IntOrString':'./int_or_string.dart'},
            generatorName: Generator.dioAlt)
      '''),
          contains(
              'generate -o ${Directory.current.path} -i ../openapi-spec.yaml -g dart2-api --import-mappings=IntOrString=./int_or_string.dart --type-mappings=int-or-string=IntOrString'));
    });
  });
}
