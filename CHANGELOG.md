## [0.1.0-dev.1] - 09/04/2020 Initial release.
- Added ObjectId class.
  - Added `ObjectId()` and `ObjectId.fromHexString()` constructors.
  - Added `isValid` helper method.
  - Added equality operator overload `==`.
  - Added `hexString` and `generationTime` getters with caching support.
