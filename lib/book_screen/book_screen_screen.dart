import 'dart:io';
import 'package:timeago/timeago.dart' as timeago;
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
  GlobalKey<AnimatedListState> _listKey = GlobalKey();

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

  void createMockSession() async {
    await bloc.addReadingSession(
      ReadingSession(
        duration: Duration(hours: 2),
        endPage: widget.book.currentPage + 50,
        startPage: widget.book.currentPage,
        startTime: DateTime(2019, 11, 11),
      ),
    );
    _listKey.currentState.insertItem(0);
  }

  @override
  Widget build(BuildContext context) {
    ShapeBorder shape = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(20),
    );
    return Scaffold(
      appBar: AppBar(title: Text(widget.book.name),),
      body: Column(
        children: <Widget>[
          Container(
              margin: EdgeInsets.all(8),
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
                        child: Container(
                          decoration: ShapeDecoration(
                            color: Colors.red,
                            image: widget.book.imagePath != null
                                ? DecorationImage(
                                    fit: BoxFit.cover,
                                    image:
                                        FileImage(File(widget.book.imagePath)),
                                  )
                                : null,
                            shape: shape,
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
                          children: <Widget>[
                            Align(
                              alignment: Alignment.centerLeft,
                              child: Wrap(
                                children: <Widget>[
                                  Baseline(
                                    baseline: 9,
                                    baselineType: TextBaseline.alphabetic,
                                    child: Text(
                                      "${widget.book.currentPage}",
                                      style: TextStyle(
                                          fontSize: 20,
                                          color: Colors.grey[800],
                                          fontStyle: FontStyle.italic),
                                    ),
                                  ),
                                  Baseline(
                                    baseline: 9,
                                    baselineType: TextBaseline.alphabetic,
                                    child: Text(
                                      " out of",
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.grey[800],
                                      ),
                                    ),
                                  ),
                                  Baseline(
                                    baseline: 9,
                                    baselineType: TextBaseline.alphabetic,
                                    child: Text(
                                      " ${widget.book.pageCount} ",
                                      style: TextStyle(
                                          fontSize: 20,
                                          color: Colors.grey[800],
                                          fontStyle: FontStyle.italic),
                                    ),
                                  ),
                                  Baseline(
                                    baseline: 9,
                                    baselineType: TextBaseline.alphabetic,
                                    child: Text(
                                      " pages read",
                                      style: TextStyle(
                                          fontSize: 14,
                                          color: Colors.grey[800],
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(height: 20,),
                            Align(
                              alignment: Alignment.centerLeft,
                              child: Wrap(
                                children: <Widget>[
                                  Baseline(
                                    baseline: 9,
                                    baselineType: TextBaseline.alphabetic,
                                    child: Text(
                                      "${widget.book.currentPage}",
                                      style: TextStyle(
                                          fontSize: 20,
                                          color: Colors.grey[800],
                                          fontStyle: FontStyle.italic),
                                    ),
                                  ),
                                ],
                              ),
                            )
                          ],
                        )),
                  )
                ],
              )),
          Expanded(
            flex: 3,
            child: Container(
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
                                  top: BorderSide(color: Colors.black26))),
                        ),
                        AnimatedList(
                          shrinkWrap: true,
                          physics: BouncingScrollPhysics(),
                          itemBuilder: (context, index, animation) {
                            return SizeTransition(
                              sizeFactor: animation,
                              child: ReadingSessionItem(
                                bloc,
                                sessions.reversed.toList()[index],
                                onDelete: () {
                                  ReadingSession session =
                                      sessions.reversed.toList()[index];
                                  _listKey.currentState.removeItem(index,
                                      (context, animation) {
                                    return SizeTransition(
                                      sizeFactor: animation,
                                      child: ReadingSessionItem(
                                        bloc,
                                        session,
                                      ),
                                    );
                                  });
                                  bloc.removeReadingSession(session);
                                },
                              ),
                            );
                          },
                          key: _listKey,
                          initialItemCount: sessions.length,
                        ),
                        if (sessions.isEmpty)
                          Container(
                            padding:
                            EdgeInsets.only(left: 16, right: 16),
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
}

class ReadingSessionItem extends StatelessWidget {
  ReadingSessionItem(this.bloc, this.session, {this.onDelete});

  final ReadingSession session;
  final BookBloc bloc;
  final Function() onDelete;

  void deleteReadingSession(BuildContext context) {
    showDialog(
      context: context,
      child: AlertDialog(
        title: Text("Are you sure you want to delete?"),
        actions: <Widget>[
          FlatButton(
            child: Text("No"),
            onPressed: () async {
              Navigator.of(context).pop();
            },
          ),
          RaisedButton(
            color: Theme.of(context).primaryColor,
            child: Text("Yes"),
            onPressed: () {
              onDelete();
              Navigator.of(context).pop();
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    NumberFormat n = NumberFormat("00");
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
                Text("${timeago.format(session.startTime)}"),
                Text(
                  "${session.duration.inHours} hours, ${session.duration.inSeconds % 60} minutes",
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
