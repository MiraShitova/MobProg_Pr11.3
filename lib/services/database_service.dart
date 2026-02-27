import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import '../models/library_book.dart';

class DatabaseService {
  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'library_v4.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute(
          'CREATE TABLE users(id INTEGER PRIMARY KEY AUTOINCREMENT, email TEXT UNIQUE, password TEXT)',
        );
        await db.execute(
          'CREATE TABLE library_books(id TEXT PRIMARY KEY, bookId TEXT, title TEXT, authors TEXT, coverUrl TEXT, status TEXT, rating REAL, notes TEXT, userId TEXT)',
        );
      },
    );
  }

  Future<int> registerUser(String email, String password) async {
    final db = await database;
    try {
      return await db.insert('users', {'email': email, 'password': password});
    } catch (e) {
      return -1;
    }
  }

  Future<Map<String, dynamic>?> loginUser(String email, String password) async {
    final db = await database;
    final List<Map<String, dynamic>> results = await db.query(
      'users',
      where: 'email = ? AND password = ?',
      whereArgs: [email, password],
    );
    return results.isNotEmpty ? results.first : null;
  }

  Future<void> saveBookToLocal(LibraryBook book, String userId) async {
    final db = await database;
    final map = book.toMap();
    map['userId'] = userId;
    await db.insert('library_books', map, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<List<LibraryBook>> getAllLocalBooks(String userId) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'library_books',
      where: 'userId = ?',
      whereArgs: [userId],
    );
    return List.generate(maps.length, (i) => LibraryBook.fromMap(maps[i]));
  }

  Future<void> deleteLocalBook(String id) async {
    final db = await database;
    await db.delete('library_books', where: 'id = ?', whereArgs: [id]);
  }
}
