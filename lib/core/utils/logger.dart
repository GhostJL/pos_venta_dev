import 'package:flutter/foundation.dart';
import 'package:logging/logging.dart';

final Logger appLogger = Logger('POSVentaApp');

void setupLogger() {
  Logger.root.level = Level.ALL;
  Logger.root.onRecord.listen((record) {
    if (kDebugMode) {
      print('${record.level.name}: ${record.time}: ${record.message}');
      if (record.error != null) {
        print('ERROR: ${record.error}');
      }
      if (record.stackTrace != null) {
        print('STACKTRACE: ${record.stackTrace}');
      }
    }
  });
}
