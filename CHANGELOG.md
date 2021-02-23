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
