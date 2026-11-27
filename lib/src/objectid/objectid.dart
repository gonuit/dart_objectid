import 'dart:math' as math;
import 'dart:typed_data';

import '../hash/murmur_hash_2.dart';
import '../platform/is_js.dart';
import '../process_unique/process_unique.dart';

const _hexDigits = '0123456789abcdef';

const _invalidHex = 0x80;

const _upperHex = 0x40;

/// Maps ASCII code units to 4-bit hex values.
/// Upper case digits are flagged with [_upperHex].
final Uint8List _hexTable = () {
  final table = Uint8List(128)..fillRange(0, 128, _invalidHex);
  for (var i = 0; i < 10; i++) {
    table[0x30 + i] = i;
  }
  for (var i = 0; i < 6; i++) {
    table[0x61 + i] = 10 + i;
    table[0x41 + i] = (10 + i) | _upperHex;
  }
  return table;
}();

/// Hex strings of all byte values. Used on JavaScript only.
final List<String> _byteHex = List<String>.generate(
  256,
  (i) => _hexDigits[i >> 4] + _hexDigits[i & 0xf],
  growable: false,
);

extension on int {
  /// Converts integer to 5 bytes Uint8List.
  @pragma('vm:prefer-inline')
  Uint8List toProcessUniqueBytes() {
    return Uint8List(ProcessUnique.size)
      ..[0] = (this ~/ 0x100000000) & 0xff
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
  /// ObjectId counter cannot be larger than 3 bytes.
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

    final table = _hexTable;
    final bytes = _bytes;

    var codes = 0;
    var flags = 0;
    for (var i = 0; i < byteLength; i++) {
      final o = i * 2;
      final highCode = hexString.codeUnitAt(o);
      final lowCode = hexString.codeUnitAt(o + 1);
      final high = table[highCode & 0x7f];
      final low = table[lowCode & 0x7f];
      codes |= highCode | lowCode;
      flags |= high | low;
      bytes[i] = ((high & 0xf) << 4) | (low & 0xf);
    }

    if (codes > 0x7f || (flags & _invalidHex) != 0) {
      throw _invalidHexCharacter(hexString);
    }

    // hexString is always lowercase.
    if ((flags & _upperHex) == 0) _hexString = hexString;
  }

  @pragma('vm:prefer-inline')
  static bool _isHexCode(int code) =>
      code <= 0x7f && _hexTable[code] != _invalidHex;

  static FormatException _invalidHexCharacter(String hexString) {
    for (var i = 0; i < hexString.length; i++) {
      final code = hexString.codeUnitAt(i);
      if (!_isHexCode(code)) {
        return FormatException(
          'Invalid hex character',
          String.fromCharCode(code),
        );
      }
    }
    return FormatException('Invalid hex string', hexString);
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
    int millisecondsSinceEpoch,
    Uint8List processUnique,
    int counter,
  ) {
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

    if (!isJs && bytes is Uint8List) {
      _bytes.setRange(0, byteLength, bytes);
    } else {
      for (var i = 0; i < byteLength; i++) {
        _bytes[i] = bytes[i];
      }
    }
  }

  DateTime? _timestamp;

  /// Returns the generation date (accurate up to the second) that this
  /// ObjectId was generated.
  DateTime get timestamp {
    if (_timestamp != null) return _timestamp!;

    final secondsSinceEpoch = _bytes[0] * 0x1000000 +
        ((_bytes[1] << 16) | (_bytes[2] << 8) | _bytes[3]);

    return _timestamp = DateTime.fromMillisecondsSinceEpoch(
      secondsSinceEpoch * 1000,
    );
  }

  String? _hexString;

  /// Returns hex string for current [ObjectId].
  String get hexString {
    return _hexString ??= _createHexString();
  }

  String _createHexString() {
    final bytes = _bytes;
    if (isJs) {
      final t = _byteHex;
      return t[bytes[0]] +
          t[bytes[1]] +
          t[bytes[2]] +
          t[bytes[3]] +
          t[bytes[4]] +
          t[bytes[5]] +
          t[bytes[6]] +
          t[bytes[7]] +
          t[bytes[8]] +
          t[bytes[9]] +
          t[bytes[10]] +
          t[bytes[11]];
    }
    final codes = Uint8List(hexStringLength);
    for (var i = 0; i < byteLength; i++) {
      final byte = bytes[i];
      final o = i * 2;
      codes[o] = _hexDigits.codeUnitAt(byte >> 4);
      codes[o + 1] = _hexDigits.codeUnitAt(byte & 0xf);
    }
    return String.fromCharCodes(codes);
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
    if (hexString.length != hexStringLength) return false;

    final table = _hexTable;
    var codes = 0;
    var flags = 0;
    for (var i = 0; i < hexStringLength; i++) {
      final code = hexString.codeUnitAt(i);
      codes |= code;
      flags |= table[code & 0x7f];
    }
    return codes <= 0x7f && (flags & _invalidHex) == 0;
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
