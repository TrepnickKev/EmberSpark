---
title: EmberSpark — Privacy Policy
permalink: /privacy
---

# EmberSpark — Privacy Policy

*Last updated: 2026-05-20*

EmberSpark is an open-source mobile client for self-hosted [LNbits](https://lnbits.com) Lightning Network wallets. The app is published by the EmberSpark project on GitHub. This policy describes exactly what data EmberSpark handles, where it goes, and what it does **not** do.

## TL;DR

- EmberSpark **does not run a backend.** It talks only to (a) the LNbits server you configure, (b) `mempool.space` for exchange rates, and (c) GitHub for update checks.
- All wallet credentials are stored locally on your device in the Android Keystore via `flutter_secure_storage`.
- **No analytics, no ads, no third-party SDKs, no telemetry.**
- Auto-backup to Google Drive and device-to-device transfer are **disabled** so wallet credentials cannot leak via cloud restore.

## Data stored on your device

EmberSpark stores the following entirely on-device, encrypted at rest by the Android Keystore:

| Item | Why |
|---|---|
| LNbits server URL | To know which server to talk to |
| LNbits admin / invoice key | To authenticate API calls to your server |
| Optional: Lightning address, BOLT12 offer, LNURL-pay link | "My contact" — shared on your request |
| Fiat currency preference (USD, EUR, …) | To show ~fiat amounts next to sats |
| App language preference | UI localization |
| Biometric-lock toggle | To enable/disable app-launch lock |
| "Trust unverified TLS" toggle | For self-signed / onion LNbits servers |

These values are deleted when you uninstall the app.

## Data sent off the device

EmberSpark contacts only three categories of external server:

1. **Your LNbits server** — every wallet operation (balance, send, receive, history, LNURL, BOLT12) is an HTTPS call to the URL **you** configured. EmberSpark has no control over and no visibility into your LNbits server.
2. **`mempool.space`** — `GET https://mempool.space/api/v1/prices` to fetch BTC/fiat exchange rates. Result is cached for 5 minutes. No identifying information is sent.
3. **GitHub Releases API** — to check for a newer EmberSpark version when you open the About screen. No identifying information is sent.

EmberSpark does **not** contact any server operated by the EmberSpark project itself.

## Permissions

| Android permission | Purpose |
|---|---|
| `INTERNET` | Talk to your LNbits server, mempool.space, and GitHub |
| `CAMERA` | Scan QR codes for invoices, Lightning addresses, LNURLs, BOLT12 offers |
| `NFC` | Read and write Lightning payment data on NFC stickers |
| `USE_BIOMETRIC` | Optional app-launch lock via fingerprint / face |

The camera and NFC features are marked optional — the app still installs on devices without them.

## Biometric data

EmberSpark never reads, stores, or transmits biometric data. The app-launch lock delegates entirely to Android's `BiometricPrompt`, which runs in a separate system process. The app only receives a yes/no "authenticated" result.

## Auto-backup and device transfer

EmberSpark explicitly opts **out** of Android Auto Backup to Google Drive and out of device-to-device transfer (`android:allowBackup="false"` and a data-extraction-rules policy that excludes all storage domains). This is intentional: wallet credentials are not the kind of data that should be silently restored onto a new device by Google. When you set up a fresh device you re-enter your LNbits URL and key, the same way every other Lightning wallet works.

## Children

EmberSpark is a financial tool intended for adults. It is not directed at children under 13.

## Open source

EmberSpark is open source. The code that handles every API call described above is publicly auditable at <https://github.com/TrepnickKev/EmberSpark>.

## Contact

Questions, complaints, or data requests: open an issue at <https://github.com/TrepnickKev/EmberSpark/issues>.

## Changes

If this policy changes materially, the change will be reflected in the "Last updated" date above and noted in the release notes for the version that introduces the change.
