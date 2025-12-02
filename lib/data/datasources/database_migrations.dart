import 'package:sqflite/sqflite.dart';

class DatabaseMigrations {
  static Future<void> processMigrations(
    Database db,
    int oldVersion,
    int newVersion,
  ) async {
    // Migrations will be handled here in the future.
    // Currently empty as per requirements to eliminate past migrations.
  }
}
