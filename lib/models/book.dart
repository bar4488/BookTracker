class Book{

  Book({this.id, this.name, this.writer, this.imagePath, this.pageCount, this.currentPage = 0});

  int id;
  String name;
  String writer;
  String imagePath;
  int pageCount;
  int currentPage;

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'writer': writer,
      'imagePath': imagePath,
      'pageCount': pageCount,
      'currentPage': currentPage,
    };
  }

  factory Book.fromMap(Map<String, dynamic> map){
    return Book(
      id: map["id"],
      name: map["name"],
      writer: map["writer"],
      pageCount: map["pageCount"],
      imagePath: map["imagePath"],
      currentPage: map["currentPage"] ?? 0,
    );
  }
}
