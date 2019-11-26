import 'dart:async';

import 'package:book_tracker/models/reading_session.dart';
import 'package:flutter/material.dart';
import '../models/book.dart';
import '../books_database.dart';

class BookBloc extends ChangeNotifier {
  static LocalDatabase _db = LocalDatabase();

  BookBloc(this.book){
    sessions = _db.readingSessionsOf(book.id);
  }
  Book book;

  Future<List<ReadingSession>> sessions;

  void addReadingSession(ReadingSession session) async {
    session.bookId = book.id;
    List<ReadingSession> sessions = await this.sessions;
    sessions.add(session);
    notifyListeners();
    _db.insertReadingSession(session);
  }

  void removeReadingSession(ReadingSession session) async {
    List<ReadingSession> sessions = await this.sessions;
    //remove session that has the same id
    sessions.removeWhere((b) => b.id == session.id);
    _db.deleteReadingSession(session.id);
    notifyListeners();
  }

  void updateReadingSession(ReadingSession session) async {
    List<ReadingSession> sessions = await this.sessions;

    int index = sessions.indexWhere((b) => b.id == session.id);
    if (index != -1) {
      sessions[index] = session;
      _db.updateReadingSession(session);
      notifyListeners();
    }
  }
}
