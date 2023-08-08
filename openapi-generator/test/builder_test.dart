import 'dart:io';

import 'package:build/build.dart';
import 'package:build_test/build_test.dart';
import 'package:openapi_generator/src/openapi_generator_runner.dart';
import 'package:source_gen/source_gen.dart';
import 'package:test/expect.dart';
import 'package:test/scaffolding.dart';

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
              'generate -i ../openapi-spec.yaml -g dart-dio -o api/petstore_api --type-mappings=Pet=ExamplePet --additional-properties=pubName=petstore_api,pubAuthor=Johnny dep...'));
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
              'generate -i ../openapi-spec.yaml -g dart-dio --type-mappings=int-or-string=IntOrString --import-mappings=IntOrString=./int_or_string.dart'));
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
              generate -i ../openapi-spec.yaml -g dart-dio --type-mappings=int-or-string=IntOrString --inline-schema-name-mappings=inline_object_2=SomethingMapped,inline_object_4=nothing_new
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
              generate -i ../openapi-spec.yaml -g dart-dio -o api/petstore_api --type-mappings=Pet=ExamplePet --additional-properties=pubName=petstore_api,pubAuthor=Johnny dep...
          '''
              .trim()));
    });

    test('to generate command with import and type mapprings for dioAlt',
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
              'generate -i ../openapi-spec.yaml -g dart2-api --type-mappings=int-or-string=IntOrString --import-mappings=IntOrString=./int_or_string.dart'));
    });
  });
}

// Test setup.

final String pkgName = 'pkg';

final Builder builder = LibraryBuilder(OpenapiGenerator(),
    generatedExtension: '.openapi_generator');

Future<String> generate(String source) async {
  var srcs = <String, String>{
    'openapi_generator_annotations|lib/src/openapi_generator_annotations_base.dart':
        File('../openapi-generator-annotations/lib/src/openapi_generator_annotations_base.dart')
            .readAsStringSync(),
    'openapi_generator|lib/myapp.dart': '''
    import 'package:openapi_generator_annotations/src/openapi_generator_annotations_base.dart';
    $source
    class MyApp {
    }  
    ''',
    'openapi_generator|openapi-spec.yaml': spec
  };

  // Capture any error from generation; if there is one, return that instead of
  // the generated output.
  String? error;
  void captureError(dynamic logRecord) {
    // print(logRecord.runtimeType);
    // print(logRecord);
    // if (logRecord.error is InvalidGenerationSourceError) {
    //   if (error != null) throw StateError('Expected at most one error.');
    //   error = logRecord.error.toString();
    // }
    error = '${error ?? ''}\n${logRecord.message}';
  }

  var writer = InMemoryAssetWriter();
  await testBuilder(builder, srcs,
      rootPackage: pkgName, writer: writer, onLog: captureError);
  return error ??
      String.fromCharCodes(
          writer.assets[AssetId(pkgName, 'lib/value.g.dart')] ?? []);
}

var spec = '''
openapi: 3.0.1
info:
  title: OpenAPI Petstore
  description: This is a sample server Petstore server. For this sample, you can use
    the api key `special-key` to test the authorization filters.
  license:
    name: Apache-2.0
    url: https://www.apache.org/licenses/LICENSE-2.0.html
  version: 1.0.0
servers:
  - url: http://petstore.swagger.io/v2
tags:
  - name: pet
    description: Everything about your Pets
  - name: store
    description: Access to Petstore orders
  - name: user
    description: Operations about user
paths:
  /pet:
    put:
      tags:
        - pet
      summary: Update an existing pet
      operationId: updatePet
      requestBody:
        description: Pet object that needs to be added to the store
        content:
          application/json:
            schema:
              \$ref: '#/components/schemas/Pet'
          application/xml:
            schema:
              \$ref: '#/components/schemas/Pet'
        required: true
      responses:
        400:
          description: Invalid ID supplied
          content: {}
        404:
          description: Pet not found
          content: {}
        405:
          description: Validation exception
          content: {}
      security:
        - petstore_auth:
            - write:pets
            - read:pets
      x-codegen-request-body-name: body
    post:
      tags:
        - pet
      summary: Add a new pet to the store
      operationId: addPet
      requestBody:
        description: Pet object that needs to be added to the store
        content:
          application/json:
            schema:
              \$ref: '#/components/schemas/Pet'
          application/xml:
            schema:
              \$ref: '#/components/schemas/Pet'
        required: true
      responses:
        405:
          description: Invalid input
          content: {}
      security:
        - petstore_auth:
            - write:pets
            - read:pets
      x-codegen-request-body-name: body
components:
  schemas:
    Order:
      title: Pet Order
      type: object
      properties:
        id:
          type: integer
          format: int64
        petId:
          type: integer
          format: int64
        quantity:
          type: integer
          format: int32
        shipDate:
          type: string
          format: date-time
        status:
          type: string
          description: Order Status
          enum:
            - placed
            - approved
            - delivered
        complete:
          type: boolean
          default: false
      description: An order for a pets from the pet store
      xml:
        name: Order
    Category:
      title: Pet category
      type: object
      properties:
        id:
          type: integer
          format: int64
        name:
          type: string
      description: A category for a pet
      xml:
        name: Category
    User:
      title: a User
      type: object
      properties:
        id:
          type: integer
          format: int64
        username:
          type: string
        firstName:
          type: string
        lastName:
          type: string
        email:
          type: string
        password:
          type: string
        phone:
          type: string
        userStatus:
          type: integer
          description: User Status
          format: int32
      description: A User who is purchasing from the pet store
      xml:
        name: User
    Tag:
      title: Pet Tag
      type: object
      properties:
        id:
          type: integer
          format: int64
        name:
          type: string
      description: A tag for a pet
      xml:
        name: Tag
    Pet:
      title: a Pet
      required:
        - name
        - photoUrls
      type: object
      properties:
        id:
          type: integer
          format: int64
        category:
          \$ref: '#/components/schemas/Category'
        name:
          type: string
          example: doggie
        photoUrls:
          type: array
          xml:
            name: photoUrl
            wrapped: true
          items:
            type: string
        tags:
          type: array
          xml:
            name: tag
            wrapped: true
          items:
            \$ref: '#/components/schemas/Tag'
        status:
          type: string
          description: pet status in the store
          enum:
            - available
            - pending
            - sold
        types:
          type: "array"
          items:
            type: "string"
            enum:
              - "TRANSFER_FROM"
              - "TRANSFER_TO"
              - "MINT"
              - "BURN"
              - "MAKE_BID"
              - "GET_BID"
              - "LIST"
              - "BUY"
              - "SELL"
      description: A pet for sale in the pet store
      xml:
        name: Pet
    Patri:
      title: Patri
      required:
        - name
        - photoUrls
      type: object
      properties:
        id:
          type: integer
          format: int64
        category:
          \$ref: '#/components/schemas/Category'
        name:
          type: string
          example: doggie
        photoUrls:
          type: array
          xml:
            name: photoUrl
            wrapped: true
          items:
            type: string
        tags:
          type: array
          xml:
            name: tag
            wrapped: true
          items:
            \$ref: '#/components/schemas/Tag'
        status:
          type: string
          description: pet status in the store
          enum:
            - available
            - pending
            - sold
        types:
          type: "array"
          items:
            type: "string"
            enum:
              - "TRANSFER_FROM"
              - "TRANSFER_TO"
              - "MINT"
              - "BURN"
              - "MAKE_BID"
              - "GET_BID"
              - "LIST"
              - "BUY"
              - "SELL"
      description: A pet for sale in the pet store
      xml:
        name: Pet
    ApiResponse:
      title: An uploaded response
      type: object
      properties:
        code:
          type: integer
          format: int32
        type:
          type: string
        message:
          type: string
      description: Describes the result of uploading an image resource
  securitySchemes:
    petstore_auth:
      type: oauth2
      flows:
        implicit:
          authorizationUrl: http://petstore.swagger.io/api/oauth/dialog
          scopes:
            write:pets: modify pets in your account
            read:pets: read your pets
    api_key:
      type: apiKey
      name: api_key
      in: header

''';
