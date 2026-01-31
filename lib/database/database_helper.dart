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

    // User Profile Table
    await db.execute('''
      CREATE TABLE user_profile (
        id INTEGER PRIMARY KEY DEFAULT 1,
        name TEXT,
        blood_group TEXT,
        emergency_contact TEXT,
        medical_notes TEXT,
        telegram_chat_id TEXT
      )
    ''');

    // Emergency Logs Table
    await db.execute('''
      CREATE TABLE emergency_logs (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        timestamp TEXT,
        trigger_reason TEXT,
        latitude REAL,
        longitude REAL,
        status TEXT
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

  // --- Profile Methods ---
  Future<void> saveProfile(Map<String, dynamic> profile) async {
    final db = await database;
    profile['id'] = 1;
    await db.insert('user_profile', profile,
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<Map<String, dynamic>?> getProfile() async {
    final db = await database;
    final res = await db.query('user_profile', where: 'id = ?', whereArgs: [1]);
    if (res.isNotEmpty) return res.first;
    return null;
  }

  Future<void> logEmergency(
      String reason, double lat, double lng, String status) async {
    final db = await database;
    await db.insert('emergency_logs', {
      'timestamp': DateTime.now().toIso8601String(),
      'trigger_reason': reason,
      'latitude': lat,
      'longitude': lng,
      'status': status,
    });
  }
}
