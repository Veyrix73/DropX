# DropX

A cross-platform file-sharing app for Android, iOS, Windows, and the web.

DropX is being built around a hybrid sharing model:
- Pair devices using a short code or QR invitation.
- Prefer direct device-to-device transfer when possible.
- Use a secure cloud relay when a direct route is unavailable.

## Current stack

- React Native + TypeScript
- Expo SDK 54
- Expo Document Picker
- Expo Linear Gradient

## Current milestone

The Expo starter replaces the old Flutter starter. The current preview includes:
- A refreshed mobile-first interface with subtle motion.
- Send, Activity, and Settings screens.
- Native document selection on Android and iOS.
- Light/dark appearance, motion toggle, and accent colour controls.

**Real transfers are not implemented yet.** Device pairing, QR invitations, transfer progress, direct transfer, cloud relay, and end-to-end encryption are still planned. The Join button intentionally explains that pairing is not connected. Do not treat this preview as a file-transfer app yet.

## Requirements

- Node.js 20.19.4 or newer.
- npm.
- Expo Go on a supported phone for previewing.

## Run on Windows

Clone the repository and install dependencies:

```cmd
git clone https://github.com/Veyrix73/DropX.git
cd DropX
npm install
```

Start the development server:

```cmd
npx expo start
```

A QR code will appear in the terminal and the Expo developer tools.

### iPhone

1. Install Expo Go from the App Store.
2. Connect the iPhone and PC to the same Wi-Fi network.
3. Scan the QR code using the iPhone Camera app, then open it in Expo Go.

If the network blocks local connections, stop the server and run `npx expo start --tunnel` instead.

This starter is pinned to SDK 54 because the App Store version of Expo Go supports SDK 54. Newer Expo SDKs require a development build on a physical iPhone. See the [Expo Go compatibility guide](https://docs.expo.dev/troubleshooting/expo-go-version-mismatch/).

### Android

Install the Expo Go version compatible with SDK 54 from [expo.dev/go](https://expo.dev/go), then scan the QR code from the app.

## Useful commands

```cmd
npm start
npm run typecheck
```

## Roadmap

1. Build real pairing sessions with expiring codes and QR invitations.
2. Add a signalling service so two devices can discover each other.
3. Implement direct transfers and a cloud-relay fallback.
4. Add transfer progress, retries, and cancellation.
5. Design and review the encryption model before sending private files.
6. Add persistent preferences, transfer history, tests, and release builds.
