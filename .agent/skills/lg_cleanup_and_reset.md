---
name: LG Cleanup and Reset
description: Clean all KMLs from the rig and reset the view
---

# Cleanup & Reset

## Why Cleanup Matters

KML files accumulate on the rig. Old placemarks, tours, and overlays can interfere with new features. Always clean up when:

- Switching features
- On app exit
- Before displaying new data

## Quick Cleanup

```dart
await lgService.executeCleanup();
```

This does:

1. Empties `/tmp/query.txt`
2. Empties `/var/www/html/kmls.txt`
3. Removes all `.kml` files from `/var/www/html/kml/`
4. Sends a clean empty KML document
5. Resets camera to world overview

## Manual Cleanup Steps

```dart
// Clear query file
await sshService.execute('> /tmp/query.txt');

// Clear KML list
await sshService.execute('> /var/www/html/kmls.txt');

// Remove KML files
await sshService.execute('rm -f /var/www/html/kml/*.kml');
```

## Reset Camera

```dart
await lgService.navigateTo(0, 0, range: 15000000);
```

## Relaunch Google Earth

If the rig is in a bad state:

```dart
await sshService.relaunchLG();
```

## DO

- Call cleanup when leaving a feature/screen
- Call cleanup before displaying new data
- Add a cleanup button in the UI (already in HomeScreen)

## DON'T

- Don't forget to clean — stale KMLs cause confusion
- Don't relaunch LG unless necessary — it takes time to restart
- Don't delete files outside `/var/www/html/kml/`
