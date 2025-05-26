import 'package:injectable/injectable.dart';

/// Local database service for offline data storage
@singleton
class LocalDatabase {
  LocalDatabase();

  Future<void> initialize() async {
    // Initialize local database (SQLite, Hive, etc.)
  }

  Future<void> clearAll() async {
    // Clear all local data
  }

  Future<Map<String, dynamic>?> get(String key) async {
    // Get data by key
    return null;
  }

  Future<void> put(String key, Map<String, dynamic> value) async {
    // Store data by key
  }

  Future<void> delete(String key) async {
    // Delete data by key
  }
}
