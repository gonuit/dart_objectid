import 'dart:io' as io;
import 'dart:math' as math;

import './process_unique.dart';

class ProcessUniqueIo implements ProcessUnique {
  /// 5 bytes
  int get value {
    int value = 0;

    /// Get's process unique by combination of timestamp, and process pid
    final random =
        math.Random((DateTime.now().millisecondsSinceEpoch ^ io.pid));

    for (int i = 0; i < 10; i++) {
      value += random.nextInt(256) * math.pow(16, i);
    }

    return value;
  }
}

ProcessUnique getProcessUnique() => ProcessUniqueIo();
