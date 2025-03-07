import 'dart:io' as io;
import 'dart:math' as math;
import 'dart:typed_data';

import '../process_unique/process_unique.dart';

/// IO Process unique implementation
class ProcessUniqueIo implements ProcessUnique {
  /// 5 bytes
  @override
  Uint8List getValue() {
    final random =
        math.Random((DateTime.now().millisecondsSinceEpoch ^ io.pid));
    final bytes = Uint8List(ProcessUnique.size);
    for (var i = 0; i < ProcessUnique.size; i++) {
      bytes[i] = random.nextInt(256);
    }
    return bytes;
  }
}

/// Process unique io factory method
ProcessUnique getProcessUnique() => ProcessUniqueIo();
