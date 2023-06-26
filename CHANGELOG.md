## 3.0.0
- ⚠️ The strict runtime type checking in the equals operator has been removed. Now all classes that extend ObjectId and have the same value will be matched by this operator.
  ```dart
  class MyObjectId extends ObjectId {}
  const hexString = '606eed9d7203bfbbb7fffffe';
  ObjectId(hexString) == MyObjectId(hexString); // true
  ```
- Updated dart sdk constraints to match new requirements.
- Updated package dependencies
  - Replaced the code analysis rules defined by the *effective_dart* package with the *lints* package. 
- Removed unnecessary (for packages) *pubspec.lock* file.

## 2.1.0
- Constants `ObjectId.byteLength` and ` ObjectId.hexStringLength` are now publicly available.
## 2.0.0

- Stable nullsafety release
- Fixed a bug that caused the counter value to overflow at `0xfffffe`.
  - Enabled counter overflow unit test.
- `toString` method now instead of `runtimeType(hexString)`, returns objectid's `hexString`.
  ```dart
  /// Before:
  print(ObjectId()) // => "ObjectId(606eed9d7203bfbbb7fffffe)"
  /// Now:
  print(ObjectId()) // => "606eed9d7203bfbbb7fffffe"
  ```
  **TIP**:  
  If you still want to use the `toString` method with `runtimeType`, you can override the `ObjectId` class. Example:
  ```dart
  class MyObjectId extends ObjectId {
    @override
    String toString() => '$runtimeType($hexString)';
  }
  ```

## 2.0.0-nullsafety.0

- Initial move towards nullsafety
- Updated changelog (removed release dates)

## 1.1.1

- Use StringBuffer instead of String class for hexString generation (almost 5 times faster generation of hexStrings).

## 1.1.0

- Migrate package to effective dart style.
- 100% tests coverage.
- Improve readme docs.
  - Added badges.
  - Added benchmark section.

## 1.0.0

- Added readme documentation

## 0.2.0

- Added unit tests
- Restructured projects
- Added `fromBytes`, `fromValues` and `fromTimestamp` constructors.
- Renamed `generationTime` property to `timestamp`.
- Added missing `hashCode` implementation based on `murmurHash2`.
- Added `bytes` property.

## 0.1.0-dev.1

- Added ObjectId class.
  - Added `ObjectId()` and `ObjectId.fromHexString()` constructors.
  - Added `isValid` helper method.
  - Added equality operator overload `==`.
  - Added `hexString` and `generationTime` getters with caching support.
