import 'dart:async';

import 'package:book_tracker/models/reading_session.dart';
import 'package:flutter/material.dart';
import '../models/book.dart';
import '../books_firebase.dart';

class BookBloc extends ChangeNotifier {
  static final FirebaseDatabase _db = FirebaseDatabase();

  BookBloc(this.book) {
    sessions = _db.readingSessionsOf(book.id);
  }
  Book book;

  Future<List<ReadingSession>>? sessions;

  Future<String> addReadingSession(ReadingSession session) async {
    session.bookId = book.id!;
    List<ReadingSession> sessions = await this.sessions!;
    String result = await _db.insertReadingSession(session);
    book.currentPage = session.endPage;
    book.lastRead = session.startTime;
    if (book.currentPage == book.pageCount) {
      book.status = BookStatus.done;
    }
    await _db.updateBook(book);
    session.id = result;
    sessions.add(session);
    notifyListeners();
    return result;
  }

  Future updateBook(Book book) async {
    assert(book.id == this.book.id);
    this.book = book;
    notifyListeners();
    await _db.updateBook(book);
    notifyListeners();
  }

  void removeReadingSession(ReadingSession session) async {
    List<ReadingSession> sessions = await this.sessions!;
    //remove session that has the same id
    sessions.removeWhere((b) => b.id == session.id);
    await _db.deleteReadingSession(session.id);
    book.currentPage -= session.endPage - session.startPage;
    // ive decided to not change last read even if the session is deleted. felt more logical.
    await _db.updateBook(book);
    notifyListeners();
  }

  void updateReadingSession(ReadingSession session) async {
    List<ReadingSession> sessions = await this.sessions!;

    int index = sessions.indexWhere((b) => b.id == session.bookId);
    if (index != -1) {
      sessions[index] = session;
      _db.updateReadingSession(session);
      notifyListeners();
    }
  }

  void notify() {
    notifyListeners();
  }
}
