import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class FavoritesHelper {
  Database? _database;

  Future<void> open() async {
    if (_database == null) {
      final databasesPath = await getDatabasesPath();
      final path = join(databasesPath, 'favorites.db');
      _database = await openDatabase(path, version: 1, onCreate: _onCreate);
    }
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE favorites (
        id INTEGER PRIMARY KEY,
        name TEXT,
        gender TEXT,
        intelligence TEXT,
        image TEXT
      )
    ''');
  }

  Future<List<Map<String, dynamic>>> getFavorites() async {
    await open();
    return await _database!.query('favorites');
  }

  Future<void> deleteFromFavorites(int id) async {
    await open();
    await _database!.delete('favorites', where: 'id = ?', whereArgs: [id]);
  }

  Future<bool> isFavorite(String heroName) async {
    await open();

    final result = await _database!.query(
      'favorites',
      where: 'name = ?',
      whereArgs: [heroName],
    );

    return result.isNotEmpty;
  }

  Future<void> addToFavorite(Map<String, dynamic> hero) async {
    await open();

    final existingHero = await _database!.query(
      'favorites',
      where: 'name = ?',
      whereArgs: [hero['name']],
    );

    if (existingHero.isEmpty) {
      await _database?.insert(
        'favorites',
        {
          'name': hero['name'],
          'gender': hero['appearance']['gender'],
          'intelligence': hero['powerstats']['intelligence'],
          'image': hero['image']['url'],
        },

      );
    } else {
      print("El hero ya esta en favoritos");
    }
  }
}
