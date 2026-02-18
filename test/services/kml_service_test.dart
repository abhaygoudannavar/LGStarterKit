// Copyright 2024 LG-Flutter-StarterKit Authors
// Licensed under the Apache License, Version 2.0
// See LICENSE file for details.

import 'package:flutter_test/flutter_test.dart';
import 'package:lg_flutter_starter_kit/services/kml_service.dart';
import 'package:lg_flutter_starter_kit/models/tour_step.dart';

void main() {
  group('KMLService', () {
    // ─── flyTo ─────────────────────────────────────────────────────

    group('flyTo', () {
      test('should return flytoview query with LookAt element', () {
        final result = KMLService.flyTo(40.7128, -74.006);

        expect(result, startsWith('flytoview='));
        expect(result, contains('<LookAt>'));
        expect(result, contains('<latitude>40.7128</latitude>'));
        expect(result, contains('<longitude>-74.006</longitude>'));
        expect(result, contains('</LookAt>'));
      });

      test('should include custom range, tilt, and heading', () {
        final result = KMLService.flyTo(
          10.0, 20.0,
          range: 5000,
          tilt: 60,
          heading: 90,
        );

        expect(result, contains('<range>5000.0</range>'));
        expect(result, contains('<tilt>60.0</tilt>'));
        expect(result, contains('<heading>90.0</heading>'));
      });
    });

    // ─── createPlacemark ───────────────────────────────────────────

    group('createPlacemark', () {
      test('should produce valid KML with namespaces', () {
        final result = KMLService.createPlacemark(
          40.7128, -74.006, 'New York', 'NYC',
        );

        expect(result, contains('<?xml version="1.0"'));
        expect(result, contains('xmlns="http://www.opengis.net/kml/2.2"'));
        expect(result, contains('xmlns:gx="http://www.google.com/kml/ext/2.2"'));
        expect(result, contains('<name>New York</name>'));
        expect(result, contains('<coordinates>-74.006,40.7128,0</coordinates>'));
      });

      test('should include icon style when iconUrl is provided', () {
        final result = KMLService.createPlacemark(
          10, 20, 'Test', 'Desc',
          iconUrl: 'https://example.com/icon.png',
        );

        expect(result, contains('<IconStyle>'));
        expect(result, contains('<href>https://example.com/icon.png</href>'));
      });

      test('should not include icon style when iconUrl is null', () {
        final result = KMLService.createPlacemark(10, 20, 'Test', 'Desc');

        expect(result, isNot(contains('<IconStyle>')));
      });
    });

    // ─── createBalloonPlacemark ────────────────────────────────────

    group('createBalloonPlacemark', () {
      test('should include BalloonStyle with HTML content', () {
        final result = KMLService.createBalloonPlacemark(
          10, 20, 'Balloon', '<h1>Hello</h1>',
        );

        expect(result, contains('<BalloonStyle>'));
        expect(result, contains('<![CDATA[<h1>Hello</h1>]]>'));
        expect(result, contains('<styleUrl>#balloonStyle</styleUrl>'));
      });
    });

    // ─── createOrbit ──────────────────────────────────────────────

    group('createOrbit', () {
      test('should generate correct number of FlyTo steps', () {
        final result = KMLService.createOrbit(10, 20, steps: 12);

        final flyToCount = '<gx:FlyTo>'
            .allMatches(result)
            .length;
        expect(flyToCount, equals(12));
      });

      test('should create a gx:Tour with Playlist', () {
        final result = KMLService.createOrbit(10, 20);

        expect(result, contains('<gx:Tour>'));
        expect(result, contains('<gx:Playlist>'));
        expect(result, contains('</gx:Playlist>'));
        expect(result, contains('</gx:Tour>'));
      });

      test('should use smooth flyToMode', () {
        final result = KMLService.createOrbit(10, 20, steps: 4);

        expect(result, contains('<gx:flyToMode>smooth</gx:flyToMode>'));
      });
    });

    // ─── createTour ───────────────────────────────────────────────

    group('createTour', () {
      test('should create tour from waypoints list', () {
        final steps = [
          const TourStep(latitude: 10, longitude: 20),
          const TourStep(latitude: 30, longitude: 40),
        ];

        final result = KMLService.createTour(steps);

        expect(result, contains('<gx:Tour>'));
        expect(result, contains('<latitude>10.0</latitude>'));
        expect(result, contains('<latitude>30.0</latitude>'));

        final flyToCount = '<gx:FlyTo>'
            .allMatches(result)
            .length;
        expect(flyToCount, equals(2));
      });
    });

    // ─── cleanDocument ────────────────────────────────────────────

    group('cleanDocument', () {
      test('should return empty KML document', () {
        final result = KMLService.cleanDocument();

        expect(result, contains('<Document/>'));
        expect(result, contains('xmlns="http://www.opengis.net/kml/2.2"'));
      });
    });

    // ─── wrapInFolder ─────────────────────────────────────────────

    group('wrapInFolder', () {
      test('should wrap elements in a Folder', () {
        final result = KMLService.wrapInFolder(
          'My Folder',
          ['<Placemark/>', '<Placemark/>'],
        );

        expect(result, contains('<Folder>'));
        expect(result, contains('<name>My Folder</name>'));
        expect(result, contains('<Placemark/>'));
      });
    });
  });
}
