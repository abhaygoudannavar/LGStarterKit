// Copyright 2024 LG-Flutter-StarterKit Authors
// Licensed under the Apache License, Version 2.0
// See LICENSE file for details.

/// Typed model for a KML placemark with optional icon and balloon HTML.
class PlacemarkData {
  final double latitude;
  final double longitude;
  final String name;
  final String description;
  final String? iconUrl;
  final double altitude;
  final String altitudeMode;
  final String? balloonHtml;

  const PlacemarkData({
    required this.latitude,
    required this.longitude,
    required this.name,
    this.description = '',
    this.iconUrl,
    this.altitude = 0,
    this.altitudeMode = 'relativeToGround',
    this.balloonHtml,
  });

  PlacemarkData copyWith({
    double? latitude,
    double? longitude,
    String? name,
    String? description,
    String? iconUrl,
    double? altitude,
    String? altitudeMode,
    String? balloonHtml,
  }) {
    return PlacemarkData(
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      name: name ?? this.name,
      description: description ?? this.description,
      iconUrl: iconUrl ?? this.iconUrl,
      altitude: altitude ?? this.altitude,
      altitudeMode: altitudeMode ?? this.altitudeMode,
      balloonHtml: balloonHtml ?? this.balloonHtml,
    );
  }

  Map<String, dynamic> toJson() => {
        'latitude': latitude,
        'longitude': longitude,
        'name': name,
        'description': description,
        'iconUrl': iconUrl,
        'altitude': altitude,
        'altitudeMode': altitudeMode,
        'balloonHtml': balloonHtml,
      };

  factory PlacemarkData.fromJson(Map<String, dynamic> json) => PlacemarkData(
        latitude: (json['latitude'] as num).toDouble(),
        longitude: (json['longitude'] as num).toDouble(),
        name: json['name'] as String,
        description: json['description'] as String? ?? '',
        iconUrl: json['iconUrl'] as String?,
        altitude: (json['altitude'] as num?)?.toDouble() ?? 0,
        altitudeMode:
            json['altitudeMode'] as String? ?? 'relativeToGround',
        balloonHtml: json['balloonHtml'] as String?,
      );

  @override
  String toString() => 'PlacemarkData(name: $name, lat: $latitude, lng: $longitude)';
}
