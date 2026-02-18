// Copyright 2024 LG-Flutter-StarterKit Authors
// Licensed under the Apache License, Version 2.0
// See LICENSE file for details.

import '../core/errors/lg_exceptions.dart';
import '../models/placemark_data.dart';
import '../models/tour_step.dart';
import 'api_service.dart';
import 'kml_service.dart';
import 'ssh_service.dart';

/// High-level orchestrator combining [SSHService] and [KMLService]
/// into convenient, ready-to-use Liquid Galaxy operations.
///
/// Usage:
/// ```dart
/// final lg = LGService.instance;
/// await lg.connectAndVerify('192.168.56.101', 22, 'lg', 'lg');
/// await lg.navigateTo(40.7128, -74.006, range: 10000);
/// await lg.executeCleanup();
/// ```
class LGService {
  LGService._();

  static final LGService instance = LGService._();

  final SSHService _ssh = SSHService.instance;
  final ApiService _api = ApiService.instance;

  /// Whether the rig is connected and verified.
  bool get isConnected => _ssh.isConnected;

  // ─── Connection ────────────────────────────────────────────────────

  /// Connects to the Liquid Galaxy rig and verifies with a test command.
  ///
  /// Returns `true` if both connection and verification succeed.
  Future<bool> connectAndVerify(
    String host,
    int port,
    String username,
    String password,
  ) async {
    try {
      final connected = await _ssh.connect(host, port, username, password);
      if (!connected) return false;

      // Verify with a simple echo command
      final result = await _ssh.execute('echo "LG_CONNECTED"');
      final verified = result?.trim() == 'LG_CONNECTED';

      if (!verified) {
        await _ssh.disconnect();
        return false;
      }

      return true;
    } catch (e) {
      await _ssh.disconnect();
      if (e is LGException) rethrow;
      throw LGSSHException('Connection verification failed', e);
    }
  }

  /// Disconnects from the Liquid Galaxy rig.
  Future<void> disconnect() async {
    await _ssh.disconnect();
  }

  // ─── Camera Navigation ─────────────────────────────────────────────

  /// Navigates the Liquid Galaxy camera to the given coordinates.
  Future<void> navigateTo(
    double lat,
    double lng, {
    double range = 15000000,
    double tilt = 0,
    double heading = 0,
  }) async {
    final query = KMLService.flyTo(
      lat,
      lng,
      range: range,
      tilt: tilt,
      heading: heading,
    );
    await _ssh.sendQuery(query);
  }

  // ─── Placemarks ────────────────────────────────────────────────────

  /// Generates KML from [PlacemarkData] and sends it to the rig.
  Future<void> displayPlacemark(PlacemarkData data) async {
    final kml = KMLService.createPlacemarkFromData(data);
    final filename = _sanitizeFilename(data.name);
    await _ssh.sendKML(kml, filename);
  }

  // ─── Orbit Tours ──────────────────────────────────────────────────

  /// Starts an orbit animation around the given point.
  Future<void> startOrbit(
    double lat,
    double lng, {
    double range = 5000,
    double tilt = 60,
    int steps = 36,
  }) async {
    final kml = KMLService.createOrbit(
      lat,
      lng,
      range: range,
      tilt: tilt,
      steps: steps,
    );
    await _ssh.sendKML(kml, 'orbit_tour');
  }

  // ─── Balloon Overlays ──────────────────────────────────────────────

  /// Creates and displays a balloon overlay with HTML content.
  Future<void> showBalloon(
    double lat,
    double lng,
    String title,
    String htmlBody,
  ) async {
    final kml = KMLService.createBalloonPlacemark(
      lat,
      lng,
      title,
      htmlBody,
    );
    final filename = _sanitizeFilename(title);
    await _ssh.sendKML(kml, 'balloon_$filename');
  }

  // ─── Multi-Waypoint Tour ──────────────────────────────────────────

  /// Sends a guided tour through multiple waypoints.
  Future<void> startTour(List<TourStep> waypoints) async {
    final kml = KMLService.createTour(waypoints);
    await _ssh.sendKML(kml, 'guided_tour');
  }

  // ─── Cleanup ───────────────────────────────────────────────────────

  /// Cleans all KML data and resets the Liquid Galaxy view.
  Future<void> executeCleanup() async {
    await _ssh.cleanKMLs();

    // Send an empty KML document to clear the display
    final cleanKml = KMLService.cleanDocument();
    await _ssh.sendKML(cleanKml, 'clean');

    // Reset to default view
    await navigateTo(0, 0, range: 15000000);
  }

  // ─── API → KML Pipeline ──────────────────────────────────────────

  /// Fetches data from an API, parses it using the provided [parser],
  /// and displays the result as KML on the Liquid Galaxy.
  ///
  /// The [parser] function should convert the API response (JSON)
  /// into a KML string ready for display.
  ///
  /// Optionally navigates to [lat], [lng] after displaying.
  Future<void> showDataFromAPI(
    String apiUrl,
    String Function(dynamic jsonData) parser,
    double lat,
    double lng, {
    String filename = 'api_data',
  }) async {
    try {
      final jsonData = await _api.getJson(apiUrl);
      final kml = parser(jsonData);

      await _ssh.sendKML(kml, filename);
      await navigateTo(lat, lng, range: 10000, tilt: 45);
    } catch (e) {
      if (e is LGException) rethrow;
      throw LGException('API to KML pipeline failed: $apiUrl', e);
    }
  }

  // ─── Private Helpers ───────────────────────────────────────────────

  /// Converts a name into a safe filename (lowercase, no spaces/special chars).
  String _sanitizeFilename(String name) {
    return name
        .toLowerCase()
        .replaceAll(RegExp(r'[^a-z0-9]'), '_')
        .replaceAll(RegExp(r'_+'), '_');
  }
}
