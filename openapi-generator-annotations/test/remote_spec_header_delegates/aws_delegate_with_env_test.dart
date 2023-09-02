import 'dart:io';

import 'package:openapi_generator_annotations/openapi_generator_annotations.dart';
import 'package:test/test.dart';

import '../utils.dart';

void main() {
  group('AWSRemoteSpecDelegate', () {
    test(
      'uses environment variables',
      () {
        final delegate = AWSRemoteSpecHeaderDelegate(bucket: 'bucket');
        try {
          final actualHeaders = delegate.header(path: 'openapi.yaml');
          expect(actualHeaders, isNotNull);

          expect(actualHeaders!['x-amz-date'], isNotNull);
          final dateTimeUsed = DateTime.parse(actualHeaders['x-amz-date']!);
          final expectedAuthHeader = awsSign(
              Platform.environment['AWS_ACCESS_KEY_ID']!,
              Platform.environment['AWS_SECRET_ACCESS_KEY']!,
              delegate.bucket,
              'openapi.yaml',
              dateTimeUsed);
          expect(actualHeaders['Authorization'], expectedAuthHeader);
        } catch (e, _) {
          fail('should not fail when provided the required values');
        }
      },
      skip: Platform.environment['AWS_ACCESS_KEY_ID'] == null ||
          Platform.environment['AWS_SECRET_ACCESS_KEY'] == null,
    );

    test(
      'header throws when no creds are available',
      () {
        final thrown = AssertionError(
            'AWS_SECRET_KEY_ID & AWS_SECRET_ACCESS_KEY should be defined and not empty or they should be provided in the delegate constructor.');
        final delegate = AWSRemoteSpecHeaderDelegate(bucket: 'bucket');
        try {
          delegate.header(path: 'openapi.yaml');
        } catch (e, _) {
          expect(e, isA<AssertionError>());
          expect(e.toString(), thrown.toString());
        }
      },
      skip: !(Platform.environment['AWS_ACCESS_KEY_ID'] == null ||
          Platform.environment['AWS_SECRET_ACCESS_KEY'] == null),
    );
  });
}
