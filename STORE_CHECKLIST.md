# Google Play Store release checklist

The in-repo work for Play Store readiness is complete (AAB build in CI, backup-exclusion rules, R8 + ProGuard, INTERNET permission, pinned targetSdk 35, privacy policy at `docs/privacy.md`). This file documents the steps that happen **outside** the repo.

## One-time setup

- [ ] **Enable GitHub Pages** on `TrepnickKev/EmberSpark` → Settings → Pages → Source: deploy from branch → `main` / `/docs`. After ~1 min the privacy policy is live at:
  `https://trepnickkev.github.io/EmberSpark/privacy`
- [ ] **Register Play Console developer account** ($25 one-time). Verify identity (gov ID + address; ~3 day wait).
- [ ] **Create the app in Play Console**:
  - Package name: `com.emberspark.wallet` *(IRREVERSIBLE — already matches `applicationId`)*
  - App name: `EmberSpark`
  - Category: `Finance`
  - Free / no in-app purchases / no ads
- [ ] **Enroll in Play App Signing** when prompted on first upload. Your `release.keystore` becomes the upload key; Google holds the actual app signing key and can re-issue your upload key if it's ever lost.

## Per-release workflow

1. **Trigger CI**: Actions → "Build & release Android APKs + AAB" → Run workflow → enter version (e.g. `1.1.0`).
2. **Download the AAB** from the resulting GitHub Release: `EmberSpark-v{version}.aab`.
3. **Play Console** → Internal testing → Create new release → upload the AAB.
4. **Release notes**: paste the relevant changelog (Play Console allows per-locale notes; English + Deutsch).

### App-content forms (required, fill once and update on changes)

- [ ] **Privacy policy URL**: `https://trepnickkev.github.io/EmberSpark/privacy`
- [ ] **App access**: declare that the app requires a user-supplied LNbits server URL + API key. Provide reviewers a test LNbits demo URL + invoice key so they can exercise the app without a wallet of their own.
- [ ] **Ads**: No
- [ ] **Content rating** (IARC questionnaire): Finance app, no violence, no gambling content → expect PEGI-3 / ESRB-Everyone.
- [ ] **Target audience**: 18+. Not directed at children.
- [ ] **News app**: No
- [ ] **COVID-19 contact tracing**: No
- [ ] **Data safety form**: declare:
  - No data collected by EmberSpark itself.
  - Data stored on-device only: LNbits URL + key, fiat preference, locale, biometric-lock toggle. Encrypted at rest.
  - Data shared off-device: only to the user's chosen LNbits server (user-configured destination), mempool.space (exchange rates, no PII), and GitHub Releases (update check, no PII).
  - No third-party analytics / advertising / crash reporting.
- [ ] **Government app**: No
- [ ] **Financial features**: Yes → "I provide a wallet for cryptocurrency". Declare it as a **non-custodial** client for a user-operated LNbits server (no in-app exchange, no token sale, no on-device mining).

### Store listing assets (need to be produced)

- [ ] **Short description** (≤ 80 chars)
- [ ] **Full description** (≤ 4000 chars)
- [ ] **2–8 phone screenshots** (PNG / JPEG, 16:9 or 9:16). Suggested: Send, Receive, History, My contact, Settings.
- [ ] **7" tablet screenshots** (optional)
- [ ] **10" tablet screenshots** (optional)
- [ ] **Feature graphic**: 1024×500 PNG/JPG (no alpha)
- [ ] **High-res app icon**: 512×512 PNG with alpha (Play crops corners itself — do not pre-round)
- [ ] **Promo video**: YouTube URL (optional)

## Testing track gate

New Play Console developer accounts are subject to a **closed-testing requirement** before production rollout is unlocked:

- **Internal testing** track: up to 100 testers, instant. Use this for your own smoke tests.
- **Closed testing** track: ≥ 12 testers × ≥ 14 days. Required before the "Production" track becomes available for new developers.
- **Production**: staged rollout 1% → 5% → 20% → 100% over a few days.

## Per-release smoke checklist (before promoting Internal → Closed)

- [ ] Login via QR scan (mobile_scanner under R8)
- [ ] Receive: create an invoice (HTTP + secure_storage under R8)
- [ ] Send: pay a 1-sat invoice (HTTP + bolt11 decode under R8)
- [ ] My contact → NFC write (nfc_manager under R8)
- [ ] Settings → App Lock toggle (local_auth BiometricPrompt under R8)
- [ ] Receive: fiat amount preview updates (mempool.space fetch)
- [ ] About screen: version matches the release tag

If any path crashes only in release+R8, add the missing `-keep` rule to `android/app/proguard-rules.pro` and rebuild.

## Annual maintenance

- **`targetSdk` bump**: Play raises the floor each August. Update `android/app/build.gradle.kts:targetSdk` before that year's deadline.
- **Privacy policy review**: re-check `docs/privacy.md` whenever a new permission, network endpoint, or data field is added.
