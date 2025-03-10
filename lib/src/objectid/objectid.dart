import 'dart:math' as math;
import 'dart:typed_data';

import '../hash/murmur_hash_2.dart';
import '../process_unique/process_unique.dart';

extension on int {
  /// Converts integer to 5 bytes Uint8List.
  @pragma('vm:prefer-inline')
  Uint8List toProcessUniqueBytes() {
    return Uint8List(ProcessUnique.size)
      ..[0] = (this >> 32) & 0xff
      ..[1] = (this >> 24) & 0xff
      ..[2] = (this >> 16) & 0xff
      ..[3] = (this >> 8) & 0xff
      ..[4] = this & 0xff;
  }
}

/// ## ObjectId
/// This class allows you to create and manipulate bson ObjectIds.
///
/// Example:
/// ```dart
/// final id = ObjectId();
/// final id2 = ObjectId.fromHexString('5f527e9b350aa5f9709daf16');
/// final id3 = ObjectId.fromBytes(
///   [95, 82, 126, 187, 124, 177, 57, 83, 165, 119, 211, 48],
/// );
/// final id4 = ObjectId.fromValues(timestamp, processUnique, counter);
/// ```
class ObjectId {
  static const _maxCounterValue = 0xffffff;
  static const _counterMask = _maxCounterValue + 1;

  /// Length of the [ObjectId] in bytes.
  static const byteLength = 12;

  /// Length of the ObjectId [hexString].
  static const hexStringLength = byteLength * 2;

  /// 5 bytes of process and timestamp specific random number.
  static final Uint8List _processUnique = ProcessUnique().getValue();

  /// ObjectId counter that will be used for ObjectId generation.
  ///
  /// Initialized with random value.
  static int _counter = math.Random().nextInt(_counterMask);

  /// Get ObjectId counter by incrementing current counter value by 1.
  /// ObjectId counter cannot be larger than 3 bits.
  static int _getCounter() => (_counter = (_counter + 1) % _counterMask);

  final Uint8List _bytes = Uint8List(byteLength);

  /// ObjectId bytes.
  Uint8List get bytes => _bytes;

  /// Creates ObjectId instance.
  ///
  /// {@template objectid.structure}
  /// ObjectId structure:
  /// ```
  ///   4 byte timestamp    5 byte process unique   3 byte counter
  /// |<----------------->|<---------------------->|<------------>|
  /// |----|----|----|----|----|----|----|----|----|----|----|----|
  /// 0                   4                   8                   12
  /// ```
  /// {@endtemplate}
  ///
  ObjectId() {
    _initialize(
      DateTime.now().millisecondsSinceEpoch,
      _processUnique,
      _getCounter(),
    );
  }

  /// Creates ObjectId from provided values.
  ///
  /// {@macro objectid.structure}
  ObjectId.fromValues(
    int millisecondsSinceEpoch,
    int processUnique,
    int counter,
  ) {
    _initialize(
      millisecondsSinceEpoch,
      processUnique.toProcessUniqueBytes(),
      counter,
    );
  }

  /// Creates ObjectId from provided timestamp.
  ///
  /// Only timestamp segment is set while the rest of the ObjectId is
  /// zeroed out.
  ///
  /// Example:
  /// ```
  /// final id = ObjectId.fromTimestamp(DateTime.now());
  /// ```
  /// {@macro objectid.structure}
  ObjectId.fromTimestamp(DateTime timestamp) {
    ArgumentError.checkNotNull(timestamp, 'timestamp');

    final secondsSinceEpoch = timestamp.millisecondsSinceEpoch ~/ 1000;

    // 4-byte timestamp
    _bytes
      ..[3] = secondsSinceEpoch & 0xff
      ..[2] = (secondsSinceEpoch >> 8) & 0xff
      ..[1] = (secondsSinceEpoch >> 16) & 0xff
      ..[0] = (secondsSinceEpoch >> 24) & 0xff;
  }

  /// Creates ObjectId from hex string.
  ///
  /// Can be helpful for mapping hex strings returned from
  /// API / MongoDB to ObjectId instances.
  ///
  /// Example usage:
  /// ```dart
  /// final id = ObjectId();
  /// final id2 = ObjectId.fromHexString(id.hexString);
  /// print(id == id2) // => true
  /// ```
  /// {@macro objectid.structure}
  ObjectId.fromHexString(String hexString) {
    if (hexString.length != hexStringLength) {
      throw ArgumentError.value(
        hexString,
        'hexString',
        'ObjectId hexString must be exactly $hexStringLength characters long.',
      );
    }

    final secondsSinceEpoch = int.parse(hexString.substring(0, 8), radix: 16);
    final millisecondsSinceEpoch = secondsSinceEpoch * 1000;

    final processUnique = int.parse(hexString.substring(8, 18), radix: 16);
    final counter = int.parse(hexString.substring(18, 24), radix: 16);

    /// cache this value
    _hexString = hexString;

    _initialize(
      millisecondsSinceEpoch,
      processUnique.toProcessUniqueBytes(),
      counter,
    );
  }

  /// Creates ObjectId from a JSON string.
  ///
  /// This is a factory constructor that maps JSON data
  /// to an ObjectId instance.
  ///
  /// Example usage:
  /// ```dart
  /// final jsonString = '{"_id": "507f1f77bcf86cd799439011"}';
  /// final json = jsonDecode(jsonString);
  /// final ObjectId objectId = ObjectId.fromJson(json['_id']);
  /// print(objectId.hexString); // Output: 507f1f77bcf86cd799439011
  /// ```
  ///
  /// **Note:** This method is functionally equivalent to
  /// [ObjectId.fromHexString]. It serves as an alias to clearly indicate
  /// the intention to deserialize from a JSON value.
  factory ObjectId.fromJson(String json) = ObjectId.fromHexString;

  /// Internally initialize ObjectId instance by filling
  /// bytes array with provided data.
  @pragma('vm:prefer-inline')
  void _initialize(
      int millisecondsSinceEpoch, Uint8List processUnique, int counter) {
    final secondsSinceEpoch = millisecondsSinceEpoch ~/ 1000;

    // 4-byte timestamp
    _bytes
      ..[3] = secondsSinceEpoch & 0xff
      ..[2] = (secondsSinceEpoch >> 8) & 0xff
      ..[1] = (secondsSinceEpoch >> 16) & 0xff
      ..[0] = (secondsSinceEpoch >> 24) & 0xff;

    // 5-byte process unique
    _bytes
      ..[4] = processUnique[0]
      ..[5] = processUnique[1]
      ..[6] = processUnique[2]
      ..[7] = processUnique[3]
      ..[8] = processUnique[4];

    // 3-byte counter
    _bytes
      ..[11] = counter & 0xff
      ..[10] = (counter >> 8) & 0xff
      ..[9] = (counter >> 16) & 0xff;
  }

  /// ### Creates ObjectId from bytes.
  /// Example usage:
  /// ```dart
  /// final id = ObjectId();
  /// final id2 = ObjectId.fromBytes(id.bytes);
  /// print(id == id2) // => true
  /// ```
  ///
  /// {@macro objectid.structure}
  ObjectId.fromBytes(List<int> bytes) {
    ArgumentError.checkNotNull(bytes, 'bytes');
    if (bytes.length != byteLength) {
      throw ArgumentError.value(
        bytes,
        'bytes',
        'Expected $byteLength bytes but got ${bytes.length}.',
      );
    }

    for (var i = 0; i < byteLength; i++) {
      _bytes[i] = bytes[i];
    }
  }

  DateTime? _timestamp;

  /// Returns the generation date (accurate up to the second) that this
  /// ObjectId was generated.
  DateTime get timestamp {
    if (_timestamp != null) return _timestamp!;

    var secondsSinceEpoch = 0;
    for (var x = 3, y = 0; x >= 0; x--, y++) {
      secondsSinceEpoch += _bytes[x] * math.pow(256, y).toInt();
    }

    return _timestamp = DateTime.fromMillisecondsSinceEpoch(
      secondsSinceEpoch * 1000,
    );
  }

  String? _hexString;

  /// Returns hex string for current [ObjectId].
  String get hexString {
    if (_hexString == null) {
      final buffer = StringBuffer();
      for (var i = 0; i < _bytes.length; i++) {
        buffer.write(_bytes[i].toRadixString(16).padLeft(2, '0'));
      }
      _hexString = buffer.toString();
    }

    return _hexString!;
  }

  @override
  bool operator ==(Object other) {
    if (other is! ObjectId) return false;
    for (var i = 0; i < _bytes.length; i++) {
      if (other._bytes[i] != _bytes[i]) return false;
    }
    return true;
  }

  /// Whether hexString is a valid ObjectId
  static bool isValid(String hexString) {
    try {
      if (hexString.length != 24) return false;

      int.parse(hexString.substring(0, 8), radix: 16);
      int.parse(hexString.substring(8, 18), radix: 16);
      int.parse(hexString.substring(18, 24), radix: 16);
    } on FormatException {
      return false;
    }
    return true;
  }

  /// Caches [hashCode].
  /// Prevents multiple calculations of the same value.
  int? _hashCode;
  @override
  int get hashCode => _hashCode ??= murmurHash2(bytes);

  dynamic toJson() => hexString;

  @override
  String toString() => hexString;
}
