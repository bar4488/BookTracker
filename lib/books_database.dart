import 'dart:async';
import 'models/book.dart';
import 'models/reading_session.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class LocalDatabase{

  static Future<Database> database;

  LocalDatabase(){
    if(database == null)
      database = _initDatabase();
  }

  Future<Database> _initDatabase() async{
    return openDatabase(
      // Set the path to the database. Note: Using the `join` function from the
      // `path` package is best practice to ensure the path is correctly
      // constructed for each platform.
        join(await getDatabasesPath(), 'books_database.db'),
      // When the database is first created, create a table to store dogs.
      onCreate: (db, version) {
        db.execute(
          "CREATE TABLE books(id INTEGER PRIMARY KEY, name TEXT, writer TEXT, imagePath TEXT, pageCount INTEGER, currentPage INTEGER)",
        );
        db.execute(
          "CREATE TABLE readingSessions(id INTEGER PRIMARY KEY, bookId int, startPage int, endPage int, startTime int, duration int)",
        );
      },
      // Set the version. This executes the onCreate function and provides a
      // path to perform database upgrades and downgrades.
      version: 2,
    );
  }

  Future<int> insertBook(Book book) async{
    final Database db = await database;

    return db.insert("books", book.toMap(), conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<List<Book>> books() async{
    final Database db = await database;
    final List<Map<String, dynamic>> maps = await db.query("books");

    return List.generate(maps.length, (i){
      return Book.fromMap(maps[i]);
    });
  }

  Future updateBook(Book book) async{
    final Database db = await database;

    await db.update("books", book.toMap(), where: "id = ?", whereArgs: [book.id]);
  }

  Future deleteBook(int id) async{
    final Database db = await database;

    await db.delete("books", where: "id = ?", whereArgs: [id]);
  }


  Future<int> insertReadingSession(ReadingSession readingSession) async{
    final Database db = await database;
    return db.insert("readingSessions", readingSession.toMap(), conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<List<ReadingSession>> readingSessions() async{
    final Database db = await database;
    final List<Map<String, dynamic>> maps = await db.query("readingSessions");

    return List.generate(maps.length, (i){
      return ReadingSession.fromMap(maps[i]);
    });
  }

  Future updateReadingSession(ReadingSession readingSession) async{
    final Database db = await database;

    await db.update("readingSessions", readingSession.toMap(), where: "id = ?", whereArgs: [readingSession.id]);
  }

  Future deleteReadingSession(int id) async{
    final Database db = await database;

    await db.delete("readingSessions", where: "id = ?", whereArgs: [id]);
  }

  Future<List<ReadingSession>> readingSessionsOf(int bookId) async{
    final Database db = await database;
    final List<Map<String, dynamic>> maps = await db.query("readingSessions", where: "bookId = ?", whereArgs: [bookId], orderBy: "startTime desc");

    return List.generate(maps.length, (i){
      return ReadingSession.fromMap(maps[i]);
    });
  }

}