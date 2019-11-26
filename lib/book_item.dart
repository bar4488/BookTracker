import 'dart:io';
import 'dart:math';
import 'package:book_tracker/books_bloc.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'models/book.dart';
import 'widgets/press_effect.dart';

class BookItem extends StatefulWidget {
  const BookItem({
    Key key,
    this.isDeleting = false,
    @required this.book,
    this.onLongPress,
    this.onTap,
    this.onDelete,
  }) : super(key: key);

  final Book book;
  final bool isDeleting;
  final Function() onTap;
  final Function() onDelete;
  final Function() onLongPress;

  @override
  _BookItemState createState() => _BookItemState();
}

class _BookItemState extends State<BookItem>
    with SingleTickerProviderStateMixin {
  AnimationController _animationController;

  @override
  void initState() {
    _animationController = new AnimationController(
      vsync: this,
      duration: new Duration(milliseconds: 150),
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

  @override
  Widget build(BuildContext context) {
    BooksBloc bloc = Provider.of<BooksBloc>(context);
    if (widget.isDeleting && !_animationController.isAnimating)
      _animationController.forward();
    if (!widget.isDeleting &&
        !_animationController.isDismissed &&
        _animationController.value != 0.5) _animationController.animateTo(0.5);
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, widget) {
        return Transform.rotate(
          angle: (_animationController.value - 0.5) * 0.1,
          child: widget,
        );
      },
      child: Stack(
        children: <Widget>[
          AnimatedContainer(
            duration: Duration(milliseconds: 300),
            margin: EdgeInsets.all(widget.isDeleting ? 5 : 0),
            child: PressEffect(
              onLongPress: widget.onLongPress,
              onTap: widget.onTap,
              child: ClipPath(
                clipper: ShapeBorderClipper(
                  shape: ContinuousRectangleBorder(
                    borderRadius: BorderRadius.circular(100),
                  ),
                ),
                child: Stack(
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
                      bottom: 0,
                      right: 0,
                      left: 0,
                      child: Container(
                        height: 50,
                        color: Colors.black.withOpacity(0.5),
                        child: Center(
                          child: Text(
                            widget.book.name,
                            style: TextStyle(color: Colors.white, fontSize: 18),
                          ),
                        ),
                      ),
                    )
                  ],
                ),
              ),
              color: Colors.red,
              shape: ContinuousRectangleBorder(
                borderRadius: BorderRadius.circular(100),
              ),
            ),
          ),
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: AnimatedSwitcher(
                duration: Duration(milliseconds: 200),
                transitionBuilder: (child, animation) {
                  return ScaleTransition(child: child, scale: animation);
                },
                child: Transform.scale(
                  scale: 0.8,
                  child: widget.isDeleting
                      ? FloatingActionButton(
                          onPressed: () {
                            setState(() {
                              bloc.removeBook(widget.book);
                              if (widget.onDelete != null) widget.onDelete();
                            });
                          },
                          elevation: 10,
                          child: Icon(
                            Icons.close,
                            color: Colors.black,
                          ),
                          backgroundColor: Colors.white,
                        )
                      : SizedBox(),
                )),
          )
        ],
      ),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }
}
