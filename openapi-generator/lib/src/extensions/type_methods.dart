import 'dart:mirrors';

import 'package:analyzer/dart/element/type.dart';
import 'package:openapi_generator/src/utils.dart';
import 'package:openapi_generator_annotations/openapi_generator_annotations.dart';
import 'package:source_gen/source_gen.dart' show ConstantReader, TypeChecker;

/// Extension adding the type methods to `ConstantReader`.
extension TypeMethods on ConstantReader {
  /// Returns `true` if `this` represents a constant expression
  /// with type `dynamic`.
  bool get isDynamic => objectValue.type?.isDynamic ?? false;

  /// Returns `true` is `this` represents a constant expression with
  /// type exactly `Iterable`.
  ///
  /// Note: Returns `false` if the static type represents `List` or `Set`.
  bool get isIterable => objectValue.type?.isDartCoreIterable ?? false;

  /// Returns `true` if the static type represents a
  /// `List`, `Set`, `Map`, or `Iterable`.
  bool get isCollection => isList || isSet || isMap || isIterable;

  /// Returns `true` if the static type *and* the static type argument
  /// represent a `List`, `Set`, `Map`, or `Iterable`
  bool get isRecursiveCollection {
    if (isNotCollection) return false;
    final typeArg = dartTypeArgs[0];
    if (typeArg.isDartCoreIterable ||
        typeArg.isDartCoreList ||
        typeArg.isDartCoreSet ||
        typeArg.isDartCoreMap) {
      return true;
    } else {
      return false;
    }
  }

  /// Returns `true` if the static type does not represent
  /// `List`, `Set`, `Map`, or `Iterable`.
  bool get isNotCollection => !isList && !isSet && !isMap && !isIterable;

  /// Returns the static type of `this`.
  DartType? get dartType => objectValue.type;

  /// Returns a `List` of type arguments or the empty list.
  List<DartType> get dartTypeArgs => <DartType>[];

  /// Reads a instance of a Dart enumeration.
  ///
  /// Throws [ErrorOf] if a constant cannot be read.
  T enumValue<T>() {
    if (T == dynamic) {
      throw Exception(
          'Method getEnum does not work with type: dynamic. A type argument "T" in getEnum<T> that represents a Dart enum.');
    }

    final classMirror = reflectClass(T);
    if (!classMirror.isEnum) {
      throw Exception(
          'Could not read constant via enumValue<$T>(). $T is not a Dart enum.');
    }

    if (!instanceOf(TypeChecker.fromRuntime(T))) {
      throw Exception('Not an instance of $T.');
    }

    // Access enum field 'values'.
    final values = classMirror.getField(const Symbol('values')).reflectee;
    // Get enum field 'index'.
    final enumIndex = objectValue.getField('index')!.toIntValue();

    return values[enumIndex];
  }
}

extension ReadProperty on ConstantReader {
  T readPropertyOrDefault<T>(String name, T defaultValue) {
    final v = peek(name);
    if (v == null) {
      return defaultValue;
    }

    if (isA(v, InputSpec)) {
      final revived = v.revive();

      if (isA(v, RemoteSpec)) {
        final map = revived.namedArguments;
        final delegate = map['headerDelegate'];
        final mapped = <String, dynamic>{
          'path': convertToPropertyValue(map['path']!),
        };
        if (delegate?.isNull ?? true) {
          return RemoteSpec.fromMap(mapped) as T;
        } else {
          final delegateReader = ConstantReader(delegate);
          if (isA(delegateReader, AWSRemoteSpecHeaderDelegate)) {
            mapped['headerDelegate'] = AWSRemoteSpecHeaderDelegate.fromMap(
              delegateReader.revive().namedArguments.map(
                    (key, value) => MapEntry(
                      key,
                      convertToPropertyValue(value),
                    ),
                  ),
            );
          }
          return RemoteSpec.fromMap(mapped) as T;
        }
      } else {
        final map = revived.namedArguments.map(
          (key, value) => MapEntry(
            key,
            convertToPropertyValue(value),
          ),
        );
        return InputSpec.fromMap(map) as T;
      }
    }

    if (isA(v, AdditionalProperties)) {
      final map = v.revive().namedArguments.map(
            (key, value) => MapEntry(
              key,
              convertToPropertyValue(value),
            ),
          );
      if (isA(v, DioProperties)) {
        return DioProperties.fromMap(map) as T;
      } else if (isA(v, DioAltProperties)) {
        return DioAltProperties.fromMap(map) as T;
      } else {
        return AdditionalProperties.fromMap(map) as T;
      }
    }

    if (isA(v, InlineSchemaOptions)) {
      return InlineSchemaOptions.fromMap(
        v.revive().namedArguments.map(
              (key, value) => MapEntry(
                key,
                convertToPropertyValue(value),
              ),
            ),
      ) as T;
    }

    if (isA(v, Map<String, String>)) {
      return v.mapValue.map((key, value) => MapEntry(
          convertToPropertyValue(key!) as String,
          convertToPropertyValue(value!) as String)) as T;
    } else if (isA(v, bool)) {
      return v.boolValue as T;
    } else if (isA(v, double)) {
      return v.doubleValue as T;
    } else if (isA(v, int)) {
      return v.intValue as T;
    } else if (isA(v, String)) {
      return v.stringValue as T;
    } else if (isA(v, Set)) {
      return v.setValue.map(convertToPropertyValue) as T;
    } else if (isA(v, List)) {
      return v.listValue.map(convertToPropertyValue) as T;
    } else if (isA(v, Enum)) {
      return v.enumValue();
    } else {
      return defaultValue;
    }
  }
}

bool isA(ConstantReader? v, Type t) =>
    v?.instanceOf(TypeChecker.fromRuntime(t)) ?? false;
