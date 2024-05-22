import 'package:logger/logger.dart';

/// Local logger for beauty output info in console
final Logger _localLogger = Logger(
  printer: PrettyPrinter(
    printEmojis: false,
    printTime: true,
  ),
);

/// Local logger for beauty output info in console without stack
final Logger _localPureLogger = Logger(
  printer: PrettyPrinter(
    methodCount: 0,
    printEmojis: false,
    printTime: true,
  ),
);

/// Logging some information
void logInfo({
  required String info,
  String? additional,
}) {
  /// Prepare full error message
  String message = info;
  if (additional != null) message += ': $additional';

  _localPureLogger.i(message);
}

/// Logging some error
void logError({
  required String error,
  String? additional,
}) {
  /// Prepare full error message
  String message = error;
  if (additional != null) message += ': $additional';

  _localLogger.e(message);
}
