import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;
  
  static Database? _database;

  DatabaseHelper._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentsDirectory.path, "driver_guard.db");
    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }

  Future _onCreate(Database db, int version) async {
    // Session Table
    await db.execute('''
      CREATE TABLE sessions (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        startTime TEXT,
        endTime TEXT
      )
    ''');
    
    // Events Table
    await db.execute('''
      CREATE TABLE events (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        sessionId INTEGER,
        type TEXT,
        value REAL,
        timestamp TEXT
      )
    ''');
  }

  Future<int> startSession() async {
    final db = await database;
    return await db.insert('sessions', {
      'startTime': DateTime.now().toIso8601String(),
    });
  }

  Future<void> endSession(int sessionId) async {
    final db = await database;
    await db.update(
      'sessions',
      {'endTime': DateTime.now().toIso8601String()},
      where: 'id = ?',
      whereArgs: [sessionId],
    );
  }

  Future<void> logEvent(int sessionId, String type, double? value) async {
    final db = await database;
    await db.insert('events', {
      'sessionId': sessionId,
      'type': type,
      'value': value,
      'timestamp': DateTime.now().toIso8601String(),
    });
  }
}
