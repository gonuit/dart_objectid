import 'dart:typed_data';

import 'package:objectid/objectid.dart';
import 'package:benchmark_harness/benchmark_harness.dart';
import 'package:uuid/uuid.dart';

/// Reports the time of a single [run].
abstract class Benchmark extends BenchmarkBase {
  const Benchmark(super.name);

  static const _runs = 1000;

  @override
  void exercise() {
    for (var i = 0; i < _runs; i++) {
      run();
    }
  }

  @override
  double measure() => super.measure() / _runs;
}

/// Reports the time of [read] for ids without cached values.
abstract class PropertyBenchmark extends BenchmarkBase {
  const PropertyBenchmark(super.name);

  static const _batch = 100000;
  static const _minimumMillis = 2000;

  Object? read(ObjectId id);

  static Object? result;

  @override
  double measure() {
    final watch = Stopwatch();
    var count = -_batch;

    while (watch.elapsedMilliseconds < _minimumMillis) {
      final ids = List.generate(_batch, (_) => ObjectId());

      // First batch is a warmup.
      if (count == 0) watch.reset();

      watch.start();
      for (var i = 0; i < _batch; i++) {
        result = read(ids[i]);
      }
      watch.stop();
      count += _batch;
    }

    return watch.elapsedMicroseconds / count;
  }
}

class ObjectIdBenchmark extends Benchmark {
  const ObjectIdBenchmark() : super('ObjectId() → ');

  static void main() {
    ObjectIdBenchmark().report();
  }

  @override
  void run() {
    ObjectId();
  }
}

class UuidBenchmark extends Benchmark {
  const UuidBenchmark() : super('Uuid().v1() → ');

  static void main() {
    UuidBenchmark().report();
  }

  @override
  void run() {
    Uuid().v1();
  }
}

class UuidBenchmarkV1 extends Benchmark {
  const UuidBenchmarkV1() : super('uuid.v1() → ');

  final uuid = const Uuid();

  static void main() {
    UuidBenchmarkV1().report();
  }

  @override
  void run() {
    uuid.v1();
  }
}

class UuidBenchmarkV4 extends Benchmark {
  const UuidBenchmarkV4() : super('uuid.v4() → ');

  final uuid = const Uuid();

  static void main() {
    UuidBenchmarkV4().report();
  }

  @override
  void run() {
    uuid.v4();
  }
}

class FromHexStringBenchmark extends Benchmark {
  const FromHexStringBenchmark() : super('ObjectId.fromHexString() → ');

  static void main() {
    FromHexStringBenchmark().report();
  }

  static const hexString = '5f5173058e87a402f8e678e0';

  @override
  void run() {
    ObjectId.fromHexString(hexString);
  }
}

class HexStringBenchmark extends PropertyBenchmark {
  const HexStringBenchmark() : super('ObjectId.hexString → ');

  static void main() {
    HexStringBenchmark().report();
  }

  @override
  Object? read(ObjectId id) => id.hexString;
}

class EqualityOperatorBenchmark extends Benchmark {
  EqualityOperatorBenchmark() : super('ObjectId == ObjectId → ');

  static void main() {
    EqualityOperatorBenchmark().report();
  }

  ObjectId? _objectIdA;
  ObjectId? _objectIdB;

  @override
  void run() {
    _objectIdA == _objectIdB;
  }

  @override
  void setup() {
    _objectIdA = ObjectId();
    _objectIdB = ObjectId();
  }
}

class TimestampBenchmark extends PropertyBenchmark {
  const TimestampBenchmark() : super('ObjectId.timestamp → ');

  static void main() {
    TimestampBenchmark().report();
  }

  @override
  Object? read(ObjectId id) => id.timestamp;
}

class HashCodeBenchmark extends PropertyBenchmark {
  const HashCodeBenchmark() : super('ObjectId.hashCode → ');

  static void main() {
    HashCodeBenchmark().report();
  }

  @override
  Object? read(ObjectId id) => id.hashCode;
}

class FromBytesBenchmark extends Benchmark {
  FromBytesBenchmark() : super('ObjectId.fromBytes() → ');

  static void main() {
    FromBytesBenchmark().report();
  }

  Uint8List? _bytes;
  @override
  void run() {
    ObjectId.fromBytes(_bytes!);
  }

  @override
  void setup() {
    _bytes = Uint8List.fromList(
      [95, 82, 205, 121, 180, 195, 28, 88, 32, 47, 183, 78],
    );
  }
}

class FromValuesBenchmark extends Benchmark {
  FromValuesBenchmark() : super('ObjectId.fromValues() → ');

  static void main() {
    FromValuesBenchmark().report();
  }

  @override
  void run() {
    ObjectId.fromValues(123456, 123456, 123456);
  }
}

class FromTimestampBenchmark extends Benchmark {
  FromTimestampBenchmark() : super('ObjectId.fromTimestamp() → ');

  static void main() {
    FromTimestampBenchmark().report();
  }

  DateTime? _timestamp;

  @override
  void run() {
    ObjectId.fromTimestamp(_timestamp!);
  }

  @override
  void setup() {
    _timestamp = DateTime.now();
  }
}

void main(List<String> arguments) async {
  print('Constructors:');
  ObjectIdBenchmark.main();
  FromHexStringBenchmark.main();
  FromBytesBenchmark.main();
  FromValuesBenchmark.main();
  FromTimestampBenchmark.main();
  print('Properties:');
  HexStringBenchmark.main();
  TimestampBenchmark.main();
  HashCodeBenchmark.main();
  print('Operators:');
  EqualityOperatorBenchmark.main();

  print('Uuid:');
  UuidBenchmark.main();
  UuidBenchmarkV1.main();
  UuidBenchmarkV4.main();
}
