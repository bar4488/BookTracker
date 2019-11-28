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

  Future<int> addReadingSession(ReadingSession session) async {
    session.bookId = book.id;
    List<ReadingSession> sessions = await this.sessions;
    int result = await _db.insertReadingSession(session);
    book.currentPage = session.endPage;
    await _db.updateBook(book);
    session.id = result;
    sessions.add(session);
    notifyListeners();
    return result;
  }

  void removeReadingSession(ReadingSession session) async {
    List<ReadingSession> sessions = await this.sessions;
    //remove session that has the same id
    sessions.removeWhere((b) => b.id == session.id);
    _db.deleteReadingSession(session.id);
    book.currentPage -= session.endPage - session.startPage;
    await _db.updateBook(book);
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
