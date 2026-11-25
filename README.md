# DropX

A cross-platform file-sharing app for Android, iOS, Windows, and the web.

DropX is planned around a hybrid transfer model:
- **Direct transfer** when devices can reach each other locally.
- **Cloud relay** when a direct connection is unavailable.
- **Pair by code or QR** so a receiver can join a transfer session.

## Project status

This first milestone contains the Flutter interface, cross-platform file selection, a QR/code pairing preview, and saved appearance preferences. The actual device discovery, pairing handshake, direct transfer, cloud relay, and end-to-end encryption are **not implemented yet**.

The pairing QR currently contains a preview URI only. It does not connect devices or transfer files. Do not use this starter to send private files.

## Stack

- Flutter / Dart
- `file_picker` for cross-platform file selection
- `qr_flutter` for QR rendering
- `shared_preferences` for saved appearance settings

## First-time setup

Install Flutter with Dart 3.11 or newer. From the project root, generate the platform runner folders and fetch dependencies:

```bash
flutter create --platforms=android,ios,windows,web .
flutter pub get
```

Run the web version:

```bash
flutter run -d chrome
```

For Android, connect a device or start an emulator, then run `flutter run`. Windows builds need the Windows desktop toolchain. iOS builds require macOS and Xcode.

## Next milestones

1. Implement expiring pairing sessions and a signaling API.
2. Add local-network discovery and direct transfer.
3. Add an authenticated cloud-relay fallback.
4. Implement and review end-to-end encryption.
5. Add transfer history, automated tests, and release workflows.
