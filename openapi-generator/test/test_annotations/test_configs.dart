library test_annotations;

import 'package:openapi_generator_annotations/openapi_generator_annotations.dart';
import 'package:source_gen_test/annotations.dart';

@ShouldGenerate(r'''
const alwaysRun = false;

const fetchDependencies = true;

const generatorName = 'dio';

const inputSpecFile = '';

const runSourceGenOnOutput = true;

const skipSpecValidation = false;

const useNextGen = false;
''')
@Openapi(inputSpecFile: '', generatorName: Generator.dio)
class TestClassDefault extends OpenapiGeneratorConfig {}

@ShouldThrow('useNextGen must be set when using cachePath', element: false)
@Openapi(inputSpecFile: '', generatorName: Generator.dio, cachePath: './')
class TestClassInvalidCachePathUsage extends OpenapiGeneratorConfig {}

@ShouldGenerate(r'''
const additionalProperties = wrapper = 'flutterw';

const alwaysRun = false;

const fetchDependencies = true;

const generatorName = 'dart';

const inputSpecFile = '';

const runSourceGenOnOutput = true;

const skipSpecValidation = false;

const useNextGen = false;
''')
@Openapi(
  inputSpecFile: '',
  generatorName: Generator.dart,
  additionalProperties: AdditionalProperties(
    wrapper: Wrapper.flutterw,
  ),
)
class TestClassHasCustomAnnotations extends OpenapiGeneratorConfig {}

@ShouldGenerate(r'''
const additionalProperties = wrapper = 'flutterw', nullableFields = 'true';

const alwaysRun = false;

const fetchDependencies = true;

const generatorName = 'dart';

const inputSpecFile = '';

const runSourceGenOnOutput = true;

const skipSpecValidation = false;

const useNextGen = false;
''')
@Openapi(
  inputSpecFile: '',
  generatorName: Generator.dart,
  additionalProperties: DioProperties(
    wrapper: Wrapper.flutterw,
    nullableFields: true,
  ),
)
class TestClassHasDioProperties extends OpenapiGeneratorConfig {}
