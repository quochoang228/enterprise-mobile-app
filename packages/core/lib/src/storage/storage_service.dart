import 'package:injectable/injectable.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Simple key-value storage service for persisting lists and simple data
@singleton
class StorageService {
  SharedPreferences? _prefs;

  StorageService();

  Future<void> _ensureInitialized() async {
    _prefs ??= await SharedPreferences.getInstance();
  }

  /// Get a list of strings by key
  Future<List<String>?> getStringList(String key) async {
    await _ensureInitialized();
    return _prefs!.getStringList(key);
  }

  /// Set a list of strings by key
  Future<void> setStringList(String key, List<String> value) async {
    await _ensureInitialized();
    await _prefs!.setStringList(key, value);
  }

  /// Get a string value by key
  Future<String?> getString(String key) async {
    await _ensureInitialized();
    return _prefs!.getString(key);
  }

  /// Set a string value by key
  Future<void> setString(String key, String value) async {
    await _ensureInitialized();
    await _prefs!.setString(key, value);
  }

  /// Get an integer value by key
  Future<int?> getInt(String key) async {
    await _ensureInitialized();
    return _prefs!.getInt(key);
  }

  /// Set an integer value by key
  Future<void> setInt(String key, int value) async {
    await _ensureInitialized();
    await _prefs!.setInt(key, value);
  }

  /// Get a boolean value by key
  Future<bool?> getBool(String key) async {
    await _ensureInitialized();
    return _prefs!.getBool(key);
  }

  /// Set a boolean value by key
  Future<void> setBool(String key, bool value) async {
    await _ensureInitialized();
    await _prefs!.setBool(key, value);
  }

  /// Get a double value by key
  Future<double?> getDouble(String key) async {
    await _ensureInitialized();
    return _prefs!.getDouble(key);
  }

  /// Set a double value by key
  Future<void> setDouble(String key, double value) async {
    await _ensureInitialized();
    await _prefs!.setDouble(key, value);
  }

  /// Remove a value by key
  Future<void> remove(String key) async {
    await _ensureInitialized();
    await _prefs!.remove(key);
  }

  /// Clear all stored values
  Future<void> clear() async {
    await _ensureInitialized();
    await _prefs!.clear();
  }

  /// Check if a key exists
  Future<bool> containsKey(String key) async {
    await _ensureInitialized();
    return _prefs!.containsKey(key);
  }

  /// Get all keys
  Future<Set<String>> getKeys() async {
    await _ensureInitialized();
    return _prefs!.getKeys();
  }
}
