import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

const supportedLanguageCodes = ['system', 'en', 'de'];
const _languageKey = 'app_language';

/// `null` = follow the device locale.
final ValueNotifier<Locale?> appLocale = ValueNotifier<Locale?>(null);

Future<String> getSelectedLanguageCode() async {
  const storage = FlutterSecureStorage();
  return await storage.read(key: _languageKey) ?? 'system';
}

Future<void> setSelectedLanguage(String code) async {
  const storage = FlutterSecureStorage();
  await storage.write(key: _languageKey, value: code);
  appLocale.value = code == 'system' ? null : Locale(code);
}

/// Seed `appLocale` from persisted storage at app startup.
Future<void> loadInitialLocale() async {
  final code = await getSelectedLanguageCode();
  appLocale.value = code == 'system' ? null : Locale(code);
}
