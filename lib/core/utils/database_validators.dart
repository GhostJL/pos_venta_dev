import 'package:sqflite/sqflite.dart';

/// Utility class for common database validation operations
class DatabaseValidators {
  /// Validates if a field value is unique in a table
  ///
  /// Returns `true` if the value is unique (not found in the table).
  /// Returns `false` if the value already exists.
  ///
  /// Parameters:
  /// - [db]: Database instance to query
  /// - [tableName]: Name of the table to check
  /// - [fieldName]: Name of the field to validate
  /// - [value]: Value to check for uniqueness
  /// - [excludeId]: Optional ID to exclude from check (useful for updates)
  ///
  /// Example:
  /// ```dart
  /// final isUnique = await DatabaseValidators.isFieldUnique(
  ///   db: db,
  ///   tableName: 'products',
  ///   fieldName: 'code',
  ///   value: 'PROD001',
  ///   excludeId: 5, // Exclude product with ID 5 from check
  /// );
  /// ```
  static Future<bool> isFieldUnique({
    required Database db,
    required String tableName,
    required String fieldName,
    required String value,
    int? excludeId,
  }) async {
    final List<Object> whereArgs = [value];
    var whereClause = '$fieldName = ?';

    if (excludeId != null) {
      whereClause += ' AND id != ?';
      whereArgs.add(excludeId);
    }

    final count = Sqflite.firstIntValue(
      await db.rawQuery(
        'SELECT COUNT(*) FROM $tableName WHERE $whereClause',
        whereArgs,
      ),
    );

    return count == 0;
  }
}
