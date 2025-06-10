library test_annotations;

import 'package:openapi_generator_annotations/openapi_generator_annotations.dart';
import 'package:source_gen_test/annotations.dart';

@ShouldGenerate(r'''
const fetchDependencies = true;

const forceAlwaysRun = false;

const generatorName = 'dio';

const inputSpec = '';

const runSourceGenOnOutput = true;

const skipSpecValidation = false;
''')
@Openapi(inputSpec: InputSpec(path: ''), generatorName: Generator.dio)
class TestClassDefault {}

@ShouldGenerate(r'''
const additionalProperties = wrapper = 'flutterw';

const fetchDependencies = true;

const forceAlwaysRun = false;

const generatorName = 'dart';

const inputSpec = '';

const runSourceGenOnOutput = true;

const skipSpecValidation = false;
''')
@Openapi(
  inputSpec: InputSpec(path: ''),
  generatorName: Generator.dart,
  additionalProperties: AdditionalProperties(wrapper: Wrapper.flutterw),
)
class TestClassHasCustomAnnotations {}

@ShouldGenerate(r'''
const additionalProperties = wrapper = 'flutterw', nullableFields = 'true';

const fetchDependencies = true;

const forceAlwaysRun = false;

const generatorName = 'dart';

const inputSpec = '';

const runSourceGenOnOutput = true;

const skipSpecValidation = false;
''')
@Openapi(
  inputSpec: InputSpec(path: ''),
  generatorName: Generator.dart,
  additionalProperties: DioProperties(
    wrapper: Wrapper.flutterw,
    nullableFields: true,
  ),
)
class TestClassHasDioProperties {}
