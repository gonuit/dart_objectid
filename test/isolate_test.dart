// ignore: library_annotations
@TestOn('vm')

import 'dart:async';
import 'dart:isolate';

import 'package:objectid/objectid.dart';
import 'package:test/test.dart';

void createObjectId(SendPort sendPort) {
  final id = ObjectId();
  sendPort.send(id);
}

void main() {
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
