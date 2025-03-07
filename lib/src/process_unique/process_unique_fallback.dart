import 'dart:math' as math;
import 'dart:typed_data';

import '../process_unique/process_unique.dart';

/// Fallback Process unique implementation
class FallbackProcessUnique implements ProcessUnique {
  @override
  Uint8List getValue() {
    final bytes = Uint8List(ProcessUnique.size);

    math.Random? random;
    try {
      random = math.Random.secure();
    } on UnsupportedError {
      random = math.Random();
    }
    for (var i = 0; i < bytes.length; i++) {
      bytes[i] = random.nextInt(256);
    }
    return bytes;
  }
}

/// Process unique fallback factory method
ProcessUnique getProcessUnique() => FallbackProcessUnique();
