---
name: LG Connection Workflow
description: How to connect, disconnect, and test SSH to the Liquid Galaxy rig
---

# LG Connection Workflow

## Overview

SSH is the only transport to the Liquid Galaxy rig. All KML, query, and control commands flow through it.

## Steps to Connect

### 1. Read Settings

```dart
final prefs = await SharedPreferences.getInstance();
final host = prefs.getString('lg_host') ?? LGConstants.defaultHost;
final port = prefs.getInt('lg_port') ?? LGConstants.defaultPort;
final username = prefs.getString('lg_username') ?? LGConstants.defaultUsername;
final password = prefs.getString('lg_password') ?? LGConstants.defaultPassword;
```

### 2. Connect & Verify

```dart
final lgService = LGService.instance;
try {
  final success = await lgService.connectAndVerify(host, port, username, password);
  if (success) {
    // Connected and verified
  } else {
    // Verification failed
  }
} on LGSSHException catch (e) {
  // Handle connection errors
}
```

### 3. Disconnect

```dart
await lgService.disconnect();
```

## Connection Guard

Every method in `SSHService` checks `_guardConnection()` before executing. If not connected, it throws `LGNotConnectedException`.

## Error Scenarios

| Error                     | Cause                           | Recovery                      |
| ------------------------- | ------------------------------- | ----------------------------- |
| `LGSSHException`          | Wrong IP, port, or credentials  | Check settings, re-enter      |
| `LGTimeoutException`      | Rig unreachable                 | Check network, VM running     |
| `LGNotConnectedException` | Called method before connecting | Call `connectAndVerify` first |

## DO

- Always call `connectAndVerify` (not raw `connect`) — it includes healthcheck
- Show connection status via `ConnectionIndicator` widget
- Persist settings in `SharedPreferences`

## DON'T

- Don't hardcode credentials in source code for production
- Don't leave connections open indefinitely without keepalive
- Don't ignore `LGSSHException` — always show user feedback
