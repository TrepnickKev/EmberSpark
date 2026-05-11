# EmberSpark — Lightning wallet

![EmberSpark logo](images/Logo.png)

A small Flutter wallet that talks to your own [LNbits](https://lnbits.com) server. Built primarily for Android; also runs on Windows desktop and Chrome for development.

## Features

- Balance, send, and receive — directly against your LNbits wallet
- QR scanner that auto-detects what you scanned and routes to the right flow:
  - **BOLT11** invoice → pre-filled Send screen
  - **LNURL-pay** → amount prompt → invoice → pay
  - **LNURL-withdraw** → amount prompt → invoice → submit
  - **LNURL-auth** → cryptographic site login (secp256k1 ECDSA)
  - **Lightning address** (`name@host`) → resolves and treats as LNURL-pay
- Registered as a system Lightning handler — `lightning:` and `lnurl:` deep links from other apps open EmberSpark
- Transaction history with pull-to-refresh
- Two-key setup (admin + invoice) — invoice key is used for read operations, admin key only for outgoing payments
- Settings toggle to allow self-signed / incomplete-chain HTTPS for hobbyist or `.onion` LNbits servers

## Requirements

- An **LNbits server** with a real Lightning funding source (LND / CLN / Phoenixd / NWC / etc.) — VoidWallet won't work, it can't move sats
- For Android builds: Android SDK (platform `android-36`, build-tools, platform-tools) and JDK 17+
- Flutter SDK (3.27 or newer)

## How to build

### One-time setup

1. Install Flutter — https://docs.flutter.dev/install
2. Clone or copy this repo
3. From the project root:

```powershell
flutter pub get
```

If you ever change the icon or rebrand, regenerate launcher icons:

```powershell
dart run flutter_launcher_icons
```

### Android APK (sideload to phone)

```powershell
flutter build apk --debug --split-per-abi
```

Output: `build\app\outputs\flutter-apk\app-arm64-v8a-debug.apk` (use this one for any modern phone). For a smaller, faster build:

```powershell
flutter build apk --release --split-per-abi
```

Transfer the APK to your phone (USB, Drive, Telegram-to-self, etc.). On the phone, allow installs from your file manager / browser, tap the APK, install.

### Run on Windows desktop (no emulator needed)

```powershell
flutter run -d windows
```

The wallet works fully on Windows except QR scanning (no camera).

### Run directly on a USB-tethered phone (best dev loop)

Enable Developer Options + USB debugging on the phone, plug it in, then:

```powershell
flutter devices    # confirm phone shows up
flutter run        # builds, installs, hot-reloads
```

While running: `r` = hot reload, `R` = hot restart, `q` = quit.

### Reset to a clean build (when things get weird)

```powershell
flutter clean
flutter pub get
flutter build apk --debug --split-per-abi
```

## How to configure

After installing, on first launch you see the Setup screen with three fields. The QR-scan icon next to each field reads the corresponding QR from LNbits' "API Info" panel.

| Field | What to enter |
| --- | --- |
| **LNbits URL** | Base URL of your LNbits server, e.g. `https://lnbits.example.com` or `http://abcd.onion`. Leading `https://` is optional — the app fills it in. |
| **Admin key** | Used only for sending payments. Find it in LNbits → wallet → **API Info → Admin key**. |
| **Invoice / read key** | Used for balance, creating invoices, and reading payments. LNbits → wallet → **API Info → Invoice/read key**. |

Find all three QR codes in your LNbits wallet's "API Info" panel — each field's scan button accepts its QR.

### Settings → Allow unverified HTTPS

Off by default. Turn on if your LNbits sits behind a self-signed cert, an incomplete certificate chain, or a `.onion` address. Bypasses TLS validation for **all** outgoing requests, so only enable for servers you trust.

## How to use

- **Receive sats** — Receive → enter amount + optional memo → screen shows a QR for the BOLT11 invoice, plus Copy button.
- **Send sats** — Send → paste a BOLT11 invoice → Pay. Or, easier: tap **Scan QR** on the home screen, the wallet detects the format and routes you to the right flow.
- **History** — clock icon in the top bar. Pull down to refresh.
- **Lightning deep link from another app** — when an app like a Bitcoin game offers "Open with…", pick EmberSpark; the wallet handles the BOLT11/LNURL/Lightning-address automatically.

## Troubleshooting

| Symptom | Cause / fix |
| --- | --- |
| `VoidWallet cannot create invoices` (520) | LNbits has no real funding source. Configure LND/CLN/Phoenixd/NWC in LNbits → Server → Funding. |
| `CERTIFICATE_VERIFY_FAILED` | Self-signed or incomplete chain on the LNbits / LNURL server. Settings → Allow unverified HTTPS. |
| `403 Forbidden` from an LNURL endpoint | Most often the voucher is already redeemed or expired. Confirm by pasting the URL (use the "Copy URL" button on the error screen) into a browser — same 403 means it's the server, not the app. |
| LNURL withdraw says success but balance doesn't change | LNURL-withdraw is fire-and-forget; the server has to actually pay your invoice. Pull-to-refresh History after a few seconds. |
| Build fails with Kotlin "different roots" / `relativeTo` errors | Pub cache is on a different drive than the project. Set `PUB_CACHE` to a folder on the same drive as the project, then `flutter clean` + `flutter pub get`. |

## Project layout

```
lib/
  main.dart                          # MaterialApp + deep-link listener
  screens/
    login_screen.dart                # URL + admin/invoice key setup, QR scan per field
    home_screen.dart                 # balance, scan, send, receive, history, settings
    send_screen.dart                 # BOLT11 paste + pay
    receive_screen.dart              # amount + memo → invoice + QR
    qr_scan_screen.dart              # full-screen scanner with torch / camera switch
    lnurl_action_screen.dart         # LNURL-pay/withdraw/auth UI
    history_screen.dart              # transaction list, pull-to-refresh
    settings_screen.dart             # TLS-trust toggle
  services/
    lnbits_service.dart              # /api/v1/wallet, /payments, list payments
    lnurl.dart                       # bech32 decode, fetch, payRequest/withdrawRequest/login parse
    lnurl_auth.dart                  # secp256k1 ECDSA signing of the LNURL-auth k1
    lightning_router.dart            # classify scanned/deep-linked code → push the right screen
    http_client_factory.dart         # IOClient with custom UA + optional cert bypass
android/                             # Manifest (lightning:/lnurl: intent filters), Kotlin
ios/                                 # Info.plist (camera permission, display name)
images/                              # source artwork (Logo.png, Logo_icon.png)
```

## Caveats

- **Debug APKs are large** (~88 MB) because they bundle the Dart VM, debug symbols, and JIT. Release builds are 25–35 MB.
- **APKs are signed with the auto-generated debug key** — fine for sideloading; not Play-Store-ready.
- **LNURL-auth** uses a simplified HMAC derivation, not BIP-32. This means your identity doesn't roam to other LNURL-auth wallets. Each install generates a fresh master seed; sites you've logged into will see you as a new user after a reinstall.
- The **invoice key alone** is enough for receive + history; the **admin key** is required only for send. If you only paste the invoice key, paying will fail with a 401 until you add the admin key.
