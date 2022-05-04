class ReadingSession {
  ReadingSession({
    this.id,
    required this.bookId,
    required this.startPage,
    required this.endPage,
    this.startTime,
    this.duration,
    this.comment,
  });

  String? id;
  String bookId;
  int startPage;
  int endPage;
  DateTime? startTime;
  Duration? duration;
  String? comment;

  double? get pagesPerHour => duration == null
      ? null
      : (endPage - startPage) / duration!.inSeconds * 3600;

  bool get hasDuration => duration != null && duration!.inMicroseconds != 0;

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'bookId': bookId,
      'startPage': startPage,
      'endPage': endPage,
      if (startTime != null) 'startTime': startTime!.millisecondsSinceEpoch,
      if (duration != null) 'duration': duration!.inSeconds,
      if (comment != null) 'comment': comment,
    };
  }

  factory ReadingSession.fromMap(Map<String, dynamic> map) {
    return ReadingSession(
      id: map["id"],
      bookId: map["bookId"],
      startPage: map["startPage"],
      endPage: map["endPage"],
      startTime: DateTime.fromMillisecondsSinceEpoch(map["startTime"]),
      duration: Duration(seconds: map["duration"]),
      comment: map["comment"],
    );
  }
}
