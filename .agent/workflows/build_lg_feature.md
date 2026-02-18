---
description: Step-by-step workflow to build a new Liquid Galaxy feature from idea to display
---

# Build LG Feature Workflow

Follow these steps to add a new Liquid Galaxy feature to your app.

## Step 1: Define the Data Source

Identify where the data comes from:

- External API (weather, earthquakes, landmarks, etc.)
- Static data (hardcoded coordinates)
- User input (search, form)

## Step 2: Create Models

If the data needs a model, create it in `lib/models/`:

```dart
class MyFeatureData {
  final double latitude;
  final double longitude;
  final String name;
  // ... add fields
}
```

## Step 3: Fetch Data (if API)

Use `ApiService` to fetch data:

```dart
final data = await ApiService.instance.getJson('https://api.example.com/data');
```

## Step 4: Generate KML

Use `KMLService` to convert data to KML:

```dart
final kml = KMLService.createPlacemark(lat, lng, name, description);
// or
final kml = KMLService.createBalloonPlacemark(lat, lng, name, htmlContent);
```

## Step 5: Send to LG

Use `LGService` to orchestrate:

```dart
await lgService.displayPlacemark(placemarkData);
// or
await lgService.showBalloon(lat, lng, title, html);
// and navigate
await lgService.navigateTo(lat, lng, range: 10000, tilt: 45);
```

## Step 6: Add UI

Create a screen or add a button to `HomeScreen`:

```dart
LGActionButton(
  icon: Icons.my_feature,
  label: 'My Feature',
  onPressed: () => _runMyFeature(),
),
```

## Step 7: Test

- Test KML generation in `test/services/`
- Test the feature on the LG rig manually
- Verify cleanup works after feature exits

## Step 8: Clean Up

Always add cleanup when the feature exits:

```dart
@override
void dispose() {
  lgService.executeCleanup();
  super.dispose();
}
```
