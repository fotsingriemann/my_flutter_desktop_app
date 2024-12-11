import '../models/user_record.dart';
import 'database_service.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart'; // Import for ConflictAlgorithm

class StorageService {
  static final StorageService instance = StorageService._init();
  final DatabaseService _databaseService = DatabaseService.instance;

  StorageService._init();

  /// Fetch all user records from the `africasystem` table.
  Future<List<UserRecord>> getAllRecords() async {
    final db = await _databaseService.database;

    try {
      final List<Map<String, dynamic>> maps = await db.query(
        'attendance',
        orderBy: 'id ASC', // Modify the ordering if necessary
      );
      return List.generate(maps.length, (i) => UserRecord.fromMap(maps[i]));
    } catch (e) {
      print('Error fetching records: $e');
      return [];
    }
  }

  /// Insert a new user record into the `africasystem` table.
  Future<void> insertRecord(UserRecord record) async {
    final db = await _databaseService.database;

    try {
      await db.insert(
        'africasystem',
        record.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    } catch (e) {
      print('Error inserting record: $e');
    }
  }
}
