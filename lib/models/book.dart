class Book {
  Book({
    this.id,
    required this.name,
    required this.writer,
    required this.imagePath,
    required this.pageCount,
    this.currentPage = 0,
    this.comment,
    this.lastRead,
    this.createdAt,
  });

  String? id;
  String name;
  String writer;
  String? imagePath;
  int pageCount;
  int currentPage;
  DateTime? lastRead;
  DateTime? createdAt;

  String? comment;

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'writer': writer,
      'imagePath': imagePath,
      'pageCount': pageCount,
      'currentPage': currentPage,
      'comment': comment,
      'lastRead': lastRead?.millisecondsSinceEpoch,
      'createdAt': createdAt?.millisecondsSinceEpoch,
    };
  }

  factory Book.fromMap(Map<String, dynamic> map) {
    return Book(
      id: map["id"],
      name: map["name"],
      writer: map["writer"],
      pageCount: map["pageCount"],
      imagePath: map["imagePath"],
      currentPage: map["currentPage"] ?? 0,
      comment: map["comment"],
      lastRead: map["lastRead"] == null
          ? null
          : DateTime.fromMillisecondsSinceEpoch(map["lastRead"]),
      createdAt: map["createdAt"] == null
          ? null
          : DateTime.fromMillisecondsSinceEpoch(map["createdAt"]),
    );
  }
}
