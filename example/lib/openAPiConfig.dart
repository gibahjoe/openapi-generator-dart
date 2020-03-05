import 'package:flutter/material.dart';
import 'package:meta/meta.dart';
import 'package:openapi_generator_annotations/openapi_generator_annotations.dart';

@Openapi(inputSpecFile: 'spec/openapi-spec.yaml',generator: 'dart',outputDirectory: 'petstore/api')
class OpenapiGeneratorCo extends OpenapiGeneratorConfig {}
