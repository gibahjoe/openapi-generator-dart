import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:meta/meta.dart';

@visibleForTesting
final awsSign = (String aKey, String sKey, String b, String p, DateTime n) {
  // https://docs.aws.amazon.com/AmazonS3/latest/userguide/RESTAuthentication.html#RESTAuthenticationExamples
  String toSign = [
    'GET',
    '',
    '',
    n.toIso8601String(),
    '/$b/$p',
  ].join('\n');

  final utf8AKey = utf8.encode(sKey);
  final utf8ToSign = utf8.encode(toSign);

  final signature =
      base64Encode(Hmac(sha1, utf8AKey).convert(utf8ToSign).bytes);
  return 'AWS $aKey:$signature';
};
