import 'dart:io';
import 'package:book_tracker/book_screen/new_reading_session.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:book_tracker/book_screen/book_bloc.dart';
import 'package:book_tracker/models/book.dart';
import 'package:book_tracker/models/reading_session.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../edit_book_page.dart';

import '../models/reading_session.dart';
import 'book_bloc.dart';

class BookScreenScreen extends StatefulWidget {
  const BookScreenScreen({
    Key key,
    this.book,
  }) : super(key: key);

  final Book book;

  @override
  BookScreenScreenState createState() {
    return BookScreenScreenState();
  }
}

class BookScreenScreenState extends State<BookScreenScreen> {
  BookScreenScreenState();
  BookBloc bloc;

  @override
  void initState() {
    bloc = BookBloc(widget.book);
    bloc.addListener(() => setState(() {}));
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  void startNewSession(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => NewReadingSessionScreen(bloc, widget.book),
      ),
    );
  }

  double averagePagesPerHour(List<ReadingSession> sessions) {
    List<double> avgs = sessions
        .where((s) => s.duration.inMicroseconds != 0)
        .map((session) =>
            (session.endPage - session.startPage) /
            (session.duration.inSeconds / 3600))
        .toList();
    double sum = 0;
    for (var i in avgs) {
      sum += i;
    }
    return sum / avgs.length;
  }

  @override
  Widget build(BuildContext context) {
    ShapeBorder shape = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(20),
    );
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.book.name),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.edit),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) {
                    return EditBookPage(bloc);
                  },
                ),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: <Widget>[
          Container(
              margin: EdgeInsets.only(top: 8, left: 8, right: 8),
              child: Row(
                mainAxisSize: MainAxisSize.max,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Expanded(
                    flex: 2,
                    child: AspectRatio(
                      aspectRatio: 3 / 4,
                      child: Container(
                        margin: EdgeInsets.all(16),
                        child: ClipPath(
                          clipper: ShapeBorderClipper(
                            shape: shape,
                          ),
                          child: Stack(
                            children: [
                              Container(
                                decoration: ShapeDecoration(
                                  color: Colors.red,
                                  image: widget.book.imagePath != null
                                      ? DecorationImage(
                                          fit: BoxFit.cover,
                                          image: FileImage(
                                              File(widget.book.imagePath)),
                                        )
                                      : null,
                                  shape: shape,
                                ),
                              ),
                              Positioned(
                                bottom: 0,
                                right: 0,
                                left: 0,
                                child: LinearProgressIndicator(
                                  value: widget.book.currentPage /
                                      widget.book.pageCount,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 3,
                    child: Container(
                      margin: EdgeInsets.only(top: 24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            widget.book.name,
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey[800],
                            ),
                          ),
                          SizedBox(
                            height: 8,
                          ),
                          Text(
                            "writer: ${widget.book.writer}",
                            style: TextStyle(
                              color: Colors.grey[800],
                            ),
                          ),
                          SizedBox(
                            height: 8,
                          ),
                          Text(
                            "pages read: ${widget.book.currentPage}/${widget.book.pageCount}",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Colors.grey[800],
                            ),
                          ),
                          SizedBox(
                            height: 8,
                          ),
                          FutureBuilder<List<ReadingSession>>(
                            future: bloc.sessions,
                            builder: (context, snapshot) {
                              if (!snapshot.hasData) return SizedBox();
                              final sessions = snapshot.data;
                              NumberFormat n = NumberFormat("#.#");
                              return Text(
                                "pages an hour: ${n.format(averagePagesPerHour(sessions))}",
                                style: TextStyle(
                                  color: Colors.grey[800],
                                  fontStyle: FontStyle.italic,
                                ),
                              );
                            },
                          )
                        ],
                      ),
                    ),
                  )
                ],
              )),
          Expanded(
            flex: 3,
            child: FutureBuilder<List<ReadingSession>>(
              future: bloc.sessions,
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  List<ReadingSession> sessions = snapshot.data;
                  return Column(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Container(
                        margin: EdgeInsets.symmetric(horizontal: 16),
                        height: 20,
                        decoration: BoxDecoration(
                          border: Border(
                            top: BorderSide(color: Colors.black26),
                          ),
                        ),
                      ),
                      if (sessions.isNotEmpty)
                        Expanded(
                          child: ListView.builder(
                            physics: BouncingScrollPhysics(),
                            itemCount: sessions.length,
                            itemBuilder: (context, index) {
                              index = sessions.length - 1 - index;
                              return ReadingSessionItem(
                                bloc,
                                sessions[index],
                                onDelete: () {
                                  ReadingSession session = sessions[index];
                                  bloc.removeReadingSession(session);
                                },
                              );
                            },
                          ),
                        ),
                      if (sessions.isEmpty)
                        Container(
                          padding: EdgeInsets.only(left: 16, right: 16),
                          child: Text(
                            "you dont have any reading sessions...\n\npress the floating button to start a new one!",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                fontStyle: FontStyle.italic,
                                fontWeight: FontWeight.bold),
                          ),
                        ),
                    ],
                  );
                }

                return Center(
                  child: Text("Loading..."),
                );
              },
            ),
          )
        ],
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.play_arrow),
        onPressed: () => startNewSession(context),
      ),
    );
  }
}

class ReadingSessionItem extends StatelessWidget {
  const ReadingSessionItem(this.bloc, this.session, {Key key, this.onDelete})
      : super(key: key);

  final ReadingSession session;
  final BookBloc bloc;
  final Function() onDelete;

  void deleteReadingSession(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Are you sure you want to delete?"),
          actions: <Widget>[
            TextButton(
              child: Text("No"),
              onPressed: () async {
                Navigator.of(context).pop();
              },
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                primary: Theme.of(context).primaryColor,
              ),
              child: Text("Yes"),
              onPressed: () {
                onDelete();
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    // NumberFormat n = NumberFormat("00");
    return Container(
      decoration: BoxDecoration(
        border: Border(),
      ),
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 16),
          child: ListTile(
            trailing: IconButton(
              tooltip: "delete session",
              onPressed: () => deleteReadingSession(context),
              icon: Icon(Icons.delete),
            ),
            leading: Icon(Icons.chrome_reader_mode),
            title: Text("${session.endPage - session.startPage} pages read"),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                if (session.startTime != null)
                  Text(timeago.format(session.startTime)),
                if (session.duration != null &&
                    session.duration.inMicroseconds != 0)
                  Text(
                    session.duration.inSeconds > 60
                        ? "${session.duration.inHours} hours, ${session.duration.inMinutes % 60} minutes"
                        : "${session.duration.inSeconds} seconds",
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
