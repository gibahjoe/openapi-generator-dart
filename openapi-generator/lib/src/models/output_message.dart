import 'package:logging/logging.dart';

/// A message to be displayed to the end user.
///
/// Provides a common base shape to report logs to the end user. Also, acts as an
/// error wrapper.
class OutputMessage {
  final Level level;
  final String message;
  final Object? additionalContext;
  final StackTrace? stackTrace;

  const OutputMessage({
    required this.message,
    this.level = Level.INFO,
    this.additionalContext,
    this.stackTrace,
  });

  @override
  String toString() {
    return '$message ${additionalContext ?? ''} ${stackTrace ?? ''}';
  }
}
