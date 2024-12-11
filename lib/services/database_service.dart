import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:path/path.dart';
import '../models/user_record.dart';

class DatabaseService {
  static final DatabaseService instance = DatabaseService._init();
  static Database? _database;

  DatabaseService._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('rfid_records.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    sqfliteFfiInit(); // Ensure FFI is initialized
    databaseFactory = databaseFactoryFfi; // Use FFI for desktop
    final dbPath = await databaseFactory.getDatabasesPath();
    final path = join(dbPath, filePath);

    return await databaseFactory.openDatabase(
      path,
      options: OpenDatabaseOptions(
        version: 1,
        onCreate: _createDB,
      ),
    );
  }

  Future<void> _createDB(Database db, int version) async {
    // Create the table
    print("creation de la table");
    await db.execute('''
        CREATE TABLE IF NOT EXISTS africasystem (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT,
        rfidcode TEXT,
        image TEXT,
        description TEXT
        );
    ''');

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
    ''');
  }

}
