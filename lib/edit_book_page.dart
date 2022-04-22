import 'package:book_tracker/book_screen/book_bloc.dart';
import 'package:book_tracker/books_bloc.dart';
import 'package:book_tracker/widgets/press_effect.dart';
import 'package:flutter/material.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

import 'package:provider/provider.dart';

class EditBookPage extends StatefulWidget {
  final String title = "Add Book";
  final BookBloc bloc;

  const EditBookPage(this.bloc, {Key key}) : super(key: key);

  @override
  _EditBookPageState createState() => _EditBookPageState();
}

class _EditBookPageState extends State<EditBookPage> with ChangeNotifier {
  File image;
  final _formKey = GlobalKey<FormState>();
  BookBloc bloc;

  @override
  void setState(VoidCallback fn) {
    if (bloc.book.imagePath != null) image = File(bloc.book.imagePath);
    bloc = widget.bloc;
    super.setState(fn);
  }

  void getImage() async {
    File image;
    final ImagePicker _picker = ImagePicker();
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Pick from gallary or camera"),
          actions: <Widget>[
            TextButton(
              child: Text("Camera"),
              onPressed: () async {
                image = File(
                    (await _picker.pickImage(source: ImageSource.camera)).path);
                if (image != null && image.path != null) {
                  var decodedImage =
                      await decodeImageFromList(image.readAsBytesSync());
                  if (decodedImage.width > decodedImage.height) {
                    image = await FlutterImageCompress.compressAndGetFile(
                        image.path, image.path,
                        autoCorrectionAngle: true, rotate: 90);
                  }
                }

                setState(() {
                  Navigator.of(context).pop();
                  this.image = image;
                });
              },
            ),
            TextButton(
              child: Text("Gallery"),
              onPressed: () async {
                image = File(
                    (await _picker.pickImage(source: ImageSource.gallery))
                        .path);
                setState(() {
                  Navigator.of(context).pop();
                  this.image = image;
                });
              },
            )
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    BooksBloc booksBloc = Provider.of<BooksBloc>(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: SizedBox(
        height: double.infinity,
        child: SingleChildScrollView(
          physics: BouncingScrollPhysics(),
          child: Container(
            margin: EdgeInsets.only(left: 12, right: 12, top: 22),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.max,
                children: <Widget>[
                  PressEffect(
                    onTap: () {
                      getImage();
                    },
                    width: 108,
                    height: 164,
                    color: Colors.amber,
                    shape: ContinuousRectangleBorder(
                      borderRadius: BorderRadius.circular(70),
                    ),
                    child: Container(
                      decoration: ShapeDecoration(
                        image: image != null
                            ? DecorationImage(
                                fit: BoxFit.cover,
                                image: FileImage(image),
                              )
                            : null,
                        shape: ContinuousRectangleBorder(
                          borderRadius: BorderRadius.circular(70),
                        ),
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: const [Colors.amber, Colors.red],
                        ),
                      ),
                    ),
                  ),
                  TextFormField(
                    validator: (value) {
                      if (value.isEmpty) return "please enter book name";
                      bloc.book.name = value;
                      return null;
                    },
                    initialValue: bloc.book.name,
                    decoration: InputDecoration(
                      labelText: "name",
                    ),
                  ),
                  SizedBox(
                    height: 12,
                  ),
                  TextFormField(
                    validator: (value) {
                      if (value.isEmpty) return "please enter writer name";
                      bloc.book.writer = value;
                      return null;
                    },
                    initialValue: bloc.book.writer,
                    decoration: InputDecoration(
                      labelText: "writer",
                    ),
                  ),
                  SizedBox(
                    height: 12,
                  ),
                  TextFormField(
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value.isEmpty) return "please enter number of pages";
                      if (int.tryParse(value) == null) {
                        return "number of pages must be a number";
                      }
                      bloc.book.pageCount = int.parse(value);
                      return null;
                    },
                    initialValue: bloc.book.pageCount.toString(),
                    decoration: InputDecoration(
                      labelText: "number of pages",
                    ),
                  ),
                  SizedBox(
                    height: 12,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        label: Text("Save Book"),
        onPressed: () {
          if (_formKey.currentState.validate()) {
            _updateBook(booksBloc);
            Navigator.of(context).pop();
          }
        },
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  void _updateBook(BooksBloc booksBloc) {
    bloc.book.imagePath = image?.path;
    booksBloc.updateBook(bloc.book);
    bloc.notifyListeners();
  }
}
