---
name: LG Orbit Animation
description: Circular orbit tours and cinematic camera animations
---

# Orbit & Cinematic Animations

## How Orbits Work

An orbit is a `<gx:Tour>` with `<gx:FlyTo>` steps arranged in a circle. Each step increments the heading by `360/steps` degrees while keeping the same lat/lng center.

## Quick Orbit

```dart
await lgService.startOrbit(
  40.7128, -74.006,
  range: 8000,   // meters from center
  tilt: 60,      // camera angle
  steps: 36,     // smoothness (more = smoother)
);
```

## Generate Orbit KML Manually

```dart
final kml = KMLService.createOrbit(
  lat, lng,
  range: 5000,
  tilt: 60,
  steps: 36,
  duration: 2,  // seconds per step
);
await sshService.sendKML(kml, 'orbit');
```

## Multi-Waypoint Tours

```dart
final tour = [
  TourStep(latitude: 40.71, longitude: -74.00, range: 10000, duration: 3),
  TourStep(latitude: 48.85, longitude: 2.29, range: 8000, duration: 4),
  TourStep(latitude: 35.68, longitude: 139.69, range: 12000, duration: 3),
];
await lgService.startTour(tour);
```

## Orbit Parameters

| Parameter  | Effect         | Recommended       |
| ---------- | -------------- | ----------------- |
| `steps`    | Smoothness     | 36 (10° per step) |
| `range`    | Distance       | 3000–10000m       |
| `tilt`     | Camera angle   | 50–70°            |
| `duration` | Speed per step | 1.5–3s            |

## DO

- Use `steps: 36` or `72` for smooth orbits
- Set `tilt: 60` for cinematic perspective
- Use `TourStep` model for multi-waypoint tours

## DON'T

- Don't use too few steps (< 12) — looks jerky
- Don't set duration too low (< 1s) — too fast to see
- Don't send multiple tours simultaneously
