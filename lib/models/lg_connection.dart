// Copyright 2024 LG-Flutter-StarterKit Authors
// Licensed under the Apache License, Version 2.0
// See LICENSE file for details.

/// Represents the connection state to a Liquid Galaxy rig.
class LGConnection {
  final String host;
  final int port;
  final String username;
  final String password;
  final bool isConnected;
  final int screenCount;

  const LGConnection({
    this.host = '192.168.56.101',
    this.port = 22,
    this.username = 'lg',
    this.password = 'lg',
    this.isConnected = false,
    this.screenCount = 3,
  });

  LGConnection copyWith({
    String? host,
    int? port,
    String? username,
    String? password,
    bool? isConnected,
    int? screenCount,
  }) {
    return LGConnection(
      host: host ?? this.host,
      port: port ?? this.port,
      username: username ?? this.username,
      password: password ?? this.password,
      isConnected: isConnected ?? this.isConnected,
      screenCount: screenCount ?? this.screenCount,
    );
  }

  Map<String, dynamic> toJson() => {
        'host': host,
        'port': port,
        'username': username,
        'password': password,
        'isConnected': isConnected,
        'screenCount': screenCount,
      };

  factory LGConnection.fromJson(Map<String, dynamic> json) => LGConnection(
        host: json['host'] as String? ?? '192.168.56.101',
        port: json['port'] as int? ?? 22,
        username: json['username'] as String? ?? 'lg',
        password: json['password'] as String? ?? 'lg',
        isConnected: json['isConnected'] as bool? ?? false,
        screenCount: json['screenCount'] as int? ?? 3,
      );

  @override
  String toString() =>
      'LGConnection(host: $host, port: $port, connected: $isConnected)';
}
