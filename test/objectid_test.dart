import 'dart:typed_data';

import 'package:matcher/matcher.dart';
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

    test('HashCode works correctly', () {
      var checksToBeDone = 100;
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

        final customId = TestObjectId.fromHexString(id.hexString);
        expect(customId.hashCode, isNot(equals(id.hashCode)));
        expect(customId.hashCode, isNot(equals(id2.hashCode)));

        /// create new values
        id = ObjectId();
        id2 = ObjectId();
      } while (--checksToBeDone >= 0);
    });

    test('toString method works correctly', () {
      var id = ObjectId.fromHexString('5f52f0b42b5bb4c3adef2044');

      expect(id.toString(), equals('5f52f0b42b5bb4c3adef2044'));
    });
  });
}
