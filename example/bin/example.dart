import 'package:objectid/objectid.dart';
import 'package:benchmark_harness/benchmark_harness.dart';

const _numberOfTests = 1000;

class ObjectIdBenchmark extends BenchmarkBase {
  const ObjectIdBenchmark() : super('ObjectId() → ');

  static void main() {
    ObjectIdBenchmark().report();
  }

  @override
  void run() {
    for (var i = 0; i < _numberOfTests; i++) {
      ObjectId();
    }
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
    for (var i = 0; i < _numberOfTests; i++) {
      ObjectId.fromHexString(hexString);
    }
  }
}

class HexStringBenchmark extends BenchmarkBase {
  HexStringBenchmark() : super('ObjectId.hexString → ');

  static void main() {
    HexStringBenchmark().report();
  }

  ObjectId _objectId;

  @override
  void run() {
    for (var i = 0; i < _numberOfTests; i++) {
      _objectId.hexString;
    }
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

  ObjectId _objectIdA;
  ObjectId _objectIdB;

  @override
  void run() {
    for (var i = 0; i < _numberOfTests; i++) {
      _objectIdA == _objectIdB;
    }
  }

  @override
  void setup() {
    _objectIdA = ObjectId();
    _objectIdB = ObjectId();
    // print(_objectIdA.hexString + _objectIdB.hexString);
  }
}

class GenerationTimeBenchmark extends BenchmarkBase {
  GenerationTimeBenchmark() : super('ObjectId.generationTime → ');

  static void main() {
    GenerationTimeBenchmark().report();
  }

  ObjectId _objectIdA;

  @override
  void run() {
    for (var i = 0; i < _numberOfTests; i++) {
      _objectIdA.generationTime;
    }
  }

  @override
  void setup() {
    _objectIdA = ObjectId();
  }
}

void main(List<String> arguments) async {
  GenerationTimeBenchmark.main();
  ObjectIdBenchmark.main();
  FromHexStringBenchmark.main();
  EqualityOperatorBenchmark.main();
  HexStringBenchmark.main();
}
