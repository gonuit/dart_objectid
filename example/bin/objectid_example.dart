import 'dart:typed_data';

import 'package:objectid/objectid.dart';
import 'package:benchmark_harness/benchmark_harness.dart';
import 'package:uuid/uuid.dart';

class ObjectIdBenchmark extends BenchmarkBase {
  const ObjectIdBenchmark() : super('ObjectId() → ');

  static void main() {
    ObjectIdBenchmark().report();
  }

  @override
  void run() {
    ObjectId();
  }
}

class UuidBenchmark extends BenchmarkBase {
  const UuidBenchmark() : super('Uuid().v1() → ');

  static void main() {
    UuidBenchmark().report();
  }

  @override
  void run() {
    Uuid().v1();
  }
}

class UuidBenchmarkV1 extends BenchmarkBase {
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

class UuidBenchmarkV4 extends BenchmarkBase {
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

class FromHexStringBenchmark extends BenchmarkBase {
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

class HexStringBenchmark extends BenchmarkBase {
  HexStringBenchmark() : super('ObjectId.hexString → ');

  static void main() {
    HexStringBenchmark().report();
  }

  ObjectId? _objectId;

  @override
  void run() {
    _objectId!.hexString;
  }

  @override
  void setup() {
    _objectId = ObjectId();
  }
}

class EqualityOperatorBenchmark extends BenchmarkBase {
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

class TimestampBenchmark extends BenchmarkBase {
  TimestampBenchmark() : super('ObjectId.timestamp → ');

  static void main() {
    TimestampBenchmark().report();
  }

  ObjectId? _objectIdA;

  @override
  void run() {
    _objectIdA!.timestamp;
  }

  @override
  void setup() {
    _objectIdA = ObjectId();
  }
}

class HashCodeBenchmark extends BenchmarkBase {
  HashCodeBenchmark() : super('ObjectId.hashCode → ');

  static void main() {
    HashCodeBenchmark().report();
  }

  ObjectId? _id;

  @override
  void run() {
    _id.hashCode;
  }

  @override
  void setup() {
    _id = ObjectId();
  }
}

class FromBytesBenchmark extends BenchmarkBase {
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

class FromValuesBenchmark extends BenchmarkBase {
  FromValuesBenchmark() : super('ObjectId.fromValues() → ');

  static void main() {
    FromValuesBenchmark().report();
  }

  @override
  void run() {
    ObjectId.fromValues(123456, 123456, 123456);
  }
}

class FromTimestampBenchmark extends BenchmarkBase {
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
