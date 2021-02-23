# ObjectId

### Blazing fast, cross-platform ObjectId implementation for the dart language!

![Dart tests](https://github.com/gonuit/dart_objectid/workflows/Dart%20tests/badge.svg?branch=master)
[![pub package](https://img.shields.io/pub/v/objectid.svg)](https://pub.dartlang.org/packages/objectid)
[![License: MIT](https://img.shields.io/badge/license-MIT-blue.svg)](https://opensource.org/licenses/MIT)
[![style: effective dart](https://img.shields.io/badge/style-effective_dart-40c4ff.svg)](https://github.com/tenhobi/effective_dart)
[![codecov](https://codecov.io/gh/gonuit/dart_objectid/branch/master/graph/badge.svg)](https://codecov.io/gh/gonuit/dart_objectid)
  
Why this package?
- 🚀 Fast.
- 📱 Cross-platform.
- 🧪 Well tested.
- 📒 Fulfills [bson ObjectId specification](https://github.com/mongodb/specifications/blob/master/source/objectid.rst).
- 📝 Documented.


## Getting started.
1. Depend on it.
```yml
dependencies:
  objectid: 1.1.0
```
2. Play with it!
```dart
final id = ObjectId(); // That's all 🔥😮!
print(id.hexString);   // it's working! => 5f52c805df41c9df948e6135
```

***

## Documentation

### **ObjectId()**
Creates ObjectId instance based on current timestamp, process unique and counter. For more information take a look at [ObjectId specification](https://github.com/mongodb/specifications/blob/master/source/objectid.rst). 
```dart
/// Creates ObjectId instance.
final id = ObjectId();
print(id.hexString); // => 5f52c805df41c9df948e6135
```

### **ObjectId.fromHexString(String hexString)**
Creates ObjectId from hex string.  
  
**TIP 💡:**   
Can be helpful for mapping hex strings returned from API / mongodb.
```dart
/// Create ObjectId instance.
final id = ObjectId.fromHexString('5f52c805df41c9df948e6135');
print(id.hexString); // => 5f52c805df41c9df948e6135

final id2 = ObjectId.fromHexString(id.hexString);
print(id == id2); // => true
```

### ObjectId.fromBytes(List<int> bytes)
Creates ObjectId from bytes.  
  
**TIP 💡:**   
Sometimes we may want to save ObjectId representation to file, binary format is the best way to do so.
```dart
/// Create ObjectId instance.
final id = ObjectId.fromBytes([95, 82, 205, 121, 180, 195, 28, 88, 32, 47, 183, 78]);
print(id.hexString); // => 5f52cd79b4c31c58202fb74e

/// To retrive ObjectId bytes as [Uint8list] you can use `bytes` property.
print(id.bytes); // => [95, 82, 205, 121, 180, 195, 28, 88, 32, 47, 183, 78]

final id2 = ObjectId.fromBytes(id.bytes);
print(id == id2); // => true
```

### ObjectId.fromValues(int millisecondsSinceEpoch, int processUnique, int counter)
Creates an ObjectId from the provided integer values.  
  
```dart
/// Create ObjectId instance.
/// `hexString = 000000000000000000000000`
final zeroed = ObjectId.fromValues(0, 0, 0);

/// `hexString = ffffffff0000000000000000`
final withTimestamp = ObjectId.fromValues(0x3e7fffffc18, 0, 0); 

/// `hexString = 00000000ffffffffff000000`
final withProcessUnique = ObjectId.fromValues(0, 0xffffffffff, 0); 

/// `hexString = 000000000000000000ffffff`
final withCounter = ObjectId.fromValues(0, 0, 0xffffff);

/// `hexString = ffffffffffffffffffffffff`
final filled = ObjectId.fromValues(0x3e7fffffc18, 0xffffffffff, 0xffffff);
```

### ObjectId.fromTimestamp(DateTime timestamp)
Creates ObjectId from provided timestamp.  
Propably you do not want to use this constructor. It is mostly used for ObjectId comparisons or sorting.  
  
**Warning ⚠️:**   
Only timestamp segment is set while the rest of the ObjectId is zeroed out.
```dart
/// Create ObjectId instance.
final id = ObjectId.fromTimestamp(DateTime.now());
print(id.hexString); // => 5f52d05e0000000000000000
```

***

### bool operator ==
It is possible to compare ObjectIds instances by equality operator `==`.  
Comparison is based on ObjectId `runtimeType` and `bytes`.

### int hashCode
Hashcode is calculated by dart implementation of Austin Appleby, MurmurHash2 algorithm; wich is for ObjectId almost 2 times faster 🚀 than the commonly used Jenkins algorithm.  
  
Property value will be generated only once (with the first read) and cached, what's strongly improves performance.

### String hexString
Returns a 24-bit hex string representation of the ObjectId.
  
Property value will be generated only once (with the first read) and cached, what's strongly improves performance.

### DateTime timestamp
Returns an accurate up to the second ObjectId generation time (timestamp).  
  
Property value will be generated only once (with the first read) and cached, what's strongly improves performance.

### Uint8List bytes
Returns a ObjectId bytes.  

***

### static bool isValid(String hexString)
Helper method that checks whether the provided `hexString` is a valid ObjectId. 

***

## Benchmark:
Benchmark hardware/software:  
CPU: 2,3 GHz 8-Core Intel Core i9  
RAM: 32 GB 2667 MHz DDR4
OS: macOS Big Sur  
  
```
Constructors:
ObjectId() → (RunTime): 1.4411921541499129 us.
ObjectId.fromHexString() → (RunTime): 1.4694861207035899 us.
ObjectId.fromBytes() → (RunTime): 0.36035068608068 us.
ObjectId.fromValues() → (RunTime): 0.15900537684632074 us.
ObjectId.fromTimestamp() → (RunTime): 0.16805727556390831 us.
Properties:
ObjectId.hexString → (RunTime): 0.1998765961895126 us.
ObjectId.timestamp → (RunTime): 0.20065183755949578 us.
ObjectId.hashCode → (RunTime): 0.18386848255180036 us.
Operators:
ObjectId == ObjectId → (RunTime): 0.35003159035102915 us.
```
  
Benchmark is available in the example app.
 
