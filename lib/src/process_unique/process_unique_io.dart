import 'dart:io' as io;
import 'dart:math' as math;

import 'package:objectid/src/process_unique/process_unique.dart';

class ProcessUniqueIo implements ProcessUnique {
  /// 5 bytes
  @override
  int get value {
    var value = 0;

    /// Get's process unique by combination of timestamp, and process pid
    final random =
        math.Random((DateTime.now().millisecondsSinceEpoch ^ io.pid));

    for (var i = 0; i < 10; i++) {
      value += random.nextInt(256) * math.pow(16, i);
    }

    return value;
  }
}

ProcessUnique getProcessUnique() => ProcessUniqueIo();
