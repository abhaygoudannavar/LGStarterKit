---
name: LG Multi-Screen Layout
description: Distribute content across master and slave screens in a Liquid Galaxy rig
---

# Multi-Screen Content Distribution

## LG Screen Architecture

A typical Liquid Galaxy has 3–7 screens:

- **Screen 1 (Master):** Runs the main Google Earth process
- **Screens 2–N (Slaves):** Mirror/extend the master view

## How Slave Syncing Works

1. Master writes KML files to `/var/www/html/kml/`
2. Master registers them in `/var/www/html/kmls.txt`
3. Slaves periodically poll `kmls.txt` and load the KML files via `NetworkLink`
4. `SSHService.setRefresh()` configures the polling interval

## Set Up Slave Refresh

```dart
await sshService.setRefresh(screenCount: 5);
```

This writes a refresh KML to each slave node.

## Screen-Specific Content

To show different content on different screens, create separate KML files per screen:

```dart
for (int screen = 2; screen <= screenCount; screen++) {
  final kml = generateContentForScreen(screen, data);
  await sshService.writeFile(
    '/var/www/html/kml/screen_$screen.kml',
    kml,
  );
}
```

## Logo/Overlay on Specific Screens

Use `<ScreenOverlay>` for logos or branding on specific slave screens:

```xml
<ScreenOverlay>
  <name>Logo</name>
  <Icon><href>http://yourserver/logo.png</href></Icon>
  <overlayXY x="0" y="1" xunits="fraction" yunits="fraction"/>
  <screenXY x="0.02" y="0.98" xunits="fraction" yunits="fraction"/>
  <size x="0.15" y="0" xunits="fraction" yunits="fraction"/>
</ScreenOverlay>
```

## DO

- Call `setRefresh()` after connecting
- Use `screenCount` from settings
- Test with your actual rig configuration

## DON'T

- Don't assume screen count — read from settings
- Don't write directly to slave machines — use the `/var/www/html/` path
- Don't forget to clean slave KMLs with `cleanKMLs()`
