// Copyright 2024 LG-Flutter-StarterKit Authors
// Licensed under the Apache License, Version 2.0
// See LICENSE file for details.

/// Base exception for all Liquid Galaxy errors.
class LGException implements Exception {
  final String message;
  final dynamic originalError;

  const LGException(this.message, [this.originalError]);

  @override
  String toString() => 'LGException: $message';
}

/// Thrown when an operation requires an active SSH connection
/// but none is established.
class LGNotConnectedException extends LGException {
  const LGNotConnectedException([
    String message = 'Not connected to Liquid Galaxy rig.',
  ]) : super(message);

  @override
  String toString() => 'LGNotConnectedException: $message';
}

/// Thrown when an SSH operation fails (auth, socket, command).
class LGSSHException extends LGException {
  const LGSSHException(super.message, [super.originalError]);

  @override
  String toString() => 'LGSSHException: $message';
}

/// Thrown when a connection or command times out.
class LGTimeoutException extends LGException {
  const LGTimeoutException([
    String message = 'Operation timed out.',
  ]) : super(message);

  @override
  String toString() => 'LGTimeoutException: $message';
}

/// Thrown when KML generation or parsing fails.
class LGKMLException extends LGException {
  const LGKMLException(super.message, [super.originalError]);

  @override
  String toString() => 'LGKMLException: $message';
}
