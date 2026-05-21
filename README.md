# EmberSpark

<p align="center">
  <img src="images/Logo.png" alt="EmberSpark logo" width="50%">
</p>

A small Lightning wallet for your own [LNbits](https://lnbits.com) server.
Built for everyday personal and family use. Send, receive, scan a QR, and
move on.

[![Latest release](https://img.shields.io/github/v/release/TrepnickKev/EmberSpark?label=latest&color=ff8c42)](https://github.com/TrepnickKev/EmberSpark/releases/latest)

## Features

- Lightning **send & receive** through your LNbits wallet
- **Multiple LNbits wallets** managed in one app, with a quick switcher under
  the home menu and per-wallet identifiers and label
- **QR scanner** that auto-detects BOLT11, BOLT12, LNURL, or Lightning
  addresses and routes to the right flow
- **BOLT12** support: pay offers (`lno1…`) and invoices (`lni1…`), or
  generate your own offer for static receive
- **LNURL** support: pay, withdraw, and cryptographic auth (LUD-04)
- **Lightning addresses** (`user@host`)
- **My Contact**: share your Lightning address, BOLT12 offer, and LNURL-pay
  link via QR, copy, system share, or NFC. The LNURL-pay link and BOLT12
  offer can be auto-generated from your LNbits server.
- **Deterministic per-wallet avatars** derived from your public Lightning
  identity, so the same wallet shows the same avatar across devices and
  saved contacts show the same avatar as the owner's home screen
- **NFC** read and write for Lightning destinations
- Acts as a **system handler for `lightning:` deep links**. Tap a Lightning
  link in any app and EmberSpark opens.
- **Live transaction history**: incoming and outgoing payments surface
  within a few seconds, no manual refresh
- **Tap any amount** on Home or History to swap between sats and fiat. The
  preference persists across restarts.
- **Currency switcher** on the Receive screen, so you can enter the amount
  in fiat, see the sats equivalent, and create the right invoice
- **Fiat balance** display (USD / EUR / GBP / CHF / CAD / AUD / JPY) via
  mempool.space
- **Contacts**: save destinations you pay regularly, scan-to-add or paste,
  edit or delete, pick from the list on the Send-to screen
- Editable **wallets** (URL, admin key, label) without losing the
  per-wallet My-Contact entries
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
  funding source (LND / CLN / Phoenixd / NWC). VoidWallet won't work. It
  can't move sats.
- Network reachability from your phone to your LNbits server

## Configure the wallet

On first launch, the Setup screen asks for two fields. Use the QR icon next
to each to scan from LNbits' API Info panel.

| Field | What to enter |
|---|---|
| **LNbits URL** | Base URL of your LNbits, e.g. `https://lnbits.example.com` or `http://abcd.onion`. The `https://` prefix is added automatically if missing. |
| **Admin API key** | LNbits → wallet → **API Info → Admin key**. Full-access key, used for every operation. |

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
| LNURL-withdraw says "Withdrawing…" but the balance doesn't move | LNURL-withdraw is fire-and-forget. The server has to actually pay your invoice. Pull-to-refresh History after a few seconds. |
| `Not enough sats in your wallet for this payment.` | Wallet balance is below the invoice amount plus any routing fees. Top up the LNbits wallet or pick a smaller invoice. |
| `Your LNbits server returned an insecure (http://) callback URL.` | LNbits is behind a reverse proxy without proxy-header awareness. On the LNbits host set `LNBITS_BASE_URL=https://your-host` in `.env` and restart. Alternatively, configure the proxy to pass `X-Forwarded-Proto: https`. |

## Issues & feature requests

Bug reports, ideas, and feedback all go in the
**[issue tracker](https://github.com/TrepnickKev/EmberSpark/issues)**.

## Caveats

- **LNURL-auth identity is per install.** It uses a simplified HMAC
  derivation rather than BIP-32, so a reinstall generates a new identity,
  and sites you've authed against will see a new user.
- **Android only.** iOS / desktop builds aren't published here.
- **No cloud backup or device-to-device transfer.** Wallet credentials are
  intentionally excluded from Android Auto Backup so they cannot leak to
  Google Drive. Set up your wallet again on a new device the same way you
  did the first time.

## Support development

EmberSpark is built and maintained in spare time. If it makes your sats
easier to manage, the on-chain BTC donate address is shown inside the app at
**Settings → About**. Every bit keeps the project alive. Thank you.

## License

All rights reserved by **Trepnick Solutions** until a `LICENSE` file is
added to this repo.

---

© 2026 Trepnick Solutions
