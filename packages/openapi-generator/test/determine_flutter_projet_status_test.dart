import 'dart:io';

import 'package:openapi_generator/src/determine_flutter_project_status.dart';
import 'package:openapi_generator_annotations/openapi_generator_annotations.dart';
import 'package:test/test.dart';

final basePath =
    '${Directory.current.path}${Platform.pathSeparator}test${Platform.pathSeparator}specs${Platform.pathSeparator}';

void main() {
  group('Determines Flutter Project status', () {
    test('via wrapper', () async {
      expect(
          await checkPubspecAndWrapperForFlutterSupport(wrapper: Wrapper.fvm),
          isTrue);
      expect(
          await checkPubspecAndWrapperForFlutterSupport(
              wrapper: Wrapper.flutterw),
          isTrue);
    });
    group('checks the pubspec', () {
      group('and throws when', () {
        test('pubspec is empty', () async {
          // TODO: There is likely a better way to handle this.
          try {
            await checkPubspecAndWrapperForFlutterSupport(
                providedPubspecPath: '${basePath}empty_pubspec.yaml');
            fail('Should\'ve thrown invalid error');
          } catch (e, _) {
            expect(e, 'Invalid pubspec.yaml');
          }
        });
        test('pubspec doesn\'t exist', () async {
          final path = '${basePath}doesnotexist.yaml';
          try {
            await checkPubspecAndWrapperForFlutterSupport(
                providedPubspecPath: path);
            fail('Should\'ve thrown missing pubspec error');
          } catch (e, _) {
            expect(e, 'Pubspec doesn\'t exist at path: $path');
          }
        });
      });
      test('at PWD/pubspec.yaml by default', () async {
        // This project doesn't have a dependency on the flutter sdk list in the
        // pubspec.yaml.
        //
        // Since the test command is generally run from the root of this project
        // this should be a stable assumption.
        expect(await checkPubspecAndWrapperForFlutterSupport(), isFalse);
      });
      test('is false if key is missing from dependencies', () async {
        final pubspecPath = '${basePath}dart_pubspec.test.yaml';
        expect(
            await checkPubspecAndWrapperForFlutterSupport(
                providedPubspecPath: pubspecPath),
            isFalse);
      });
      test('is true when key is in dependencies', () async {
        final pubspecPath = '${basePath}flutter_pubspec.test.yaml';
        expect(
            await checkPubspecAndWrapperForFlutterSupport(
                providedPubspecPath: pubspecPath),
            isTrue);
      });
    });
  });
}
