import 'dart:convert';
import 'dart:typed_data';
import '../encoding/mat_charset.dart';
import '../exceptions.dart';

/// Control byte constants used by the MAT communication protocol.
class ProtocolConstants {
  static const int stx = 0x02; // Start of Text
  static const int etx = 0x03; // End of Text
  static const int enq = 0x05; // Enquiry
  static const int ack = 0x06; // Acknowledge
  static const int nak = 0x15; // Not Acknowledge
  static const int can = 0x18; // Cancel
  static const int separator = 0x2F; // '/'
}

/// Builds a request packet to be sent to the ECR.
///
/// Wire format: STX [requestCode] '/' [field1] '/' … [checksum2] ETX
///
/// The checksum is calculated on the encoded **bytes** of the payload,
/// not on the Unicode string — this ensures Greek characters produce the
/// correct checksum on the ECR side.
class MatPacket {
  final String requestCode;
  final List<String> fields;

  MatPacket({
    required this.requestCode,
    this.fields = const [],
  });

  // ── Checksum ───────────────────────────────────────────────────────────────

  /// Calculates the MAT checksum over a list of **encoded bytes**:
  /// `sum(bytes) % 100`, zero-padded to 2 ASCII characters.
  ///
  /// This is the canonical checksum method. For ASCII-only payloads the byte
  /// values equal the Unicode code points, so results are identical to the
  /// legacy string-based approach.
  static String calculateChecksumFromBytes(List<int> bytes) {
    int sum = 0;
    for (final b in bytes) {
      sum += b;
    }
    return (sum % 100).toString().padLeft(2, '0');
  }

  /// Legacy helper — calculates checksum over the **Unicode code units** of
  /// [payload].
  ///
  /// ⚠ Only correct for pure ASCII payloads. For Greek text use
  /// [calculateChecksumFromBytes] on the Windows-1253-encoded bytes.
  static String calculateChecksum(String payload) {
    int sum = 0;
    for (final cu in payload.codeUnits) {
      sum += cu;
    }
    return (sum % 100).toString().padLeft(2, '0');
  }

  // ── Serialisation ──────────────────────────────────────────────────────────

  /// Serialises the packet to bytes ready for TCP transmission.
  ///
  /// [charset] controls how text fields are encoded into bytes.
  /// Defaults to [MatCharset.windows1253] (Greek ECR standard).
  ///
  /// Throws [MatPacketException] if any field contains a character that cannot
  /// be represented in the chosen [charset].
  Uint8List toBytes({MatCharset charset = MatCharset.windows1253}) {
    final buffer = StringBuffer()
      ..write(requestCode)
      ..write('/');

    for (final field in fields) {
      buffer
        ..write(field)
        ..write('/');
    }

    final payloadString = buffer.toString();

    // Encode payload string → bytes using the specified charset.
    final List<int> payloadBytes;
    try {
      payloadBytes = encodeString(payloadString, charset);
    } on MatPacketException {
      rethrow;
    }

    // Checksum is calculated over the encoded bytes.
    final checksum = calculateChecksumFromBytes(payloadBytes);
    // Checksum is always 2 ASCII digits — safe to encode as ASCII.
    final checksumBytes = ascii.encode(checksum);

    final builder = BytesBuilder()
      ..addByte(ProtocolConstants.stx)
      ..add(payloadBytes)
      ..add(checksumBytes)
      ..addByte(ProtocolConstants.etx);

    return builder.toBytes();
  }
}

/// Represents a parsed reply packet received from the ECR.
class MatReplyPacket {
  /// 2-digit reply code. `'00'` means success; anything else is an error.
  final String replyCode;

  /// Raw 4-character hex status string (DeviceStatus byte + FiscalStatus byte).
  final String status;

  /// Optional data fields returned after the status.
  final List<String> fields;

  /// The 2-character checksum string as received from the ECR.
  final String checksum;

  const MatReplyPacket({
    required this.replyCode,
    required this.status,
    required this.fields,
    required this.checksum,
  });

  // ── Accessors ──────────────────────────────────────────────────────────────

  /// Returns `true` when the ECR acknowledged the command successfully.
  bool get isSuccess => replyCode == '00';

  /// Human-readable description for [replyCode].
  String get replyDescription =>
      _replyDescriptions[replyCode] ?? 'Unknown error (code $replyCode)';

  static const Map<String, String> _replyDescriptions = {
    '00': 'Επιτυχία',
    '01': 'Άγνωστη εντολή',
    '02': 'Η εντολή δεν επιτρέπεται σε αυτή την κατάσταση',
    '03': 'Ελλιπής εντολή / παράμετρος λείπει',
    '04': 'Απαιτείται ανοιχτή ημέρα',
    '05': 'Απαιτείται κλειστή ημέρα',
    '06': 'Απαιτείται ανοιχτή απόδειξη',
    '07': 'Απαιτείται κλειστή απόδειξη',
    '08': 'Μνήμη γεμάτη',
    '09': 'Δεν υπάρχουν δεδομένα',
    '10': 'Μη επιτρεπτό σε τιμολόγιο',
    '11': 'Άκυρο τμήμα (DPT)',
    '12': 'Άκυρος τρόπος πληρωμής',
    '13': 'Άκυρος ΦΠΑ',
    '14': 'Δεν βρέθηκε χειριστής',
    '15': 'Δεν βρέθηκε PLU',
    '16': 'Σφάλμα φορολογικής μνήμης',
    '17': 'Σφάλμα εκτυπωτή',
    '18': 'Το σύνολο απόδειξης δεν μπορεί να είναι αρνητικό',
    '19': 'Η απόδειξη βρίσκεται ήδη σε φάση πληρωμής',
    '20': 'Το ποσό πληρωμής υπερβαίνει το σύνολο',
  };

  // ── Parsing ────────────────────────────────────────────────────────────────

  /// Parses raw bytes (between STX and ETX) into a [MatReplyPacket].
  ///
  /// The checksum is validated against the **encoded bytes** — this is the
  /// correct approach for Greek ECRs that use Windows-1253.
  ///
  /// [charset] must match the encoding configured on the ECR (default:
  /// [MatCharset.windows1253]).
  ///
  /// Throws [MatPacketException] on short data or checksum mismatch.
  static MatReplyPacket fromBytes(
    List<int> rawBytes, {
    MatCharset charset = MatCharset.windows1253,
  }) {
    if (rawBytes.length < 4) {
      throw MatPacketException(
          'Reply too short (${rawBytes.length} bytes)');
    }

    // Last 2 bytes are the checksum (always ASCII digits).
    final payloadBytes = rawBytes.sublist(0, rawBytes.length - 2);
    final receivedChecksum =
        String.fromCharCodes(rawBytes.sublist(rawBytes.length - 2));
    final expectedChecksum = MatPacket.calculateChecksumFromBytes(payloadBytes);

    if (receivedChecksum != expectedChecksum) {
      throw MatPacketException(
        'Checksum mismatch — expected $expectedChecksum, got $receivedChecksum',
      );
    }

    // Decode the payload bytes to a String using the specified charset.
    final payload = decodeBytes(payloadBytes, charset);
    return _parsePayload(payload, receivedChecksum);
  }

  /// Parses a pre-decoded ASCII [String] into a [MatReplyPacket].
  ///
  /// ⚠ Only correct for pure ASCII replies. For Greek-capable ECRs prefer
  /// [fromBytes] which validates the checksum on raw bytes.
  static MatReplyPacket fromString(String data) {
    if (data.length < 4) {
      throw MatPacketException(
          'Reply too short (${data.length} chars): "$data"');
    }

    final payload = data.substring(0, data.length - 2);
    final receivedChecksum = data.substring(data.length - 2);
    final expectedChecksum = MatPacket.calculateChecksum(payload);

    if (receivedChecksum != expectedChecksum) {
      throw MatPacketException(
        'Checksum mismatch — expected $expectedChecksum, got $receivedChecksum',
      );
    }

    return _parsePayload(payload, receivedChecksum);
  }

  /// Shared payload → MatReplyPacket logic.
  static MatReplyPacket _parsePayload(String payload, String checksum) {
    final parts = payload.split('/');
    if (parts.isNotEmpty && parts.last.isEmpty) {
      parts.removeLast();
    }

    if (parts.length < 2) {
      throw MatPacketException(
          'Invalid reply format — expected replyCode/status, got: "$payload"');
    }

    return MatReplyPacket(
      replyCode: parts[0],
      status: parts[1],
      fields: parts.length > 2
          ? List<String>.unmodifiable(parts.sublist(2))
          : const <String>[],
      checksum: checksum,
    );
  }

  @override
  String toString() =>
      'MatReplyPacket(code=$replyCode, status=$status, fields=$fields)';
}
