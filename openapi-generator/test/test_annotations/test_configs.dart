library test_annotations;

import 'package:openapi_generator_annotations/openapi_generator_annotations.dart';
import 'package:source_gen_test/annotations.dart';

@ShouldGenerate(r'''
import 'dart:io';

void main() {
  Process.run(
    'dart',
    ['run', 'openapi_generator_cli:main', 'generate', '-i=', '-g=dart-dio'],
    workingDirectory: Directory.current.path,
    runInShell: Platform.isWindows,
  );
}
''')
@Openapi(inputSpec: InputSpec(path: ''), generatorName: Generator.dio)
class TestClassDefault {}

@ShouldGenerate(r'''
import 'dart:io';

void main() {
  Process.run(
    'dart',
    [
      'run',
      'openapi_generator_cli:main',
      'generate',
      '-i=',
      '-g=dart',
      '--additional-properties=allowUnicodeIdentifiers=false,ensureUniqueParams=true,useEnumExtension=true,enumUnknownDefaultCase=false,prependFormOrBodyParameters=false,legacyDiscriminatorBehavior=true,sortModelPropertiesByRequiredFlag=true,sortParamsByRequiredFlag=true,wrapper=flutterw',
    ],
    workingDirectory: Directory.current.path,
    runInShell: Platform.isWindows,
  );
}
''')
@Openapi(
  inputSpec: InputSpec(path: ''),
  generatorName: Generator.dart,
  additionalProperties: AdditionalProperties(wrapper: Wrapper.flutterw),
)
class TestClassHasCustomAnnotations {}

@ShouldGenerate(r'''
import 'dart:io';

void main() {
  Process.run(
    'dart',
    [
      'run',
      'openapi_generator_cli:main',
      'generate',
      '-i=',
      '-g=dart',
      '--additional-properties=allowUnicodeIdentifiers=false,ensureUniqueParams=true,useEnumExtension=true,enumUnknownDefaultCase=false,prependFormOrBodyParameters=false,legacyDiscriminatorBehavior=true,sortModelPropertiesByRequiredFlag=true,sortParamsByRequiredFlag=true,wrapper=flutterw,nullableFields=true',
    ],
    workingDirectory: Directory.current.path,
    runInShell: Platform.isWindows,
  );
}
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
