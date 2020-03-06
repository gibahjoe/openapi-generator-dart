import 'package:flutter/material.dart';
import 'package:meta/meta.dart';
import 'package:openapi_generator_annotations/openapi_generator_annotations.dart';

@Openapi(
    additionalProperties:
        AdditionalProperties(pubName: 'petstore_api', pubAuthor: 'Johnny dep'),
    inputSpecFile: 'spec/openapi-spec.yaml',
    generatorName: 'dart-jaguar',
    outputDirectory: 'api/petstore_api')
class OpenapiGeneratorCo extends OpenapiGeneratorConfig {}
