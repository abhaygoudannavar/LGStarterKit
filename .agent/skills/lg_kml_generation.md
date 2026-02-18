---
name: LG KML Generation
description: Patterns for generating valid KML documents for Liquid Galaxy
---

# KML Generation Patterns

## Overview

All KML is generated via `KMLService` — static, pure functions. Never write KML strings by hand.

## Required XML Namespaces

Every KML document MUST include:

```xml
xmlns="http://www.opengis.net/kml/2.2"
xmlns:gx="http://www.google.com/kml/ext/2.2"
```

## Available Generators

### Simple Placemark

```dart
final kml = KMLService.createPlacemark(
  40.7128, -74.006,
  'New York City',
  'The Big Apple',
  iconUrl: 'https://example.com/icon.png', // optional
);
```

### Placemark from Model

```dart
final data = PlacemarkData(
  latitude: 40.7128, longitude: -74.006,
  name: 'NYC', description: 'Info here',
);
final kml = KMLService.createPlacemarkFromData(data);
```

### Balloon with HTML

```dart
final kml = KMLService.createBalloonPlacemark(
  lat, lng, 'Title',
  '<div style="color:white;"><h2>Info</h2><p>Details</p></div>',
);
```

### Multiple Placemarks in a Folder

```dart
final placemarks = cities.map((c) =>
  '<Placemark><name>${c.name}</name><Point><coordinates>${c.lng},${c.lat},0</coordinates></Point></Placemark>'
).toList();
final kml = KMLService.wrapInFolder('Cities', placemarks);
```

### Clean Document

```dart
final empty = KMLService.cleanDocument();
```

## Sending KML to LG

```dart
await sshService.sendKML(kmlContent, 'my_feature');
// This writes to /var/www/html/kml/my_feature.kml
// and registers in /var/www/html/kmls.txt
```

## DO

- Always use `KMLService` static methods
- Use `CDATA` for description content (already handled by KMLService)
- Use `PlacemarkData` model for typed data

## DON'T

- Don't concatenate KML strings manually
- Don't forget the `gx:` namespace for tours and extensions
- Don't use special characters in filenames (use `_sanitizeFilename`)
