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

Future<List<Contact>> getContacts() async {
  const storage = FlutterSecureStorage();
  final raw = await storage.read(key: _contactsKey);
  if (raw == null || raw.isEmpty) return const [];
  try {
    final list = jsonDecode(raw) as List;
    return list
        .map((e) => Contact.fromJson(e as Map<String, dynamic>))
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
  final list = List<Contact>.of(await getContacts())..add(c);
  list.sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
  await saveContacts(list);
}

Future<void> deleteContact(int index) async {
  final list = List<Contact>.of(await getContacts());
  if (index < 0 || index >= list.length) return;
  list.removeAt(index);
  await saveContacts(list);
}
