import 'dart:async';
import 'dart:collection';
import 'dart:typed_data';
import '../connection/tcp_connection.dart';
import '../encoding/mat_charset.dart';
import '../exceptions.dart';
import 'packet.dart';

/// Implements the MAT RS-232 / TCP protocol state machine:
///   Idle → ENQ → wait ACK → send STX…ETX → wait ACK →
///   wait STX reply → receive reply bytes → send ACK → parse reply → done.
class ProtocolHandler {
  final TcpConnection connection;

  /// The character encoding used for all packets on this connection.
  ///
  /// Must match the language configuration of the ECR.
  /// Defaults to [MatCharset.windows1253] (Greek fiscal ECR standard).
  final MatCharset charset;

  StreamSubscription<Uint8List>? _dataSub;

  // Buffer for incoming bytes to ensure none are lost between await calls.
  final Queue<int> _rxBuffer = Queue<int>();
  Completer<int>? _byteCompleter;

  ProtocolHandler(this.connection,
      {this.charset = MatCharset.windows1253}) {
    _dataSub = connection.onData.listen(
      (chunk) {
        for (final byte in chunk) {
          _rxBuffer.add(byte);
          if (_byteCompleter != null && !_byteCompleter!.isCompleted) {
            _byteCompleter!.complete(_rxBuffer.removeFirst());
            _byteCompleter = null;
          }
        }
      },
      onError: (Object err, StackTrace st) {
        if (_byteCompleter != null && !_byteCompleter!.isCompleted) {
          _byteCompleter!.completeError(err, st);
          _byteCompleter = null;
        }
      },
    );
  }

  void dispose() {
    _dataSub?.cancel();
    _dataSub = null;
    if (_byteCompleter != null && !_byteCompleter!.isCompleted) {
      _byteCompleter!.completeError(
          const MatConnectionException('ProtocolHandler disposed'));
      _byteCompleter = null;
    }
  }

  // ── Public API ────────────────────────────────────────────────────────────

  /// Executes the full send-receive handshake and returns the parsed reply.
  ///
  /// Retries up to [maxRetries] times on transient failures.
  /// Throws a [MatException] subclass on permanent failure.
  Future<MatReplyPacket> sendCommand(
    MatPacket packet, {
    int maxRetries = 3,
    Duration replyTimeout = const Duration(seconds: 10),
  }) async {
    if (!connection.isConnected) {
      throw const MatConnectionException(
          'Cannot send command: socket is not connected');
    }

    Object? lastError;

    for (int attempt = 1; attempt <= maxRetries; attempt++) {
      // MatConnectionException (e.g. socket closed mid-retry) propagates
      // immediately without being caught here — that is intentional.
      try {
        _flushRxBuffer(); // Clear any stale bytes from previous failures/noise

        // Send CAN on first attempt to clear ECR state if needed (optional sync step).
        if (attempt == 1) {
          connection.write([ProtocolConstants.can]);
          await Future<void>.delayed(const Duration(milliseconds: 100));
          _flushRxBuffer(); // Flush any response to CAN
        }

        await _enquire();
        await _transmitPacket(packet);
        final rawBytes = await _receivePacket(replyTimeout: replyTimeout);
        _sendAck(); // Fire-and-forget; ECR does not reply to our ACK.
        
        // Parse using fromBytes so the checksum is validated on raw bytes
        // (correct for Greek Windows-1253 encoding).
        return MatReplyPacket.fromBytes(rawBytes, charset: charset);
      } on MatTimeoutException catch (e) {
        lastError = e;
        if (attempt < maxRetries) {
          await Future<void>.delayed(const Duration(milliseconds: 800));
        }
      } on MatCommunicationException catch (e) {
        lastError = e;
        if (attempt < maxRetries) {
          await Future<void>.delayed(const Duration(milliseconds: 300));
        }
      } on MatPacketException catch (e) {
        // Bad checksum → send NAK so the ECR retransmits.
        _sendNak();
        lastError = e;
        if (attempt < maxRetries) {
          await Future<void>.delayed(const Duration(milliseconds: 300));
        }
      }
    }

    throw MatCommunicationException(
      'Command failed after $maxRetries attempt(s). Last error: $lastError',
    );
  }

  // ── Private handshake steps ───────────────────────────────────────────────

  void _flushRxBuffer() {
    _rxBuffer.clear();
  }

  Future<void> _enquire() async {
    connection.write([ProtocolConstants.enq]);
    
    // Hunt for ACK, respecting the hard deadline, ignoring stray bytes (like 0x30).
    final deadline = DateTime.now().add(const Duration(seconds: 2));
    
    while (true) {
      final remaining = deadline.difference(DateTime.now());
      if (remaining.isNegative || remaining == Duration.zero) {
        throw const MatTimeoutException('Timeout waiting for ACK after ENQ');
      }
      final byte = await _waitForByte(timeout: remaining, step: 'ENQ');
      
      if (byte == ProtocolConstants.ack) {
        return; // Success!
      } else if (byte == ProtocolConstants.nak) {
        throw const MatCommunicationException(
            'ECR returned NAK during ENQ phase — device may be busy');
      }
      // If we receive other bytes like 0x30, ignore them and keep waiting for ACK or NAK.
      // Some serial-to-ethernet converters inject status bytes.
    }
  }

  Future<void> _transmitPacket(MatPacket packet) async {
    // Encode packet using the handler's charset.
    connection.write(packet.toBytes(charset: charset));
    
    final deadline = DateTime.now().add(const Duration(seconds: 2));
    
    while (true) {
      final remaining = deadline.difference(DateTime.now());
      if (remaining.isNegative || remaining == Duration.zero) {
        throw const MatTimeoutException('Timeout waiting for ACK after packet TX');
      }
      final byte = await _waitForByte(timeout: remaining, step: 'TX');
      
      if (byte == ProtocolConstants.ack) {
        return; // Success!
      } else if (byte == ProtocolConstants.nak) {
        throw const MatCommunicationException(
            'ECR returned NAK after packet transmission — will retry');
      }
      // Ignore unexpected bytes
    }
  }

  /// Receives a reply packet, returning the **raw bytes** between STX and ETX.
  ///
  /// Returning raw bytes (not a decoded String) ensures that checksum
  /// validation in [MatReplyPacket.fromBytes] operates on the same bytes
  /// the ECR used when it calculated the checksum.
  Future<List<int>> _receivePacket({required Duration replyTimeout}) async {
    final deadline = DateTime.now().add(replyTimeout);

    // Hunt for STX, respecting the hard deadline.
    while (true) {
      final remaining = deadline.difference(DateTime.now());
      if (remaining.isNegative || remaining == Duration.zero) {
        throw MatTimeoutException(
          'Timeout waiting for STX from ECR (limit: ${replyTimeout.inMilliseconds}ms)',
        );
      }
      final byte = await _waitForByte(timeout: remaining, step: 'RX:STX');
      if (byte == ProtocolConstants.stx) break;
      // Ignore stray bytes before STX.
    }

    // Collect payload bytes until ETX (3-second per-byte timeout).
    final buffer = <int>[];
    while (true) {
      final byte = await _waitForByte(
        timeout: const Duration(seconds: 3),
        step: 'RX:payload',
      );
      if (byte == ProtocolConstants.etx) break;
      buffer.add(byte);
    }

    return buffer; // Raw bytes — NOT decoded to String.
  }

  void _sendAck() {
    try {
      connection.write([ProtocolConstants.ack]);
    } catch (_) {
      // Best-effort — do not throw if ACK fails to send.
    }
  }

  void _sendNak() {
    try {
      connection.write([ProtocolConstants.nak]);
    } catch (_) {
      // Best-effort.
    }
  }

  // ── Byte-level helpers ────────────────────────────────────────────────────

  Future<int> _waitForByte({
    required Duration timeout,
    required String step,
  }) async {
    if (_rxBuffer.isNotEmpty) {
      return _rxBuffer.removeFirst();
    }
    
    _byteCompleter = Completer<int>();
    try {
      return await _byteCompleter!.future.timeout(timeout);
    } on TimeoutException {
      _byteCompleter = null;
      throw MatTimeoutException(
          'Timeout waiting for ECR response (step: $step, limit: ${timeout.inMilliseconds}ms)');
    }
  }
}
