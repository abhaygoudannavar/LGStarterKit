---
name: LG FlyTo Navigation
description: Camera navigation via query.txt and LookAt commands
---

# Camera Navigation & FlyTo

## How It Works

Liquid Galaxy reads `/tmp/query.txt` for camera commands. Writing `flytoview=<LookAt>...</LookAt>` moves all screens.

## Navigate via LGService

```dart
// Simple navigation
await lgService.navigateTo(40.7128, -74.006, range: 10000, tilt: 45);

// World overview
await lgService.navigateTo(0, 0, range: 15000000);

// Close-up with heading
await lgService.navigateTo(48.8584, 2.2945, range: 1000, tilt: 70, heading: 180);
```

## Generate FlyTo String Manually

```dart
final query = KMLService.flyTo(lat, lng, range: 5000, tilt: 60, heading: 0);
// Returns: flytoview=<LookAt><longitude>...</longitude>...
await sshService.sendQuery(query);
```

## LookAt Parameters

| Parameter      | Description                  | Default          |
| -------------- | ---------------------------- | ---------------- |
| `latitude`     | Decimal degrees              | required         |
| `longitude`    | Decimal degrees              | required         |
| `range`        | Distance from point (meters) | 15000000         |
| `tilt`         | 0 = top-down, 90 = horizon   | 0                |
| `heading`      | 0 = North, 90 = East         | 0                |
| `altitudeMode` | relativeToGround, absolute   | relativeToGround |

## Common Ranges

- World: `15000000`
- Country: `1000000`
- City: `50000`
- Neighborhood: `5000`
- Building: `500`

## DO

- Use `LGService.navigateTo()` for all camera moves from UI
- Use sensible defaults — `tilt: 45` gives a nice 3D perspective
- Chain navigation with data display (navigate then show placemark)

## DON'T

- Don't write raw strings to query.txt
- Don't set tilt > 90 (invalid)
- Don't forget range — 0 range zooms to ground level
