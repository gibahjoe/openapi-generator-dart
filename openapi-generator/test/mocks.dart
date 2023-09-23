import 'dart:io';

import 'package:analyzer/dart/element/element.dart';
import 'package:build/build.dart';
import 'package:mockito/annotations.dart';
import 'package:openapi_generator/src/models/command.dart';
import 'package:openapi_generator/src/models/generator_arguments.dart';
import 'package:openapi_generator/src/openapi_generator_runner.dart';
import 'package:openapi_generator_annotations/openapi_generator_annotations.dart';

@GenerateNiceMocks([
  MockSpec<OpenapiGenerator>(),
  MockSpec<BuildStep>(),
  MockSpec<MethodElement>(),
  MockSpec<ClassElement>(),
  MockSpec<Process>(),
  MockSpec<CommandRunner>(),
  MockSpec<Openapi>(),
  MockSpec<GeneratorArguments>()
])
void main() {}
