import 'dart:io';

import 'package:book_tracker/book_screen/book_bloc.dart';
import 'package:book_tracker/book_screen/book_screen_app_bar.dart';
import 'package:book_tracker/models/book.dart';
import 'package:book_tracker/models/reading_session.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../models/reading_session.dart';
import '../widgets/press_effect.dart';
import 'book_bloc.dart';

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
  GlobalKey _listKey;

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
      appBar: AppBar(),
      body: Column(
        children: <Widget>[
          Expanded(
            flex: 2,
            child: Container(
                color: Colors.green,
                child: Row(
                  children: <Widget>[
                    Expanded(
                      flex: 2,
                      child: Container(color: Colors.white),
                    ),
                    Expanded(
                      flex: 3,
                      child: Container(
                        color: Colors.yellow,
                        child: Hero(
                          tag: "container"+widget.book.id.toString(),
                          child: PressEffect(
                            child: ClipPath(
                              clipper: ShapeBorderClipper(
                                shape: ContinuousRectangleBorder(
                                  borderRadius: BorderRadius.circular(100),
                                ),
                              ),
                              child: Stack(
                                fit: StackFit.expand,
                                children: <Widget>[
                                  Hero(
                                    tag: "cover" + widget.book.id.toString(),
                                    child: Container(
                                      decoration: ShapeDecoration(
                                        color: Colors.red,
                                        image: widget.book.imagePath != null
                                            ? DecorationImage(
                                                fit: BoxFit.cover,
                                                image: FileImage(File(
                                                    widget.book.imagePath)),
                                              )
                                            : null,
                                        shape: ContinuousRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(100),
                                        ),
                                      ),
                                    ),
                                  ),
                                  Positioned(
                                    bottom: 0,
                                    right: 0,
                                    left: 0,
                                    child: Hero(
                                      tag:
                                          "opacity" + widget.book.id.toString(),
                                      child: Container(
                                        height: 50,
                                        color: Colors.black.withOpacity(0.5),
                                      ),
                                    ),
                                  ),
                                  Positioned(
                                    bottom: 0,
                                    right: 0,
                                    left: 0,
                                    child: Container(
                                      height: 50,
                                      color: Colors.transparent,
                                      child: Center(
                                        child: Hero(
                                          tag: "text" +
                                              widget.book.id.toString(),
                                          flightShuttleBuilder:
                                              (a, b, c, d, e) {
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
                                              fit: BoxFit.fitWidth,
                                              child: Text(
                                                widget.book.name,
                                                style: TextStyle(
                                                    color: Colors.white,
                                                    fontSize: 18),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  )
                                ],
                              ),
                            ),
                            color: widget.book.imagePath != null
                                ? Colors.transparent
                                : Colors.red,
                            shape: ContinuousRectangleBorder(
                              borderRadius: BorderRadius.circular(100),
                            ),
                          ),
                        ),
                      ),
                    )
                  ],
                )),
          ),
          Expanded(
            flex: 3,
            child: Container(
              color: Colors.pink,
              child: FutureBuilder<List<ReadingSession>>(
                future: bloc.sessions,
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    List<ReadingSession> sessions = snapshot.data;
                    return AnimatedList(
                      itemBuilder: (context, index, animation) {
                        return ReadingSessionItem(bloc, sessions[index]);
                      },
                      key: _listKey,
                      initialItemCount: sessions.length,
                    );
                  }
                  return Center(
                    child: Text("Loading..."),
                  );
                },
              ),
            ),
          )
        ],
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
      flexibleSpace: FlexibleSpaceBar(
        title: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: <Widget>[
            Container(
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
          ],
        ),
        background: Hero(
          tag: "cover" + widget.book.id.toString(),
          child: Container(
            decoration: ShapeDecoration(
              color: widget.book.imagePath == null
                  ? Colors.red
                  : Colors.transparent,
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
  ReadingSessionItem(this.bloc, this.session);

  final ReadingSession session;
  final BookBloc bloc;

  @override
  Widget build(BuildContext context) {
    NumberFormat n = NumberFormat("00");
    return Column(
      mainAxisSize: MainAxisSize.max,
      children: <Widget>[
        Card(
          elevation: 20,
          child: ListTile(
            dense: false,
            trailing: IconButton(
              tooltip: "delete session",
              onPressed: () {
                bloc.removeReadingSession(session);
              },
              icon: Icon(Icons.delete),
            ),
            title: Text(
                "${n.format(session.duration.inHours)}:${n.format(session.duration.inSeconds % 60)}"),
          ),
        ),
        SizedBox(
          height: 20,
        )
      ],
    );
  }
}
