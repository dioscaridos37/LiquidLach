# FLauncher — Liquid Glass Edition (UI concept + integration starter)

This package contains a working browser demonstration and reusable Flutter UI building blocks inspired by the supplied Liquid Glass references.

## What's included
- `demo/index.html` — interactive 16:9 launcher mockup. Open it in Chrome/Edge; no server or dependencies needed.
- `lib/liquid_glass_tokens.dart` — reusable Flutter glass surface, centered clock header and sliding settings drawer.
- `docs/INTEGRATION.md` — integration notes for the upstream FLauncher codebase.
- `docs/DEMO.md` — feature walkthrough and keyboard controls.

## Important scope note
This is an **integration starter**, not a complete rebuilt FLauncher repository or installable APK. The execution environment could not clone the GitLab repository (network DNS unavailable), so the original source tree and its app-discovery/database/platform code were not modified. The demo is functional as a visual prototype; its app tiles are illustrative and do not launch Android packages. Use the Flutter file inside a local clone of FLauncher and connect it to the existing app/category/settings providers as described in `docs/INTEGRATION.md`.

## Run the demo
Open `demo/index.html` directly in a desktop browser. For the best preview use a 1920×1080 window.

## Build the Android launcher after integration
From the FLauncher project root, with Flutter and Android SDK installed:

```bash
flutter pub get
flutter analyze
flutter build apk --release
```

The output is normally `build/app/outputs/flutter-apk/app-release.apk`.

## Upstream
Original project: https://gitlab.com/flauncher/flauncher (Flutter Android TV launcher; upstream repository is GPL-3.0 licensed). Preserve its LICENSE and notices when redistributing a derivative build.
