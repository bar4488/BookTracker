import 'dart:async';

import 'package:flutter/material.dart';
import 'models/book.dart';
import 'books_database.dart';

class BooksBloc extends ChangeNotifier {
  static LocalDatabase _db = LocalDatabase();

  BooksBloc();

  Future<List<Book>> books = _db.books();

  void addBook(Book book) async {
    List<Book> books = await this.books;
    int id = await _db.insertBook(book);
    book.id = id;
    books.add(book);
    notifyListeners();
  }

  void removeBook(Book book) async {
    List<Book> books = await this.books;
    //remove book that has the same id
    books.removeWhere((b) => b.id == book.id);
    _db.deleteBook(book.id);
    notifyListeners();
  }

  void updateBook(Book book) async {
    List<Book> books = await this.books;

    int index = books.indexWhere((b) => b.id == book.id);
    if (index != -1) {
      books[index] = book;
      _db.updateBook(book);
      notifyListeners();
    }
  }
}
