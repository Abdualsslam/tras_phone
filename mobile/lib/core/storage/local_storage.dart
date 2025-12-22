/// Local Storage wrapper using SharedPreferences
library;

import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class LocalStorage {
  late SharedPreferences _prefs;

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  // String
  Future<bool> setString(String key, String value) {
    return _prefs.setString(key, value);
  }

  String? getString(String key) {
    return _prefs.getString(key);
  }

  // Int
  Future<bool> setInt(String key, int value) {
    return _prefs.setInt(key, value);
  }

  int? getInt(String key) {
    return _prefs.getInt(key);
  }

  // Double
  Future<bool> setDouble(String key, double value) {
    return _prefs.setDouble(key, value);
  }

  double? getDouble(String key) {
    return _prefs.getDouble(key);
  }

  // Bool
  Future<bool> setBool(String key, bool value) {
    return _prefs.setBool(key, value);
  }

  bool? getBool(String key) {
    return _prefs.getBool(key);
  }

  // String List
  Future<bool> setStringList(String key, List<String> value) {
    return _prefs.setStringList(key, value);
  }

  List<String>? getStringList(String key) {
    return _prefs.getStringList(key);
  }

  // JSON Object
  Future<bool> setObject(String key, Map<String, dynamic> value) {
    return _prefs.setString(key, jsonEncode(value));
  }

  Map<String, dynamic>? getObject(String key) {
    final String? jsonStr = _prefs.getString(key);
    if (jsonStr == null) return null;
    return jsonDecode(jsonStr) as Map<String, dynamic>;
  }

  // JSON List
  Future<bool> setObjectList(String key, List<Map<String, dynamic>> value) {
    return _prefs.setString(key, jsonEncode(value));
  }

  List<Map<String, dynamic>>? getObjectList(String key) {
    final String? jsonStr = _prefs.getString(key);
    if (jsonStr == null) return null;
    final List<dynamic> list = jsonDecode(jsonStr);
    return list.cast<Map<String, dynamic>>();
  }

  // Remove
  Future<bool> remove(String key) {
    return _prefs.remove(key);
  }

  // Clear all
  Future<bool> clear() {
    return _prefs.clear();
  }

  // Check if key exists
  bool containsKey(String key) {
    return _prefs.containsKey(key);
  }
}
