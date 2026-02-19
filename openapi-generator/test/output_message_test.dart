import 'package:logging/logging.dart';
import 'package:openapi_generator/src/models/output_message.dart';
import 'package:test/test.dart';

void main() {
  group('OutputMessage ', () {
    test('defaults', () {
      final message = OutputMessage(message: 'message');
      expect(message.message, 'message');
      expect(message.additionalContext, isNull);
      expect(message.stackTrace, isNull);
      expect(message.level, Level.INFO);
    });
    test('uses provided level', () {
      final message = OutputMessage(message: 'message', level: Level.WARNING);
      expect(message.message, 'message');
      expect(message.additionalContext, isNull);
      expect(message.stackTrace, isNull);
      expect(message.level, Level.WARNING);
    });
    test('uses provided message', () {
      final message = OutputMessage(message: 'sup');
      expect(message.message, 'sup');
      expect(message.additionalContext, isNull);
      expect(message.stackTrace, isNull);
      expect(message.level, Level.INFO);
    });
    test('uses provided error', () {
      final message =
          OutputMessage(message: 'message', additionalContext: 'thisIsAnError');
      expect(message.message, 'message');
      expect(message.additionalContext, 'thisIsAnError');
      expect(message.stackTrace, isNull);
      expect(message.level, Level.INFO);
    });
    test('uses provided stacktrace', () {
      final stack = StackTrace.current;
      final message = OutputMessage(message: 'message', stackTrace: stack);
      expect(message.message, 'message');
      expect(message.additionalContext, isNull);
      expect(message.stackTrace, stack);
      expect(message.level, Level.INFO);
    });
    test('toString includes message, additionalContext and stackTrace', () {
      final stack = StackTrace.current;
      final message = OutputMessage(
        message: 'hello',
        additionalContext: 'ctx',
        stackTrace: stack,
      );
      final result = message.toString();
      expect(result, contains('hello'));
      expect(result, contains('ctx'));
      expect(result, contains(stack.toString()));
    });
  });
}
