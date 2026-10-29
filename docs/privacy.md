---
title: EmberSpark — Privacy Policy
permalink: /privacy
---

# EmberSpark — Privacy Policy

*Last updated: 2026-10-29*

EmberSpark is an open-source mobile client for self-hosted [LNbits](https://lnbits.com) Lightning Network wallets. The app is published by the EmberSpark project on GitHub. This policy describes exactly what data EmberSpark handles, where it goes, and what it does **not** do.

## TL;DR

- EmberSpark **does not run a backend.** It talks only to (a) the LNbits server you configure, (b) the Lightning address and LNURL services you choose to use, (c) `mempool.space` for exchange rates, and (d) GitHub for update checks, unless Google Play or F-Droid installed the app.
- All wallet credentials are stored locally on your device in the Android Keystore via `flutter_secure_storage`.
- **No analytics, no ads, no third-party SDKs, no telemetry.**
- Auto-backup to Google Drive and device-to-device transfer are **disabled** so wallet credentials cannot leak via cloud restore.

## Data stored on your device

EmberSpark stores the following entirely on-device, encrypted at rest by the Android Keystore:

| Item | Why |
|---|---|
| LNbits server URL, admin / invoice key and label of each wallet you add | To know which server to talk to and to authenticate API calls to it |
| Optional: Lightning address, BOLT12 offer, LNURL-pay link | "My contact" — shared on your request |
| Contacts you save (name, Lightning address, LNURL or BOLT12 offer) | To pay them again quickly |
| Recent payment history and the last seen balance | To show the history quickly and mark new incoming payments |
| Current and historical exchange rates | To show ~fiat amounts without fetching them every time |
| Fiat currency, amount display and avatar style | UI preferences |
| App language preference | UI localization |
| Biometric-lock toggle | To enable/disable app-launch lock |
| Payment notification and sound toggles | For the optional received-payment notifications |
| "Allow unverified HTTPS" toggle | For self-signed / onion LNbits servers. It applies only to your LNbits servers; every other server is always verified |

These values are deleted when you uninstall the app.

## Data sent off the device

EmberSpark contacts only these external servers:

1. **Your LNbits server:** every wallet operation (balance, send, receive, history, BOLT12, Bolt Cards) is an HTTPS call to the URL **you** configured. EmberSpark has no control over and no visibility into your LNbits server.
2. **Lightning address and LNURL services you use:** when you pay a Lightning address or open an LNURL (pay, withdraw or login), the app asks that service's server for an invoice or the next step. It sends what the protocol needs: the amount, an optional comment you type and, for LNURL login, a signature with a key that is different for every service, so services can't link your logins. Like any server, they see your IP address.
3. **`mempool.space`:** `GET https://mempool.space/api/v1/prices` for current BTC/fiat exchange rates (cached for 5 minutes) and `GET https://mempool.space/api/v1/historical-price` for the rate at the time of past payments. No identifying information is sent.
4. **GitHub Releases API:** to check for a newer EmberSpark version when you open the About screen. Skipped when Google Play or F-Droid installed the app, because the store handles updates. No identifying information is sent.

If you turn on received-payment notifications, the app checks your LNbits server(s) in the background about every 15 minutes. It contacts nothing else for this.

Scanning a QR code from a picture and importing or exporting contacts happen on your device only. Nothing is uploaded.

EmberSpark does **not** contact any server operated by the EmberSpark project itself.

## Permissions

| Android permission | Purpose |
|---|---|
| `INTERNET` | Talk to the servers listed above |
| `CAMERA` | Scan QR codes for invoices, Lightning addresses, LNURLs, BOLT12 offers |
| `NFC` | Read and write Lightning payment data on NFC stickers and set up Bolt Cards |
| `USE_BIOMETRIC` | Optional app-launch lock via fingerprint / face |
| `POST_NOTIFICATIONS` | Optional received-payment notifications |
| `WAKE_LOCK` | Lets the background check for received payments finish |

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
