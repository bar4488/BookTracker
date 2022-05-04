class Book {
  Book({
    this.id,
    required this.name,
    required this.writer,
    required this.imagePath,
    required this.pageCount,
    this.currentPage = 0,
    this.comment,
  });

  String? id;
  String name;
  String writer;
  String? imagePath;
  int pageCount;
  int currentPage;

  String? comment;

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'writer': writer,
      'imagePath': imagePath,
      'pageCount': pageCount,
      'currentPage': currentPage,
      'comment': comment
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
        comment: map["comment"]);
  }
}
