import 'package:book_tracker/book_screen/book_bloc.dart';
import 'package:book_tracker/models/book.dart';
import 'package:book_tracker/book_screen/timer_service.dart';
import 'package:book_tracker/models/reading_session.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:provider/provider.dart';

class NewReadingSessionScreen extends StatefulWidget {
  const NewReadingSessionScreen(this.bloc, this.book, {Key? key})
      : super(key: key);

  final BookBloc? bloc;
  final Book book;

  @override
  _NewReadingSessionScreenState createState() =>
      _NewReadingSessionScreenState();
}

class _NewReadingSessionScreenState extends State<NewReadingSessionScreen> {
  _NewReadingSessionScreenState();

  BookBloc? bloc;

  GlobalKey first = GlobalKey();
  GlobalKey second = GlobalKey();
  GlobalKey third = GlobalKey();
  DateTime? startTime;

  bool _timedSession = true;

  final TextEditingController _pageController = TextEditingController();
  final TextEditingController _commentController = TextEditingController();
  final TimerService timer = TimerService();

  final _form = GlobalKey<FormState>();
  bool empty = false;
  bool number = true;

  @override
  void initState() {
    bloc = widget.bloc;
    super.initState();
  }

  void saveSession(Duration duration) {
    if (_form.currentState?.validate() ?? false) {
      ReadingSession newSession = ReadingSession(
        bookId: widget.book.id!,
        startPage: widget.book.currentPage,
        endPage: int.parse(_pageController.value.text),
        startTime: startTime ?? DateTime.now(),
        duration: duration,
        comment: _commentController.value.text,
      );
      bloc!.addReadingSession(newSession);
      Navigator.of(context).pop();
    }
  }

  Future<bool> onWillPop() async {
    if (_timedSession && !timer.isRunning && !timer.finished) return true;
    return (await showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text('Are you sure?'),
            content: Text('session will be discarded.'),
            actions: <Widget>[
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: Text('No'),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: Text('Yes'),
              ),
            ],
          ),
        )) ??
        false;
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<TimerService>.value(
      value: timer,
      child: WillPopScope(
        onWillPop: onWillPop,
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
            alignment:
                Alignment.lerp(Alignment.center, Alignment.topCenter, 0.4)!,
            child: Consumer<TimerService>(
              builder: (context, service, child) {
                return SingleChildScrollView(
                  child: AnimatedContainer(
                    duration: Duration(milliseconds: 400),
                    padding: EdgeInsets.only(
                        top: 24,
                        bottom: service.finished || !_timedSession ? 24 : 8,
                        left: 16,
                        right: 16),
                    margin: EdgeInsets.symmetric(horizontal: 32),
                    child: Consumer<TimerService>(
                        builder: (build, service, widget) {
                      if (service.finished || !_timedSession) {
                        return containerAfterFinished(
                          service.currentDuration,
                        );
                      }
                      return containerBeforeFinish(service);
                    }),
                    decoration: ShapeDecoration(
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30)),
                      color: Colors.white,
                    ),
                  ),
                );
              },
            ),
          ),
          floatingActionButtonLocation:
              FloatingActionButtonLocation.centerFloat,
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
      ),
    );
  }

  Widget containerAfterFinished(Duration? duration) {
    return Form(
      key: _form,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            "Well Done!",
            style: TextStyle(
              fontSize: 24,
              fontStyle: FontStyle.italic,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(
            height: 8,
          ),
          if (duration != null)
            Text(
              "${duration.inMinutes} minutes, ${duration.inSeconds % 60} seconds",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w300),
            ),
          SizedBox(
            height: 8,
          ),
          Container(
            margin: EdgeInsets.all(8),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              color: Colors.grey.withOpacity(0.4),
            ),
            padding: EdgeInsets.all(8),
            child: TextFormField(
              validator: (value) {
                if (value == null || value == "") {
                  return "please enter a page";
                } else {
                  if (int.tryParse(value) == null) {
                    return "enter a valid number";
                  }
                  return null;
                }
              },
              controller: _pageController,
              decoration: InputDecoration.collapsed(
                  hintText: "What page are you on now?"),
            ),
          ),
          Container(
            margin: EdgeInsets.all(8),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              color: Colors.grey.withOpacity(0.4),
            ),
            padding: EdgeInsets.all(8),
            child: TextField(
              controller: _commentController,
              minLines: 4,
              maxLines: null,
              decoration:
                  InputDecoration.collapsed(hintText: "What did you think?"),
            ),
          ),
        ],
      ),
    );
  }

  Widget containerBeforeFinish(TimerService service) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      mainAxisSize: MainAxisSize.max,
      children: <Widget>[
        Text(
          "your'e currently on page ${widget.book.currentPage}",
          style: TextStyle(
            fontSize: 24,
            fontStyle: FontStyle.italic,
            fontWeight: FontWeight.bold,
          ),
          textAlign: TextAlign.center,
        ),
        SizedBox(height: 16),
        TimerText(),
        SizedBox(height: 16),
        Visibility(
          maintainSize: true,
          maintainAnimation: true,
          maintainState: true,
          visible: !service.isRunning,
          child: TextButton(
            onPressed: () => setState(() => _timedSession = false),
            child: Text("skip timer"),
          ),
        ),
      ],
    );
  }
}

class TimerText extends StatelessWidget {
  final NumberFormat formatter = NumberFormat("00");

  TimerText({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<TimerService>(builder: (context, service, widget) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: <Widget>[
          Text(
            "${formatter.format(service.currentDuration.inHours)}:${formatter.format(service.currentDuration.inMinutes % 60)}:${formatter.format(service.currentDuration.inSeconds % 60)}",
            style: TextStyle(fontSize: 48, fontWeight: FontWeight.w200),
          ),
        ],
      );
    });
  }
}
