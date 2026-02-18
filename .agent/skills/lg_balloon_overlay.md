---
name: LG Balloon Overlay
description: HTML balloon overlays on placemarks for rich information display
---

# HTML Balloon Overlays

## What Are Balloons?

KML `<BalloonStyle>` lets you embed arbitrary HTML in a popup attached to a placemark. Great for showing data, images, and styled information.

## Display a Balloon

```dart
await lgService.showBalloon(
  40.7128, -74.006,
  'New York City',
  '''
  <div style="font-family: Arial; padding: 10px; color: white; background: #1e1e2e;">
    <h2 style="color: #6C63FF;">🏙️ New York City</h2>
    <hr style="border-color: #333;"/>
    <p><b>Population:</b> 8.3 million</p>
    <p><b>Area:</b> 783.8 km²</p>
    <img src="https://example.com/nyc.jpg" width="200"/>
  </div>
  ''',
);
```

## Generate Balloon KML

```dart
final kml = KMLService.createBalloonPlacemark(
  lat, lng, 'Title',
  '<div>Your HTML here</div>',
);
```

## HTML Guidelines for Balloons

- Use **inline styles** (no external CSS)
- Keep width under **400px** for readability
- Use **dark backgrounds** that match LG aesthetics
- Include `font-family: Arial, sans-serif`
- Images should use absolute URLs

## Example: Weather Balloon

```html
<div
  style="font-family: Arial; padding: 15px; background: #1a1a2e; color: white; border-radius: 8px;"
>
  <h2 style="color: #00e5ff;">🌤️ Weather in Paris</h2>
  <p>Temperature: <b>22°C</b></p>
  <p>Humidity: <b>65%</b></p>
  <p>Wind: <b>12 km/h NW</b></p>
</div>
```

## DO

- Use CDATA wrapping (handled automatically by `KMLService`)
- Use semantic HTML with inline styles
- Keep content concise and scannable

## DON'T

- Don't use JavaScript in balloons (not supported)
- Don't use external stylesheets
- Don't make balloons too wide (> 500px)
