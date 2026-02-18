// Copyright 2024 LG-Flutter-StarterKit Authors
// Licensed under the Apache License, Version 2.0
// See LICENSE file for details.

import '../core/constants/lg_constants.dart';
import '../models/placemark_data.dart';
import '../models/tour_step.dart';

/// Static KML generators — pure functions for creating KML documents.
///
/// All methods return well-formed KML strings with the necessary XML
/// namespaces for Google Earth compatibility.
class KMLService {
  KMLService._();

  static const String _kmlNamespace =
      'http://www.opengis.net/kml/2.2';
  static const String _gxNamespace =
      'http://www.google.com/kml/ext/2.2';

  // ─── Camera Navigation ─────────────────────────────────────────────

  /// Generates a `flytoview=<LookAt>` query string to move the camera.
  ///
  /// Returns the full query string ready to write to `/tmp/query.txt`.
  static String flyTo(
    double lat,
    double lng, {
    double range = LGConstants.defaultRange,
    double tilt = LGConstants.defaultTilt,
    double heading = LGConstants.defaultHeading,
    String altitudeMode = LGConstants.defaultAltitudeMode,
  }) {
    return 'flytoview=<LookAt>'
        '<longitude>$lng</longitude>'
        '<latitude>$lat</latitude>'
        '<range>$range</range>'
        '<tilt>$tilt</tilt>'
        '<heading>$heading</heading>'
        '<gx:altitudeMode>$altitudeMode</gx:altitudeMode>'
        '</LookAt>';
  }

  // ─── Placemarks ────────────────────────────────────────────────────

  /// Creates a full KML document containing a single `<Placemark>`.
  static String createPlacemark(
    double lat,
    double lng,
    String name,
    String description, {
    String? iconUrl,
  }) {
    final iconStyle = iconUrl != null
        ? '''
      <Style>
        <IconStyle>
          <Icon>
            <href>$iconUrl</href>
          </Icon>
        </IconStyle>
      </Style>'''
        : '';

    return '''<?xml version="1.0" encoding="UTF-8"?>
<kml xmlns="$_kmlNamespace" xmlns:gx="$_gxNamespace">
  <Document>
    <name>$name</name>$iconStyle
    <Placemark>
      <name>$name</name>
      <description><![CDATA[$description]]></description>
      <Point>
        <coordinates>$lng,$lat,0</coordinates>
      </Point>
    </Placemark>
  </Document>
</kml>''';
  }

  /// Creates a placemark from a [PlacemarkData] model object.
  static String createPlacemarkFromData(PlacemarkData data) {
    if (data.balloonHtml != null) {
      return createBalloonPlacemark(
        data.latitude,
        data.longitude,
        data.name,
        data.balloonHtml!,
      );
    }
    return createPlacemark(
      data.latitude,
      data.longitude,
      data.name,
      data.description,
      iconUrl: data.iconUrl,
    );
  }

  // ─── Balloon Overlays ──────────────────────────────────────────────

  /// Creates a placemark with a `<BalloonStyle>` containing arbitrary HTML.
  ///
  /// Use this for rich info windows showing data, images, charts, etc.
  static String createBalloonPlacemark(
    double lat,
    double lng,
    String name,
    String htmlContent,
  ) {
    return '''<?xml version="1.0" encoding="UTF-8"?>
<kml xmlns="$_kmlNamespace" xmlns:gx="$_gxNamespace">
  <Document>
    <name>$name</name>
    <Style id="balloonStyle">
      <BalloonStyle>
        <text><![CDATA[$htmlContent]]></text>
        <bgColor>ff1e1e2e</bgColor>
      </BalloonStyle>
    </Style>
    <Placemark>
      <name>$name</name>
      <styleUrl>#balloonStyle</styleUrl>
      <Point>
        <coordinates>$lng,$lat,0</coordinates>
      </Point>
    </Placemark>
  </Document>
</kml>''';
  }

  // ─── Orbit Tours ───────────────────────────────────────────────────

  /// Creates a `<gx:Tour>` that orbits around a point (circular flyaround).
  ///
  /// [steps] controls smoothness — 36 steps = 10° per step.
  /// [tilt] controls the camera angle (0 = top-down, 90 = horizon).
  static String createOrbit(
    double lat,
    double lng, {
    double range = LGConstants.defaultOrbitRange,
    double tilt = LGConstants.defaultOrbitTilt,
    int steps = LGConstants.defaultOrbitSteps,
    double duration = LGConstants.orbitDuration,
  }) {
    final buffer = StringBuffer();
    buffer.writeln('<?xml version="1.0" encoding="UTF-8"?>');
    buffer.writeln(
        '<kml xmlns="$_kmlNamespace" xmlns:gx="$_gxNamespace">');
    buffer.writeln('  <Document>');
    buffer.writeln('    <name>Orbit</name>');
    buffer.writeln('    <gx:Tour>');
    buffer.writeln('      <name>Orbit Tour</name>');
    buffer.writeln('      <gx:Playlist>');

    for (int i = 0; i < steps; i++) {
      final heading = (i * 360.0) / steps;
      buffer.writeln('        <gx:FlyTo>');
      buffer.writeln(
          '          <gx:duration>$duration</gx:duration>');
      buffer.writeln(
          '          <gx:flyToMode>smooth</gx:flyToMode>');
      buffer.writeln('          <LookAt>');
      buffer.writeln(
          '            <longitude>$lng</longitude>');
      buffer.writeln(
          '            <latitude>$lat</latitude>');
      buffer.writeln('            <range>$range</range>');
      buffer.writeln('            <tilt>$tilt</tilt>');
      buffer.writeln(
          '            <heading>$heading</heading>');
      buffer.writeln(
          '            <gx:altitudeMode>relativeToGround</gx:altitudeMode>');
      buffer.writeln('          </LookAt>');
      buffer.writeln('        </gx:FlyTo>');
    }

    buffer.writeln('      </gx:Playlist>');
    buffer.writeln('    </gx:Tour>');
    buffer.writeln('  </Document>');
    buffer.writeln('</kml>');

    return buffer.toString();
  }

  // ─── Multi-Waypoint Tours ──────────────────────────────────────────

  /// Creates a `<gx:Tour>` from a list of [TourStep] waypoints.
  static String createTour(List<TourStep> waypoints) {
    final buffer = StringBuffer();
    buffer.writeln('<?xml version="1.0" encoding="UTF-8"?>');
    buffer.writeln(
        '<kml xmlns="$_kmlNamespace" xmlns:gx="$_gxNamespace">');
    buffer.writeln('  <Document>');
    buffer.writeln('    <name>Tour</name>');
    buffer.writeln('    <gx:Tour>');
    buffer.writeln('      <name>Guided Tour</name>');
    buffer.writeln('      <gx:Playlist>');

    for (final step in waypoints) {
      buffer.writeln('        <gx:FlyTo>');
      buffer.writeln(
          '          <gx:duration>${step.duration}</gx:duration>');
      buffer.writeln(
          '          <gx:flyToMode>smooth</gx:flyToMode>');
      buffer.writeln('          <LookAt>');
      buffer.writeln(
          '            <longitude>${step.longitude}</longitude>');
      buffer.writeln(
          '            <latitude>${step.latitude}</latitude>');
      buffer.writeln(
          '            <range>${step.range}</range>');
      buffer.writeln(
          '            <tilt>${step.tilt}</tilt>');
      buffer.writeln(
          '            <heading>${step.heading}</heading>');
      buffer.writeln(
          '            <gx:altitudeMode>${step.altitudeMode}</gx:altitudeMode>');
      buffer.writeln('          </LookAt>');
      buffer.writeln('        </gx:FlyTo>');
    }

    buffer.writeln('      </gx:Playlist>');
    buffer.writeln('    </gx:Tour>');
    buffer.writeln('  </Document>');
    buffer.writeln('</kml>');

    return buffer.toString();
  }

  // ─── Utility Methods ───────────────────────────────────────────────

  /// Wraps a list of KML element strings inside a `<Folder>`.
  static String wrapInFolder(String name, List<String> kmlElements) {
    final elementsStr = kmlElements.join('\n    ');
    return '''<?xml version="1.0" encoding="UTF-8"?>
<kml xmlns="$_kmlNamespace" xmlns:gx="$_gxNamespace">
  <Document>
    <Folder>
      <name>$name</name>
      $elementsStr
    </Folder>
  </Document>
</kml>''';
  }

  /// Returns an empty KML document — used for cleaning/resetting.
  static String cleanDocument() {
    return '''<?xml version="1.0" encoding="UTF-8"?>
<kml xmlns="$_kmlNamespace" xmlns:gx="$_gxNamespace">
  <Document/>
</kml>''';
  }
}
