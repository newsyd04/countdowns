# Countdowns

A premium countdown app built with Flutter, designed to feel indistinguishable from a top-tier Apple-designed application. Track life's moments with style.

## Screenshots

<!-- Add screenshots here -->
| Home | Create | Detail |
|------|--------|--------|
| _coming soon_ | _coming soon_ | _coming soon_ |

## Setup

### Prerequisites

- Flutter SDK >= 3.19.0
- Dart >= 3.2.0
- Xcode (for iOS builds)
- Android Studio (for Android builds)

### Install

```bash
git clone https://github.com/daranewsome/countdowns.git
cd countdowns
flutter pub get
```

## Run

```bash
# Web
flutter run -d chrome

# iOS Simulator
flutter run -d ios

# Android Emulator
flutter run -d android
```

For iOS, run `cd ios && pod install && cd ..` first if needed.

## Test

```bash
flutter test
flutter test --coverage
```

## Build

```bash
flutter build apk --release
```

The APK will be at `build/app/outputs/flutter-apk/app-release.apk`.

## Release

Tag a version to trigger an automated GitHub Release with the APK attached:

```bash
git tag v1.0.0
git push origin v1.0.0
```

Download APKs from the [Releases](../../releases) page.

## Architecture

This project follows **Clean Architecture** with strict separation of concerns:

```
lib/
  core/                  # Design system, constants, utilities, extensions
  features/
    countdowns/
      data/              # Hive persistence layer
      domain/            # Entities, repository contracts, use cases
      presentation/      # Pages, widgets, Riverpod providers
      services/          # Notifications
```

**Key technologies:** Riverpod (state management), Hive CE (local persistence), Clean Architecture (structure).

See [docs/design_system.md](docs/design_system.md) for the full design system reference.

## Features

- Emoji and color picker for personalization
- Smart date suggestions (past dates suggest next year)
- Recurring events (weekly, monthly, yearly)
- Drag-to-reorder with spring animations
- Swipe gestures with undo support
- Local notifications with timezone-safe scheduling
- Haptic feedback tuned per interaction
- Frosted glass navigation bar
- Dark mode with adaptive colors

## CI/CD

GitHub Actions runs on every push and PR to `main`:

1. **Analyze & Lint** -- formatting and static analysis
2. **Test** -- full test suite with coverage
3. **Build APK** -- release APK uploaded as artifact

Tagged releases (`v*`) automatically create GitHub Releases with the APK attached.

## Credits

Made by Dara Newsome.

## License

MIT
