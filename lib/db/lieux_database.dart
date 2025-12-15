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
      version: 2, //  Version 2 pour créer la nouvelle table
      onCreate: (db, version) async {
        // TABLE DES LIEUX
        await db.execute('''
          CREATE TABLE lieux(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            name TEXT,
            category TEXT,
            lat REAL,
            lon REAL,
            city TEXT
          )
        ''');

        //  TABLE DES COMMENTAIRES + NOTES
        await db.execute('''
          CREATE TABLE reviews(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            lieuId INTEGER,
            rating REAL,
            comment TEXT
          )
        ''');
      },

      //  Si la BD existait déjà → créer reviews
      onUpgrade: (db, oldVersion, newVersion) async {
        if (oldVersion < 2) {
          await db.execute('''
            CREATE TABLE reviews(
              id INTEGER PRIMARY KEY AUTOINCREMENT,
              lieuId INTEGER,
              rating REAL,
              comment TEXT
            )
          ''');
        }
      },
    );

    return _db!;
  }

  // ==========================
  // INSERTION LIEU
  // ==========================
  static Future<void> insertLieu(Lieu lieu) async {
    final db = await database;
    await db.insert(
      'lieux',
      lieu.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  // ==========================
  // SELECT LIEUX PAR VILLE
  // ==========================
  static Future<List<Lieu>> lieuxForCity(String city) async {
    final db = await database;

    final maps = await db.query('lieux', where: 'city = ?', whereArgs: [city]);

    return maps.map((m) => Lieu.fromMap(m)).toList();
  }

  // ==========================
  // DELETE LIEU
  // ==========================
  static Future<void> deleteLieu(int id) async {
    final db = await database;
    await db.delete('lieux', where: 'id = ?', whereArgs: [id]);
  }

  // ============================================================
  //  FONCTIONS POUR COMMENTAIRES ET NOTES
  // ============================================================

  // Ajouter un commentaire et une note
  static Future<void> addReview(
    int lieuId,
    double rating,
    String comment,
  ) async {
    final db = await database;
    await db.insert("reviews", {
      "lieuId": lieuId,
      "rating": rating,
      "comment": comment,
    });
  }

  // Charger tous les avis d’un lieu
  static Future<List<Map<String, Object?>>> getReviews(int lieuId) async {
    final db = await database;

    return await db.query(
      "reviews",
      where: "lieuId = ?",
      whereArgs: [lieuId],
      orderBy: "id DESC",
    );
  }

  // Calculer la note moyenne
  static Future<double> getAverageRating(int lieuId) async {
    final db = await database;

    final res = await db.rawQuery(
      "SELECT AVG(rating) AS avg FROM reviews WHERE lieuId = ?",
      [lieuId],
    );

    final avg = res.first["avg"];
    return avg == null ? 0 : (avg as num).toDouble();
  }
}
