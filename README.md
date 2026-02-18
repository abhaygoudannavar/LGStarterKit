# LG-Flutter-StarterKit

A clean, modular Flutter starter kit for building **Liquid Galaxy** applications. Provides SSH connectivity, KML generation, camera navigation, orbit tours, balloon overlays, and a complete agent skill set for AI-assisted development.

## 🏗️ Architecture

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
    └─────────────────────────────┘
```

## ✨ Features

- **SSH Service** — Singleton SSH wrapper with connection guard, base64 file transfer
- **KML Service** — Pure static generators for placemarks, balloons, orbits, tours
- **LG Service** — High-level orchestrator combining SSH + KML
- **API Service** — Generic HTTP client with JSON parsing
- **Material 3 UI** — Dark/light themes, connection indicator, action buttons
- **Agent Skills** — 10 skill files teaching AI how to build LG apps
- **Unit Tests** — KML generation, model serialization, service orchestration

## 📁 Project Structure

```
lib/
├── core/
│   ├── constants/lg_constants.dart    # Connection defaults, paths
│   ├── errors/lg_exceptions.dart      # Custom exception hierarchy
│   └── theme/app_theme.dart           # Material 3 themes
├── models/
│   ├── lg_connection.dart             # Connection state
│   ├── placemark_data.dart            # Placemark model
│   └── tour_step.dart                 # Tour waypoint model
├── services/
│   ├── ssh_service.dart               # SSH singleton
│   ├── kml_service.dart               # Static KML generators
│   ├── lg_service.dart                # LG orchestrator
│   └── api_service.dart               # HTTP client
├── screens/
│   ├── home_screen.dart               # Dashboard
│   └── settings_screen.dart           # Connection settings
├── widgets/
│   ├── connection_indicator.dart      # Animated status dot
│   ├── lg_action_button.dart          # Styled action button
│   └── kml_preview_card.dart          # KML preview card
└── main.dart                          # App entry point
```

## 🚀 Getting Started

### Prerequisites

- Flutter SDK ≥ 3.0.0
- A Liquid Galaxy rig (or VM) with SSH access
- Google Earth Pro running on the master node

### Installation

```bash
git clone https://github.com/your-username/LG-Flutter-StarterKit.git
cd LG-Flutter-StarterKit
flutter pub get
flutter run
```

### Configuration

1. Launch the app
2. Go to **Settings** (gear icon)
3. Enter your LG master node IP, port, username, and password
4. Save and return to the dashboard
5. Tap **"Connect to LG"**

## 📖 Usage

### Navigate to a Location

```dart
await LGService.instance.navigateTo(40.7128, -74.006, range: 10000, tilt: 45);
```

### Display a Placemark

```dart
await LGService.instance.displayPlacemark(PlacemarkData(
  latitude: 48.8584, longitude: 2.2945,
  name: 'Eiffel Tower', description: 'Paris, France',
));
```

### Start an Orbit

```dart
await LGService.instance.startOrbit(40.7128, -74.006, range: 8000);
```

### Show a Balloon Overlay

```dart
await LGService.instance.showBalloon(
  40.7128, -74.006, 'NYC Info',
  '<div style="color:white;"><h2>New York</h2><p>Population: 8.3M</p></div>',
);
```

### API → KML Pipeline

```dart
await LGService.instance.showDataFromAPI(
  'https://api.example.com/data',
  (json) => KMLService.createBalloonPlacemark(lat, lng, 'Title', htmlFromJson(json)),
  lat, lng,
);
```

## 🧪 Testing

```bash
flutter test
```

Tests cover:

- KML generation (flyTo, placemarks, orbits, tours, balloons)
- Model serialization (toJson/fromJson round-trip)
- Service orchestration (singleton, connection guard)

## 🤖 Agent Skills

The `.agent/skills/` directory contains 10 skill files that teach AI coding agents how to build Liquid Galaxy applications:

| Skill             | File                        |
| ----------------- | --------------------------- |
| SSH Connection    | `lg_connection_workflow.md` |
| KML Generation    | `lg_kml_generation.md`      |
| Camera Navigation | `lg_flyto_navigation.md`    |
| Orbit Animation   | `lg_orbit_animation.md`     |
| Balloon Overlays  | `lg_balloon_overlay.md`     |
| Multi-Screen      | `lg_multi_screen_layout.md` |
| API → KML         | `lg_api_to_kml_pipeline.md` |
| Cleanup           | `lg_cleanup_and_reset.md`   |
| Error Handling    | `lg_error_handling.md`      |

## 📄 License

This project is licensed under the Apache License 2.0 — see the [LICENSE](LICENSE) file for details.
