import '../services/database_service.dart';
import '../models/user_record.dart';
import '../services/attendance_service.dart'; // Import the attendance service


class RFIDService {
  final DatabaseService _databaseService = DatabaseService.instance;

  /// Ensure the table `attendance` exists and fetch user data by RFID code.
  Future<UserRecord?> getUserData(String rfidCode) async {
    try {
      final db = await _databaseService.database;
      print(rfidCode);

      // Ensure the `attendance` table exists
      await db.execute(''' 
        CREATE TABLE IF NOT EXISTS attendance (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          id_user INTEGER NOT NULL,
          is_checkin BOOLEAN DEFAULT 1,
          checkin_time DATETIME,
          checkout_time DATETIME,
          created_at DATETIME,
          isLocal BOOLEAN DEFAULT 1,
          FOREIGN KEY (id_user) REFERENCES africasystem(id) ON DELETE CASCADE ON UPDATE CASCADE
        )
      ''');

      // Query user data by RFID code
      final List<Map<String, dynamic>> result = await db.rawQuery(
        'SELECT * FROM africasystem WHERE rfidcode = ?',
        [rfidCode],
      );

      if (result.isNotEmpty) {
        print("Il y a des données");

        // Convert the first matching result to a UserRecord object
        UserRecord userRecord = UserRecord.fromMap(result.first);

        // Call handleCreateAttendanceCorrect function
        final attendanceResult = await AttendanceService.instance.handleCreateAttendanceCorrect(
          userRecord.id,  // Pass the user ID from the UserRecord
          userRecord.name, // Pass the user name from the UserRecord
          db,              // Pass the database instance
        );

        // Log the result of the attendance check
        print(attendanceResult['message']);

        return userRecord;
      } else {
        print("Aucun utilisateur trouvé");
        return null;
      }
    } catch (e) {
      throw Exception('Erreur base de données : $e');
    }
  }
}
