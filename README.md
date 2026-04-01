# ObjectId

### Blazing fast, cross-platform ObjectId implementation for the dart language!

[![Dart tests](https://github.com/gonuit/dart_objectid/actions/workflows/test.yml/badge.svg?branch=master)](https://github.com/gonuit/dart_objectid/actions/workflows/test.yml)
[![codecov](https://codecov.io/gh/gonuit/dart_objectid/branch/master/graph/badge.svg)](https://codecov.io/gh/gonuit/dart_objectid)
[![pub package](https://img.shields.io/pub/v/objectid.svg)](https://pub.dev/packages/objectid)
[![License: MIT](https://img.shields.io/badge/license-MIT-blue.svg)](https://opensource.org/licenses/MIT)
[![style: lints/recommended](https://img.shields.io/badge/style-lints/recommended-40c4ff.svg)](https://pub.dev/packages/lints)
  
Why this package?
- 🚀 Fast.
- 📱 Cross-platform.
- 🧪 Well tested.
- 📒 Fulfills [bson ObjectId specification](https://github.com/mongodb/specifications/blob/master/source/bson-objectid/objectid.md).
- 📝 Documented.


## Getting started
1. Depend on it.
```yml
dependencies:
  objectid: 4.0.3
```
2. Play with it!
```dart
final id = ObjectId(); // That's all 🔥😮!
print(id);   // it's working! => 5f52c805df41c9df948e6135
```

## Documentation

### Constructors

#### `ObjectId()`
Creates an ObjectId instance based on current timestamp, process unique and counter.
```dart
final id = ObjectId();
print(id.hexString); // => 5f52c805df41c9df948e6135
```

#### `ObjectId.fromHexString(String hexString)`
Creates ObjectId from a 24-character hex string.
```dart
// Useful for mapping hex strings from APIs or MongoDB
final id = ObjectId.fromHexString('5f52c805df41c9df948e6135');
print(id == ObjectId.fromHexString(id.hexString)); // => true
```

#### `ObjectId.fromBytes(List<int> bytes)`
Creates ObjectId from a 12-byte array.
```dart
// Perfect for storing ObjectId in binary format
final id = ObjectId.fromBytes([95, 82, 205, 121, 180, 195, 28, 88, 32, 47, 183, 78]);
print(id.hexString); // => 5f52cd79b4c31c58202fb74e

// Retrieve bytes with the bytes property
final id2 = ObjectId.fromBytes(id.bytes);
print(id == id2); // => true
```

#### `ObjectId.fromValues(int millisecondsSinceEpoch, int processUnique, int counter)`
Creates an ObjectId from provided integer values.
```dart
// Examples of different ObjectId patterns
final zeroed = ObjectId.fromValues(0, 0, 0);                    // 000000000000000000000000
final withTimestamp = ObjectId.fromValues(0x3e7fffffc18, 0, 0); // ffffffff0000000000000000
final withProcessUnique = ObjectId.fromValues(0, 0xffffffffff, 0); // 00000000ffffffffff000000
final withCounter = ObjectId.fromValues(0, 0, 0xffffff);        // 000000000000000000ffffff
final filled = ObjectId.fromValues(0x3e7fffffc18, 0xffffffffff, 0xffffff); // ffffffffffffffffffffffff
```

#### `ObjectId.fromTimestamp(DateTime timestamp)`
Creates ObjectId from provided timestamp with other segments zeroed out.
```dart
// Useful for ObjectId comparisons or sorting
final id = ObjectId.fromTimestamp(DateTime.now());
print(id.hexString); // => 5f52d05e0000000000000000
```

### Properties and Methods

#### `String hexString`
Returns a 24-character hex string representation of the ObjectId (cached for performance).

#### `DateTime timestamp`
Returns the generation time accurate to the second (cached for performance).

#### `Uint8List bytes`
Returns the ObjectId's raw byte representation.

#### `int hashCode`
Uses MurmurHash2 algorithm for fast hashing (cached for performance).

#### `operator ==`
Compares ObjectIds based on type and byte equality.

#### `static bool isValid(String hexString)`
Checks if a string is a valid ObjectId hex string.
```dart
print(ObjectId.isValid('5f52c805df41c9df948e6135')); // => true
print(ObjectId.isValid('invalid')); // => false
```

All implementation details conform to the [BSON ObjectId specification](https://github.com/mongodb/specifications/blob/master/source/bson-objectid/objectid.md).

## Benchmark
Benchmark hardware/software:
UNIT: MacBook Pro (M4 Pro, 2024)
CPU: Apple M4 Pro
RAM: 48 GB
OS: macOS 26.3.1
Dart SDK version: 3.11.4

```
Constructors:
ObjectId() → (RunTime): 0.28017946395452636 us.
ObjectId.fromHexString() → (RunTime): 0.1964833532549569 us.
ObjectId.fromBytes() → (RunTime): 0.11237176106442358 us.
ObjectId.fromValues() → (RunTime): 0.02774876977800984 us.
ObjectId.fromTimestamp() → (RunTime): 0.04264624207353758 us.
Properties:
ObjectId.hexString → (RunTime): 0.03615293445770598 us.
ObjectId.timestamp → (RunTime): 0.03690251970477984 us.
ObjectId.hashCode → (RunTime): 0.02660910959699762 us.
Operators:
ObjectId == ObjectId → (RunTime): 0.08761381094863427 us.
```

Benchmark is available in the example app.
 
