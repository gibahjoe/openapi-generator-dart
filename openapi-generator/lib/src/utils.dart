import 'package:analyzer/dart/constant/value.dart';
import 'package:logging/logging.dart';

import 'models/output_message.dart';

/// A utility function that prints out a log meant for the end user.
void logOutputMessage(
        {required Logger log, required OutputMessage communication}) =>
    log.log(communication.level, communication.message,
        communication.additionalContext, communication.stackTrace);

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

/// Converts a key into an expected field name.
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

String Function(String, MapEntry<String, dynamic>) foldStringMap({
  String Function(String)? keyModifier,
  String Function(dynamic)? valueModifier,
}) =>
    (String prev, MapEntry<String, dynamic> curr) =>
        '${prev.trim().isEmpty ? '' : '$prev,'}${keyModifier != null ? keyModifier(curr.key) : curr.key}=${valueModifier != null ? valueModifier(curr.value) : curr.value}';
