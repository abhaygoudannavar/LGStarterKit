// Copyright 2024 LG-Flutter-StarterKit Authors
// Licensed under the Apache License, Version 2.0
// See LICENSE file for details.

import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:dartssh2/dartssh2.dart';

import '../core/constants/lg_constants.dart';
import '../core/errors/lg_exceptions.dart';

/// Singleton SSH wrapper for communicating with the Liquid Galaxy master rig.
///
/// Usage:
/// ```dart
/// final ssh = SSHService.instance;
/// await ssh.connect('192.168.56.101', 22, 'lg', 'lg');
/// await ssh.execute('echo "Hello LG"');
/// await ssh.disconnect();
/// ```
class SSHService {
  SSHService._();

  static final SSHService instance = SSHService._();

  SSHClient? _client;
  bool _connected = false;

  /// Whether an active SSH connection exists.
  bool get isConnected => _connected;

  // ─── Connection Methods ────────────────────────────────────────────

  /// Establishes an SSH connection to the Liquid Galaxy master node.
  ///
  /// Returns `true` on success, `false` on failure.
  Future<bool> connect(
    String host,
    int port,
    String username,
    String password,
  ) async {
    try {
      // Close any existing connection first
      await disconnect();

      final socket = await SSHSocket.connect(
        host,
        port,
        timeout: LGConstants.connectionTimeout,
      );

      _client = SSHClient(
        socket,
        username: username,
        onPasswordRequest: () => password,
      );

      // Wait for authentication to complete
      await _client!.authenticated;

      _connected = true;
      return true;
    } on SocketException catch (e) {
      _connected = false;
      throw LGSSHException(
        'Failed to connect: ${e.message}',
        e,
      );
    } on SSHAuthFailError catch (e) {
      _connected = false;
      throw LGSSHException(
        'Authentication failed for $username@$host',
        e,
      );
    } catch (e) {
      _connected = false;
      throw LGSSHException('Connection error: $e', e);
    }
  }

  /// Gracefully closes the SSH connection.
  Future<void> disconnect() async {
    try {
      _client?.close();
    } catch (_) {
      // Ignore errors during disconnect
    } finally {
      _client = null;
      _connected = false;
    }
  }

  // ─── Command Execution ─────────────────────────────────────────────

  /// Executes a shell command on the remote rig and returns stdout.
  ///
  /// Throws [LGNotConnectedException] if not connected.
  Future<String?> execute(String command) async {
    _guardConnection();
    try {
      final result = await _client!.run(command);
      return utf8.decode(result);
    } catch (e) {
      throw LGSSHException('Command execution failed: $command', e);
    }
  }

  /// Writes content to a remote file using base64 encoding to avoid
  /// shell escaping issues.
  ///
  /// The content is base64-encoded locally, sent via SSH, and decoded
  /// on the remote machine.
  Future<void> writeFile(String remotePath, String content) async {
    _guardConnection();
    try {
      final encoded = base64.encode(Uint8List.fromList(utf8.encode(content)));
      await execute('echo "$encoded" | base64 -d > $remotePath');
    } catch (e) {
      if (e is LGSSHException) rethrow;
      throw LGSSHException('Failed to write file: $remotePath', e);
    }
  }

  // ─── LG-Specific Methods ──────────────────────────────────────────

  /// Writes a flytoview query to `/tmp/query.txt` to move the camera.
  Future<void> sendQuery(String queryContent) async {
    _guardConnection();
    try {
      await writeFile(LGConstants.queryFile, queryContent);
    } catch (e) {
      if (e is LGSSHException) rethrow;
      throw LGSSHException('Failed to send query', e);
    }
  }

  /// Sends KML content to the master rig:
  /// 1. Writes the KML file to `/var/www/html/kml/{filename}.kml`
  /// 2. Registers the network link in `/var/www/html/kmls.txt`
  Future<void> sendKML(String kmlContent, String filename) async {
    _guardConnection();
    try {
      final remotePath = '${LGConstants.kmlDirectory}$filename.kml';
      await writeFile(remotePath, kmlContent);

      // Append network link to kmls.txt
      final networkLink = '''
http://localhost/kml/$filename.kml''';
      await execute(
        'echo "$networkLink" >> ${LGConstants.kmlListFile}',
      );
    } catch (e) {
      if (e is LGSSHException) rethrow;
      throw LGSSHException('Failed to send KML: $filename', e);
    }
  }

  /// Cleans all KML data from the Liquid Galaxy:
  /// - Empties `/tmp/query.txt`
  /// - Empties `/var/www/html/kmls.txt`
  /// - Removes all KML files from `/var/www/html/kml/`
  Future<void> cleanKMLs() async {
    _guardConnection();
    try {
      await execute('> ${LGConstants.queryFile}');
      await execute('> ${LGConstants.kmlListFile}');
      await execute('rm -f ${LGConstants.kmlDirectory}*.kml');
    } catch (e) {
      if (e is LGSSHException) rethrow;
      throw LGSSHException('Failed to clean KMLs', e);
    }
  }

  /// Restarts Google Earth on all rig nodes.
  Future<void> relaunchLG() async {
    _guardConnection();
    try {
      // Kill existing instances
      await execute("pkill -f 'google-earth' || true");
      // Wait a moment before relaunching
      await Future.delayed(const Duration(seconds: 2));
      // Relaunch on the master
      await execute(
        'nohup ${LGConstants.googleEarthBin} &>/dev/null &',
      );
    } catch (e) {
      if (e is LGSSHException) rethrow;
      throw LGSSHException('Failed to relaunch LG', e);
    }
  }

  /// Sets the KML refresh interval for slave screen syncing.
  ///
  /// The refresh file is written per-slave node. The [screenCount] determines
  /// how many slave nodes to configure.
  Future<void> setRefresh({int screenCount = 3}) async {
    _guardConnection();
    try {
      final refreshKML = '''<?xml version="1.0" encoding="UTF-8"?>
<kml xmlns="http://www.opengis.net/kml/2.2"
     xmlns:gx="http://www.google.com/kml/ext/2.2">
  <Document>
    <name>slave_refresh</name>
    <NetworkLink>
      <name>Slave Refresh</name>
      <Link>
        <href>${LGConstants.kmlListFile}</href>
        <refreshMode>onInterval</refreshMode>
        <refreshInterval>2</refreshInterval>
      </Link>
    </NetworkLink>
  </Document>
</kml>''';

      // Write refresh KML for each slave node
      for (int i = 2; i <= screenCount; i++) {
        await writeFile(
          '/var/www/html/kml/slave_$i.kml',
          refreshKML,
        );
      }
    } catch (e) {
      if (e is LGSSHException) rethrow;
      throw LGSSHException('Failed to set refresh', e);
    }
  }

  // ─── Private Helpers ───────────────────────────────────────────────

  /// Throws [LGNotConnectedException] if not connected.
  void _guardConnection() {
    if (!_connected || _client == null) {
      throw const LGNotConnectedException();
    }
  }
}
