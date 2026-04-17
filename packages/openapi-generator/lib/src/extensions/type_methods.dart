import 'dart:mirrors';
import 'package:analyzer/dart/element/type.dart';
import 'package:openapi_generator/src/utils.dart';
import 'package:openapi_generator_annotations/openapi_generator_annotations.dart';
import 'package:source_gen/source_gen.dart' show ConstantReader, TypeChecker;

/// Extension adding the type methods to `ConstantReader`.
extension TypeMethods on ConstantReader {
  /// Returns `true` if `this` represents a constant expression
  /// with type `dynamic`.
  bool get isDynamic => objectValue.type is DynamicType;

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

    try {
      // Access enum field 'values'.
      final values = classMirror.getField(const Symbol('values')).reflectee;
      // Get enum field 'index'.
      final enumIndex = objectValue.getField('index')!.toIntValue();

      return values[enumIndex];
    } catch (_, __) {
      throw Exception(
          'Could not read constant via enumValue<$T>(). $this is not an instance of $T.');
    }
  }
}

extension ReadProperty on ConstantReader {
  T readPropertyOrDefault<T>(String name, T defaultValue) {
    final v = peek(name);
    if (v == null) {
      return defaultValue;
    }

    var property = readPropertyOrNull<T>(name);
    if (property == null) {
      return defaultValue;
    }
    return property;
  }

  T? readPropertyOrNull<T>(String name) {
    final v = peek(name);
    if (v == null) {
      return null;
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
      return v.listValue.map(convertToPropertyValue).toList() as T;
    } else if (isA(v, Enum)) {
      return v.enumValue<T>();
    } else {
      return null;
    }
  }
}

bool isA(ConstantReader? v, Type t) {
  return v?.instanceOf(TypeChecker.typeNamed(t)) ?? false;
}

// TypeChecker fromRuntime(Type type) {
//   final mirror = reflectClass(type);
//   final uri = normalizeUrl(
//     (mirror.owner as LibraryMirror).uri,
//   ).replace(fragment: MirrorSystem.getName(mirror.simpleName));
//   return _runtimeCache[type] ??= TypeChecker.fromUrl(uri);
// }

// // Precomputed type checker cache for runtime types.
// final Map<Type, TypeChecker> _runtimeCache = <Type, TypeChecker>{};
// class _MirrorTypeChecker extends TypeChecker {
//   static Uri _uriOf(ClassMirror mirror) => normalizeUrl(
//     (mirror.owner as LibraryMirror).uri,
//   ).replace(fragment: MirrorSystem.getName(mirror.simpleName));

//   // Precomputed type checker for types that already have been used.
//   static final _cache = Expando<TypeChecker>();

//   final Type _type;

//   const _MirrorTypeChecker(this._type) : super._();

//   TypeChecker get _computed =>
//       _cache[this] ??= TypeChecker.fromUrl(_uriOf(reflectClass(_type)));

//   @override
//   bool isExactly(Element element) => _computed.isExactly(element);

//   @override
//   String toString() => _computed.toString();
// }

// Checks a runtime type name and optional package against a static type.
// class _NameTypeChecker extends TypeChecker {
//   final Type _type;

//   final String? _inPackage;
//   final bool _inSdk;

//   const _NameTypeChecker(this._type, {String? inPackage, bool? inSdk})
//     : _inPackage = inPackage,
//       _inSdk = inSdk ?? false,
//       super._();

//   String get _typeName {
//     final result = _type.toString();
//     return result.contains('<')
//         ? result.substring(0, result.indexOf('<'))
//         : result;
//   }

//   @override
//   bool isExactly(Element element) {
//     final uri = element.library!.uri;
//     return element.name == _typeName &&
//         (_inPackage == null ||
//             (((uri.scheme == 'dart') == _inSdk) &&
//                 uri.pathSegments.first == _inPackage));
//   }

//   @override
//   String toString() => _inPackage == null ? '$_type' : '$_inPackage#$_type';
// }
