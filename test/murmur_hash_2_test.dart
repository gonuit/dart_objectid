import 'dart:typed_data';

import 'package:objectid/src/hash/murmur_hash_2.dart';
import 'package:test/test.dart';

Uint8List _bytes(String hex) => Uint8List.fromList([
      for (var i = 0; i < hex.length; i += 2)
        int.parse(hex.substring(i, i + 2), radix: 16),
    ]);

void main() {
  /// Expected values come from the reference C implementation.
  group('murmurHash2 matches the reference implementation', () {
    const vectors = <String, List<int>>{
      // [seed 0, seed 42]
      '000000000000000000000000': [0x25c148bc, 0x28e4bebd],
      'ffffffffffffffffffffffff': [0x3ca2c77a, 0x9ccf997b],
      '5f527e9b350aa5f9709daf16': [0x30216977, 0x553ce839],
      '507f1f77bcf86cd799439011': [0xfea08dcc, 0x1fd94d2c],
      '000102030405060708090a0b': [0xd55a2b52, 0x4f2215b9],
      '800000008000000080000000': [0xd768afad, 0x0a130c9e],
      '000000800000008000000080': [0xd4284b55, 0x8a2e1549],
      '6553f1001122334455000010': [0xd207cfe5, 0x74d25845],
      '6553f1001122334455000100': [0x8f8cffe5, 0x7fbe5d62],
    };

    vectors.forEach((hex, expected) {
      test(hex, () {
        expect(murmurHash2(_bytes(hex)), equals(expected[0]));
        expect(murmurHash2(_bytes(hex), 42), equals(expected[1]));
      });
    });
  });

  test('murmurHash2 result is an unsigned 32-bit integer', () {
    for (var i = 0; i < 1000; i++) {
      final data = Uint8List(12)
        ..[0] = i & 0xff
        ..[5] = (i * 7) & 0xff
        ..[11] = (i * 13) & 0xff;
      final hash = murmurHash2(data);
      expect(hash, greaterThanOrEqualTo(0));
      expect(hash, lessThanOrEqualTo(0xffffffff));
    }
  });
}
