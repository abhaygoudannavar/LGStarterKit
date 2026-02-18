// Copyright 2024 LG-Flutter-StarterKit Authors
// Licensed under the Apache License, Version 2.0
// See LICENSE file for details.

import 'package:flutter/material.dart';

import '../core/theme/app_theme.dart';

/// Animated connection status indicator.
///
/// Displays a pulsing dot (green/amber/red) with a text label
/// showing the current connection state.
class ConnectionIndicator extends StatefulWidget {
  final bool isConnected;
  final bool isConnecting;

  const ConnectionIndicator({
    super.key,
    required this.isConnected,
    this.isConnecting = false,
  });

  @override
  State<ConnectionIndicator> createState() => _ConnectionIndicatorState();
}

class _ConnectionIndicatorState extends State<ConnectionIndicator>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _pulseAnimation = Tween<double>(begin: 0.8, end: 1.2).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    if (widget.isConnecting) {
      _pulseController.repeat(reverse: true);
    }
  }

  @override
  void didUpdateWidget(covariant ConnectionIndicator oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isConnecting) {
      _pulseController.repeat(reverse: true);
    } else {
      _pulseController.stop();
      _pulseController.reset();
    }
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  Color get _statusColor {
    if (widget.isConnecting) return AppTheme.connectingColor;
    return widget.isConnected
        ? AppTheme.connectedColor
        : AppTheme.disconnectedColor;
  }

  String get _statusText {
    if (widget.isConnecting) return 'Connecting...';
    return widget.isConnected ? 'Connected' : 'Disconnected';
  }

  IconData get _statusIcon {
    if (widget.isConnecting) return Icons.sync;
    return widget.isConnected ? Icons.check_circle : Icons.cancel;
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _pulseAnimation,
      builder: (context, child) {
        final scale = widget.isConnecting ? _pulseAnimation.value : 1.0;
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(
            color: _statusColor.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(30),
            border: Border.all(
              color: _statusColor.withValues(alpha: 0.4),
              width: 1.5,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Transform.scale(
                scale: scale,
                child: Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _statusColor,
                    boxShadow: [
                      BoxShadow(
                        color: _statusColor.withValues(alpha: 0.5),
                        blurRadius: 8,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Icon(_statusIcon, color: _statusColor, size: 18),
              const SizedBox(width: 6),
              Text(
                _statusText,
                style: TextStyle(
                  color: _statusColor,
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}


