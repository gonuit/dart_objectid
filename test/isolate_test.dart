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

String createProcessUnique() => ObjectId().hexString.substring(8, 18);

void sendProcessUnique(SendPort sendPort) {
  sendPort.send(createProcessUnique());
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

  test(
      'Ensure that isolates spawned at the same time do not share '
      'the "random number unique to a machine and process".', () async {
    const isolates = 16;
    final receivePort = ReceivePort();
    await Future.wait([
      for (var i = 0; i < isolates; i++)
        Isolate.spawn(sendProcessUnique, receivePort.sendPort),
    ]);
    final values = await receivePort.take(isolates).cast<String>().toList();

    expect(
      {...values, createProcessUnique()},
      hasLength(isolates + 1),
    );
  });
}
