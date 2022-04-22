import 'package:book_tracker/book_screen/book_bloc.dart';
import 'package:book_tracker/book_screen/timer_service.dart';
import 'package:book_tracker/models/book.dart';
import 'package:book_tracker/models/reading_session.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:provider/provider.dart';

class NewReadingSessionScreen extends StatefulWidget {
  NewReadingSessionScreen(this.bloc, this.book);

  final BookBloc bloc;
  final Book book;

  @override
  _NewReadingSessionScreenState createState() =>
      _NewReadingSessionScreenState(this.bloc);
}

class _NewReadingSessionScreenState extends State<NewReadingSessionScreen> {
  _NewReadingSessionScreenState(this.bloc);

  BookBloc bloc;

  GlobalKey first = GlobalKey();
  GlobalKey second = GlobalKey();
  GlobalKey third = GlobalKey();
  DateTime startTime;

  bool _timedSession = true;

  TextEditingController _editingController = TextEditingController();
  bool empty = false;
  bool number = true;

  saveSession(Duration duration) {
    final text = _editingController.text;
    if (text.isEmpty) {
      setState(() {
        empty = true;
      });
      return;
    }
    int currentPage = int.tryParse(text);
    if (currentPage == null) {
      setState(() {
        empty = false;
        number = false;
      });
      return;
    }
    ReadingSession newSession = ReadingSession(
        bookId: widget.book.id,
        startPage: widget.book.currentPage,
        endPage: currentPage,
        startTime: startTime ?? DateTime.now(),
        duration: duration);
    bloc.addReadingSession(newSession);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<TimerService>(
      create: (_) => TimerService(),
      child: Scaffold(
        backgroundColor: Theme.of(context).primaryColorLight,
        appBar: AppBar(
          elevation: 0,
          backgroundColor: Theme.of(context).primaryColorLight,
          iconTheme: IconThemeData(color: Colors.black),
          title: Text(
            "New Reading Sessions",
            style: TextStyle(color: Colors.black),
          ),
        ),
        body: Align(
          alignment: Alignment.lerp(Alignment.center, Alignment.topCenter, 0.4),
          child: Consumer<TimerService>(
            builder: (context, service, child) {
              return AnimatedContainer(
                duration: Duration(milliseconds: 400),
                padding: EdgeInsets.symmetric(vertical: 64, horizontal: 16),
                margin: EdgeInsets.symmetric(horizontal: 32),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Text(
                      "your'e currently in page ${widget.book.currentPage}",
                      style: TextStyle(
                        fontSize: 24,
                        fontStyle: FontStyle.italic,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 24),
                    Row(
                      children: <Widget>[
                        Checkbox(
                          value: _timedSession,
                          onChanged: service.isRunning || service.finished
                              ? null
                              : (value) {
                                  setState(() {
                                    _timedSession = value;
                                  });
                                },
                        ),
                        Text(
                          "timed session",
                          style: TextStyle(fontSize: 16),
                        )
                      ],
                    ),
                    if (_timedSession) TimerText(),
                    SizedBox(height: 24),
                    !service.finished && _timedSession
                        ? SizedBox()
                        : TextField(
                            keyboardType: TextInputType.number,
                            controller: _editingController,
                            decoration: InputDecoration(
                              labelText: "what page are you on now?",
                              errorText: empty
                                  ? "please type the current page"
                                  : !number
                                      ? "please enter a number"
                                      : null,
                              border: OutlineInputBorder(),
                            ),
                          ),
                  ],
                ),
                decoration: ShapeDecoration(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30)),
                  color: Colors.white,
                ),
              );
            },
          ),
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
        floatingActionButton: Consumer<TimerService>(
          builder: (context, service, widget) {
            return Container(
              margin: EdgeInsets.only(bottom: 40),
              child: AnimatedSwitcher(
                duration: Duration(milliseconds: 400),
                transitionBuilder: (child, animation) {
                  return ScaleTransition(
                    scale: animation,
                    child: child,
                  );
                },
                child: FloatingActionButton.extended(
                  key: service.isRunning
                      ? second
                      : service.finished || _timedSession
                          ? third
                          : first,
                  backgroundColor: Theme.of(context).canvasColor,
                  onPressed: service.isRunning
                      ? service.stop
                      : service.finished || !_timedSession
                          ? () => saveSession(service.currentDuration)
                          : () {
                              service.start();
                              startTime = DateTime.now();
                            },
                  label: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12.0),
                    child: Text(
                      service.isRunning
                          ? "Finish"
                          : service.finished || !_timedSession
                              ? "Save Session"
                              : "Start Reading",
                      style: TextStyle(color: Colors.black),
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class TimerText extends StatelessWidget {
  final NumberFormat formatter = NumberFormat("00");

  @override
  Widget build(BuildContext context) {
    return Consumer<TimerService>(builder: (context, service, widget) {
      return Container(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: <Widget>[
            Text(
              "${formatter.format(service.currentDuration.inHours)}:${formatter.format(service.currentDuration.inMinutes % 60)}",
              style: TextStyle(fontSize: 48),
            ),
            Baseline(
              baseline: -12,
              baselineType: TextBaseline.alphabetic,
              child: Text(
                ":${formatter.format(service.currentDuration.inSeconds % 60)}",
                style: TextStyle(fontSize: 24),
              ),
            ),
          ],
        ),
      );
    });
  }
}
