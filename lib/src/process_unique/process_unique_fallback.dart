import 'dart:math' as math;
import 'package:objectid/src/process_unique/process_unique.dart';

class FallbackProcessUnique implements ProcessUnique {
  @override
  int get value {
    var value = 0;

    math.Random random;

    try {
      random = math.Random.secure();
    } on UnsupportedError {
      random = math.Random();
    }

    for (var i = 0; i < 10; i++) {
      value += random.nextInt(256) * math.pow(16, i);
    }

    return value;
  }
}

ProcessUnique getProcessUnique() => FallbackProcessUnique();
