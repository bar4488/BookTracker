import 'dart:async';
import 'package:book_tracker/auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'models/book.dart';
import 'models/reading_session.dart';

class FirebaseDatabase {
  late FirebaseFirestore firestore;

  FirebaseDatabase() {
    firestore = FirebaseFirestore.instance;
  }

  Future<CollectionReference> get booksCollection async => firestore
      .collection("user")
      .doc(await Auth().getLoggedInEmail())
      .collection("books");
  Future<CollectionReference> get readingSessionsCollection async => firestore
      .collection("user")
      .doc(await Auth().getLoggedInEmail())
      .collection("readingSessions");

  Future<String> insertBook(Book book) async {
    String id = (await (await booksCollection).add(book.toMap())).id;
    book.id = id;
    (await booksCollection).doc(id).set(book.toMap());
    return id;
  }

  Future<List<Book>> books() async {
    QuerySnapshot s = await (await booksCollection).get();
    return s.docs.map((e) => Book.fromMap(e.data() as Map<String, dynamic>)).toList();
  }

  Future updateBook(Book book) async {
    var doc = (await booksCollection).doc(book.id);
    doc.set(book.toMap());
  }

  Future deleteBook(String? id) async {
    DocumentReference doc = (await booksCollection).doc(id);
    QuerySnapshot s = await doc.collection("readingSession").get();
    for (var element in s.docs) {
      deleteReadingSession(element.id);
    }
    doc.delete();
  }

  Future<String> insertReadingSession(ReadingSession readingSession) async {
    var doc = (await booksCollection).doc(readingSession.bookId);
    String id =
        (await (await readingSessionsCollection).add(readingSession.toMap()))
            .id;
    readingSession.id = id;
    (await readingSessionsCollection).doc(id).set(readingSession.toMap());
    await doc.collection("readingSession").doc(id).set(readingSession.toMap());
    return id;
  }

  Future<List<ReadingSession>> readingSessions() async {
    QuerySnapshot s = await (await readingSessionsCollection).get();
    return s.docs.map((e) => ReadingSession.fromMap(e.data() as Map<String, dynamic>)).toList()
      ..sort((a, b) => (a.startTime!.millisecondsSinceEpoch)
          .compareTo(b.startTime!.millisecondsSinceEpoch));
  }

  Future updateReadingSession(ReadingSession readingSession) async {
    var readingSessionDoc =
        (await readingSessionsCollection).doc(readingSession.id);
    readingSessionDoc.set(readingSession.toMap());
    var bookDoc = (await booksCollection).doc(readingSession.bookId);
    await bookDoc
        .collection("readingSession")
        .doc(readingSession.id)
        .set(readingSession.toMap());
  }

  Future deleteReadingSession(String? id) async {
    var readingSessionDoc = (await readingSessionsCollection).doc(id);
    String? bookId = ((await readingSessionDoc.get()).data()
        as Map<String, dynamic>)["bookId"];
    readingSessionDoc.delete();
    var bookDoc = (await booksCollection).doc(bookId);
    await bookDoc.collection("readingSession").doc(id).delete();
  }

  Future<List<ReadingSession>> readingSessionsOf(String? bookId) async {
    QuerySnapshot s = await (await booksCollection)
        .doc(bookId)
        .collection("readingSession")
        .get();
    return s.docs.map((e) => ReadingSession.fromMap(e.data() as Map<String, dynamic>)).toList()
      ..sort((a, b) => (a.startTime!.millisecondsSinceEpoch)
          .compareTo(b.startTime!.millisecondsSinceEpoch));
  }
/*

*/
}
