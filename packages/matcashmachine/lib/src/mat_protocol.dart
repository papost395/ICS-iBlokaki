import 'models/status.dart';
import 'connection/tcp_connection.dart';
import 'encoding/mat_charset.dart';
import 'exceptions.dart';
import 'protocol/packet.dart';
import 'protocol/protocol_handler.dart';

/// Main entry point for communicating with a MAT fiscal ECR / POS device.
///
/// ## Quick start
/// ```dart
/// final mat = MatProtocol(
///   host: '192.168.1.100',
///   port: 9100,
///   // charset defaults to MatCharset.windows1253 (Greek) — no need to set it.
/// );
/// await mat.connect();
///
/// // Πώληση στα ελληνικά
/// await mat.itemSale(2.50, description: 'ΚΑΦΕΣ ESPRESSO', department: 1);
/// await mat.sendPayment(2.50, paymentCode: 1); // 1 = Μετρητά
///
/// await mat.disconnect();
/// await mat.dispose();
/// ```
class MatProtocol {
  final String host;
  final int port;

  /// The character encoding used when serialising text fields for the ECR.
  ///
  /// Defaults to [MatCharset.windows1253] — the standard Greek fiscal ECR
  /// encoding (MIRKA III / INFOCARINA i57 III). Change to [MatCharset.ascii]
  /// only if your device is configured for a non-Greek locale.
  final MatCharset charset;

  late final TcpConnection _connection;
  late final ProtocolHandler _handler;

  MatProtocol({
    required this.host,
    required this.port,
    this.charset = MatCharset.windows1253,
  }) {
    _connection = TcpConnection(host: host, port: port);
    _handler = ProtocolHandler(_connection, charset: charset);
  }

  // ── Connection lifecycle ──────────────────────────────────────────────────

  /// Opens the TCP connection to the ECR.
  ///
  /// Throws [MatConnectionException] if the connection cannot be established.
  Future<void> connect() => _connection.connect();

  /// Closes the TCP connection gracefully.
  Future<void> disconnect() => _connection.disconnect();

  /// Releases all resources. Call [disconnect] first, then [dispose].
  ///
  /// This method is async — always `await` it.
  Future<void> dispose() async {
    _handler.dispose();
    await _connection.dispose();
  }

  // ── Status ────────────────────────────────────────────────────────────────

  /// Reads the current device and fiscal status from the ECR (Command '?').
  Future<MatStatus> getStatus() async {
    final reply = await sendRawCommand(MatPacket(requestCode: '?'));
    return MatStatus.fromString(reply.status);
  }

  // ── Convenience methods ───────────────────────────────────────────────────

  /// Registers a payment on the open receipt (Command '5').
  ///
  /// [amount]       – ποσό πληρωμής σε ευρώ (π.χ. 2.50).
  /// [paymentCode]  – 1=Μετρητά, 2=Κάρτα, 3=Επιταγή, 4=Πίστωση,
  ///                  5=Συνάλλαγμα, 6=Κουπόνι, 7=Προπληρωμή. Προεπιλογή: 1.
  /// [description]  – προαιρετική επιπλέον περιγραφή στην απόδειξη.
  ///
  /// Throws [MatEcrErrorException] if the ECR returns an error code.
  Future<bool> sendPayment(
    double amount, {
    String description = '',
    int paymentCode = 1,
  }) async {
    final reply = await sendRawCommand(MatPacket(
      requestCode: '5',
      fields: [
        paymentCode.toString(),
        amount.toStringAsFixed(2),
        description,
        '', // N.A.
        '', // Extended description 2
        '', // EFTPOS number
        '', // EFTPOS transaction type
      ],
    ));
    _assertSuccess(reply, command: '5/sendPayment');
    return true;
  }

  /// Sells an item on the open receipt (Command '3').
  ///
  /// [price]       – τιμή μονάδας σε ευρώ.
  /// [description] – περιγραφή είδους — **μπορείς να γράψεις ελληνικά!**
  /// [department]  – αριθμός τμήματος (1-based).
  ///
  /// Throws [MatEcrErrorException] if the ECR returns an error code.
  Future<bool> itemSale(
    double price, {
    String description = '',
    int department = 1,
  }) async {
    final reply = await sendRawCommand(MatPacket(
      requestCode: '3',
      fields: [
        'S', // Operation: S = Sale
        description,
        '', // Extended description
        '1', // Quantity
        price.toStringAsFixed(2),
        department.toString(),
      ],
    ));
    _assertSuccess(reply, command: '3/itemSale');
    return true;
  }

  /// Issues a Z-closure report (Command 'x', type 7).
  ///
  /// Throws [MatEcrErrorException] if the ECR returns an error code.
  Future<bool> issueZReport() async {
    final reply = await sendRawCommand(MatPacket(
      requestCode: 'x',
      fields: ['7'],
    ));
    _assertSuccess(reply, command: 'x/issueZReport');
    return true;
  }

  // ── Raw command access ────────────────────────────────────────────────────

  /// Sends any [MatPacket] and returns the raw [MatReplyPacket].
  ///
  /// The packet is encoded using [charset] (set in the constructor).
  /// Throws a [MatException] subclass on failure.
  Future<MatReplyPacket> sendRawCommand(
    MatPacket packet, {
    int maxRetries = 3,
    Duration replyTimeout = const Duration(seconds: 10),
  }) {
    return _handler.sendCommand(
      packet,
      maxRetries: maxRetries,
      replyTimeout: replyTimeout,
    );
  }

  // ── Helpers ───────────────────────────────────────────────────────────────

  void _assertSuccess(MatReplyPacket reply, {required String command}) {
    if (!reply.isSuccess) {
      throw MatEcrErrorException(
        reply.replyDescription,
        errorCode: reply.replyCode,
        command: command,
      );
    }
  }
}
