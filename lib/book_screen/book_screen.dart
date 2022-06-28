import 'dart:io';
import 'dart:math';
import 'package:book_tracker/book_screen/new_reading_session.dart';
import 'package:book_tracker/book_screen/reading_session_dialog.dart';
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
    Key? key,
    required this.book,
  }) : super(key: key);

  final Book book;

  @override
  BookScreenScreenState createState() {
    return BookScreenScreenState();
  }
}

class BookScreenScreenState extends State<BookScreenScreen> {
  BookScreenScreenState();
  late BookBloc bloc;

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
        .where((s) => s.duration!.inMicroseconds != 0)
        .map((session) =>
            (session.endPage - session.startPage) /
            (session.duration!.inSeconds / 3600))
        .toList();
    double sum = 0;
    for (var i in avgs) {
      sum += i;
    }
    return sum / avgs.length;
  }

  double timeToFinish(List<ReadingSession> sessions) {
    var avg = averagePagesPerHour(sessions);
    if (avg.isNaN) {
      return avg;
    }
    return max(0, (widget.book.pageCount - widget.book.currentPage) / avg);
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
            onPressed: () async {
              if (await Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) {
                        return EditBookPage(bloc);
                      },
                    ),
                  ) ==
                  true) {
                setState(() {});
              }
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
                      child: Stack(
                        children: [
                          Container(
                            margin: EdgeInsets.all(16),
                            child: Column(
                              children: [
                                Expanded(
                                  child: Hero(
                                    tag: "cover" + widget.book.id!,
                                    child: Container(
                                      decoration: ShapeDecoration(
                                        color: Colors.red,
                                        image: widget.book.imagePath != null
                                            ? DecorationImage(
                                                fit: BoxFit.cover,
                                                image: FileImage(File(
                                                    widget.book.imagePath!)),
                                              )
                                            : null,
                                        shape: shape,
                                      ),
                                    ),
                                  ),
                                ),
                                SizedBox(
                                  height: 4,
                                ),
                                Hero(
                                  tag: "indicator" + widget.book.id!,
                                  child: ClipPath(
                                    clipper: ShapeBorderClipper(
                                      shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(2)),
                                    ),
                                    child: LinearProgressIndicator(
                                      value: widget.book.currentPage /
                                          widget.book.pageCount,
                                      color: widget.book.currentPage >=
                                              widget.book.pageCount
                                          ? Colors.amber
                                          : null,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Positioned(
                            right: 8,
                            top: 8,
                            child: DropdownButtonHideUnderline(
                              child: DropdownButton<BookStatus>(
                                isDense: true,
                                isExpanded: false,
                                icon: Hero(
                                  tag: "status" + widget.book.id!,
                                  child: buildStatus(widget.book.status),
                                ),
                                items: [
                                  for (var status in BookStatus.values)
                                    DropdownMenuItem(
                                      child: Row(
                                        children: [
                                          buildStatus(status),
                                          Text(" ${status.name}")
                                        ],
                                      ),
                                      value: status,
                                    ),
                                ],
                                onChanged: (val) {
                                  if (val != null) {
                                    setState(() {
                                      widget.book.status = val;
                                      bloc.updateBook(widget.book);
                                    });
                                  }
                                },
                              ),
                            ),
                          )
                        ],
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
                            height: 4,
                          ),
                          Text(
                            "writer: ${widget.book.writer}",
                            style: TextStyle(
                              color: Colors.grey[800],
                            ),
                          ),
                          SizedBox(
                            height: 4,
                          ),
                          Text(
                            "pages read: ${widget.book.currentPage}/${widget.book.pageCount}, ${widget.book.pageCount - widget.book.currentPage} left!",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Colors.grey[800],
                            ),
                          ),
                          SizedBox(
                            height: 4,
                          ),
                          FutureBuilder<List<ReadingSession>>(
                            future: bloc.sessions,
                            builder: (context, snapshot) {
                              if (!snapshot.hasData ||
                                  snapshot.data!.isEmpty ||
                                  snapshot.data!.every((s) => !s.hasDuration)) {
                                return SizedBox();
                              }
                              final sessions = snapshot.data!;
                              NumberFormat n = NumberFormat("#.#");
                              return Text(
                                "pages an hour: ${n.format(averagePagesPerHour(sessions))}",
                                style: TextStyle(
                                  color: Colors.grey[800],
                                  fontStyle: FontStyle.italic,
                                ),
                              );
                            },
                          ),
                          SizedBox(
                            height: 4,
                          ),
                          FutureBuilder<List<ReadingSession>>(
                            future: bloc.sessions!,
                            builder: (context, snapshot) {
                              if (!snapshot.hasData ||
                                  snapshot.data!.isEmpty ||
                                  snapshot.data!.every((s) => !s.hasDuration)) {
                                return SizedBox();
                              }
                              final sessions = snapshot.data!;
                              NumberFormat n = NumberFormat("#.#");
                              var hoursSpent = sessions
                                  .where((element) => element.hasDuration)
                                  .map(
                                    (e) => e.duration!.inSeconds / 3600,
                                  )
                                  .reduce(
                                    (value, element) => value + element,
                                  );
                              return Text(
                                "time read: ${n.format(hoursSpent)} hours",
                                style: TextStyle(
                                  color: Colors.grey[800],
                                  fontStyle: FontStyle.italic,
                                ),
                              );
                            },
                          ),
                          SizedBox(
                            height: 4,
                          ),
                          FutureBuilder<List<ReadingSession>>(
                            future: bloc.sessions,
                            builder: (context, snapshot) {
                              if (!snapshot.hasData ||
                                  snapshot.data!.isEmpty ||
                                  snapshot.data!.every((s) => !s.hasDuration)) {
                                return SizedBox();
                              }
                              final sessions = snapshot.data!;
                              NumberFormat n = NumberFormat("#.#");
                              return Text(
                                "time to finish: ${n.format(timeToFinish(sessions))} hours",
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
                  List<ReadingSession> sessions = snapshot.data!;
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
                                sessions,
                                index,
                                onDelete: (session) {
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

  CircleAvatar buildStatus(BookStatus status) {
    switch (status) {
      case BookStatus.done:
        return CircleAvatar(
          radius: 12,
          backgroundColor: Colors.white,
          child: Icon(
            Icons.check_circle,
            color: Color(0xff81E500),
          ),
        );
      case BookStatus.planning:
        return CircleAvatar(
          radius: 12,
          backgroundColor: Colors.white,
          child: Icon(
            Icons.info,
            color: Color(0xff2B99FF),
          ),
        );
      case BookStatus.reading:
        return CircleAvatar(
          radius: 12,
          backgroundColor: Colors.white,
          child: CircleAvatar(
            radius: 10,
            backgroundColor: Color(0xffFF7A00),
            child: Icon(
              Icons.more_horiz,
              size: 20,
              color: Colors.white,
            ),
          ),
        );
    }
  }
}

class ReadingSessionItem extends StatelessWidget {
  const ReadingSessionItem(this.bloc, this.sessions, this.index,
      {Key? key, this.onDelete})
      : super(key: key);

  final List<ReadingSession> sessions;
  final int index;
  final BookBloc? bloc;
  final Function(ReadingSession)? onDelete;

  Future<bool> deleteReadingSession(BuildContext context) async {
    bool deleted = false;
    await showDialog(
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
                deleted = true;
                onDelete!(sessions[index]);
                Navigator.of(context).popUntil(
                  (route) => route.settings.name == "book_page",
                );
              },
            ),
          ],
        );
      },
    );
    return deleted;
  }

  @override
  Widget build(BuildContext context) {
    NumberFormat n = NumberFormat("#.#");
    var session = sessions[index];
    return Container(
      decoration: BoxDecoration(
        border: Border(),
      ),
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: ListTile(
          contentPadding: EdgeInsets.symmetric(vertical: 16, horizontal: 16),
          onTap: () {
            showDialog(
              context: context,
              builder: (context) {
                return ReadingSessionDialog(
                  sessions,
                  index,
                  onDelete: onDelete,
                );
              },
            );
          },
          trailing: IconButton(
            tooltip: "delete session",
            onPressed: () async {
              await deleteReadingSession(context);
            },
            icon: Icon(Icons.delete),
          ),
          leading: Icon(Icons.chrome_reader_mode),
          title: Text("${session.endPage - session.startPage} pages read"),
          subtitle: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    if (session.startTime != null)
                      Text(timeago.format(session.startTime!)),
                    if (session.duration != null &&
                        session.duration!.inMicroseconds != 0)
                      Text(
                        session.duration!.inSeconds > 60
                            ? "${session.duration!.inHours} hours, ${session.duration!.inMinutes % 60} minutes"
                            : "${session.duration!.inSeconds} seconds",
                      ),
                  ],
                ),
              ),
              if (session.hasDuration)
                Text("${n.format(session.pagesPerHour!)}/h"),
            ],
          ),
        ),
      ),
    );
  }
}
