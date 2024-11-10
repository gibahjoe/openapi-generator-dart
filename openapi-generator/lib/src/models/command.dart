import 'package:openapi_generator_annotations/openapi_generator_annotations.dart';

/// Creates a representation of a cli request for Flutter or Dart.
class Command {
  final String _executable;
  final List<String> _arguments;

  String get executable => _executable;

  List<String> get arguments => _arguments;

  Command._(this._executable, this._arguments);

  /// Provides an in memory representation of the Dart of Flutter cli command.
  ///
  /// If [executable] is the Dart executable or the [wrapper] is [Wrapper.none]
  /// it provides the raw executable. Otherwise it wraps it in the appropriate
  /// wrapper, flutterw and fvm respectively.
  Command({
    Wrapper wrapper = Wrapper.none,
    required String executable,
    required List<String> arguments,
  }) : this._(
          wrapper == Wrapper.none
              ? executable
              : wrapper == Wrapper.flutterw
                  ? './flutterw'
                  : 'fvm',
          [
            if (wrapper == Wrapper.fvm) executable,
            ...arguments,
          ],
        );
}
