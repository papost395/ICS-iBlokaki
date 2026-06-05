import '../mat_protocol.dart';
import '../exceptions.dart';
import '../protocol/packet.dart';

/// Extension providing all ECR *fiscal transaction* commands — commands that
/// open, modify, or close fiscal receipts and reports.
extension FiscalCommands on MatProtocol {
  // ── Clerk / session ───────────────────────────────────────────────────────

  /// Set the active clerk before opening a receipt (Command '1').
  Future<MatReplyPacket> setActiveClerkCommand(int clerkNumber) =>
      _send('1', [clerkNumber.toString()]);

  /// Set / recall a client for an invoice receipt (Command '2').
  Future<MatReplyPacket> setClientName(String clientId) =>
      _send('2', [clientId]);

  // ── Item line operations ──────────────────────────────────────────────────

  /// Register one item line on the open receipt (Command '3').
  ///
  /// [operation]   – 'S'=Sale, 'R'=Return.
  /// [description] – item description (up to 32 chars).
  /// [quantity]    – quantity (e.g. 1.000).
  /// [price]       – unit price in euros.
  /// [department]  – department number (1-based).
  ///
  /// Returns the raw reply; throws [MatEcrErrorException] on ECR error.
  Future<MatReplyPacket> executeItemSale(
    String operation,
    String description,
    double quantity,
    double price,
    int department,
  ) async {
    final reply = await _send('3', [
      operation,
      description,
      '', // Extended description
      quantity.toStringAsFixed(3),
      price.toStringAsFixed(2),
      department.toString(),
    ]);
    _assertSuccess(reply, '3/executeItemSale');
    return reply;
  }

  /// Apply discount or markup on the last item or on the subtotal (Command '4').
  ///
  /// Returns the raw reply; throws [MatEcrErrorException] on ECR error.
  Future<MatReplyPacket> executeDiscountMarkup(
    double amount,
    String description,
    int operationCode,
    int operationMode,
    int specifier,
  ) async {
    final reply = await _send('4', [
      amount.toStringAsFixed(2),
      description,
      operationCode.toString(),
      operationMode.toString(),
      specifier.toString(),
    ]);
    _assertSuccess(reply, '4/executeDiscountMarkup');
    return reply;
  }

  // ── Payment ───────────────────────────────────────────────────────────────

  /// Execute a payment tender on the open receipt (Command '5').
  ///
  /// [type]        – payment type code (1=Cash, 2=Card, etc.).
  /// [amount]      – tendered amount.
  /// [description] – optional description.
  /// [shorthand]   – optional short label (e.g. "VISA").
  ///
  /// Returns the raw reply (contains change amount in fields[0] if applicable).
  /// Throws [MatEcrErrorException] on ECR error.
  Future<MatReplyPacket> executePayment(
    int type,
    double amount,
    String description,
    String shorthand,
  ) async {
    final reply = await _send('5', [
      type.toString(),
      amount.toStringAsFixed(2),
      description,
      '',
      shorthand,
    ]);
    _assertSuccess(reply, '5/executePayment');
    return reply;
  }

  // ── Receipt control ───────────────────────────────────────────────────────

  /// Open a cash-in or cash-out transaction (Command '6').
  Future<MatReplyPacket> openCashInOut(int type, int prepaymentType) async {
    final reply = await _send('6', [type.toString(), prepaymentType.toString()]);
    _assertSuccess(reply, '6/openCashInOut');
    return reply;
  }

  /// Cancel (void) the currently open receipt (Command '+').
  Future<MatReplyPacket> cancelReceipt() async {
    final reply = await _send('+');
    _assertSuccess(reply, '+/cancelReceipt');
    return reply;
  }

  /// Calculate and display the running subtotal (Command 'U').
  Future<MatReplyPacket> calculateSubtotal() =>
      _send('U'); // Returns subtotal — no assertSuccess needed.

  // ── Reports ───────────────────────────────────────────────────────────────

  /// Issue a fiscal report (Command 'x').
  ///
  /// Common [type] values:
  /// - 1 = X-report (read totals without resetting)
  /// - 7 = Z-report (daily closure with reset)
  ///
  /// Returns the raw reply; throws [MatEcrErrorException] on ECR error.
  Future<MatReplyPacket> executeIssueReport(int type) async {
    final reply = await _send('x', [type.toString()]);
    _assertSuccess(reply, 'x/executeIssueReport');
    return reply;
  }

  /// Clear / reset statistic counters (Command '8').
  Future<MatReplyPacket> clearStatistics(int fileNo, int type) async {
    final reply = await _send('8', [fileNo.toString(), type.toString()]);
    _assertSuccess(reply, '8/clearStatistics');
    return reply;
  }

  /// Print a report from the SD journal (Command '@').
  Future<MatReplyPacket> printSDReport(
      int startReceipt, int endReceipt, int output) async {
    final reply = await _send('@',
        [startReceipt.toString(), endReceipt.toString(), output.toString()]);
    _assertSuccess(reply, '@/printSDReport');
    return reply;
  }

  // ── Peripheral control ────────────────────────────────────────────────────

  /// Open the cash drawer (Command 'q').
  Future<MatReplyPacket> openDrawerCommand() async {
    final reply = await _send('q');
    _assertSuccess(reply, 'q/openDrawerCommand');
    return reply;
  }

  /// Feed paper by [lines] lines (Command 'w').
  Future<MatReplyPacket> printerFeed(int lines) async {
    final reply = await _send('w', ['1', lines.toString()]);
    _assertSuccess(reply, 'w/printerFeed');
    return reply;
  }

  /// Disable LCD display output — useful during heavy fiscal printing (Command 'W').
  Future<MatReplyPacket> disableLCD() =>
      _send('W'); // Best-effort; ignore ECR error.

  // ── Printing ──────────────────────────────────────────────────────────────

  /// Print a non-fiscal sales ticket (Command 'm').
  Future<MatReplyPacket> printSalesTicket(double price, String description) async {
    final reply = await _send('m', [price.toStringAsFixed(2), description]);
    _assertSuccess(reply, 'm/printSalesTicket');
    return reply;
  }

  /// Print a graphical barcode on the receipt (Command '[').
  Future<MatReplyPacket> printGraphicalBarcode(
    int height,
    int width,
    int position,
    int code,
    int length,
    String data,
  ) async {
    final reply = await _send('[', [
      height.toString(),
      width.toString(),
      position.toString(),
      code.toString(),
      length.toString(),
      data,
    ]);
    _assertSuccess(reply, '[/printGraphicalBarcode');
    return reply;
  }

  /// Display a scrolling message on the ECR LCD (Command 'o').
  Future<MatReplyPacket> displayScrollMessage(String message) =>
      _send('o', [message]); // Best-effort.

  // ── Coupons & special items ───────────────────────────────────────────────

  /// Register a coupon sale (Command 'Z').
  Future<MatReplyPacket> saleOfCoupon(
    int numberOfCoupons,
    double amount,
    String description,
    String barcode,
  ) async {
    final reply = await _send('Z', [
      numberOfCoupons.toString(),
      amount.toStringAsFixed(2),
      description,
      barcode,
    ]);
    _assertSuccess(reply, 'Z/saleOfCoupon');
    return reply;
  }

  /// Program a ticket product (Command '*').
  Future<MatReplyPacket> programTicketCommand(
    int index,
    String description,
    double amount,
    int active,
  ) async {
    final reply = await _send('*', [
      index.toString(),
      description,
      amount.toStringAsFixed(2),
      active.toString(),
    ]);
    _assertSuccess(reply, '*/programTicketCommand');
    return reply;
  }

  // ── Table management ──────────────────────────────────────────────────────

  /// Open, close, return, transfer, or report on a table (Command '&').
  Future<MatReplyPacket> tableCommand(int type, int tableIndex) async {
    final reply = await _send('&', [type.toString(), tableIndex.toString()]);
    _assertSuccess(reply, '&/tableCommand');
    return reply;
  }

  // ── Internal helper ───────────────────────────────────────────────────────

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
