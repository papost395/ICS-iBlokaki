/// Custom exception hierarchy for the matcashmachine package.
library;

/// Base exception class for all MAT protocol errors.
class MatException implements Exception {
  final String message;
  final String? command;

  const MatException(this.message, {this.command});

  @override
  String toString() =>
      command != null ? 'MatException [$command]: $message' : 'MatException: $message';
}

/// Thrown when a TCP connection cannot be established or is lost.
class MatConnectionException extends MatException {
  const MatConnectionException(super.message, {super.command});

  @override
  String toString() => command != null
      ? 'MatConnectionException [$command]: $message'
      : 'MatConnectionException: $message';
}

/// Thrown when the ECR does not acknowledge a transmission (NAK received or timeout).
class MatCommunicationException extends MatException {
  const MatCommunicationException(super.message, {super.command});

  @override
  String toString() => command != null
      ? 'MatCommunicationException [$command]: $message'
      : 'MatCommunicationException: $message';
}

/// Thrown when the ECR replies with a non-success error code.
class MatEcrErrorException extends MatException {
  /// The 2-digit error code returned by the ECR.
  final String errorCode;

  const MatEcrErrorException(super.message, {required this.errorCode, super.command});

  @override
  String toString() => command != null
      ? 'MatEcrErrorException [$command] (code=$errorCode): $message'
      : 'MatEcrErrorException (code=$errorCode): $message';
}

/// Thrown when a reply packet cannot be parsed (bad format or checksum mismatch).
class MatPacketException extends MatException {
  const MatPacketException(super.message, {super.command});

  @override
  String toString() => command != null
      ? 'MatPacketException [$command]: $message'
      : 'MatPacketException: $message';
}

/// Thrown when a command times out waiting for a response from the ECR.
class MatTimeoutException extends MatException {
  const MatTimeoutException(super.message, {super.command});

  @override
  String toString() => command != null
      ? 'MatTimeoutException [$command]: $message'
      : 'MatTimeoutException: $message';
}
