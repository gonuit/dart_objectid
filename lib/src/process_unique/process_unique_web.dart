import 'dart:math' as math;
import 'dart:html' as web;

import 'package:objectid/src/process_unique/process_unique.dart';

class ProcessUniqueWeb implements ProcessUnique {
  /// 5 bytes
  @override
  int get value {
    var value = 0;

    /// Get's process unique by combination of timestamp, hostname and random value
    final random = math.Random(DateTime.now().millisecondsSinceEpoch ^
        web.window.location.hostname.codeUnits
            .reduce((value, element) => value + element) ^
        math.Random().nextInt(0xffffff));

    for (var i = 0; i < 10; i++) {
      value += random.nextInt(256) * math.pow(16, i);
    }

    return value;
  }
}

ProcessUnique getProcessUnique() => ProcessUniqueWeb();
