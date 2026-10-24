import 'dart:convert';

import 'package:package_info_plus/package_info_plus.dart';

import 'http_client_factory.dart';

const _repoReleasesApi =
    'https://api.github.com/repos/TrepnickKev/EmberSpark/releases/latest';
const _repoReleasesUrl =
    'https://github.com/TrepnickKev/EmberSpark/releases/latest';

class VersionInfo {
  /// Version baked into this build (from pubspec, possibly overridden at
  /// build time via `--build-name`).
  final String current;

  /// Tag name of the latest GitHub Release, without the leading `v`.
  /// Null if the check didn't reach GitHub or no release exists yet.
  final String? latest;

  /// True only when [latest] is parseable as semver and strictly newer than
  /// [current].
  final bool updateAvailable;

  /// `html_url` of the latest release, for "Open release" linking. Falls back
  /// to the generic /releases/latest URL when the API didn't return one.
  final String? releaseUrl;

  /// True when the check itself failed (offline, 5xx, etc.) — UI shows a
  /// muted "Couldn't check for updates" rather than implying up-to-date.
  final bool checkFailed;

  /// Name of the store that installed the app and handles its updates (Google
  /// Play, F-Droid), or null for sideloads. When set, the in-app GitHub-release
  /// check is skipped.
  final String? store;

  const VersionInfo({
    required this.current,
    required this.latest,
    required this.updateAvailable,
    required this.releaseUrl,
    required this.checkFailed,
    this.store,
  });
}

/// F-Droid builds pass `--dart-define=ES_UPDATE_CHECK=false`: F-Droid signs
/// with its own key, so GitHub APKs can't update them.
const _updateCheckEnabled =
    bool.fromEnvironment('ES_UPDATE_CHECK', defaultValue: true);

/// Installer package names of F-Droid and its common alternative clients.
const _fdroidInstallers = {
  'org.fdroid.fdroid',
  'org.fdroid.basic',
  'com.looker.droidify',
  'com.machiav3lli.fdroid',
};

/// The store that manages updates for this install, or null for sideloads.
String? _managingStore(String? installer) {
  if (installer == 'com.android.vending') return 'Google Play';
  if (!_updateCheckEnabled || _fdroidInstallers.contains(installer)) {
    return 'F-Droid';
  }
  return null;
}

Future<String> getCurrentVersion() async {
  final info = await PackageInfo.fromPlatform();
  return info.version;
}

/// On-demand check: fetches the latest release from GitHub and compares to
/// the version baked into this build. Never throws — failure modes are
/// folded into the returned [VersionInfo].
Future<VersionInfo> checkForUpdate() async {
  final packageInfo = await PackageInfo.fromPlatform();
  final current = packageInfo.version;

  // Installed from Google Play or F-Droid? Then the store handles updates, so
  // skip the in-app GitHub-release check entirely (Play policy forbids
  // prompting sideload updates, and F-Droid installs carry F-Droid's key).
  // Sideloads (other installer, or null for adb/desktop) fall through to the
  // GitHub check.
  final store = _managingStore(packageInfo.installerStore);
  if (store != null) {
    return VersionInfo(
      current: current,
      latest: null,
      updateAvailable: false,
      releaseUrl: null,
      checkFailed: false,
      store: store,
    );
  }

  try {
    final client = await getHttpClient();
    final res = await client
        .get(Uri.parse(_repoReleasesApi), headers: browserLikeHeaders)
        .timeout(const Duration(seconds: 10));
    if (res.statusCode == 404) {
      // No releases yet — not an error from the user's perspective.
      return VersionInfo(
        current: current,
        latest: null,
        updateAvailable: false,
        releaseUrl: _repoReleasesUrl,
        checkFailed: false,
      );
    }
    if (res.statusCode != 200) {
      return VersionInfo(
        current: current,
        latest: null,
        updateAvailable: false,
        releaseUrl: _repoReleasesUrl,
        checkFailed: true,
      );
    }
    final data = jsonDecode(res.body) as Map<String, dynamic>;
    final tag = (data['tag_name'] as String?) ?? '';
    final latest = tag.replaceFirst(RegExp(r'^v'), '');
    final url = (data['html_url'] as String?) ?? _repoReleasesUrl;
    return VersionInfo(
      current: current,
      latest: latest.isEmpty ? null : latest,
      updateAvailable: latest.isNotEmpty && _isNewer(latest, current),
      releaseUrl: url,
      checkFailed: false,
    );
  } catch (_) {
    return VersionInfo(
      current: current,
      latest: null,
      updateAvailable: false,
      releaseUrl: _repoReleasesUrl,
      checkFailed: true,
    );
  }
}

/// Semver-style integer compare per dot-separated segment. Trailing build
/// suffixes after `+` or `-` are ignored. Empty / unparseable segments
/// compare as 0.
bool _isNewer(String latest, String current) {
  final a = _parts(latest);
  final b = _parts(current);
  final len = a.length > b.length ? a.length : b.length;
  for (var i = 0; i < len; i++) {
    final ai = i < a.length ? a[i] : 0;
    final bi = i < b.length ? b[i] : 0;
    if (ai > bi) return true;
    if (ai < bi) return false;
  }
  return false;
}

List<int> _parts(String v) {
  // Strip everything after `+` or `-` (build metadata / prerelease tags).
  final clean = v.split(RegExp(r'[+-]')).first;
  return clean.split('.').map((s) => int.tryParse(s) ?? 0).toList();
}
