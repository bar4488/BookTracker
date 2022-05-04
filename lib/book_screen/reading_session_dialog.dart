import 'package:book_tracker/models/reading_session.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ReadingSessionDialog extends StatefulWidget {
  const ReadingSessionDialog(this.sessions, this.startIndex,
      {Key? key, this.onDelete})
      : super(key: key);

  final List<ReadingSession> sessions;
  final int startIndex;
  final Function(ReadingSession)? onDelete;

  @override
  State<ReadingSessionDialog> createState() => _ReadingSessionDialogState();
}

class _ReadingSessionDialogState extends State<ReadingSessionDialog> {
  late int currentIndex;

  @override
  void initState() {
    currentIndex = widget.startIndex;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var session = widget.sessions[currentIndex];
    var format = DateFormat('yyyy-MM-dd kk:mm');
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
      child: ConstrainedBox(
        constraints: BoxConstraints(minHeight: 300),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  onPressed: currentIndex == 0
                      ? null
                      : () => setState(() {
                            currentIndex--;
                          }),
                  icon: Icon(Icons.arrow_back),
                ),
                Text(
                  "${currentIndex + 1}. ${format.format(session.startTime!)}",
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
                IconButton(
                  onPressed: currentIndex == widget.sessions.length - 1
                      ? null
                      : () => setState(() {
                            currentIndex++;
                          }),
                  icon: Icon(Icons.arrow_forward),
                ),
              ],
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                PropertyValueRow(
                  property: "Start page",
                  value: session.startPage.toString(),
                  padding: EdgeInsets.all(8),
                ),
                PropertyValueRow(
                  property: "End page",
                  value: session.endPage.toString(),
                  padding: EdgeInsets.all(8),
                ),
                if (session.hasDuration && session.duration!.inMinutes != 0)
                  PropertyValueRow(
                    property: "Duration",
                    value: "${session.duration!.inMinutes}m",
                    padding: EdgeInsets.all(8),
                  ),
                if (session.hasDuration)
                  PropertyValueRow(
                    property: "Duration",
                    value: "${session.duration!.inSeconds}s",
                    padding: EdgeInsets.all(8),
                  ),
                PropertyValueRow(
                  property: "Pages per hour",
                  value: "cde",
                  padding: EdgeInsets.all(8),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (session.comment != null)
                    Text.rich(
                      TextSpan(
                        children: [
                          TextSpan(
                            text: "Comment: ",
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          TextSpan(text: session.comment!),
                        ],
                      ),
                    ),
                  if (session.comment == null) Text("session has no comment")
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: Text("Close"),
                  ),
                  if (widget.onDelete != null)
                    IconButton(
                      tooltip: "delete session",
                      onPressed: () => deleteReadingSession(context, session),
                      icon: Icon(Icons.delete_outline),
                    )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void deleteReadingSession(BuildContext context, ReadingSession session) {
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
                widget.onDelete!(session);
                Navigator.of(context).popUntil(
                  (route) => route.settings.name == "book_page",
                );
              },
            ),
          ],
        );
      },
    );
  }
}

class PropertyValueRow extends StatelessWidget {
  const PropertyValueRow(
      {required this.property,
      required this.value,
      this.padding = EdgeInsets.zero,
      Key? key})
      : super(key: key);

  final EdgeInsetsGeometry padding;
  final String property;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding,
      child: Row(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            property,
            style: TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
          Expanded(
            child: Container(
              margin: EdgeInsets.symmetric(horizontal: 12),
              color: Colors.grey,
              height: 0.3,
            ),
          ),
          Text(value),
        ],
      ),
    );
  }
}
