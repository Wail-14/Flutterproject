import 'package:flutter/foundation.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:sqflite_common_ffi_web/sqflite_ffi_web.dart';

import 'Lieu.dart';

class LieuxDatabase {
  static Database? _db;

  static Future<Database> get database async {
    if (_db != null) return _db!;

    // --- CHOIX DE LA FACTORY SELON LA PLATFORME ---
    if (kIsWeb) {
      databaseFactory = databaseFactoryFfiWeb;
    } else if (!kIsWeb &&
        (defaultTargetPlatform == TargetPlatform.linux ||
            defaultTargetPlatform == TargetPlatform.windows ||
            defaultTargetPlatform == TargetPlatform.macOS)) {
      sqfliteFfiInit();
      databaseFactory = databaseFactoryFfi;
    }

    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'lieux_web.db');

    _db = await databaseFactory.openDatabase(
      path,
      options: OpenDatabaseOptions(
        version: 1,
        onCreate: (db, version) async {
          await _createTable(db);
        },
        onOpen: (db) async {
          await _createTable(db); // <-- FORCÉ sur Web
        },
      ),
    );

    return _db!;
  }

  // ---- Création de la table (FORCÉE) ----
  static Future<void> _createTable(Database db) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS lieux(
        id INTEGER PRIMARY KEY,
        name TEXT,
        category TEXT,
        lat REAL,
        lon REAL,
        city TEXT
      )
    ''');
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
