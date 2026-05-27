import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class Contact {
  /// Display name.
  final String name;

  /// Lightning address, LNURL, or BOLT11. Routed via `routeLightningCode`
  /// when the user picks the contact.
  final String destination;

  const Contact({required this.name, required this.destination});

  Map<String, dynamic> toJson() => {
        'name': name,
        'destination': destination,
      };

  factory Contact.fromJson(Map<String, dynamic> j) => Contact(
        name: j['name'] as String? ?? '',
        destination: j['destination'] as String? ?? '',
      );
}

const _contactsKey = 'contacts_v1';

/// Removes the `lightning:` / `lnurl:` URI-scheme prefix from a destination.
/// The prefix is metadata, not part of the destination, and showing it in
/// the saved contact's subtitle looks like a bug to users. Case-preserving
/// (case still matters in some bech32 contexts; only the scheme is dropped).
String _stripLightningPrefix(String s) => s.trim().replaceFirst(
      RegExp(r'^(lightning|lnurl):', caseSensitive: false),
      '',
    );

Contact _normalize(Contact c) =>
    Contact(name: c.name, destination: _stripLightningPrefix(c.destination));

Future<List<Contact>> getContacts() async {
  const storage = FlutterSecureStorage();
  final raw = await storage.read(key: _contactsKey);
  if (raw == null || raw.isEmpty) return const [];
  try {
    final list = jsonDecode(raw) as List;
    return list
        .map((e) => Contact.fromJson(e as Map<String, dynamic>))
        .map(_normalize)
        .toList();
  } catch (_) {
    return const [];
  }
}

Future<void> saveContacts(List<Contact> contacts) async {
  const storage = FlutterSecureStorage();
  final raw = jsonEncode(contacts.map((c) => c.toJson()).toList());
  await storage.write(key: _contactsKey, value: raw);
}

Future<void> addContact(Contact c) async {
  final list = List<Contact>.of(await getContacts())..add(_normalize(c));
  list.sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
  await saveContacts(list);
}

Future<void> updateContact(int index, Contact c) async {
  final list = List<Contact>.of(await getContacts());
  if (index < 0 || index >= list.length) return;
  list[index] = _normalize(c);
  list.sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
  await saveContacts(list);
}

Future<void> deleteContact(int index) async {
  final list = List<Contact>.of(await getContacts());
  if (index < 0 || index >= list.length) return;
  list.removeAt(index);
  await saveContacts(list);
}

/// Serializes contacts to the EmberSpark export format (pretty-printed).
String exportContactsJson(List<Contact> contacts) =>
    const JsonEncoder.withIndent('  ').convert({
      'app': 'EmberSpark',
      'type': 'contacts',
      'version': 1,
      'contacts': contacts.map((c) => c.toJson()).toList(),
    });

/// Parses an exported contacts file. Accepts either the wrapped object
/// (`{"contacts":[...]}`) or a bare array. Throws [FormatException] if the
/// shape is unrecognized. Skips entries missing a name or destination.
List<Contact> parseContactsJson(String raw) {
  final decoded = jsonDecode(raw);
  final List items;
  if (decoded is List) {
    items = decoded;
  } else if (decoded is Map && decoded['contacts'] is List) {
    items = decoded['contacts'] as List;
  } else {
    throw const FormatException('Unrecognized contacts file');
  }
  return items
      .whereType<Map<String, dynamic>>()
      .map(Contact.fromJson)
      .map(_normalize)
      .where((c) => c.name.isNotEmpty && c.destination.isNotEmpty)
      .toList();
}

/// Merges [incoming] into the saved contacts, skipping any whose
/// destination (prefix-stripped, lower-cased) already exists. Never removes
/// existing contacts. Returns how many were actually added.
Future<int> importContacts(List<Contact> incoming) async {
  final merged = List<Contact>.of(await getContacts());
  String key(Contact c) => _stripLightningPrefix(c.destination).toLowerCase();
  final seen = merged.map(key).toSet();
  var added = 0;
  for (final c in incoming.map(_normalize)) {
    if (c.destination.isEmpty || !seen.add(key(c))) continue;
    merged.add(c);
    added++;
  }
  merged.sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
  await saveContacts(merged);
  return added;
}
