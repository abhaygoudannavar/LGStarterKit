// Copyright 2024 LG-Flutter-StarterKit Authors
// Licensed under the Apache License, Version 2.0
// See LICENSE file for details.

import 'package:flutter/material.dart';

import '../core/errors/lg_exceptions.dart';
import '../services/lg_service.dart';
import '../widgets/connection_indicator.dart';
import '../widgets/lg_action_button.dart';

/// Main dashboard screen for the Liquid Galaxy Starter Kit.
///
/// Shows connection status and provides action buttons for
/// common LG operations like navigation, orbit, and cleanup.
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final LGService _lgService = LGService.instance;
  bool _isConnecting = false;
  String? _activeAction;

  // ─── Actions ───────────────────────────────────────────────────────

  Future<void> _navigateHome() async {
    await _runAction('navigate', () async {
      // Fly to a default overview position (e.g. world view)
      await _lgService.navigateTo(0, 0, range: 15000000);
    });
  }

  Future<void> _navigateToNewYork() async {
    await _runAction('nyc', () async {
      await _lgService.navigateTo(40.7128, -74.006, range: 10000, tilt: 45);
    });
  }

  Future<void> _startOrbit() async {
    await _runAction('orbit', () async {
      await _lgService.startOrbit(40.7128, -74.006, range: 8000);
    });
  }

  Future<void> _showBalloon() async {
    await _runAction('balloon', () async {
      await _lgService.showBalloon(
        40.7128,
        -74.006,
        'New York City',
        '''
        <div style="font-family: Arial; padding: 10px; color: white;">
          <h2 style="color: #6C63FF;">🏙️ New York City</h2>
          <p>Population: 8.3 million</p>
          <p>Area: 783.8 km²</p>
          <p><b>The Big Apple</b> — Cultural capital of the world.</p>
        </div>
        ''',
      );
    });
  }

  Future<void> _cleanup() async {
    await _runAction('cleanup', () async {
      await _lgService.executeCleanup();
    });
  }

  Future<void> _runAction(
    String actionId,
    Future<void> Function() action,
  ) async {
    if (!_lgService.isConnected) {
      _showSnackBar('Not connected to Liquid Galaxy.', isError: true);
      return;
    }

    setState(() => _activeAction = actionId);
    try {
      await action();
      _showSnackBar('Action completed ✓');
    } on LGException catch (e) {
      _showSnackBar(e.message, isError: true);
    } catch (e) {
      _showSnackBar('Error: $e', isError: true);
    } finally {
      if (mounted) setState(() => _activeAction = null);
    }
  }

  void _showSnackBar(String message, {bool isError = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              isError ? Icons.error_outline : Icons.check_circle_outline,
              color: isError ? Colors.redAccent : Colors.greenAccent,
              size: 20,
            ),
            const SizedBox(width: 10),
            Expanded(child: Text(message)),
          ],
        ),
        behavior: SnackBarBehavior.floating,
        backgroundColor: Theme.of(context).cardTheme.color,
      ),
    );
  }

  // ─── UI ────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'LG Starter Kit',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            tooltip: 'Settings',
            onPressed: () => Navigator.pushNamed(context, '/settings'),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Connection Status
              Center(
                child: ConnectionIndicator(
                  isConnected: _lgService.isConnected,
                  isConnecting: _isConnecting,
                ),
              ),

              const SizedBox(height: 24),

              // Connect / Disconnect Button
              _buildConnectButton(theme),

              const SizedBox(height: 32),

              // Section Title
              Text(
                'Quick Actions',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 16),

              // Action Grid
              GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 2,
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                childAspectRatio: 1.3,
                children: [
                  LGActionButton(
                    icon: Icons.home,
                    label: 'Fly Home',
                    isLoading: _activeAction == 'navigate',
                    onPressed: _navigateHome,
                  ),
                  LGActionButton(
                    icon: Icons.location_city,
                    label: 'Fly to NYC',
                    isLoading: _activeAction == 'nyc',
                    onPressed: _navigateToNewYork,
                    color: const Color(0xFF00E5FF),
                  ),
                  LGActionButton(
                    icon: Icons.rotate_right,
                    label: 'Start Orbit',
                    isLoading: _activeAction == 'orbit',
                    onPressed: _startOrbit,
                    color: const Color(0xFFFFA726),
                  ),
                  LGActionButton(
                    icon: Icons.info_outline,
                    label: 'Show Balloon',
                    isLoading: _activeAction == 'balloon',
                    onPressed: _showBalloon,
                    color: const Color(0xFF66BB6A),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // Cleanup Button
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: _activeAction == 'cleanup'
                      ? null
                      : _cleanup,
                  icon: _activeAction == 'cleanup'
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.cleaning_services),
                  label: const Text('Clean & Reset'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.redAccent,
                    side: const BorderSide(color: Colors.redAccent),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildConnectButton(ThemeData theme) {
    final isConnected = _lgService.isConnected;

    return ElevatedButton.icon(
      onPressed: _isConnecting
          ? null
          : () async {
              if (isConnected) {
                await _lgService.disconnect();
                if (mounted) setState(() {});
              } else {
                setState(() => _isConnecting = true);
                try {
                  // Read connection details from settings or use defaults
                  final success = await _lgService.connectAndVerify(
                    '192.168.56.101',
                    22,
                    'lg',
                    'lg',
                  );
                  if (!success) {
                    _showSnackBar(
                      'Connection verification failed.',
                      isError: true,
                    );
                  }
                } on LGException catch (e) {
                  _showSnackBar(e.message, isError: true);
                } catch (e) {
                  _showSnackBar('Connection failed: $e', isError: true);
                } finally {
                  if (mounted) setState(() => _isConnecting = false);
                }
              }
            },
      icon: Icon(isConnected ? Icons.link_off : Icons.link),
      label: Text(
        _isConnecting
            ? 'Connecting...'
            : isConnected
                ? 'Disconnect'
                : 'Connect to LG',
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor:
            isConnected ? Colors.redAccent : theme.colorScheme.primary,
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }
}
