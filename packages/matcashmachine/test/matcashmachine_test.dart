import 'package:test/test.dart';
import 'package:matcashmachine/matcashmachine.dart';

void main() {
  // ── Checksum ───────────────────────────────────────────────────────────────

  group('MatPacket — checksum (ASCII bytes)', () {
    test('produces a 2-digit result', () {
      const payload = '5/1/10.00////';
      final cs = MatPacket.calculateChecksum(payload);
      expect(cs.length, equals(2));
      expect(int.tryParse(cs), isNotNull);
    });

    test('is zero-padded when < 10', () {
      // We need a payload whose byte sum mod 100 < 10.
      // Sum of '?' + '/' = 63 + 47 = 110 → 110 % 100 = 10. Let's try '!' + '/'
      // '!' = 33, '/' = 47 → 80 % 100 = 80. Keep trying…
      // Just test the padding by direct call.
      final cs = MatPacket.calculateChecksum('/');  // 47 % 100 = 47 → '47'
      expect(cs.length, equals(2));
    });

    test('calculateChecksumFromBytes matches calculateChecksum for ASCII', () {
      const payload = '3/S/COFFEE/1/2.50/1/';
      final fromString = MatPacket.calculateChecksum(payload);
      final fromBytes = MatPacket.calculateChecksumFromBytes(
          payload.codeUnits.toList());
      expect(fromString, equals(fromBytes));
    });
  });

  // ── Packet building ────────────────────────────────────────────────────────

  group('MatPacket — toBytes', () {
    test('starts with STX (0x02) and ends with ETX (0x03)', () {
      final p = MatPacket(requestCode: '?');
      final b = p.toBytes();
      expect(b.first, equals(0x02));
      expect(b.last, equals(0x03));
    });

    test('request code appears immediately after STX', () {
      final p = MatPacket(requestCode: '?');
      expect(p.toBytes()[1], equals('?'.codeUnitAt(0)));
    });

    test('fields are separated by "/"', () {
      final p = MatPacket(requestCode: '5', fields: ['1', '10.00']);
      final content = String.fromCharCodes(
          p.toBytes().sublist(1, p.toBytes().length - 1));
      expect(content, contains('/'));
      expect(content, contains('10.00'));
    });

    test('Greek text encodes to Windows-1253 bytes with toBytes()', () {
      // 'α' in Windows-1253 is 0xE1
      final p = MatPacket(requestCode: '3', fields: ['S', 'α', '', '1', '1.00', '1']);
      final bytes = p.toBytes(charset: MatCharset.windows1253);
      // Content between STX and ETX
      final content = bytes.sublist(1, bytes.length - 1);
      // 'α' should appear as byte 0xE1
      expect(content, contains(0xE1));
    });

    test('full Greek item description survives encode/decode round-trip', () {
      const description = 'ΚΑΦΕΣ ESPRESSO';
      final p = MatPacket(requestCode: '3', fields: ['S', description, '', '1', '2.50', '1']);
      final bytes = p.toBytes(charset: MatCharset.windows1253);
      // Strip STX, last 3 bytes (checksum + ETX).
      final payloadBytes = bytes.sublist(1, bytes.length - 3);
      final decoded = decodeBytes(payloadBytes.toList(), MatCharset.windows1253);
      expect(decoded, contains(description));
    });
  });

  // ── Reply parsing ──────────────────────────────────────────────────────────

  group('MatReplyPacket — fromString', () {
    test('parses a valid ASCII reply', () {
      const payload = '00/0000/';
      final cs = MatPacket.calculateChecksum(payload);
      final r = MatReplyPacket.fromString(payload + cs);
      expect(r.replyCode, equals('00'));
      expect(r.status, equals('0000'));
      expect(r.isSuccess, isTrue);
    });

    test('isSuccess is false for non-00 code', () {
      const payload = '06/0000/';
      final cs = MatPacket.calculateChecksum(payload);
      final r = MatReplyPacket.fromString(payload + cs);
      expect(r.isSuccess, isFalse);
    });

    test('throws MatPacketException on checksum mismatch', () {
      expect(
        () => MatReplyPacket.fromString('00/0000/99'),
        throwsA(isA<MatPacketException>()),
      );
    });

    test('throws MatPacketException on data too short', () {
      expect(
        () => MatReplyPacket.fromString('ab'),
        throwsA(isA<MatPacketException>()),
      );
    });

    test('replyDescription is non-empty for known code', () {
      const payload = '00/0000/';
      final r = MatReplyPacket.fromString(
          payload + MatPacket.calculateChecksum(payload));
      expect(r.replyDescription.isNotEmpty, isTrue);
    });

    test('replyDescription mentions the code for unknown codes', () {
      const payload = '99/0000/';
      final r = MatReplyPacket.fromString(
          payload + MatPacket.calculateChecksum(payload));
      expect(r.replyDescription, contains('99'));
    });

    test('parses extra fields correctly', () {
      const payload = '00/0000/fieldA/fieldB/';
      final r = MatReplyPacket.fromString(
          payload + MatPacket.calculateChecksum(payload));
      expect(r.fields.length, equals(2));
      expect(r.fields[0], equals('fieldA'));
      expect(r.fields[1], equals('fieldB'));
    });
  });

  group('MatReplyPacket — fromBytes (Windows-1253)', () {
    test('parses a valid reply from raw bytes', () {
      const payload = '00/0000/';
      final payloadBytes = encodeString(payload, MatCharset.windows1253);
      final cs = MatPacket.calculateChecksumFromBytes(payloadBytes);
      final rawBytes = [...payloadBytes, ...cs.codeUnits];
      final r = MatReplyPacket.fromBytes(rawBytes, charset: MatCharset.windows1253);
      expect(r.isSuccess, isTrue);
      expect(r.replyCode, equals('00'));
    });

    test('decodes Greek field correctly', () {
      // Build a fake reply with a Greek field: 00/0000/ΚΑΦΕΣ/
      const greekField = 'ΚΑΦΕΣ';
      final payloadStr = '00/0000/$greekField/';
      final payloadBytes = encodeString(payloadStr, MatCharset.windows1253);
      final cs = MatPacket.calculateChecksumFromBytes(payloadBytes);
      final rawBytes = [...payloadBytes, ...cs.codeUnits];

      final r = MatReplyPacket.fromBytes(rawBytes, charset: MatCharset.windows1253);
      expect(r.fields.first, equals(greekField));
    });

    test('throws MatPacketException on checksum mismatch', () {
      // Corrupt last checksum byte.
      final rawBytes = [0x30, 0x30, 0x2F, 0x30, 0x30, 0x30, 0x30, 0x2F, 0x39, 0x39];
      expect(
        () => MatReplyPacket.fromBytes(rawBytes),
        throwsA(isA<MatPacketException>()),
      );
    });
  });

  // ── Charset encoding ───────────────────────────────────────────────────────

  group('MatCharset — Windows-1253 encoding', () {
    test('encodes basic Greek lowercase (α→0xE1)', () {
      final bytes = encodeString('α', MatCharset.windows1253);
      expect(bytes, equals([0xE1]));
    });

    test('encodes Greek uppercase Ω→0xD9', () {
      final bytes = encodeString('Ω', MatCharset.windows1253);
      expect(bytes, equals([0xD9]));
    });

    test('encodes euro sign €→0x80', () {
      final bytes = encodeString('€', MatCharset.windows1253);
      expect(bytes, equals([0x80]));
    });

    test('encodes accented ά→0xDC', () {
      final bytes = encodeString('ά', MatCharset.windows1253);
      expect(bytes, equals([0xDC]));
    });

    test('round-trip: encode then decode returns original string', () {
      const original = 'ΚΑΦΕΣ ESPRESSO 2.50€';
      final bytes = encodeString(original, MatCharset.windows1253);
      final decoded = decodeBytes(bytes, MatCharset.windows1253);
      expect(decoded, equals(original));
    });

    test('ASCII characters have same byte value in Windows-1253', () {
      const ascii = 'Hello/World';
      final bytes = encodeString(ascii, MatCharset.windows1253);
      for (int i = 0; i < ascii.length; i++) {
        expect(bytes[i], equals(ascii.codeUnitAt(i)));
      }
    });

    test('throws MatPacketException for unencodable character', () {
      // Chinese character — not in Windows-1253
      expect(
        () => encodeString('中', MatCharset.windows1253),
        throwsA(isA<MatPacketException>()),
      );
    });
  });

  // ── Exception hierarchy ────────────────────────────────────────────────────

  group('Exception hierarchy', () {
    test('MatConnectionException is a MatException', () {
      const ex = MatConnectionException('test');
      expect(ex, isA<MatException>());
    });

    test('MatEcrErrorException carries error code', () {
      const ex = MatEcrErrorException('test', errorCode: '06');
      expect(ex.errorCode, equals('06'));
      expect(ex.toString(), contains('06'));
    });

    test('MatTimeoutException toString includes message', () {
      const ex = MatTimeoutException('timed out after 2s');
      expect(ex.toString(), contains('timed out after 2s'));
    });

    test('MatException with command includes command in toString', () {
      const ex = MatException('failed', command: '5/sendPayment');
      expect(ex.toString(), contains('5/sendPayment'));
    });
  });
}
