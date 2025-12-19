/// Secure Storage wrapper using flutter_secure_storage
library;

import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecureStorage {
  late FlutterSecureStorage _storage;

  SecureStorage() {
    _storage = const FlutterSecureStorage(
      aOptions: AndroidOptions(encryptedSharedPreferences: true),
      iOptions: IOSOptions(accessibility: KeychainAccessibility.first_unlock),
    );
  }

  // Write
  Future<void> write(String key, String value) async {
    await _storage.write(key: key, value: value);
  }

  // Read
  Future<String?> read(String key) async {
    return await _storage.read(key: key);
  }

  // Delete
  Future<void> delete(String key) async {
    await _storage.delete(key: key);
  }

  // Delete all
  Future<void> deleteAll() async {
    await _storage.deleteAll();
  }

  // Check if key exists
  Future<bool> containsKey(String key) async {
    return await _storage.containsKey(key: key);
  }

  // Read all
  Future<Map<String, String>> readAll() async {
    return await _storage.readAll();
  }
}
