import 'dart:io';

import 'package:book_tracker/add_book_page.dart';
import 'package:book_tracker/widgets/main_app_bar.dart';
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
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          builder: (_) => BooksBloc(),
        )
      ],
      child: MaterialApp(
        title: 'Flutter Demo',
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        home: MyHomePage(title: 'Flutter Demo Home Page'),
      ),
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
      body: Stack(
        children: <Widget>[
          Container(
            child: FutureBuilder(
              future: bloc.books,
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  List<Book> books = snapshot.data;
                  return GridView.builder(
                      padding: MediaQuery.of(context)
                          .padding
                          .add(EdgeInsets.only(top: 56)),
                      physics: BouncingScrollPhysics(),
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
          ),
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: MainAppBar(),
          ),
        ],
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
      builder: (double value) => Stack(
        fit: StackFit.expand,
        children: <Widget>[
          Container(
            decoration: ShapeDecoration(
              image: widget.book.imagePath != null
                  ? DecorationImage(
                      fit: BoxFit.cover,
                      image: FileImage(File(widget.book.imagePath)),
                    )
                  : null,
              shape: ContinuousRectangleBorder(
                borderRadius: BorderRadius.circular(100),
              ),
            ),
          ),
          Positioned(
            top: 20 + 20*value,
            left: 0,
            right: 0,
            child: Container(
              margin: EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: Color.lerp(Colors.transparent, Colors.white, value),
                borderRadius: BorderRadius.circular(12),
              ),
              padding: EdgeInsets.symmetric(vertical: 8),
              child: Text(
                widget.book.name,
                style: TextStyle(fontSize: 18 + value*10),
                textAlign: TextAlign.center,
              ),
            ),
          )
        ],
      ),
      color: Colors.red,
      shape: ContinuousRectangleBorder(
        borderRadius: BorderRadius.circular(100),
      ),
    );
  }
}
