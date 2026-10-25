# Developing EmberSpark

EmberSpark is a Flutter app. It is built primarily for Android; it also runs on
Windows desktop, which is handy for development (everything works except the
QR scanner and NFC).

## Requirements

- Flutter SDK 3.27 or newer. Releases build with Flutter 3.41.9 (Dart 3.11),
  pinned as the git submodule `.flutter`.
- For Android builds: Android SDK (platform `android-36`, build-tools,
  platform-tools) and JDK 17 or newer (releases use JDK 21)
- An LNbits server with a real Lightning funding source (LND, CLN, Phoenixd,
  NWC, ...) to test against. VoidWallet won't work, it can't move sats.

## Set up

```sh
git clone https://github.com/TrepnickKev/EmberSpark.git
cd EmberSpark
flutter pub get
```

Your own Flutter install is fine for development. To use the exact SDK the
releases are built with, run `git submodule update --init` and call
`.flutter/bin/flutter` instead of `flutter`.

The wallet avatars come from the
[animal_avatar](https://github.com/TrepnickKev/Animal-Avatar-Generator) package,
pulled by `flutter pub get` as a git dependency pinned to a release tag.

Localized strings live in `lib/l10n/app_*.arb`; `flutter pub get` regenerates the
`app_localizations*.dart` files from them. If you change the app icon, regenerate
the launcher icons with `dart run flutter_launcher_icons`.

## Checks

Run these before opening a pull request:

```sh
flutter analyze
flutter test
```

## Run and build

Run on a USB-tethered phone (enable Developer Options and USB debugging) or on
Windows desktop:

```sh
flutter devices      # confirm the device shows up
flutter run          # build, install, hot reload ("r"), hot restart ("R"), quit ("q")
flutter run -d windows
```

Build an APK to sideload:

```sh
flutter build apk --release --split-per-abi
```

The output is in `build/app/outputs/flutter-apk/`; `app-arm64-v8a-release.apk`
fits any modern phone. Debug APKs are large (about 90 MB) because they bundle the
Dart VM and debug symbols.

Release signing needs a `android/key.properties` with your own keystore; without
it, release builds are signed with the debug key. Official releases are built by
the `Build & publish` GitHub workflow (`.github/workflows/build.yml`), which signs
with the project keystore from the repository secrets, uploads the AAB to Google
Play and attaches the APKs to a GitHub release.

### Releasing

1. Bump `version:` in `pubspec.yaml`, e.g. `1.1.4+500` to `1.1.5+501`. The part
   after `+` is the Android version code and must only ever grow. The App Bundle
   uses it as is; split APKs get code * 10 + 1 (armeabi-v7a), 2 (arm64-v8a) or
   3 (x86_64).
2. Add `fastlane/metadata/android/<locale>/changelogs/<code>.txt` for the three
   APK codes, e.g. `5011.txt`, `5012.txt`, `5013.txt`.
3. Commit on `main`, then run the `Build & publish` workflow on `main`. It reads
   the version from `pubspec.yaml`, fails if the tag already exists, and creates
   the tag `v<version>`. F-Droid picks up new tags, rebuilds that commit and
   checks that its APKs match the ones on the GitHub release.
4. When updating Flutter, move the `.flutter` submodule to the new tag
   (`git -C .flutter fetch --depth 1 origin tag <version>` and check it out).

If the build gets into a strange state:

```sh
flutter clean
flutter pub get
```

## Project layout

```
lib/
  main.dart        app start, theme, deep-link handling
  screens/         one file per screen (home, send, receive, history, settings, ...)
  services/        LNbits API, LNURL / BOLT11 / BOLT12, NFC and Bolt Card, storage, prices, notifications
  widgets/         shared widgets (avatar, status ring, action buttons, ...)
  l10n/            translations (app_*.arb) and the generated localizations
test/              unit and widget tests
android/           Android project (manifest with lightning:/lnurl: intent filters, Kotlin MainActivity)
ios/, macos/, linux/, windows/, web/   other Flutter platform projects
images/            app artwork
docs/              GitHub Pages site (privacy policy)
```

## Notes

- LNbits API keys are stored with `flutter_secure_storage` and excluded from
  Android Auto Backup on purpose, so they never reach Google Drive.
- LNURL-auth uses a simplified HMAC key derivation (not BIP-32), derived from the
  wallet's admin key. The identity is stable for the same wallet on any device,
  but does not roam to other LNURL-auth wallets.
- The invoice key alone is enough for receiving and history; the admin key is
  needed only for sending.
