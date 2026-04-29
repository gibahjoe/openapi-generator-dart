import 'package:openapi_generator_annotations/openapi_generator_annotations.dart';
import 'package:test/test.dart';

void main() {
  group('AdditionalProperties', () {
    test('defaults', () {
      final props = AdditionalProperties();
      expect(props.wrapper, Wrapper.none);
      expect(props.allowUnicodeIdentifiers, isFalse);
      expect(props.ensureUniqueParams, isTrue);
      expect(props.useEnumExtension, isFalse);
      expect(props.prependFormOrBodyParameters, isFalse);
      expect(props.legacyDiscriminatorBehavior, isTrue);
      expect(props.sortModelPropertiesByRequiredFlag, isTrue);
      expect(props.sortParamsByRequiredFlag, isTrue);
      // Default null props
      for (var element in [
        props.pubVersion,
        props.pubPublishTo,
        props.pubName,
        props.pubHomepage,
        props.pubDescription,
        props.pubAuthor,
        props.pubAuthorEmail,
        props.sourceFolder
      ]) {
        expect(element, isNull);
      }
    });
    test('toMap', () {
      final props = AdditionalProperties();
      final map = props.toMap();
      expect(map['wrapper'], 'none');
      expect(map['allowUnicodeIdentifiers'], isFalse);
      expect(map['ensureUniqueParams'], isTrue);
      expect(map['useEnumExtension'], isFalse);
      expect(map['prependFormOrBodyParameters'], isFalse);
      expect(map['legacyDiscriminatorBehavior'], isTrue);
      expect(map['sortModelPropertiesByRequiredFlag'], isTrue);
      expect(map['sortParamsByRequiredFlag'], isTrue);

      // Doesn't include null fields
      for (var element in [
        'pubVersion',
        'pubPublishTo',
        'pubName',
        'pubHomepage',
        'pubDescription',
        'pubAuthor',
        'pubAuthorEmail',
        'sourceFolder'
      ]) {
        expect(map.containsKey(element), isFalse);
      }
    });
    test('fromMap', () {
      final props = AdditionalProperties(
          pubVersion: '1.0.0',
          pubPublishTo: "https://test.test",
          pubName: 'test',
          pubHomepage: 'test',
          pubDescription: 'test',
          pubAuthorEmail: 'test@test.test',
          pubAuthor: 'test');
      final map = {
        'allowUnicodeIdentifiers': props.allowUnicodeIdentifiers,
        'ensureUniqueParams': props.ensureUniqueParams,
        'useEnumExtension': props.useEnumExtension,
        'prependFormOrBodyParameters': props.prependFormOrBodyParameters,
        'pubAuthor': props.pubAuthor,
        'pubAuthorEmail': props.pubAuthorEmail,
        'pubDescription': props.pubDescription,
        'pubHomepage': props.pubHomepage,
        'pubName': props.pubName,
        'pubVersion': props.pubVersion,
        'pubPublishTo': props.pubPublishTo,
        'legacyDiscriminatorBehavior': props.legacyDiscriminatorBehavior,
        'sortModelPropertiesByRequiredFlag':
            props.sortModelPropertiesByRequiredFlag,
        'sortParamsByRequiredFlag': props.sortParamsByRequiredFlag,
        'sourceFolder': props.sourceFolder,
        'wrapper': 'none',
      };
      final actual = AdditionalProperties.fromMap(map);
      expect(actual.wrapper, props.wrapper);
      expect(actual.allowUnicodeIdentifiers, props.allowUnicodeIdentifiers);
      expect(actual.ensureUniqueParams, props.ensureUniqueParams);
      expect(actual.useEnumExtension, props.useEnumExtension);
      expect(actual.prependFormOrBodyParameters,
          props.prependFormOrBodyParameters);
      expect(actual.legacyDiscriminatorBehavior,
          props.legacyDiscriminatorBehavior);
      expect(actual.sortModelPropertiesByRequiredFlag,
          props.sortModelPropertiesByRequiredFlag);
      expect(actual.sortParamsByRequiredFlag, props.sortParamsByRequiredFlag);
      expect(actual.pubVersion, props.pubVersion);
      expect(actual.pubPublishTo, props.pubPublishTo);
      expect(actual.pubName, props.pubName);
      expect(actual.pubHomepage, props.pubHomepage);
      expect(actual.pubDescription, props.pubDescription);
      expect(actual.pubAuthor, props.pubAuthor);
      expect(actual.pubAuthorEmail, props.pubAuthorEmail);
      expect(actual.sourceFolder, props.sourceFolder);
    });
  });

  group('DioProperties', () {
    test('defaults', () {
      final props = DioProperties();
      expect(props.wrapper, Wrapper.none);
      expect(props.allowUnicodeIdentifiers, isFalse);
      expect(props.ensureUniqueParams, isTrue);
      expect(props.useEnumExtension, isTrue);
      expect(props.prependFormOrBodyParameters, isFalse);
      expect(props.legacyDiscriminatorBehavior, isTrue);
      expect(props.sortModelPropertiesByRequiredFlag, isTrue);
      expect(props.sortParamsByRequiredFlag, isTrue);
      // Default null props
      for (var element in [
        props.pubVersion,
        props.pubPublishTo,
        props.pubName,
        props.pubHomepage,
        props.pubDescription,
        props.pubAuthor,
        props.pubAuthorEmail,
        props.sourceFolder,
        props.nullableFields,
        props.serializationLibrary,
        props.dateLibrary,
      ]) {
        expect(element, isNull);
      }
    });
    test('toMap', () {
      final props = DioProperties();
      final map = props.toMap();
      expect(map['wrapper'], 'none');
      expect(map['allowUnicodeIdentifiers'], isFalse);
      expect(map['ensureUniqueParams'], isTrue);
      expect(map['useEnumExtension'], isTrue);
      expect(map['prependFormOrBodyParameters'], isFalse);
      expect(map['legacyDiscriminatorBehavior'], isTrue);
      expect(map['sortModelPropertiesByRequiredFlag'], isTrue);
      expect(map['sortParamsByRequiredFlag'], isTrue);

      // Doesn't include null fields
      for (var element in [
        'pubVersion',
        'pubPublishTo',
        'pubName',
        'pubHomepage',
        'pubDescription',
        'pubAuthor',
        'pubAuthorEmail',
        'sourceFolder'
            'dateLibrary',
        'nullableFields',
        'serializationLibrary'
      ]) {
        expect(map.containsKey(element), isFalse);
      }
    });
    test('fromMap', () {
      final props = DioProperties(
        pubVersion: '1.0.0',
        pubPublishTo: 'https://test.test',
        pubName: 'test',
        pubHomepage: 'test',
        pubDescription: 'test',
        pubAuthorEmail: 'test@test.test',
        pubAuthor: 'test',
        nullableFields: true,
        dateLibrary: DioDateLibrary.core,
        serializationLibrary: DioSerializationLibrary.jsonSerializable,
      );
      final map = {
        'allowUnicodeIdentifiers': props.allowUnicodeIdentifiers,
        'ensureUniqueParams': props.ensureUniqueParams,
        'useEnumExtension': props.useEnumExtension,
        'prependFormOrBodyParameters': props.prependFormOrBodyParameters,
        'pubAuthor': props.pubAuthor,
        'pubAuthorEmail': props.pubAuthorEmail,
        'pubDescription': props.pubDescription,
        'pubHomepage': props.pubHomepage,
        'pubName': props.pubName,
        'pubVersion': props.pubVersion,
        'pubPublishTo': props.pubPublishTo,
        'legacyDiscriminatorBehavior': props.legacyDiscriminatorBehavior,
        'sortModelPropertiesByRequiredFlag':
            props.sortModelPropertiesByRequiredFlag,
        'sortParamsByRequiredFlag': props.sortParamsByRequiredFlag,
        'sourceFolder': props.sourceFolder,
        'wrapper': 'none',
        'nullableFields': props.nullableFields,
        'dateLibrary': 'core',
        'serializationLibrary': 'json_serializable',
      };
      final actual = DioProperties.fromMap(map);
      expect(actual.wrapper, props.wrapper);
      expect(actual.allowUnicodeIdentifiers, props.allowUnicodeIdentifiers);
      expect(actual.ensureUniqueParams, props.ensureUniqueParams);
      expect(actual.useEnumExtension, props.useEnumExtension);
      expect(actual.prependFormOrBodyParameters,
          props.prependFormOrBodyParameters);
      expect(actual.legacyDiscriminatorBehavior,
          props.legacyDiscriminatorBehavior);
      expect(actual.sortModelPropertiesByRequiredFlag,
          props.sortModelPropertiesByRequiredFlag);
      expect(actual.sortParamsByRequiredFlag, props.sortParamsByRequiredFlag);
      expect(actual.pubVersion, props.pubVersion);
      expect(actual.pubPublishTo, props.pubPublishTo);
      expect(actual.pubName, props.pubName);
      expect(actual.pubHomepage, props.pubHomepage);
      expect(actual.pubDescription, props.pubDescription);
      expect(actual.pubAuthor, props.pubAuthor);
      expect(actual.pubAuthorEmail, props.pubAuthorEmail);
      expect(actual.sourceFolder, props.sourceFolder);
      expect(actual.nullableFields, props.nullableFields);
      expect(actual.dateLibrary, props.dateLibrary);
      expect(actual.serializationLibrary, props.serializationLibrary);
    });
  });
  group('DioAltProperties', () {
    test('defaults', () {
      final props = DioAltProperties();
      expect(props.wrapper, Wrapper.none);
      expect(props.allowUnicodeIdentifiers, isFalse);
      expect(props.ensureUniqueParams, isTrue);
      expect(props.useEnumExtension, isTrue);
      expect(props.prependFormOrBodyParameters, isFalse);
      expect(props.legacyDiscriminatorBehavior, isTrue);
      expect(props.sortModelPropertiesByRequiredFlag, isTrue);
      expect(props.sortParamsByRequiredFlag, isTrue);
      // Default null props
      for (var element in [
        props.pubVersion,
        props.pubPublishTo,
        props.pubName,
        props.pubHomepage,
        props.pubDescription,
        props.pubAuthor,
        props.pubAuthorEmail,
        props.sourceFolder,
        props.listAnyOf,
        props.pubspecDevDependencies,
        props.pubspecDependencies
      ]) {
        expect(element, isNull);
      }
    });
    test('toMap', () {
      final props = DioAltProperties();
      final map = props.toMap();
      expect(map['wrapper'], 'none');
      expect(map['allowUnicodeIdentifiers'], isFalse);
      expect(map['ensureUniqueParams'], isTrue);
      expect(map['useEnumExtension'], isTrue);
      expect(map['prependFormOrBodyParameters'], isFalse);
      expect(map['legacyDiscriminatorBehavior'], isTrue);
      expect(map['sortModelPropertiesByRequiredFlag'], isTrue);
      expect(map['sortParamsByRequiredFlag'], isTrue);

      // Doesn't include null fields
      for (var element in [
        'pubVersion',
        'pubPublishTo',
        'pubName',
        'pubHomepage',
        'pubDescription',
        'pubAuthor',
        'pubAuthorEmail',
        'sourceFolder'
            'nullSafe,'
            'nullSafeArrayDefault,'
            'listAnyOf,'
            'pubspecDevDependencies,'
            'pubspecDependencies'
      ]) {
        expect(map.containsKey(element), isFalse);
      }
    });
    test('fromMap', () {
      final props = DioAltProperties(
        pubVersion: '1.0.0',
        pubPublishTo: 'https://test.test',
        pubName: 'test',
        pubHomepage: 'test',
        pubDescription: 'test',
        pubAuthorEmail: 'test@test.test',
        pubAuthor: 'test',
        listAnyOf: false,
        pubspecDevDependencies: 'something',
        pubspecDependencies: 'test',
      );
      final map = {
        'allowUnicodeIdentifiers': props.allowUnicodeIdentifiers,
        'ensureUniqueParams': props.ensureUniqueParams,
        'useEnumExtension': props.useEnumExtension,
        'prependFormOrBodyParameters': props.prependFormOrBodyParameters,
        'pubAuthor': props.pubAuthor,
        'pubAuthorEmail': props.pubAuthorEmail,
        'pubDescription': props.pubDescription,
        'pubHomepage': props.pubHomepage,
        'pubName': props.pubName,
        'pubVersion': props.pubVersion,
        'pubPublishTo': props.pubPublishTo,
        'legacyDiscriminatorBehavior': props.legacyDiscriminatorBehavior,
        'sortModelPropertiesByRequiredFlag':
            props.sortModelPropertiesByRequiredFlag,
        'sortParamsByRequiredFlag': props.sortParamsByRequiredFlag,
        'sourceFolder': props.sourceFolder,
        'wrapper': 'none',
        'listAnyOf': props.listAnyOf,
        'pubspecDevDependencies': props.pubspecDevDependencies,
        'pubspecDependencies': props.pubspecDependencies,
      };
      final actual = DioAltProperties.fromMap(map);
      expect(actual.wrapper, props.wrapper);
      expect(actual.allowUnicodeIdentifiers, props.allowUnicodeIdentifiers);
      expect(actual.ensureUniqueParams, props.ensureUniqueParams);
      expect(actual.useEnumExtension, props.useEnumExtension);
      expect(actual.prependFormOrBodyParameters,
          props.prependFormOrBodyParameters);
      expect(actual.legacyDiscriminatorBehavior,
          props.legacyDiscriminatorBehavior);
      expect(actual.sortModelPropertiesByRequiredFlag,
          props.sortModelPropertiesByRequiredFlag);
      expect(actual.sortParamsByRequiredFlag, props.sortParamsByRequiredFlag);
      expect(actual.pubVersion, props.pubVersion);
      expect(actual.pubPublishTo, props.pubPublishTo);
      expect(actual.pubName, props.pubName);
      expect(actual.pubHomepage, props.pubHomepage);
      expect(actual.pubDescription, props.pubDescription);
      expect(actual.pubAuthor, props.pubAuthor);
      expect(actual.pubAuthorEmail, props.pubAuthorEmail);
      expect(actual.sourceFolder, props.sourceFolder);
      expect(actual.listAnyOf, props.listAnyOf);
      expect(actual.pubspecDevDependencies, props.pubspecDevDependencies);
      expect(actual.pubspecDependencies, props.pubspecDependencies);
    });
  });
}
