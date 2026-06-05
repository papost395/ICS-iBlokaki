import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import '../exceptions.dart';

class TcpConnection {
  final String host;
  final int port;
  final Duration connectTimeout;

  Socket? _socket;
  StreamSubscription<Uint8List>? _subscription;

  // Single broadcast stream that all listeners share.
  final _dataController = StreamController<Uint8List>.broadcast();

  TcpConnection({
    required this.host,
    required this.port,
    this.connectTimeout = const Duration(seconds: 5),
  });

  Stream<Uint8List> get onData => _dataController.stream;

  bool get isConnected => _socket != null;

  Future<void> connect() async {
    if (isConnected) return;
    try {
      _socket = await Socket.connect(host, port, timeout: connectTimeout);
      _subscription = _socket!.listen(
        (data) {
          if (!_dataController.isClosed) {
            _dataController.add(data);
          }
        },
        onError: (Object error, StackTrace stack) {
          if (!_dataController.isClosed) {
            _dataController.addError(
              MatConnectionException('Socket error: $error'),
              stack,
            );
          }
          _cleanup();
        },
        onDone: () {
          // Remote side closed the connection.
          if (!_dataController.isClosed) {
            _dataController.addError(
              const MatConnectionException('Connection closed by remote host'),
            );
          }
          _cleanup();
        },
        cancelOnError: false,
      );
    } on SocketException catch (e) {
      _socket = null;
      throw MatConnectionException(
        'Failed to connect to $host:$port — ${e.message}',
      );
    } catch (e) {
      _socket = null;
      throw MatConnectionException('Unexpected error while connecting: $e');
    }
  }

  /// Writes raw bytes to the socket.
  /// Throws [MatConnectionException] if the socket is not connected.
  void write(List<int> data) {
    if (!isConnected) {
      throw const MatConnectionException('Cannot write: socket is not connected');
    }
    try {
      _socket!.add(data);
    } on SocketException catch (e) {
      throw MatConnectionException('Write failed: ${e.message}');
    }
  }

  Future<void> disconnect() async {
    await _cleanup();
  }

  Future<void> _cleanup() async {
    await _subscription?.cancel();
    _subscription = null;
    try {
      await _socket?.close();
    } catch (_) {
      // Ignore errors while closing.
    }
    _socket = null;
  }

  /// Disposes the connection and closes the data stream permanently.
  /// Do NOT use the [TcpConnection] after calling [dispose].
  Future<void> dispose() async {
    await _cleanup();
    if (!_dataController.isClosed) {
      await _dataController.close();
    }
  }
}
