import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import '../models/Lieu.dart';

class LieuxDatabase {
  static Database? _db;

  static Future<Database> get database async {
    if (_db != null) return _db!;

    final path = join(await getDatabasesPath(), 'lieux.db');

    _db = await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) {
        return db.execute('''
          CREATE TABLE lieux(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            name TEXT,
            category TEXT,
            lat REAL,
            lon REAL,
            city TEXT
          )
        ''');
      },
    );

    return _db!;
  }

  // INSERTION
  static Future<void> insertLieu(Lieu lieu) async {
    final db = await database;
    await db.insert(
      'lieux',
      lieu.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  // SELECT ALL
  static Future<List<Lieu>> lieuxForCity(String city) async {
    final db = await database;

    final maps = await db.query('lieux', where: 'city = ?', whereArgs: [city]);

    return maps.map((m) => Lieu.fromMap(m)).toList();
  }

  // DELETE
  static Future<void> deleteLieu(int id) async {
    final db = await database;
    await db.delete('lieux', where: 'id = ?', whereArgs: [id]);
  }
}
