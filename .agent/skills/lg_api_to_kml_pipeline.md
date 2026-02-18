---
name: LG API to KML Pipeline
description: Fetch data from external APIs, parse it, and display as KML on Liquid Galaxy
---

# API → KML Pipeline

## Overview

The most common LG app pattern: fetch data from an API, parse it into KML, and display it on the rig.

## Using LGService.showDataFromAPI

```dart
await lgService.showDataFromAPI(
  'https://api.openweathermap.org/data/2.5/weather?q=London&appid=YOUR_KEY',
  (jsonData) {
    final temp = jsonData['main']['temp'];
    final desc = jsonData['weather'][0]['description'];
    return KMLService.createBalloonPlacemark(
      51.5074, -0.1278, 'London Weather',
      '<div style="color:white;font-family:Arial;padding:10px;">'
      '<h2>🌡️ London: ${(temp - 273.15).toStringAsFixed(1)}°C</h2>'
      '<p>$desc</p></div>',
    );
  },
  51.5074, -0.1278,
  filename: 'london_weather',
);
```

## Manual Pipeline Steps

### 1. Fetch Data

```dart
final apiService = ApiService.instance;
final data = await apiService.getJson('https://api.example.com/data');
```

### 2. Parse & Generate KML

```dart
final items = (data['results'] as List).map((item) {
  return PlacemarkData(
    latitude: item['lat'],
    longitude: item['lng'],
    name: item['name'],
    description: item['info'],
  );
}).toList();

final kmlElements = items.map((p) =>
  KMLService.createPlacemarkFromData(p)
).toList();
```

### 3. Send to LG

```dart
for (int i = 0; i < kmlElements.length; i++) {
  await sshService.sendKML(kmlElements[i], 'item_$i');
}
await lgService.navigateTo(items.first.latitude, items.first.longitude);
```

## Best Practices

1. **Cache API responses** — avoid hitting rate limits
2. **Validate JSON** — always handle missing/null fields
3. **Batch KML sends** — don't send hundreds of individual files
4. **Show loading state** — API calls can be slow

## DO

- Use `ApiService` for all HTTP calls
- Parse defensively with null checks
- Show user feedback during the pipeline

## DON'T

- Don't hardcode API keys in source code
- Don't send raw API JSON to the rig
- Don't skip error handling on network calls
