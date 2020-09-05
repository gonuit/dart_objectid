# ObjectId

### Blazing fast, cross-platform ObjectId implementation for the dart language!

Fully compatible with ObjectId [specification](https://github.com/mongodb/specifications/blob/master/source/objectid.rst) 💪.

## Getting started.
```dart
final id = ObjectId(); // Thats all 🔥😮!
print(id.hexString);   // => 5f52c805df41c9df948e6135
```

## Documentation

### **ObjectId()**
Creates ObjectId instance based on current timestamp, process unique and counter. For more information take a look at [ObjectId specification](https://github.com/mongodb/specifications/blob/master/source/objectid.rst). 
```dart
/// Creates ObjectId instance.
final id = ObjectId();
print(id.hexString); // => 5f52c805df41c9df948e6135
```
**Benchamark (avg time):**
```
1.694972710939354 us.
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
**Benchamark (avg time):**
```
3.6401499394306052 us.
```

### **ObjectId.fromBytes(List<int> bytes)**
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
**Benchamark (avg time):**
```
0.58338475488028056 us.
```

### **ObjectId.fromValues(int millisecondsSinceEpoch, int processUnique, int counter)**
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
**Benchamark (avg time):**
```
0.50956103355082625 us.
```

### **ObjectId.fromTimestamp(DateTime timestamp)**
Creates ObjectId from provided timestamp.  
Propably you do not want to use this constructor. It is mostly used for ObjectId comparisons or sorting.  
  
**Warning ⚠️:**   
Only timestamp segment is set while the rest of the ObjectId is zeroed out.
```dart
/// Create ObjectId instance.
final id = ObjectId.fromTimestamp(DateTime.now());
print(id.hexString); // => 5f52d05e0000000000000000
```
**Benchamark (avg time):**
```
0.47020163256147746 us.
```

***

### **bool operator ==**
It is possible to compare ObjectIds instances by equality operator `==`.  
Comparison is based on ObjectId `runtimeType` and `bytes`.

### **int hashCode**
Hashcode is calculated by dart implementation of Austin Appleby, MurmurHash2 algorithm; wich is for ObjectId almost 2 times faster 🚀 than the commonly used Jenkins algorithm.  
  
Property value will be generated only once (with the first read) and cached, what's strongly improves performance.

### **String hexString**
Returns a 24-bit hex string representation of the ObjectId.
  
Property value will be generated only once (with the first read) and cached, what's strongly improves performance.

### **DateTime timestamp**
Returns an accurate up to the second ObjectId generation time (timestamp).  
  
Property value will be generated only once (with the first read) and cached, what's strongly improves performance.

### **Uint8List bytes**
Returns a ObjectId bytes.  

***

### **static bool isValid(String hexString)**
Helper method that checks whether the provided `hexString` is a valid ObjectId. 

***

Benchmark hardware:  
Intel i7 3770k, 16GB RAM DDR3, Windows 10  
  
Benchmark is available in the example app.
 
