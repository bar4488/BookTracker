import 'dart:io';
import 'package:book_tracker/books_bloc.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'models/book.dart';
import 'widgets/press_effect.dart';

class BookItem extends StatefulWidget {
  const BookItem({
    Key? key,
    this.isDeleting = false,
    required this.book,
    this.onLongPress,
    this.onTap,
    this.onDelete,
  }) : super(key: key);

  final Book book;
  final bool isDeleting;
  final Function()? onTap;
  final Function()? onDelete;
  final Function()? onLongPress;

  @override
  _BookItemState createState() => _BookItemState();
}

class _BookItemState extends State<BookItem>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;

  @override
  void initState() {
    _animationController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 150),
    );

    _animationController.value = 0.5;
    _animationController.addStatusListener((status) {
      if (widget.isDeleting) {
        if (status == AnimationStatus.completed) {
          _animationController.reverse();
        } else if (status == AnimationStatus.dismissed) {
          _animationController.forward();
        }
      }
    });
    super.initState();
  }

  void deleteBook(BooksBloc bloc) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Are you sure you want to delete ${widget.book.name}?"),
          actions: <Widget>[
            TextButton(
              child: Text("No"),
              onPressed: () async {
                Navigator.of(context).pop();
              },
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                primary: Theme.of(context).primaryColor,
              ),
              child: Text("Yes"),
              onPressed: () async {
                bloc.removeBook(widget.book);
                if (widget.onDelete != null) widget.onDelete!();
                Navigator.of(context).pop();
              },
            )
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    BooksBloc bloc = Provider.of<BooksBloc>(context);
    if (widget.isDeleting && !_animationController.isAnimating) {
      _animationController.forward();
    }
    if (!widget.isDeleting &&
        !_animationController.isDismissed &&
        _animationController.value != 0.5) _animationController.animateTo(0.5);
    ShapeBorder shape = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(20),
    );
    return Stack(
      children: <Widget>[
        AnimatedBuilder(
          animation: _animationController,
          builder: (context, widget) {
            return Transform.rotate(
              angle: (_animationController.value - 0.5) * 0.1,
              child: widget,
            );
          },
          child: AnimatedContainer(
            duration: Duration(milliseconds: 300),
            margin: EdgeInsets.all(widget.isDeleting ? 5 : 0),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  Expanded(
                    child: PressEffect(
                      onLongPress: widget.onLongPress,
                      onTap: !widget.isDeleting ? widget.onTap : null,
                      child: ClipPath(
                        clipper: ShapeBorderClipper(
                          shape: shape,
                        ),
                        child: Stack(
                          fit: StackFit.expand,
                          children: <Widget>[
                            Hero(
                              tag: "cover" + widget.book.id!,
                              child: Container(
                                decoration: ShapeDecoration(
                                  color: Colors.red,
                                  image: widget.book.imagePath != null
                                      ? DecorationImage(
                                          fit: BoxFit.cover,
                                          image: FileImage(
                                              File(widget.book.imagePath!)),
                                        )
                                      : null,
                                  shape: shape,
                                ),
                              ),
                            ),
                            Positioned(
                              bottom: 0,
                              right: 0,
                              left: 0,
                              child: Container(
                                height: 50,
                                color: Colors.black.withOpacity(0.5),
                              ),
                            ),
                            Positioned(
                              bottom: 0,
                              right: 0,
                              left: 0,
                              child: Container(
                                height: 50,
                                color: Colors.transparent,
                                child: Center(
                                  child: Hero(
                                    tag: "text" + widget.book.id.toString(),
                                    flightShuttleBuilder: (a, b, c, d, e) {
                                      return Material(
                                        color: Colors.transparent,
                                        child: FittedBox(
                                          fit: BoxFit.contain,
                                          child: Text(
                                            widget.book.name,
                                            style: TextStyle(
                                              color: Colors.white,
                                            ),
                                          ),
                                        ),
                                      );
                                    },
                                    child: Material(
                                      color: Colors.transparent,
                                      child: FittedBox(
                                        fit: BoxFit.fitWidth,
                                        child: Text(
                                          widget.book.name,
                                          style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 18),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      color: widget.book.imagePath != null
                          ? Colors.transparent
                          : Colors.red,
                      shape: shape,
                    ),
                  ),
                  SizedBox(
                    height: 4,
                  ),
                  Hero(
                    tag: "indicator" + widget.book.id!,
                    child: ClipPath(
                      clipper: ShapeBorderClipper(
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(2)),
                      ),
                      child: LinearProgressIndicator(
                        value: widget.book.currentPage / widget.book.pageCount,
                        color: widget.book.currentPage >= widget.book.pageCount
                            ? Colors.amber
                            : null,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        Positioned(
          top: 0,
          right: 0,
          left: 0,
          child: AnimatedBuilder(
            animation: _animationController,
            builder: (context, widget) {
              return Transform.scale(
                scale: _animationController.value * 0.1 + 0.9,
                child: widget,
              );
            },
            child: AnimatedSwitcher(
              duration: Duration(milliseconds: 200),
              transitionBuilder: (child, animation) {
                return ScaleTransition(
                  child: child,
                  scale: animation,
                );
              },
              child: widget.isDeleting
                  ? Transform.scale(
                      scale: 0.8,
                      child: FloatingActionButton(
                        onPressed: () => deleteBook(bloc),
                        elevation: 10,
                        child: Icon(
                          Icons.delete,
                          color: Colors.black,
                        ),
                        backgroundColor: Colors.white,
                      ),
                    )
                  : SizedBox(),
            ),
          ),
        ),
        if (widget.book.currentPage >= widget.book.pageCount)
          Positioned(
            right: 8,
            top: 8,
            child: Hero(
              tag: "check" + widget.book.id!,
              child: CircleAvatar(
                radius: 12,
                backgroundColor: Colors.white,
                child: Icon(
                  Icons.check_circle,
                  color: Color(0xff81E500),
                ),
              ),
            ),
          )
      ],
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }
}
