import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class AlarmDatabase {
  static final AlarmDatabase _instance = AlarmDatabase._internal();
  factory AlarmDatabase() => _instance;
  AlarmDatabase._internal();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB();
    return _database!;
  }

  Future<Database> _initDB() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'alarms.db');

    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
    );
  }

  Future _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE alarms(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        hour INTEGER,
        minute INTEGER,
        am_pm TEXT,
        is_active INTEGER
      )
    ''');
  }

  // Insert alarm
  Future<int> insertAlarm(Map<String, dynamic> alarm) async {
    final db = await database;
    return await db.insert('alarms', alarm,
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  // Get all alarms
  Future<List<Map<String, dynamic>>> getAlarms() async {
    final db = await database;
    return await db.query('alarms');
  }

  // Update alarm
  Future<int> updateAlarm(Map<String, dynamic> alarm) async {
    final db = await database;
    return await db.update(
      'alarms',
      alarm,
      where: 'id = ?',
      whereArgs: [alarm['id']],
    );
  }

  // Delete alarm
  Future<int> deleteAlarm(int id) async {
    final db = await database;
    return await db.delete('alarms', where: 'id = ?', whereArgs: [id]);
  }
}
