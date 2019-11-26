import 'book_item.dart';
import 'package:book_tracker/add_book_page.dart';
import 'package:book_tracker/widgets/main_app_bar.dart';
import 'package:book_tracker/books_bloc.dart';
import 'models/book.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
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
          primarySwatch: Colors.red,
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
  bool currentlyDeleting = false;

  @override
  Widget build(BuildContext context) {
    final bloc = Provider.of<BooksBloc>(context);
    EdgeInsets padding = MediaQuery.of(context).padding;
    return WillPopScope(
      onWillPop: (){
        if(currentlyDeleting){
          setState(() {
            currentlyDeleting = false;
          });
          return Future<bool>(()=>false);
        }
        return Future<bool>(()=>true);
      },
          child: Scaffold(
        body: Container(
          child: Stack(
            children: <Widget>[
              Container(
                child: FutureBuilder(
                  future: bloc.books,
                  builder: (context, snapshot) {
                    Widget widget;
                    if (snapshot.hasData) {
                      List<Book> books = snapshot.data;
                      widget = GridView.builder(
                          padding: MediaQuery.of(context)
                              .padding
                              .add(EdgeInsets.only(top: 56)),
                          physics: BouncingScrollPhysics(),
                          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2, childAspectRatio: 3 / 4),
                          itemCount: books.length,
                          itemBuilder: (context, index) {
                            Widget item = BookItem(
                              book: books[index],
                              isDeleting: currentlyDeleting,
                              onLongPress: () {
                                setState(() {
                                  currentlyDeleting = !currentlyDeleting;
                                });
                              },
                              onDelete: () {
                                setState(() {
                                  currentlyDeleting = false;
                                });
                              },
                            );
                            return item;
                          });
                    } else {
                      widget = Center(child: Text("loading books..."));
                    }
                    return AnimatedSwitcher(
                      duration: Duration(milliseconds: 1500),
                      switchInCurve: Curves.easeIn,
                      switchOutCurve: Curves.easeOut,
                      child: widget,
                    );
                  },
                ),
              ),
              Positioned(
                top: padding.top + 8,
                left: 0,
                right: 0,
                child: MainAppBar(
                  icon: currentlyDeleting ? Icons.arrow_back : null,
                  onPress: (){
                    setState(() {
                      if(currentlyDeleting)
                        currentlyDeleting = false;
                    });
                  }
                ),
              ),
            ],
          ),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => AddBookPage(),
              ),
            );
          },
          tooltip: 'Add Book',
          child: Icon(Icons.add),
        ),
      ),
    );
  }
}
