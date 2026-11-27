import 'dart:convert';
import 'dart:typed_data';

import 'package:objectid/objectid.dart';
import 'package:test/test.dart';

class TestObjectId extends ObjectId {
  TestObjectId.fromHexString(String hexString) : super.fromHexString(hexString);
}

void main() {
  group('ObjectId', () {
    test('Default constructor works correctly.', () {
      final isObjectId = TypeMatcher<ObjectId>()
          .having((id) => id.bytes.length, 'bytes.length', equals(12))
          .having((id) => id.hexString.length, 'hexString.length', equals(24))
          .having((id) => id.timestamp, 'generationTime', isA<DateTime>());
      final id = ObjectId();
      expect(id, isObjectId);
    });

    test('fromBytes constructor works correctly', () async {
      final id = ObjectId();
      final bytes = id.bytes;
      final idFromBytes = ObjectId.fromBytes(bytes);

      expect(
        () => ObjectId.fromBytes([1, 2]),
        throwsA(TypeMatcher<ArgumentError>()),
      );
      expect(id.hexString, equals(idFromBytes.hexString));
      expect(id.bytes, equals(idFromBytes.bytes));
      expect(id.timestamp, equals(idFromBytes.timestamp));
      expect(id == idFromBytes, isTrue);
      expect(id.hashCode == idFromBytes.hashCode, isTrue);
    });

    test('fromHexString constructor works correctly', () async {
      final id = ObjectId();
      final hexString = id.hexString;
      final idFromHexString = ObjectId.fromHexString(hexString);

      expect(
        () => ObjectId.fromHexString("123456"),
        throwsA(TypeMatcher<ArgumentError>()),
      );
      expect(id.hexString, equals(idFromHexString.hexString));
      expect(id.bytes, equals(idFromHexString.bytes));
      expect(id.timestamp, equals(idFromHexString.timestamp));
      expect(id == idFromHexString, isTrue);
      expect(id.hashCode == idFromHexString.hashCode, isTrue);
    });

    test('fromTimestamp constructor works correctly', () async {
      final id = ObjectId();
      final idFromTimestamp = ObjectId.fromTimestamp(id.timestamp);

      /// timestamp is coppied correctly
      expect(idFromTimestamp.timestamp, equals(id.timestamp));
      expect(
        idFromTimestamp.bytes.sublist(0, 4),
        equals(id.bytes.sublist(0, 4)),
      );

      /// processunique and counter is zeroed out.
      expect(idFromTimestamp.bytes.sublist(4, id.bytes.length),
          equals(Uint8List(8)));

      /// ObjectIds are not equal
      expect(id == idFromTimestamp, isFalse);
      expect(id.hashCode, isNot(equals(idFromTimestamp.hashCode)));
      expect(id.bytes, isNot(equals(idFromTimestamp.bytes)));

      final timestamp = DateTime.fromMillisecondsSinceEpoch(1599244847958802);
      final timestampId = ObjectId.fromTimestamp(timestamp);

      /// Timestamp is accurate up to the second.
      expect(
        timestampId.timestamp.millisecondsSinceEpoch,
        equals(1517013846000),
      );
    });

    test('fromValues constructor works correctly', () async {
      final zeroedId = ObjectId.fromValues(0, 0, 0);

      expect(zeroedId.bytes, equals(Uint8List(12)));
      expect(zeroedId.hexString, equals('000000000000000000000000'));

      /// Only timestamp is filled
      final withTimestamp = ObjectId.fromValues(0x3e7fffffc18, 0, 0);
      expect(withTimestamp.hexString, equals('ffffffff0000000000000000'));
      expect(withTimestamp.bytes,
          equals([255, 255, 255, 255, 0, 0, 0, 0, 0, 0, 0, 0]));

      /// Only process unique is filled
      final withProcessUnique = ObjectId.fromValues(0, 0xffffffffff, 0);
      expect(withProcessUnique.hexString, equals('00000000ffffffffff000000'));
      expect(withProcessUnique.bytes,
          equals([0, 0, 0, 0, 255, 255, 255, 255, 255, 0, 0, 0]));

      /// Only conter is filled
      final withCounter = ObjectId.fromValues(0, 0, 0xffffff);
      expect(withCounter.hexString, equals('000000000000000000ffffff'));
      expect(withCounter.bytes,
          equals([0, 0, 0, 0, 0, 0, 0, 0, 0, 255, 255, 255]));
    });

    test('Two object ids generated one after other are not equal', () async {
      final id = ObjectId();
      final id2 = ObjectId();

      expect(id.hexString, isNot(equals(id2.hexString)));
      expect(id.bytes, isNot(equals(id2.bytes)));
      expect(id.timestamp, equals(id2.timestamp));
      expect(id == id2, isFalse);
      expect(id.hashCode == id2.hashCode, isFalse);
    });

    test('isValid method works correctly', () async {
      expect(ObjectId.isValid('5f527e9b350aa5f9709daf16'), isTrue);
      expect(ObjectId.isValid('000000000000000000000000'), isTrue);
      expect(ObjectId.isValid('ffffffffffffffffffffffff'), isTrue);
      expect(ObjectId.isValid('fffffffffffffffffffffff'), isFalse);
      expect(ObjectId.isValid('ffffffffffffffffffff%fff'), isFalse);
      expect(ObjectId.isValid('112123123123123123123.23'), isFalse);
      expect(ObjectId.isValid('gggggggggggggggggggggggg'), isFalse);
      expect(ObjectId.isValid(''), isFalse);
    });

    test('isValid accepts upper and mixed case hex strings', () {
      expect(ObjectId.isValid('5F527E9B350AA5F9709DAF16'), isTrue);
      expect(ObjectId.isValid('5f527E9b350aA5F9709dAf16'), isTrue);
    });

    test('isValid rejects signs and whitespace', () {
      expect(ObjectId.isValid('-0000000000000000000000a'), isFalse);
      expect(ObjectId.isValid('+0000000000000000000000a'), isFalse);
      expect(ObjectId.isValid('0000000-000000000+000000'), isFalse);
      expect(ObjectId.isValid(' 0000000000000000000000 '), isFalse);
      expect(ObjectId.isValid('00000000 000000000000000'), isFalse);
      expect(ObjectId.isValid('0x0000000000000000000000'), isFalse);
    });

    test('non-ASCII characters are rejected', () {
      final inputs = [
        '\u0130'.padRight(24, '0'),
        '\u0130'.padLeft(24, '0'),
        '0\u00e1\u00b0'.padLeft(24, '0'),
        '\uff10\uff11\uff12\uff13'.padRight(24, 'a'),
      ];
      for (final input in inputs) {
        expect(input.length, equals(24));
        expect(ObjectId.isValid(input), isFalse, reason: input);
        expect(
          () => ObjectId.fromHexString(input),
          throwsFormatException,
          reason: input,
        );
      }
    });

    test('hexString is correct for every byte value', () {
      for (var i = 0; i < 256; i++) {
        final bytes = List<int>.generate(12, (j) => (i + j * 23) & 0xff);
        final expected =
            bytes.map((b) => b.toRadixString(16).padLeft(2, '0')).join();

        expect(ObjectId.fromBytes(bytes).hexString, equals(expected));
        expect(
          ObjectId.fromBytes(Uint8List.fromList(bytes)).hexString,
          equals(expected),
        );
        expect(ObjectId.fromHexString(expected).bytes, equals(bytes));
        expect(
          ObjectId.fromHexString(expected.toUpperCase()).bytes,
          equals(bytes),
        );
      }
    });

    test('fromBytes copies provided bytes', () {
      final bytes = Uint8List.fromList(
        [95, 82, 205, 121, 180, 195, 28, 88, 32, 47, 183, 78],
      );
      final id = ObjectId.fromBytes(bytes);
      bytes[0] = 0;

      expect(id.bytes[0], equals(95));
      expect(() => ObjectId.fromBytes(Uint8List(11)), throwsArgumentError);
      expect(() => ObjectId.fromBytes(Uint8List(13)), throwsArgumentError);
    });

    test('isValid agrees with fromHexString', () {
      const inputs = [
        '5f527e9b350aa5f9709daf16',
        '5F527E9B350AA5F9709DAF16',
        '-0000000000000000000000a',
        ' 0000000000000000000000 ',
        'gggggggggggggggggggggggg',
        'fffffffffffffffffffffff',
      ];
      for (final input in inputs) {
        var parsed = true;
        try {
          ObjectId.fromHexString(input);
        } catch (_) {
          parsed = false;
        }
        expect(ObjectId.isValid(input), equals(parsed), reason: input);
      }
    });

    test('hexString is lowercase for upper case input', () {
      const upper = '5F527E9B350AA5F9709DAF16';
      const lower = '5f527e9b350aa5f9709daf16';

      final fromUpper = ObjectId.fromHexString(upper);
      final fromBytes = ObjectId.fromBytes(fromUpper.bytes);

      expect(fromUpper, equals(fromBytes));
      expect(fromUpper.hexString, equals(lower));
      expect(fromUpper.toString(), equals(lower));
      expect(fromUpper.toJson(), equals(lower));
      expect(fromUpper.hexString, equals(fromBytes.hexString));
      expect(ObjectId.fromHexString('5f527E9b350aA5F9709dAf16').hexString,
          equals(lower));
      expect(ObjectId.fromHexString(lower).hexString, equals(lower));
    });

    test('hashCode is well distributed for sequential ids', () {
      const count = 100000;
      final hashes = <int>{};
      for (var i = 0; i < count; i++) {
        hashes.add(
          ObjectId.fromValues(1700000000000, 0x1122334455, i).hashCode,
        );
      }

      expect(hashes.length, greaterThan(count - 100));
    });

    test('HashCode works correctly', () {
      var checksToBeDone = 1000;
      var id = ObjectId();
      var id2 = ObjectId();
      do {
        expect(id.hashCode, isNot(equals(id2.hashCode)));

        final idFromHexString = ObjectId.fromHexString(id.hexString);
        expect(idFromHexString.hashCode, equals(id.hashCode));
        expect(idFromHexString.hashCode, isNot(equals(id2.hashCode)));

        final idFromBytes = ObjectId.fromBytes(id2.bytes);
        expect(idFromBytes.hashCode, isNot(equals(id.hashCode)));
        expect(idFromBytes.hashCode, equals(id2.hashCode));

        final customId1 = TestObjectId.fromHexString(id.hexString);
        expect(customId1.hashCode, equals(id.hashCode));
        expect(customId1.hashCode, isNot(equals(id2.hashCode)));

        final customId2 = TestObjectId.fromHexString(id2.hexString);
        expect(customId2.hashCode, isNot(equals(id.hashCode)));
        expect(customId2.hashCode, equals(id2.hashCode));

        /// create new values
        id = ObjectId();
        id2 = ObjectId();
      } while (--checksToBeDone >= 0);
    });

    test('toString method works correctly', () {
      var id = ObjectId.fromHexString('5f52f0b42b5bb4c3adef2044');

      expect(id.toString(), equals('5f52f0b42b5bb4c3adef2044'));
    });

    test('toJson works correctly for a single element', () {
      final object = ObjectId();
      expect(object.toJson(), equals(object.hexString));
      expect(jsonEncode(object), equals('"${object.hexString}"'));
    });

    test('toJson works correctly for nested elements', () {
      final list = List.generate(10, (index) => ObjectId());
      expect(
        jsonEncode(list),
        equals("[${list.map((o) => '"${o.hexString}"').join(',')}]"),
      );
    });

    test('fromJson works correctly', () {
      final object = ObjectId();
      expect(ObjectId.fromJson(object.toJson()), equals(object));
    });
  });

  group('fromHexString rejects invalid hex characters', () {
    test('throws FormatException for non-hex characters', () {
      expect(
        () => ObjectId.fromHexString('zzzzzzzzzzzzzzzzzzzzzzzz'),
        throwsA(isA<FormatException>()),
      );
    });
  });

  group('fromHexString 32-bit bitwise boundary (web fix)', () {
    test('bytes correct when processUnique first byte has high bit set', () {
      expect(
        ObjectId.fromHexString('00000000ff00000000000000').bytes,
        equals([0, 0, 0, 0, 0xff, 0, 0, 0, 0, 0, 0, 0]),
      );
    });

    test('bytes correct when processUniqueB has 32-bit sign bit set', () {
      expect(
        ObjectId.fromHexString('000000000080000000000000').bytes,
        equals([0, 0, 0, 0, 0, 0x80, 0, 0, 0, 0, 0, 0]),
      );
    });

    test('bytes correct when all processUnique bytes are 0xff', () {
      expect(
        ObjectId.fromHexString('00000000ffffffffff000000').bytes,
        equals([0, 0, 0, 0, 0xff, 0xff, 0xff, 0xff, 0xff, 0, 0, 0]),
      );
    });
  });

  group('fromValues 32-bit bitwise boundary', () {
    test('bytes correct when processUnique top byte set (requires >>32)', () {
      expect(
        ObjectId.fromValues(0, 0xff00000000, 0).bytes,
        equals([0, 0, 0, 0, 0xff, 0, 0, 0, 0, 0, 0, 0]),
      );
    });

    test('round-trips through fromHexString for high processUnique', () {
      final id = ObjectId.fromValues(0, 0xff80ff80ff, 0);
      expect(
        ObjectId.fromHexString(id.hexString).bytes,
        equals(id.bytes),
      );
    });
  });
}
