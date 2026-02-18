// Copyright 2024 LG-Flutter-StarterKit Authors
// Licensed under the Apache License, Version 2.0
// See LICENSE file for details.

import 'package:flutter_test/flutter_test.dart';
import 'package:lg_flutter_starter_kit/models/placemark_data.dart';

void main() {
  group('PlacemarkData', () {
    const testData = PlacemarkData(
      latitude: 40.7128,
      longitude: -74.006,
      name: 'New York City',
      description: 'The Big Apple',
      iconUrl: 'https://example.com/icon.png',
      altitude: 100,
      altitudeMode: 'absolute',
      balloonHtml: '<h1>NYC</h1>',
    );

    test('should create with required fields', () {
      const data = PlacemarkData(
        latitude: 10.0,
        longitude: 20.0,
        name: 'Test',
      );

      expect(data.latitude, 10.0);
      expect(data.longitude, 20.0);
      expect(data.name, 'Test');
      expect(data.description, '');
      expect(data.iconUrl, isNull);
      expect(data.altitude, 0);
      expect(data.altitudeMode, 'relativeToGround');
      expect(data.balloonHtml, isNull);
    });

    test('should serialize to JSON', () {
      final json = testData.toJson();

      expect(json['latitude'], 40.7128);
      expect(json['longitude'], -74.006);
      expect(json['name'], 'New York City');
      expect(json['description'], 'The Big Apple');
      expect(json['iconUrl'], 'https://example.com/icon.png');
      expect(json['altitude'], 100);
      expect(json['altitudeMode'], 'absolute');
      expect(json['balloonHtml'], '<h1>NYC</h1>');
    });

    test('should deserialize from JSON', () {
      final json = testData.toJson();
      final restored = PlacemarkData.fromJson(json);

      expect(restored.latitude, testData.latitude);
      expect(restored.longitude, testData.longitude);
      expect(restored.name, testData.name);
      expect(restored.description, testData.description);
      expect(restored.iconUrl, testData.iconUrl);
      expect(restored.altitude, testData.altitude);
      expect(restored.altitudeMode, testData.altitudeMode);
      expect(restored.balloonHtml, testData.balloonHtml);
    });

    test('JSON round-trip preserves all fields', () {
      final roundTripped = PlacemarkData.fromJson(testData.toJson());

      expect(roundTripped.toJson(), equals(testData.toJson()));
    });

    test('copyWith should override specified fields', () {
      final modified = testData.copyWith(name: 'Updated', altitude: 500);

      expect(modified.name, 'Updated');
      expect(modified.altitude, 500);
      expect(modified.latitude, testData.latitude);
      expect(modified.longitude, testData.longitude);
    });

    test('fromJson should handle missing optional fields', () {
      final data = PlacemarkData.fromJson({
        'latitude': 10,
        'longitude': 20,
        'name': 'Minimal',
      });

      expect(data.description, '');
      expect(data.iconUrl, isNull);
      expect(data.altitude, 0);
      expect(data.altitudeMode, 'relativeToGround');
      expect(data.balloonHtml, isNull);
    });
  });
}
