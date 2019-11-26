import 'dart:io';

import 'package:book_tracker/book_screen/book_bloc.dart';
import 'package:book_tracker/book_screen/book_screen_app_bar.dart';
import 'package:book_tracker/models/book.dart';
import 'package:book_tracker/models/reading_session.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class BookScreenScreen extends StatefulWidget {
  const BookScreenScreen({
    Key key,
    this.book,
  }) : super(key: key);

  final Book book;

  @override
  BookScreenScreenState createState() {
    return BookScreenScreenState(BookBloc(book));
  }
}

class BookScreenScreenState extends State<BookScreenScreen> {
  BookScreenScreenState(this.bloc);
  BookBloc bloc;

  @override
  void initState() {
    bloc.addListener(() => setState(() {}));
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  void startNewSession(BuildContext context) {}

  void createMockSession() {
    bloc.addReadingSession(
      ReadingSession(
        duration: Duration(hours: 2),
        endPage: 300,
        startPage: 200,
        startTime: DateTime(2019, 11, 11),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder<List<ReadingSession>>(
        future: bloc.sessions,
        builder: (context, snapshot) {
          Widget appBar = buildSliverAppBar();
          Widget body;
          if (snapshot.hasData)
            body = SliverList(
              delegate: SliverChildBuilderDelegate((context, index) {
                return ReadingSessionItem(snapshot.data[index]);
              }, childCount: snapshot.data.length),
            );
          else
            body = SliverFillRemaining(
              child: Center(
                child: Text("Loading Sessions..."),
              ),
            );
          return CustomScrollView(
            slivers: <Widget>[appBar, body],
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.play_arrow),
        onPressed: createMockSession,
      ),
    );
  }

  SliverAppBar buildSliverAppBar() {
    return SliverAppBar(
      pinned: true,
      expandedHeight: 250,
      backgroundColor: Colors.red,
      flexibleSpace: FlexibleSpaceBar(
        title: Container(
          child: Hero(
            tag: "text" + widget.book.id.toString(),
            flightShuttleBuilder: (a, b, c, d, e) {
              return Material(
                color: Colors.transparent,
                child: FittedBox(
                  fit: BoxFit.contain,
                  child: Text(
                    widget.book.name,
                    style: TextStyle(
                      color: Colors.white,
                    ),
                  ),
                ),
              );
            },
            child: Material(
              color: Colors.transparent,
              child: FittedBox(
                fit: BoxFit.contain,
                child: Text(
                  widget.book.name,
                  style: TextStyle(color: Colors.white, fontSize: 24),
                ),
              ),
            ),
          ),
        ),
        background: Hero(
          tag: "cover" + widget.book.id.toString(),
          child: Container(
            decoration: ShapeDecoration(
              image: widget.book.imagePath != null
                  ? DecorationImage(
                      fit: BoxFit.cover,
                      image: FileImage(File(widget.book.imagePath)),
                    )
                  : null,
              shape: RoundedRectangleBorder(),
            ),
          ),
        ),
      ),
    );
  }
}

class ReadingSessionItem extends StatelessWidget {
  ReadingSessionItem(this.session);

  final ReadingSession session;

  @override
  Widget build(BuildContext context) {
    return Container(child: Text("Good Read"));
  }
}
