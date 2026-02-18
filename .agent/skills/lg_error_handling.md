---
name: LG Error Handling
description: Robust error handling, retry logic, and user feedback patterns
---

# Error Handling & Retry Logic

## Exception Hierarchy

```
LGException (base)
├── LGNotConnectedException — no SSH connection
├── LGSSHException — SSH command/auth/socket failure
├── LGTimeoutException — operation timed out
└── LGKMLException — KML generation/parsing error
```

## Pattern: Safe Action Wrapper

```dart
Future<void> _runAction(String id, Future<void> Function() action) async {
  if (!lgService.isConnected) {
    _showError('Not connected to Liquid Galaxy.');
    return;
  }

  setState(() => _loading = true);
  try {
    await action();
    _showSuccess('Done!');
  } on LGNotConnectedException {
    _showError('Connection lost. Please reconnect.');
  } on LGSSHException catch (e) {
    _showError('SSH Error: ${e.message}');
  } on LGTimeoutException {
    _showError('Operation timed out. Check your connection.');
  } on LGException catch (e) {
    _showError(e.message);
  } catch (e) {
    _showError('Unexpected error: $e');
  } finally {
    setState(() => _loading = false);
  }
}
```

## Pattern: Retry with Backoff

```dart
Future<T> retryWithBackoff<T>(
  Future<T> Function() action, {
  int maxRetries = 3,
}) async {
  for (int attempt = 1; attempt <= maxRetries; attempt++) {
    try {
      return await action();
    } catch (e) {
      if (attempt == maxRetries) rethrow;
      await Future.delayed(Duration(seconds: attempt * 2));
    }
  }
  throw const LGException('Max retries exceeded');
}
```

## Connection Recovery

```dart
try {
  await lgService.navigateTo(lat, lng);
} on LGNotConnectedException {
  // Attempt reconnection
  final reconnected = await lgService.connectAndVerify(host, port, user, pass);
  if (reconnected) {
    await lgService.navigateTo(lat, lng); // retry
  } else {
    _showError('Could not reconnect.');
  }
}
```

## DO

- Always catch `LGException` subtypes
- Show user-friendly error messages
- Use loading states during async operations
- Log errors for debugging

## DON'T

- Don't catch and ignore errors silently
- Don't let exceptions crash the app
- Don't show raw exception messages to users
- Don't retry indefinitely — use max attempts
