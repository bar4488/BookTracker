class ReadingSession{

  ReadingSession({this.id, this.bookId, this.startPage, this.endPage, this.startTime, this.duration});

  int id;
  int bookId;
  int startPage;
  int endPage;
  DateTime startTime;
  Duration duration;

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'bookId': bookId,
      'startPage': startPage,
      'endPage': endPage,
      if(startTime != null)
      'startTime': startTime.millisecondsSinceEpoch,
      if(duration != null)
      'duration': duration.inSeconds,
    };
  }

  factory ReadingSession.fromMap(Map<String, dynamic> map){
    return ReadingSession(
      id: map["id"],
      bookId: map["bookId"],
      startPage: map["startPage"],
      endPage: map["endPage"],
      startTime: DateTime.fromMillisecondsSinceEpoch(map["startTime"]),
      duration:  Duration(seconds: map["duration"]),
    );
  }
}
