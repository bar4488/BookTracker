import 'package:book_tracker/add_book_page.dart';
import 'widgets/press_effect.dart';
import 'package:book_tracker/books_bloc.dart';
import 'models/book.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: ChangeNotifierProvider<BooksBloc>(
          builder: (_) => BooksBloc(),
          child: MyHomePage(title: 'Flutter Demo Home Page')),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);
  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    final bloc = Provider.of<BooksBloc>(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: FutureBuilder(
        future: bloc.books,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            List<Book> books = snapshot.data;
            return GridView.builder(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2, childAspectRatio: 3 / 4),
                itemCount: books.length,
                itemBuilder: (context, index) {
                  return BookItem(book: books[index]);
                });
          } else {
            return CircularProgressIndicator();
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context)
              .push(MaterialPageRoute(builder: (context) => AddBookPage()));
        },
        tooltip: 'Add Book',
        child: Icon(Icons.add),
      ),
    );
  }
}

class BookItem extends StatefulWidget {
  const BookItem({
    Key key,
    @required this.book,
  }) : super(key: key);

  final Book book;

  @override
  _BookItemState createState() => _BookItemState();
}

class _BookItemState extends State<BookItem> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return PressEffect(
      child: Container(
        margin: EdgeInsets.only(top: 16),
        child: Text(
          widget.book.name,
          style: TextStyle(fontSize: 18),
          textAlign: TextAlign.center,
        ),
      ),
      color: Colors.red,
      shape: ContinuousRectangleBorder(
        borderRadius: BorderRadius.circular(100),
      ),
    );
  }
}
