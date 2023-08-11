import 'package:logging/logging.dart';

/// A message to be displayed to the end user.
///
/// Provides a common base shape to report logs to the end user. Also, acts as an
/// error wrapper.
class OutputMessage {
  final Level level;
  final String message;
  final Object? error;
  final StackTrace? stackTrace;

  const OutputMessage({
    required this.message,
    this.level = Level.INFO,
    this.error,
    this.stackTrace,
  });
}
