import 'dart:async';
import 'package:book_tracker/Auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'models/book.dart';
import 'models/reading_session.dart';

class FirebaseDatabase {
  Firestore firestore;

  FirebaseDatabase() {
    firestore = Firestore();
  }

  Future<CollectionReference> get booksCollection async => firestore
      .collection("user")
      .document(await Auth().getLoggedInEmail())
      .collection("books");
  Future<CollectionReference> get readingSessionsCollection async => firestore
      .collection("user")
      .document(await Auth().getLoggedInEmail())
      .collection("readingSessions");

  Future<String> insertBook(Book book) async {
    String id =  (await (await booksCollection).add(book.toMap())).documentID;
    book.id = id;
    (await booksCollection).document(id).setData(book.toMap());
    return id;
  }

  Future<List<Book>> books() async {
    QuerySnapshot s = await (await booksCollection).getDocuments();
    return s.documents.map((e) => Book.fromMap(e.data)).toList();
  }

  Future updateBook(Book book) async {
    var doc = (await booksCollection).document(book.id);
    doc.setData(book.toMap());
  }

  Future deleteBook(String id) async {
    DocumentReference doc = (await booksCollection).document(id);
    QuerySnapshot s = await doc.collection("readingSession").getDocuments();
    s.documents.forEach((element) {
      deleteReadingSession(element.documentID);
    });
    doc.delete();
  }

  Future<String> insertReadingSession(ReadingSession readingSession) async {
    var doc = (await booksCollection).document(readingSession.bookId);
    String id =
        (await (await readingSessionsCollection).add(readingSession.toMap()))
            .documentID;
    readingSession.id = id;
    (await readingSessionsCollection).document(id).setData(readingSession.toMap());
    await doc
        .collection("readingSession")
        .document(id)
        .setData(readingSession.toMap());
    return id;
  }

  Future<List<ReadingSession>> readingSessions() async {
    QuerySnapshot s = await (await readingSessionsCollection).getDocuments();
    return s.documents.map((e) => ReadingSession.fromMap(e.data)).toList()..sort((a, b) => (a.startTime.millisecondsSinceEpoch).compareTo(b.startTime.millisecondsSinceEpoch));
  }

  Future updateReadingSession(ReadingSession readingSession) async {
    var readingSessionDoc =
        (await readingSessionsCollection).document(readingSession.id);
    readingSessionDoc.setData(readingSession.toMap());
    var bookDoc = (await booksCollection).document(readingSession.bookId);
    await bookDoc
        .collection("readingSession")
        .document(readingSession.id)
        .setData(readingSession.toMap());
  }

  Future deleteReadingSession(String id) async {
    var readingSessionDoc = (await readingSessionsCollection).document(id);
    String bookId = (await readingSessionDoc.get()).data["bookId"];
    readingSessionDoc.delete();
    var bookDoc = (await booksCollection).document(bookId);
    await bookDoc.collection("readingSession").document(id).delete();
  }

  Future<List<ReadingSession>> readingSessionsOf(String bookId) async {
    QuerySnapshot s = await (await booksCollection)
        .document(bookId)
        .collection("readingSession")
        .getDocuments();
    return s.documents.map((e) => ReadingSession.fromMap(e.data)).toList()..sort((a, b) => (a.startTime.millisecondsSinceEpoch).compareTo(b.startTime.millisecondsSinceEpoch));
  }
/*

*/
}
