import 'package:openapi_generator/src/models/command.dart';
import 'package:openapi_generator_annotations/openapi_generator_annotations.dart';
import 'package:test/test.dart';

void main() {
  group('Command', () {
    final testArgs = ['pub', 'get'];
    group('handles flutter wrapping', () {
      test('Wrapper.flutterw', () {
        final command = Command(
            executable: 'flutter',
            arguments: testArgs,
            wrapper: Wrapper.flutterw);
        expect(command.arguments, ['flutter', ...testArgs]);
        expect(command.executable, './flutterw');
      });
      test('Wrapper.fvw', () {
        final command = Command(
            executable: 'flutter', arguments: testArgs, wrapper: Wrapper.fvm);
        expect(command.arguments, ['flutter', ...testArgs]);
        expect(command.executable, 'fvm');
      });
      test('doesn\'t wrap Wrapper.none', () {
        final command = Command(executable: 'flutter', arguments: testArgs);
        expect(command.arguments, testArgs);
        expect(command.executable, 'flutter');
      });
    });
    test('wraps doesn\'t dart', () {
      final command = Command(executable: 'dart', arguments: testArgs);
      expect(command.arguments, testArgs);
      expect(command.executable, 'dart');
    });
  });
}
