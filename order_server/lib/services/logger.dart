import 'package:logging/logging.dart';

/// Global logger instance for the Order Server.
final Logger log = Logger('OrderServer');

/// Call once at application start.
void initLogging({Level level = Level.INFO}) {
  Logger.root.level = level;
  Logger.root.onRecord.listen((record) {
    final ts = record.time.toIso8601String();
    // ignore: avoid_print
    print('$ts [${record.level.name}] ${record.loggerName}: ${record.message}');
    if (record.error != null) {
      // ignore: avoid_print
      print('  Error: ${record.error}');
    }
    if (record.stackTrace != null) {
      // ignore: avoid_print
      print(record.stackTrace);
    }
  });
}
