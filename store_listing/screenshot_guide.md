# Movenn - Screenshot Guide for Google Play

## Required Screenshots
Google Play requires **at least 2 screenshots** (recommended 4-8).

## Recommended Screenshots to Capture

| # | Screen | What to show |
|---|--------|-------------|
| 1 | **Home Screen** | The logo and main menu with "התחל משחק" button |
| 2 | **Gameplay - Venn Diagram** | A Venn diagram with actor names visible |
| 3 | **Gameplay - Answering** | Selecting a movie answer from the options |
| 4 | **Correct Answer** | Green feedback showing a correct answer |
| 5 | **Stats Screen** | Personal statistics and high scores |
| 6 | **Instructions** | The how-to-play screen |

## Screenshot Specifications

| Spec | Requirement |
|------|-------------|
| Format | JPEG or PNG (24-bit, no alpha) |
| Min size | 320px on shortest side |
| Max size | 3840px on longest side |
| Aspect ratio | 16:9 or 9:16 (portrait recommended for phones) |
| Recommended | 1080 x 1920 px (portrait) |

## How to Capture Screenshots

### Option 1: From Android Emulator
```bash
# Run the app in an emulator
flutter run

# Take screenshot using ADB
adb shell screencap -p /sdcard/screenshot.png
adb pull /sdcard/screenshot.png screenshot_1.png
```

### Option 2: From a Physical Device
1. Run the app on your phone
2. Navigate to the desired screen
3. Press Power + Volume Down simultaneously
4. Transfer screenshots to your computer

### Option 3: From Flutter (best quality)
```bash
# Run integration test that captures screenshots
flutter drive --target=test_driver/screenshots.dart
```

## Additional Store Assets

| Asset | Size | Description |
|-------|------|-------------|
| **App Icon** | 512 x 512 px | High-res version of your logo |
| **Feature Graphic** | 1024 x 500 px | Banner shown at top of store listing |

## Tips
- Use real gameplay with interesting Venn diagrams
- Show the game in action (not empty states)
- Add Hebrew text overlays if desired (e.g., "200 דיאגרמות!")
- Keep backgrounds clean and consistent
