# ObjectId

### Blazing fast, cross-platform ObjectId implementation for the dart language!

[![Dart tests](https://github.com/gonuit/dart_objectid/actions/workflows/test.yml/badge.svg?branch=master)](https://github.com/gonuit/dart_objectid/actions/workflows/test.yml)
[![codecov](https://codecov.io/gh/gonuit/dart_objectid/branch/master/graph/badge.svg)](https://codecov.io/gh/gonuit/dart_objectid)
[![pub package](https://img.shields.io/pub/v/objectid.svg)](https://pub.dartlang.org/packages/objectid)
[![License: MIT](https://img.shields.io/badge/license-MIT-blue.svg)](https://opensource.org/licenses/MIT)
[![style: effective dart](https://img.shields.io/badge/style-lints/recommended-40c4ff.svg)](https://github.com/tenhobi/effective_dart)
  
Why this package?
- 🚀 Fast.
- 📱 Cross-platform.
- 🧪 Well tested.
- 📒 Fulfills [bson ObjectId specification](https://github.com/mongodb/specifications/blob/master/source/bson-objectid/objectid.md).
- 📝 Documented.


## Getting started.
1. Depend on it.
```yml
dependencies:
  objectid: 4.0.0
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

## Benchmark:
Benchmark hardware/software:  
UNIT: MacBook Pro (13-inch, M2, 2022)  
CPU: Apple M2, 16GB RAM  
RAM: 16 GB  
OS: macOS Monterey 12.6.1 (Build 21G217)  
Dart SDK version: 3.0.5
  
```
Constructors:
ObjectId() → (RunTime): 0.29132956069161253 us.
ObjectId.fromHexString() → (RunTime): 0.75057425 us.
ObjectId.fromBytes() → (RunTime): 0.15551437570213106 us.
ObjectId.fromValues() → (RunTime): 0.03314456474312962 us.
ObjectId.fromTimestamp() → (RunTime): 0.044412125467054496 us.
Properties:
ObjectId.hexString → (RunTime): 0.039307475449695345 us.
ObjectId.timestamp → (RunTime): 0.050248475 us.
ObjectId.hashCode → (RunTime): 0.03570540247334531 us.
Operators:
ObjectId == ObjectId → (RunTime): 0.12478619550684174 us.
```
  
Benchmark is available in the example app.
 
