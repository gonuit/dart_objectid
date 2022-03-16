import 'dart:async';
import 'dart:isolate';
import 'dart:typed_data';

import 'package:objectid/objectid.dart';
import 'package:test/test.dart';

void createObjectId(SendPort sendPort) {
  final id = ObjectId();
  sendPort.send(id);
}

void main() {
  group(
      'Ensure that the Timestamp field is represented as an unsigned '
      '32-bit representing the number of seconds since the Epoch for '
      'the Timestamp values', () {
    test('0x00000000: To match "Jan 1st, 1970 00:00:00 UTC".', () {
      final id = ObjectId.fromHexString('000000000000000000000000');
      expect(id.timestamp.toUtc().year, equals(1970));
      expect(id.timestamp.toUtc().month, equals(1));
      expect(id.timestamp.toUtc().day, equals(1));
      expect(id.timestamp.toUtc().hour, equals(0));
      expect(id.timestamp.toUtc().minute, equals(0));
      expect(id.timestamp.toUtc().second, equals(0));

      /// unnecessary
      expect(id.timestamp.toUtc().millisecond, equals(0));
      expect(id.timestamp.toUtc().microsecond, equals(0));
    });

    test('0x7FFFFFFF: To match "Jan 19th, 2038 03:14:07 UTC".', () {
      final id = ObjectId.fromHexString('7FFFFFFF0000000000000000');
      expect(id.timestamp.toUtc().year, equals(2038));
      expect(id.timestamp.toUtc().month, equals(1));
      expect(id.timestamp.toUtc().day, equals(19));
      expect(id.timestamp.toUtc().hour, equals(3));
      expect(id.timestamp.toUtc().minute, equals(14));
      expect(id.timestamp.toUtc().second, equals(7));

      /// unnecessary
      expect(id.timestamp.toUtc().millisecond, equals(0));
      expect(id.timestamp.toUtc().microsecond, equals(0));
    });

    test('0x80000000: To match "Jan 19th, 2038 03:14:08 UTC".', () {
      final id = ObjectId.fromHexString('800000000000000000000000');
      expect(id.timestamp.toUtc().year, equals(2038));
      expect(id.timestamp.toUtc().month, equals(1));
      expect(id.timestamp.toUtc().day, equals(19));
      expect(id.timestamp.toUtc().hour, equals(3));
      expect(id.timestamp.toUtc().minute, equals(14));
      expect(id.timestamp.toUtc().second, equals(8));

      /// unnecessary
      expect(id.timestamp.toUtc().millisecond, equals(0));
      expect(id.timestamp.toUtc().microsecond, equals(0));
    });

    test('0xFFFFFFFF: To match "Feb 7th, 2106 06:28:15 UTC".', () {
      final id = ObjectId.fromHexString('FFFFFFFF0000000000000000');
      expect(id.timestamp.toUtc().year, equals(2106));
      expect(id.timestamp.toUtc().month, equals(2));
      expect(id.timestamp.toUtc().day, equals(7));
      expect(id.timestamp.toUtc().hour, equals(6));
      expect(id.timestamp.toUtc().minute, equals(28));
      expect(id.timestamp.toUtc().second, equals(15));

      /// unnecessary
      expect(id.timestamp.toUtc().millisecond, equals(0));
      expect(id.timestamp.toUtc().microsecond, equals(0));
    });
  });

  test(
      'Ensure that the Counter field successfully overflows '
      'its sequence from 0xFFFFFF to 0x000000', () {
    var id = ObjectId();

    var attempt = 0;
    while (!id.bytes.sublist(9, 12).every((element) => element == 255)) {
      id = ObjectId();

      /// prevent infinit loop
      if (++attempt > 0xffffff + 1) {
        break;
      }
    }

    expect(id.bytes.sublist(9, 12), equals(Uint8List(3)..fillRange(0, 3, 255)));
    expect(ObjectId().bytes.sublist(9, 12),
        equals(Uint8List(3)..fillRange(0, 3, 0)));
  });

  test(
      'Ensure that after a new process is created through a fork() '
      'or similar process creation operation, the "random number '
      'unique to a machine and process" is no longer the same as the '
      'parent process that created the new process.', () async {
    final id = ObjectId();
    var receivePort = ReceivePort();

    final isolate = await Isolate.spawn(createObjectId, receivePort.sendPort);
    final completer = Completer<ObjectId>();
    receivePort.listen((data) {
      completer.complete(data as ObjectId);
    });
    final idFromIsolate = await completer.future;
    isolate.kill();

    /// Make sure that ObjectId processUnique is different in isolates.
    expect(id.bytes.sublist(4, 9),
        isNot(equals(idFromIsolate.bytes.sublist(4, 9))));
  });
}
