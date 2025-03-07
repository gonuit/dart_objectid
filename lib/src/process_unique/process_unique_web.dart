import 'dart:math' as math;
import 'dart:js_util' as js_utils;
import 'dart:typed_data';

import '../process_unique/process_unique.dart';

/// Web Process unique implementation
class ProcessUniqueWeb implements ProcessUnique {
  /// 5 bytes
  @override
  Uint8List getValue() {
    /// Get's process unique by combination of timestamp, hostname
    /// and random value
    final hostname =
        (js_utils.getProperty(js_utils.globalThis, 'location')?['hostname'] ??
                'localhost')
            .toString();

    final random = math.Random(DateTime.now().millisecondsSinceEpoch ^
        hostname.codeUnits.reduce((value, element) => value + element) ^
        math.Random().nextInt(0xffffff));

    final value = Uint8List.fromList(
      List.generate(5, (index) => random.nextInt(256)),
    );

    return value;
  }
}

/// Process unique web factory method
ProcessUnique getProcessUnique() => ProcessUniqueWeb();
