import '../mat_protocol.dart';
import '../exceptions.dart';
import '../protocol/packet.dart';

/// Extension providing all ECR *programming / setup* commands — commands that
/// configure PLUs, departments, VAT rates, receipt headers, etc.
extension SetupCommands on MatProtocol {
  // ── PLU programming ───────────────────────────────────────────────────────

  /// Program a PLU by index (Command 'P').
  Future<MatReplyPacket> programPLU(
    String pluIndex,
    String barcode,
    String description,
    int department,
    double price,
  ) async {
    final reply = await _send('P', [
      pluIndex,
      barcode,
      description,
      department.toString(),
      price.toStringAsFixed(2),
    ]);
    _assertSuccess(reply, 'P/programPLU');
    return reply;
  }

  /// Program a PLU by barcode (Command 'A').
  Future<MatReplyPacket> programPLUWithBarcode(
    String barcode,
    String description,
    int department,
    double price,
  ) async {
    final reply = await _send('A', [
      barcode,
      description,
      department.toString(),
      price.toStringAsFixed(2),
    ]);
    _assertSuccess(reply, 'A/programPLUWithBarcode');
    return reply;
  }

  // ── Department programming ────────────────────────────────────────────────

  /// Program a Department (Command 'D').
  Future<MatReplyPacket> programDPT(
    int index,
    String description,
    int vatRate,
  ) async {
    final reply = await _send('D', [
      index.toString(),
      description,
      vatRate.toString(),
    ]);
    _assertSuccess(reply, 'D/programDPT');
    return reply;
  }

  // ── VAT rates ─────────────────────────────────────────────────────────────

  /// Program all 5 VAT rates simultaneously (Command 'b').
  Future<MatReplyPacket> programVATRates(
    double vatA,
    double vatB,
    double vatC,
    double vatD,
    double vatE,
  ) async {
    final reply = await _send('b', [
      vatA.toStringAsFixed(2),
      vatB.toStringAsFixed(2),
      vatC.toStringAsFixed(2),
      vatD.toStringAsFixed(2),
      vatE.toStringAsFixed(2),
    ]);
    _assertSuccess(reply, 'b/programVATRates');
    return reply;
  }

  // ── Clerk programming ─────────────────────────────────────────────────────

  /// Program a Clerk / operator (Command 'C').
  Future<MatReplyPacket> programClerk(
    int index,
    String description,
    String password,
  ) async {
    final reply = await _send('C', [
      index.toString(),
      description,
      password,
    ]);
    _assertSuccess(reply, 'C/programClerk');
    return reply;
  }

  // ── Payment type programming ──────────────────────────────────────────────

  /// Program a Payment type label (Command 'Y').
  Future<MatReplyPacket> programPaymentType(int index, String description) async {
    final reply = await _send('Y', [index.toString(), description]);
    _assertSuccess(reply, 'Y/programPaymentType');
    return reply;
  }

  // ── ECR parameters ────────────────────────────────────────────────────────

  /// Program ECR global parameters (Command 'S').
  ///
  /// [parameters] must match the exact multi-field format described in the
  /// protocol specification.
  Future<MatReplyPacket> programECRParameters(String parameters) async {
    final reply = await _send('S', [parameters]);
    _assertSuccess(reply, 'S/programECRParameters');
    return reply;
  }

  // ── Receipt header / footer ───────────────────────────────────────────────

  /// Program the receipt header lines (Command 'H').
  ///
  /// [lines] – list of header text lines.
  Future<MatReplyPacket> programHeader(List<String> lines) async {
    if (lines.isEmpty) {
      throw const MatException('programHeader: at least one line is required');
    }
    final reply = await _send('H', lines);
    _assertSuccess(reply, 'H/programHeader');
    return reply;
  }

  /// Program the receipt footer lines (Command 'F').
  Future<MatReplyPacket> programFooter(List<String> lines) async {
    if (lines.isEmpty) {
      throw const MatException('programFooter: at least one line is required');
    }
    final reply = await _send('F', lines);
    _assertSuccess(reply, 'F/programFooter');
    return reply;
  }

  // ── Scrolling message ─────────────────────────────────────────────────────

  /// Program the LCD scrolling message (Command 'M').
  Future<MatReplyPacket> programScrollingMessage(
    String message,
    int showScrolling,
    int showDateTime,
    int delay,
  ) async {
    final reply = await _send('M', [
      message,
      showScrolling.toString(),
      showDateTime.toString(),
      delay.toString(),
    ]);
    _assertSuccess(reply, 'M/programScrollingMessage');
    return reply;
  }

  // ── Discount / markup ─────────────────────────────────────────────────────

  /// Program a pre-set discount or markup entry (Command 'u').
  Future<MatReplyPacket> programDiscountMarkup(
    int index,
    String description,
    int type,
    int isPercentage,
    int application,
  ) async {
    final reply = await _send('u', [
      index.toString(),
      description,
      type.toString(),
      isPercentage.toString(),
      application.toString(),
    ]);
    _assertSuccess(reply, 'u/programDiscountMarkup');
    return reply;
  }

  // ── Receipt comments ──────────────────────────────────────────────────────

  /// Set receipt comment text (Command 'j').
  Future<MatReplyPacket> setReceiptCommentText(
    List<String> comments,
    int commentType,
  ) async {
    final reply = await _send('j', [...comments, commentType.toString()]);
    _assertSuccess(reply, 'j/setReceiptCommentText');
    return reply;
  }

  /// Program start/end/in-receipt/cash-in-out comment lines (Command 'l').
  Future<MatReplyPacket> programReceiptComments(
    int type,
    int activeLines,
    List<String> lines,
  ) async {
    final reply = await _send('l', [
      type.toString(),
      activeLines.toString(),
      ...lines,
    ]);
    _assertSuccess(reply, 'l/programReceiptComments');
    return reply;
  }

  // ── Keyboard ──────────────────────────────────────────────────────────────

  /// Program a keyboard key shortcut (Command 'G').
  Future<MatReplyPacket> programKeyboard(
    int number,
    int level,
    int functionId,
  ) async {
    final reply = await _send('G', [
      number.toString(),
      level.toString(),
      functionId.toString(),
    ]);
    _assertSuccess(reply, 'G/programKeyboard');
    return reply;
  }

  // ── Bitmap ────────────────────────────────────────────────────────────────

  /// Upload one line of a bitmap graphic (Command '\$').
  Future<MatReplyPacket> programBitmap(
    int index,
    int width,
    int height,
    int lineIndex,
    String data,
  ) async {
    final reply = await _send(r'$', [
      index.toString(),
      width.toString(),
      height.toString(),
      lineIndex.toString(),
      data,
    ]);
    _assertSuccess(reply, r'$/programBitmap');
    return reply;
  }

  /// Program bitmap print position and quality (Command '~').
  Future<MatReplyPacket> programBmpPosition(
    int index,
    int position,
    int quality,
  ) async {
    final reply = await _send('~', [
      index.toString(),
      position.toString(),
      quality.toString(),
    ]);
    _assertSuccess(reply, '~/programBmpPosition');
    return reply;
  }

  // ── Category ──────────────────────────────────────────────────────────────

  /// Program a Category (Command 'R').
  Future<MatReplyPacket> programCategory(int index, String description) async {
    final reply = await _send('R', [index.toString(), description]);
    _assertSuccess(reply, 'R/programCategory');
    return reply;
  }

  // ── Client ────────────────────────────────────────────────────────────────

  /// Program a Client / customer record (Command '!').
  ///
  /// Note: the full protocol supports up to 28 fields. Pass extra fields via
  /// [extraFields] if needed.
  Future<MatReplyPacket> programClient(
    int index,
    String clientCode,
    String description, {
    List<String> extraFields = const [],
  }) async {
    final reply = await _send('!', [
      index.toString(),
      clientCode,
      description,
      ...extraFields,
    ]);
    _assertSuccess(reply, '!/programClient');
    return reply;
  }

  // ── Network / integration settings ───────────────────────────────────────

  /// Configure GSIS (ΑΑΔΕ) integration settings (Command ']').
  Future<MatReplyPacket> programGSISSettings(
    int enable,
    String serverUrl,
    int port,
    String aesKey,
  ) async {
    final reply = await _send(']', [
      enable.toString(),
      '0',
      '0',
      serverUrl,
      port.toString(),
      aesKey,
    ]);
    _assertSuccess(reply, ']/programGSISSettings');
    return reply;
  }

  /// Enable or disable the online-protocol mode (Command 'n').
  Future<MatReplyPacket> setOnlineProtocol(bool enable) async {
    final reply = await _send('n', [enable ? '1' : '0']);
    _assertSuccess(reply, 'n/setOnlineProtocol');
    return reply;
  }

  // ── Invoice parameters ────────────────────────────────────────────────────

  /// Get or set invoice parameters (Command ';').
  Future<MatReplyPacket> setGetInvoiceParameters(
    int operation,
    String row,
  ) async {
    final reply = await _send(';', [operation.toString(), row]);
    // operation 0 = read (no assertSuccess), operation 1 = write (assert).
    if (operation != 0) _assertSuccess(reply, ';/setGetInvoiceParameters');
    return reply;
  }

  // ── Tables ────────────────────────────────────────────────────────────────

  /// Get or set table configuration (Command '"').
  Future<MatReplyPacket> setGetTables(
    int operation,
    int index,
    int active,
  ) async {
    final reply = await _send('"', [
      operation.toString(),
      index.toString(),
      active.toString(),
    ]);
    if (operation != 0) _assertSuccess(reply, '"/setGetTables');
    return reply;
  }

  // ── General programming ───────────────────────────────────────────────────

  /// General-purpose programming command (Command '\').
  Future<MatReplyPacket> generalProgramming(
    int type,
    List<String> parameters,
  ) async {
    final reply = await _send(r'\', [type.toString(), ...parameters]);
    _assertSuccess(reply, r'\/generalProgramming');
    return reply;
  }

  // ── Internal helpers ──────────────────────────────────────────────────────

  Future<MatReplyPacket> _send(String code,
      [List<String> fields = const []]) async {
    final packet = MatPacket(requestCode: code, fields: fields);
    return sendRawCommand(packet);
  }

  void _assertSuccess(MatReplyPacket reply, String command) {
    if (!reply.isSuccess) {
      throw MatEcrErrorException(
        reply.replyDescription,
        errorCode: reply.replyCode,
        command: command,
      );
    }
  }
}
