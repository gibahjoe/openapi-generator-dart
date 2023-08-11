import 'package:analyzer/dart/constant/value.dart';
import 'package:logging/logging.dart';

import 'models/output_message.dart';

/// A utility function that prints out a log meant for the end user.
void logOutputMessage(
        {required Logger log, required OutputMessage communication}) =>
    log.log(communication.level, communication.message, communication.error,
        communication.stackTrace);

/// Transforms a [Map] into a string.
String getMapAsString(Map<dynamic, dynamic> data) {
  return data.entries
      .map((entry) =>
          '${entry.key.toStringValue()}=${entry.value.toStringValue()}')
      .join(',');
}

/// Converts a [DartObject] to it's given type.
String convertToPropertyValue(DartObject value) {
  if (value.isNull) {
    return '';
  }
  return value.toStringValue() ??
      value.toBoolValue()?.toString() ??
      value.toIntValue()?.toString() ??
      value.getField('_name')?.toStringValue() ??
      '';
}

/// Converts a [DartObject] key into an expected field name.
String convertToPropertyKey(String key) {
  switch (key) {
    case 'nullSafeArrayDefault':
      return 'nullSafe-array-default';
    case 'pubspecDependencies':
      return 'pubspec-dependencies';
    case 'pubspecDevDependencies':
      return 'pubspec-dev-dependencies';
    case 'arrayItemSuffix':
      return 'ARRAY_ITEM_SUFFIX';
    case 'mapItemSuffix':
      return 'MAP_ITEM_SUFFIX';
    case 'skipSchemaReuse':
      return 'SKIP_SCHEMA_REUSE';
    case 'refactorAllofInlineSchemas':
      return 'REFACTOR_ALLOF_INLINE_SCHEMAS';
    case 'resolveInlineEnums':
      return 'RESOLVE_INLINE_ENUMS';
  }
  return key;
}

/// A utility function to fold a [Map<String,DartObject>] into a compatible format for the OpenAPI compiler.
String foldNamedArgsMap(String prev, MapEntry<String, DartObject> entry) =>
    '${prev.isEmpty ? '' : ','}${convertToPropertyKey(entry.key)}=${convertToPropertyValue(entry.value)}';
