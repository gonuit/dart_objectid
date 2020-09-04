import './process_unique_stub.dart'
    if (dart.library.html) './process_unique_web.dart'
    if (dart.library.io) './process_unique_io.dart';

abstract class ProcessUnique {
  int get value;

  factory ProcessUnique() => getProcessUnique();
}
