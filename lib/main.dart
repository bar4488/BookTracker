import 'package:book_tracker/book_screen/book_screen_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'auth.dart';
import 'login_page.dart';
import 'book_item.dart';
import 'package:book_tracker/add_book_page.dart';
import 'package:book_tracker/books_bloc.dart';
import 'models/book.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => BooksBloc(),
        )
      ],
      child: MaterialApp(
        title: 'Flutter Demo',
        theme: ThemeData(
          primarySwatch: Colors.deepOrange,
        ),
        home: MyHomePage(),
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key key}) : super(key: key);

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  bool currentlyDeleting = false;
  Auth auth;
  @override
  void initState() {
    super.initState();
    checkLogin();
  }

  Future checkLogin() async {
    auth = Auth();
    if (!await auth.isLoggedIn()) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => LoginPage(auth),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final bloc = Provider.of<BooksBloc>(context);
    return WillPopScope(
      onWillPop: () {
        if (currentlyDeleting) {
          setState(() {
            currentlyDeleting = false;
          });
          return Future<bool>(() => false);
        }
        return Future<bool>(() => true);
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text("Book Reader"),
          actions: <Widget>[
            IconButton(
              icon: Icon(currentlyDeleting ? Icons.close : Icons.delete_sweep),
              onPressed: () {
                setState(() {
                  currentlyDeleting = !currentlyDeleting;
                });
              },
            ),
          ],
          leading: IconButton(
            icon: Icon(Icons.menu),
            onPressed: () {},
          ),
        ),
        body: Stack(
          children: <Widget>[
            FutureBuilder(
              future: bloc.books,
              builder: (context, snapshot) {
                Widget widget;
                if (snapshot.hasData) {
                  List<Book> books = snapshot.data;
                  if (books.isEmpty) {
                    return Center(
                      child: Text(
                        "You Dont have any books yet!",
                        style: TextStyle(fontSize: 18),
                      ),
                    );
                  }
                  widget = GridView.builder(
                      physics: BouncingScrollPhysics(),
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2, childAspectRatio: 3 / 4),
                      itemCount: books.length,
                      itemBuilder: (context, index) {
                        Widget item = BookItem(
                          book: books[index],
                          isDeleting: currentlyDeleting,
                          onTap: () {
                            Navigator.of(context).push(MaterialPageRoute(
                                builder: (_) => BookScreenScreen(
                                      book: books[index],
                                    )));
                          },
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
            /*
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
            */
          ],
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
        drawer: Drawer(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              ListView(
                shrinkWrap: true,
                // Important: Remove any padding from the ListView.
                padding: EdgeInsets.zero,
                children: <Widget>[
                  DrawerHeader(
                    child: Text('Drawer Header'),
                    decoration: BoxDecoration(
                      color: Theme.of(context).primaryColor,
                    ),
                  ),
                  ListTile(
                    title: Text('Item 1'),
                    onTap: () {
                      // Update the state of the app.
                      // ...
                    },
                  ),
                  ListTile(
                    title: Text('Item 2'),
                    onTap: () {
                      // Update the state of the app.
                      // ...
                    },
                  ),
                ],
              ),
              ListTile(
                leading: Icon(Icons.exit_to_app),
                title: Text('Logout'),
                onTap: () {
                  auth.signOut();
                  Navigator.push(context,
                      MaterialPageRoute(builder: (_) => LoginPage(auth)));
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
