---
name: LG Starter Kit Skills Index
description: Master index of all Liquid Galaxy agent skills
---

# LG Flutter Starter Kit — Agent Skills

This directory contains skill files that teach the AI agent how to build Liquid Galaxy applications using this starter kit.

## Skill Files

| Skill              | File                        | Purpose                                   |
| ------------------ | --------------------------- | ----------------------------------------- |
| SSH Connection     | `lg_connection_workflow.md` | Connect/disconnect/test SSH to the LG rig |
| KML Generation     | `lg_kml_generation.md`      | Generate valid KML documents              |
| Camera Navigation  | `lg_flyto_navigation.md`    | FlyTo commands and camera control         |
| Orbit Animation    | `lg_orbit_animation.md`     | Circular orbits and cinematic tours       |
| Balloon Overlays   | `lg_balloon_overlay.md`     | HTML balloon info windows                 |
| Multi-Screen       | `lg_multi_screen_layout.md` | Distribute content across slave screens   |
| API → KML Pipeline | `lg_api_to_kml_pipeline.md` | Fetch API data, convert to KML, display   |
| Cleanup & Reset    | `lg_cleanup_and_reset.md`   | Remove KMLs and reset LG view             |
| Error Handling     | `lg_error_handling.md`      | Robust error handling patterns            |

## Architecture Overview

```
┌─────────────────────────────────────────────┐
│                  Flutter App                 │
├─────────────────┬───────────────────────────┤
│   LGService     │     ApiService            │
│  (Orchestrator) │   (HTTP Client)           │
├────────┬────────┴───────────────────────────┤
│ SSHService      │     KMLService            │
│ (SSH I/O)       │   (Pure KML Generators)   │
└────────┴────────────────────────────────────┘
         │                    │
    SSH to rig          KML strings
         │                    │
    ┌────▼────────────────────▼───┐
    │   Liquid Galaxy Master Rig  │
    │  /tmp/query.txt             │
    │  /var/www/html/kml/         │
    │  /var/www/html/kmls.txt     │
    └─────────────────────────────┘
```

## Rules for Building LG Features

1. **Always use `LGService`** — never call `SSHService` directly from UI code.
2. **Always use `KMLService`** — never hand-write KML strings in widgets.
3. **Check connection first** — call `lgService.isConnected` before any action.
4. **Handle errors** — wrap all LG calls in try/catch for `LGException`.
5. **Clean after yourself** — call `executeCleanup()` when leaving a feature.
6. **Use models** — always use `PlacemarkData` and `TourStep`, not raw params.
