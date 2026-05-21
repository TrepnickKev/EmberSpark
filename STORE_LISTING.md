# EmberSpark: Play Store listing copy

Source of truth for the Main store listing text. Paste into Play Console at <https://play.google.com/console> under your app's **Main store listing** for the respective locale.

Conventions:
- No em-dashes (period split, colons, or bullets instead).
- Lead with **non-custodial** and **self-hosted LNbits** in both languages so Play reviewers don't mis-classify EmberSpark as an exchange or custodian.
- When a new major feature ships and gets a README bullet, mirror the addition into both languages here before the next Play Console release.

---

## English (en-US)

### Short description (74 / 80)

```
A Lightning wallet for your own LNbits server. Open source, non-custodial.
```

### Full description (~2200 / 4000)

```
EmberSpark is a small, open-source Lightning Network wallet for your own LNbits server. It moves sats through Lightning without holding your money. Every payment goes through the LNbits instance you point it at, and the admin API key stays encrypted on your phone in the Android Keystore.

NON-CUSTODIAL BY DESIGN

EmberSpark itself holds nothing. Your sats live on your LNbits server, which runs on hardware you control or trust. The app is purely a UI client. There is no EmberSpark backend, no centralised accounts, no exchange, no token sale, no on-device mining.

WHAT IT DOES

* Send and receive Lightning payments through your LNbits wallet.
* Pay BOLT11 invoices, BOLT12 offers, LNURL-pay links, and Lightning addresses (user@host).
* Receive via BOLT11 with a QR code. Share your own Lightning address, BOLT12 offer, or LNURL-pay link via QR, copy, system share, or NFC.
* Auto-generate LNURL-pay links and BOLT12 offers from your LNbits server.
* Scan QR codes, paste destinations, decode QR images from your gallery, or read Lightning data from NFC tags.
* Tap any amount to swap between sats and your preferred fiat. USD, EUR, GBP, CHF, CAD, AUD, JPY via mempool.space.
* Save contacts you pay regularly. Edit and delete entries. Each contact shows the same recognisable avatar across devices and across users.
* Manage multiple LNbits wallets in one app with a quick switcher and per-wallet identifiers.

PRIVACY

* No analytics, no ads, no third-party SDKs.
* No EmberSpark servers. The app talks to your LNbits server, mempool.space for exchange rates, and GitHub for update checks. That is the full list.
* Wallet credentials live in the Android Keystore and never leave the device.
* Cloud backup and device-to-device transfer are deliberately disabled. Set the wallet up again on a new device the same way you did the first time.
* Optional biometric or device-PIN lock on app launch.

REQUIREMENTS

* A self-hosted LNbits server with a real Lightning funding source (LND, CLN, Phoenixd, or NWC).
* Your LNbits admin or invoice API key. Scan the QR from LNbits or paste it once at setup.

LANGUAGES

English and German.

OPEN SOURCE

Code, issues, and feature requests on GitHub:
https://github.com/TrepnickKev/EmberSpark
```

---

## Deutsch (de-DE)

### Kurzbeschreibung (73 / 80)

```
Lightning-Wallet für deinen LNbits-Server. Open Source, selbstverwahrend.
```

### Vollständige Beschreibung (~2400 / 4000)

```
EmberSpark ist eine kleine Open-Source-Lightning-Wallet für deinen eigenen LNbits-Server. Sie bewegt Sats über das Lightning Network, ohne dein Geld zu verwahren. Jede Zahlung läuft über die LNbits-Instanz, die du angibst, und der Admin-API-Key bleibt verschlüsselt im Android Keystore auf deinem Telefon.

SELBSTVERWAHREND PER DESIGN

EmberSpark hält nichts. Deine Sats liegen auf deinem LNbits-Server, der auf Hardware läuft, die du kontrollierst oder der du vertraust. Die App ist nur eine Bedienoberfläche. Es gibt keinen EmberSpark-Backend, keine zentralen Konten, keine Börse, keinen Token-Verkauf, kein On-Device-Mining.

WAS SIE KANN

* Lightning-Zahlungen über deine LNbits-Wallet senden und empfangen.
* BOLT11-Rechnungen, BOLT12-Angebote, LNURL-Pay-Links und Lightning-Adressen (user@host) bezahlen.
* Über BOLT11 mit QR-Code empfangen. Eigene Lightning-Adresse, BOLT12-Angebot oder LNURL-Pay-Link via QR, Kopie, System-Teilen oder NFC teilen.
* LNURL-Pay-Links und BOLT12-Angebote automatisch über deinen LNbits-Server erzeugen.
* QR-Codes scannen, Ziele einfügen, QR-Bilder aus der Galerie dekodieren oder Lightning-Daten von NFC-Tags lesen.
* Auf jeden Betrag tippen, um zwischen Sats und deiner bevorzugten Fiat-Währung umzuschalten. USD, EUR, GBP, CHF, CAD, AUD, JPY über mempool.space.
* Kontakte speichern, die du regelmäßig bezahlst. Bearbeiten und löschen. Jeder Kontakt zeigt denselben erkennbaren Avatar geräteübergreifend und nutzerübergreifend.
* Mehrere LNbits-Wallets in einer App mit schnellem Wechsel und wallet-spezifischen Kennungen verwalten.

PRIVATSPHÄRE

* Keine Analytik, keine Werbung, keine Drittanbieter-SDKs.
* Keine EmberSpark-Server. Die App spricht mit deinem LNbits-Server, mit mempool.space für Wechselkurse und mit GitHub für Update-Prüfungen. Das ist die vollständige Liste.
* Wallet-Anmeldedaten liegen im Android Keystore und verlassen das Gerät nicht.
* Cloud-Backup und Geräte-zu-Geräte-Transfer sind bewusst deaktiviert. Richte die Wallet auf einem neuen Gerät genauso ein wie beim ersten Mal.
* Optionaler biometrischer oder Geräte-PIN-Schutz beim App-Start.

VORAUSSETZUNGEN

* Ein selbst gehosteter LNbits-Server mit einem echten Lightning-Funding-Backend (LND, CLN, Phoenixd oder NWC).
* Dein LNbits Admin- oder Invoice-API-Key. Den QR aus LNbits scannen oder einmal beim Setup einfügen.

SPRACHEN

Englisch und Deutsch.

OPEN SOURCE

Code, Issues und Feature-Wünsche auf GitHub:
https://github.com/TrepnickKev/EmberSpark
```
