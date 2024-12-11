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
        CREATE TABLE IF NOT EXISTS attendance_log (
                id INTEGER PRIMARY KEY AUTOINCREMENT,
                nom TEXT,
                datetime DATETIME DEFAULT CURRENT_TIMESTAMP,
                activity_name TEXT,
                rfid_code TEXT NOT NULL,
                status TEXT,
                message TEXT
            );
      ''');

            await db.execute(''' 
        CREATE TABLE IF NOT EXISTS attendance_students (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            id_user INTEGER NOT NULL,
            make_attendance_id INTEGER,
            is_checkin BOOLEAN DEFAULT 1,
            checkin_time DATETIME,
            checkout_time DATETIME,
            created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
            updated_at DATETIME DEFAULT CURRENT_TIMESTAMP,
            isLocal BOOLEAN DEFAULT 1,
            longitude TEXT,
            latitude TEXT,
            UNIQUE (id_user, checkin_time),
            FOREIGN KEY (id_user) REFERENCES respartner(id) ON DELETE CASCADE ON UPDATE CASCADE)
      ''');

      await db.execute('''
CREATE TABLE IF NOT EXISTS Users (
                id INTEGER PRIMARY KEY AUTOINCREMENT, 
                name TEXT, 
                email TEXT, 
                partner_id TEXT,
                phone TEXT,
                role TEXT,
                password TEXT
                );

      ''');

      
await db.execute('''
  CREATE TABLE IF NOT EXISTS students (
                id INTEGER PRIMARY KEY AUTOINCREMENT,
                name TEXT,
                rfidcode TEXT ,
                image TEXT
            );
''');
      
await db.execute('''
  CREATE TABLE IF NOT EXISTS respartner (
                id INTEGER PRIMARY KEY AUTOINCREMENT,
                name TEXT,
                rfidcode TEXT ,
                rfidcode_num TEXT ,
                image TEXT,
                type TEXT
            );
''');
      
      // Query user data by RFID code
      final List<Map<String, dynamic>> result = await db.rawQuery(
        'SELECT * FROM respartner WHERE rfidcode = ? OR rfidcode_num= ? ;',
        [rfidCode, rfidCode],
      );

      if (result.isNotEmpty) {
        print("Il y a des données");

        // Convert the first matching result to a UserRecord object
        UserRecord userRecord = UserRecord.fromMap(result.first);

        // Call handleCreateAttendanceCorrect function
        final attendanceResult = await AttendanceService.instance.handleCreateAttendanceCorrect(
          userRecord.id,  // Pass the user ID from the UserRecord
          db,
          userRecord.name, // Pass the user name from the UserRecord
          rfidCode,
          null,  // This is acceptable if the parameter can accept null
          2,
          null,  // This is acceptable if the parameter can accept null
          null,
          false           // Pass the database instance
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
