import 'package:book_tracker/book_screen/book_screen.dart';
import 'package:flutter_reorderable_grid_view/widgets/reorderable_builder.dart';
import 'auth.dart';
import 'login_page.dart';
import 'book_item.dart';
import 'package:book_tracker/add_book_page.dart';
import 'package:book_tracker/books_bloc.dart';
import 'models/book.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class BooksPage extends StatefulWidget {
  const BooksPage({Key? key}) : super(key: key);

  @override
  _BooksPageState createState() => _BooksPageState();
}

class _BooksPageState extends State<BooksPage> {
  bool currentlyDeleting = false;
  Auth? auth;
  @override
  void initState() {
    super.initState();
    checkLogin();
  }

  Future checkLogin() async {
    auth = Auth();
    if (!await auth!.isLoggedIn()) {
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
            FutureBuilder<List<Book>>(
              future: bloc.books,
              builder: (context, snapshot) {
                Widget widget;
                if (snapshot.hasData) {
                  List<Book> books = snapshot.data!;
                  if (books.isEmpty) {
                    return Center(
                      child: Text(
                        "You Dont have any books yet!",
                        style: TextStyle(fontSize: 18),
                      ),
                    );
                  }
                  widget = ReorderableBuilder(
                      children: List.generate(books.length, (index) {
                        Widget item = BookItem(
                          key: ValueKey(books[index].name),
                          book: books[index],
                          isDeleting: currentlyDeleting,
                          onTap: () async {
                            // ignore: unused_local_variable
                            final value = await Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => BookScreenScreen(
                                  book: books[index],
                                ),
                                settings: RouteSettings(name: "book_page"),
                              ),
                            );
                            setState(() {});
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
                      }),
                      enableDraggable: false,
                      builder: (children, controller) {
                        return GridView(
                          physics: BouncingScrollPhysics(),
                          gridDelegate:
                              SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 2, childAspectRatio: 3 / 4),
                          children: children,
                        );
                      });
                } else {
                  widget = Center(child: Text("loading books..."));
                }
                return widget;
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
                  auth!.signOut();
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
