import 'package:objectid/src/process_unique/process_unique_fallback.dart'
    if (dart.library.html) './process_unique_web.dart'
    if (dart.library.io) './process_unique_io.dart';

abstract class ProcessUnique {
  int getValue();

  factory ProcessUnique() => getProcessUnique();
}
