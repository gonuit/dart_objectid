import 'dart:typed_data';

import './process_unique_fallback.dart'
    if (dart.library.html) './process_unique_web.dart'
    if (dart.library.io) './process_unique_io.dart';

/// Process unique abstract class
abstract class ProcessUnique {
  static const size = 5;

  /// Get process unique random value
  Uint8List getValue();

  /// Get process implementation based on platform
  factory ProcessUnique() => getProcessUnique();
}
