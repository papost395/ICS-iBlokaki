import '../mat_protocol.dart';
import '../protocol/packet.dart';

/// Extension providing all ECR *information read* commands (commands that
/// return data but do not modify fiscal state).
extension InfoCommands on MatProtocol {
  // ── Identification & version ──────────────────────────────────────────────

  /// Read ECR identification string (Command 'a').
  Future<MatReplyPacket> readECRIdentification() =>
      _send('a');

  /// Read device software version info (Command 'v').
  Future<MatReplyPacket> readVersionInfo() =>
      _send('v');

  // ── PLU / Department / Category ──────────────────────────────────────────

  /// Read PLU data by PLU number/index (Command 'p').
  Future<MatReplyPacket> readPLUInfo(String pluNumber) =>
      _send('p', [pluNumber]);

  /// Read PLU data by barcode/code (Command 'h').
  Future<MatReplyPacket> readPLUInfoByCode(String code) =>
      _send('h', [code]);

  /// Read Department (DPT) info (Command 'd').
  Future<MatReplyPacket> readDPTInfo(int dptNumber) =>
      _send('d', [dptNumber.toString()]);

  /// Read Category info (Command 'Q').
  Future<MatReplyPacket> readCategory(int categoryIndex) =>
      _send('Q', [categoryIndex.toString()]);

  /// Read information for daily sold PLUs (Command 'k').
  Future<MatReplyPacket> readDailySoldPLU() =>
      _send('k');

  // ── Clerks ────────────────────────────────────────────────────────────────

  /// Read Clerk data (Command 'c').
  Future<MatReplyPacket> readClerkInfo(int clerkNumber) =>
      _send('c', [clerkNumber.toString()]);

  // ── Payment / VAT ─────────────────────────────────────────────────────────

  /// Read Payment type info (Command 'y').
  Future<MatReplyPacket> readPaymentInfo(int paymentCode) =>
      _send('y', [paymentCode.toString()]);

  /// Read VAT rates (Command 'e').
  Future<MatReplyPacket> readVATRates() =>
      _send('e');

  // ── Totals ────────────────────────────────────────────────────────────────

  /// Read transaction totals for the current day (Command '9').
  Future<MatReplyPacket> readTransactionTotals() =>
      _send('9');

  /// Read daily grand totals (Command '0').
  Future<MatReplyPacket> readDailyTotals() =>
      _send('0');

  // ── Parameters & configuration ────────────────────────────────────────────

  /// Read ECR configuration parameters (Command 's').
  Future<MatReplyPacket> readECRParameters() =>
      _send('s');

  /// Read Real-Time Clock value (Command 't').
  Future<MatReplyPacket> readRealTimeClock() =>
      _send('t');

  /// Read keyboard layout (Command 'B').
  Future<MatReplyPacket> readKeyboard(int keyboardType) =>
      _send('B', [keyboardType.toString()]);

  // ── Scrolling message ─────────────────────────────────────────────────────

  /// Read the programmed scrolling message (Command '^').
  Future<MatReplyPacket> readScrollingMessage() =>
      _send('^');

  // ── Fiscal file ───────────────────────────────────────────────────────────

  /// Read fiscal file information (Command 'g').
  Future<MatReplyPacket> readFiscalFileInfo() =>
      _send('g');

  /// Read fiscal file record (Command 'r').
  ///
  /// [fiscalFileType] – file type (see protocol docs).
  /// [record]         – 4-digit zero-padded record number.
  Future<MatReplyPacket> readFiscalRecord(int fiscalFileType, int record) =>
      _send('r', [fiscalFileType.toString(), record.toString().padLeft(4, '0')]);

  /// Read last fiscal data (Command 'i').
  Future<MatReplyPacket> readLastFiscalData() =>
      _send('i');

  // ── Customer / client ─────────────────────────────────────────────────────

  /// Read customer data from memory (Command '%').
  Future<MatReplyPacket> readCustomerData(String customerCode, int index) =>
      _send('%', [customerCode, index.toString()]);

  // ── General ───────────────────────────────────────────────────────────────

  /// General-purpose read (Command ',').
  Future<MatReplyPacket> generalRead(int type) =>
      _send(',', [type.toString()]);

  // ── Internal helper ───────────────────────────────────────────────────────

  Future<MatReplyPacket> _send(String code,
      [List<String> fields = const []]) async {
    final packet = MatPacket(requestCode: code, fields: fields);
    final reply = await sendRawCommand(packet);
    // Info commands always return the full reply — the caller decides whether
    // to inspect reply.isSuccess or reply.fields.
    return reply;
  }
}
