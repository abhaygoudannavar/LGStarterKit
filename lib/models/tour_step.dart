// Copyright 2024 LG-Flutter-StarterKit Authors
// Licensed under the Apache License, Version 2.0
// See LICENSE file for details.

/// Represents a single waypoint in a KML tour.
class TourStep {
  final double latitude;
  final double longitude;
  final double range;
  final double tilt;
  final double heading;
  final double duration; // seconds
  final String altitudeMode;

  const TourStep({
    required this.latitude,
    required this.longitude,
    this.range = 5000,
    this.tilt = 60,
    this.heading = 0,
    this.duration = 3,
    this.altitudeMode = 'relativeToGround',
  });

  TourStep copyWith({
    double? latitude,
    double? longitude,
    double? range,
    double? tilt,
    double? heading,
    double? duration,
    String? altitudeMode,
  }) {
    return TourStep(
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      range: range ?? this.range,
      tilt: tilt ?? this.tilt,
      heading: heading ?? this.heading,
      duration: duration ?? this.duration,
      altitudeMode: altitudeMode ?? this.altitudeMode,
    );
  }

  Map<String, dynamic> toJson() => {
        'latitude': latitude,
        'longitude': longitude,
        'range': range,
        'tilt': tilt,
        'heading': heading,
        'duration': duration,
        'altitudeMode': altitudeMode,
      };

  factory TourStep.fromJson(Map<String, dynamic> json) => TourStep(
        latitude: (json['latitude'] as num).toDouble(),
        longitude: (json['longitude'] as num).toDouble(),
        range: (json['range'] as num?)?.toDouble() ?? 5000,
        tilt: (json['tilt'] as num?)?.toDouble() ?? 60,
        heading: (json['heading'] as num?)?.toDouble() ?? 0,
        duration: (json['duration'] as num?)?.toDouble() ?? 3,
        altitudeMode:
            json['altitudeMode'] as String? ?? 'relativeToGround',
      );

  @override
  String toString() =>
      'TourStep(lat: $latitude, lng: $longitude, range: $range)';
}
