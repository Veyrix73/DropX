# DropX

A cross-platform file-sharing app for Android, iOS, Windows, and the web.

DropX is being built around a hybrid transfer model:
- **Direct transfer** when devices can reach each other locally.
- **Cloud relay** when a direct connection is unavailable.
- **Pair by code or QR** so a receiver can join a transfer session.

## Project status

The first milestone is the Flutter interface and user preference system. File selection and local pairing-preview UI are included in this starter. The actual device discovery, secure session handshake, direct transfer, and cloud relay services are **not implemented yet**.

## Tech stack

- Flutter and Dart
- `file_picker` for cross-platform file selection
- `qr_flutter` for QR rendering
- `shared_preferences` for saved appearance settings

## Getting started

Install the Flutter SDK (Dart 3.11 or newer), then run:

```bash
flutter pub get
flutter run -d chrome
```

To generate native runner folders for the platforms you want to build:

```bash
flutter create --platforms=android,ios,windows,web .
```

Then use `flutter run` with a connected device or selected desktop/browser target.

## Next milestones

1. Implement the pairing/signaling API and expiring transfer sessions.
2. Add local-network discovery and direct transfer.
3. Add an authenticated cloud relay fallback.
4. Add end-to-end encrypted transfer and safety limits for incoming files.
5. Add automated tests and platform-specific release workflows.

## Security note

Do not send private files through this starter yet. The current UI is not connected to a transfer service and does not upload or transmit selected files.
