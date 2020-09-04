import 'dart:typed_data';

const m = 0x5bd1e995;
const r = 24;

/// Dart Implementation of MurmurHash2, by Austin Appleby
int murmurHash2(Uint8List data, [int seed = 0]) {
  // 'm' and 'r' are mixing constants generated offline.
  // They're not really 'magic', they just happen to work well.

  // Initialize the hash to a 'random' value

  var len = data.length;
  var h = seed ^ len;

  // Mix 4 bytes at a time into the hash

  var pointer = 0;
  while (len >= 4) {
    var k = data[pointer + 3] +
        data[pointer + 2] * 16 +
        data[pointer + 1] * 256 +
        data[pointer] * 4096;

    k *= m;
    k ^= k >> r;
    k *= m;

    h *= m;
    h ^= k;

    pointer += 4;
    len -= 4;
  }

  /// Handle the last few bytes of the input array

  /// Duplicating values inside cases is faster than
  /// creating labels and using `continue` keyword
  switch (len) {
    case 3:
      h ^= data[pointer + 2] << 16;
      h ^= data[pointer + 1] << 8;
      h ^= data[pointer];
      h *= m;
      break;
    case 2:
      h ^= data[pointer + 1] << 8;
      h ^= data[pointer];
      h *= m;
      break;
    case 1:
      h ^= data[pointer];
      h *= m;
  }

  // Do a few final mixes of the hash to ensure the last few
  // bytes are well-incorporated.

  h ^= h >> 13;
  h *= m;
  h ^= h >> 15;

  return h;
}
