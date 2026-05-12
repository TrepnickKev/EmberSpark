# EmberSpark

![EmberSpark logo](images/Logo.png)

A small Lightning wallet for your own [LNbits](https://lnbits.com) server.
Built for everyday personal and family use — send, receive, scan a QR, and
move on.

[![Latest release](https://img.shields.io/github/v/release/TrepnickKev/EmberSpark?label=latest&color=ff8c42)](https://github.com/TrepnickKev/EmberSpark/releases/latest)

## Features

- Lightning **send & receive** through your LNbits wallet
- **QR scanner** that auto-detects BOLT11, LNURL, or Lightning addresses and
  routes to the right flow
- **LNURL** support — pay, withdraw, and cryptographic auth (LUD-04)
- **Lightning addresses** (`user@host`)
- Acts as a **system handler for `lightning:` deep links** — tap a Lightning
  link in any app and EmberSpark opens
- **Live transaction history** — incoming and outgoing payments surface within
  a few seconds, no manual refresh
- **Fiat balance** display (USD / EUR / GBP / CHF / CAD / AUD / JPY) via
  mempool.space
- **Contacts** — save destinations you pay regularly, scan-to-add, pick from a
  list in the Send screen
- **Biometric or device-PIN lock** on app launch
- API key stored in Android KeyStore via `flutter_secure_storage`
- "Allow unverified HTTPS" toggle for self-signed certificates or `.onion`
  LNbits servers

## Install

Grab the latest APK from
**[Releases](https://github.com/TrepnickKev/EmberSpark/releases/latest)**.

| File | For |
|---|---|
| `EmberSpark-v*.*.*-arm64-v8a.apk` | Modern phones (most users) |
| `EmberSpark-v*.*.*-armeabi-v7a.apk` | Older 32-bit Android phones |
| `EmberSpark-v*.*.*-x86_64.apk` | Emulators / Chromebooks |

1. On your phone, enable "Install unknown apps" for your file manager or
   browser
2. Tap the APK → **Install**
3. Open EmberSpark, paste your LNbits URL and admin API key, or scan their
   QR codes from **LNbits → wallet → API Info**

## Requirements

- **Android 6.0** (API 23) or newer
- A self-hosted **[LNbits](https://lnbits.com)** server with a real Lightning
  funding source (LND / CLN / Phoenixd / NWC). VoidWallet won't work — it
  can't move sats.
- Network reachability from your phone to your LNbits server

## Configure the wallet

On first launch, the Setup screen asks for two fields. Use the QR icon next
to each to scan from LNbits' API Info panel.

| Field | What to enter |
|---|---|
| **LNbits URL** | Base URL of your LNbits, e.g. `https://lnbits.example.com` or `http://abcd.onion`. The `https://` prefix is added automatically if missing. |
| **Admin API key** | LNbits → wallet → **API Info → Admin key**. Full-access key — used for every operation. |

### Settings → Allow unverified HTTPS

Off by default. Turn on if your LNbits sits behind a self-signed certificate,
an incomplete certificate chain, or a `.onion` address. Bypasses TLS
validation for all outgoing requests, so only enable for servers you actually
trust.

## Troubleshooting

| Symptom | Cause / fix |
|---|---|
| `VoidWallet cannot create invoices` (520) | LNbits has no real Lightning backend. Configure LND / CLN / Phoenixd / NWC in LNbits → Server → Funding. |
| `Couldn't verify the server's TLS certificate` | Self-signed or incomplete chain. Enable **Settings → Allow unverified HTTPS** if you trust the server. |
| `403 Forbidden` from an LNURL endpoint | Voucher likely already redeemed or expired. Use the "Copy URL" button on the error screen and try the URL in a browser to confirm. |
| LNURL-withdraw says "Withdrawing…" but the balance doesn't move | LNURL-withdraw is fire-and-forget. The server has to actually pay your invoice — pull-to-refresh History after a few seconds. |

## Issues & feature requests

Bug reports, ideas, and feedback all go in the
**[issue tracker](https://github.com/TrepnickKev/EmberSpark/issues)**.

## Caveats

- **APKs are signed with the auto-generated debug key.** Fine for sideloading
  on your own phone; not Play-Store-ready.
- **LNURL-auth identity is per install.** It uses a simplified HMAC derivation
  rather than BIP-32, so a reinstall generates a new identity — sites you've
  authed against will see a new user.
- **Android only.** iOS / desktop builds aren't published here.
- **No backup / restore yet.** Contacts and the LNURL-auth seed live in
  Android KeyStore on the device and don't survive an uninstall.

## Support development

EmberSpark is built and maintained in spare time. If it makes your sats
easier to manage, the on-chain BTC donate address is shown inside the app at
**Settings → About**. Every bit keeps the project alive — thank you.

## License

All rights reserved by **Trepnick Solutions** until a `LICENSE` file is
added to this repo.

---

© 2026 Trepnick Solutions
