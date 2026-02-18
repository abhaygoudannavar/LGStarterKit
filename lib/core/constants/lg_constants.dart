// Copyright 2024 LG-Flutter-StarterKit Authors
// Licensed under the Apache License, Version 2.0
// See LICENSE file for details.

/// Default constants for Liquid Galaxy connection and operation.
class LGConstants {
  LGConstants._();

  // ─── Connection Defaults ───────────────────────────────────────────
  static const String defaultHost = '192.168.56.101';
  static const int defaultPort = 22;
  static const String defaultUsername = 'lg';
  static const String defaultPassword = 'lg';
  static const int defaultScreenCount = 3;

  // ─── Remote Paths ──────────────────────────────────────────────────
  static const String kmlDirectory = '/var/www/html/kml/';
  static const String kmlListFile = '/var/www/html/kmls.txt';
  static const String queryFile = '/tmp/query.txt';

  // ─── Google Earth ──────────────────────────────────────────────────
  static const String googleEarthBin = '/usr/bin/google-earth-pro';
  static const String googleEarthPID =
      "pgrep -f 'google-earth' | head -1";

  // ─── Timeouts ──────────────────────────────────────────────────────
  static const Duration connectionTimeout = Duration(seconds: 10);
  static const Duration commandTimeout = Duration(seconds: 15);

  // ─── KML Defaults ─────────────────────────────────────────────────
  static const double defaultRange = 15000000;
  static const double defaultTilt = 0;
  static const double defaultHeading = 0;
  static const double defaultLatitude = 0;
  static const double defaultLongitude = 0;
  static const String defaultAltitudeMode = 'relativeToGround';

  // ─── Orbit Defaults ───────────────────────────────────────────────
  static const int defaultOrbitSteps = 36;
  static const double defaultOrbitRange = 5000;
  static const double defaultOrbitTilt = 60;
  static const double orbitDuration = 2; // seconds per step
}
