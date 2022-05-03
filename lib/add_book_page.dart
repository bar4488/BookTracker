import 'package:book_tracker/books_bloc.dart';
import 'package:book_tracker/models/book.dart';
import 'package:book_tracker/widgets/press_effect.dart';
import 'package:flutter/material.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

import 'package:provider/provider.dart';

class AddBookPage extends StatefulWidget {
  final String title = "Add Book";

  const AddBookPage({Key? key}) : super(key: key);

  @override
  _AddBookPageState createState() => _AddBookPageState();
}

class _AddBookPageState extends State<AddBookPage> {
  File? image;
  final _formKey = GlobalKey<FormState>();
  String? name;
  String? writer;
  int? pageCount;

  void getImage() async {
    File? image;
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
                XFile? tmp =
                    await _picker.pickImage(source: ImageSource.camera);
                if (tmp != null) {
                  image = File((tmp).path);
                  var decodedImage =
                      await decodeImageFromList(await image!.readAsBytes());
                  if (decodedImage.width > decodedImage.height) {
                    image = await FlutterImageCompress.compressAndGetFile(
                        image!.path, image!.path,
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
                XFile? tmp =
                    await _picker.pickImage(source: ImageSource.gallery);
                if (tmp != null) {
                  image = File((tmp).path);
                  var decodedImage =
                      await decodeImageFromList(await image!.readAsBytes());
                  if (decodedImage.width > decodedImage.height) {
                    image = await FlutterImageCompress.compressAndGetFile(
                        image!.path, image!.path,
                        autoCorrectionAngle: true, rotate: 90);
                  }
                }
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
    BooksBloc bloc = Provider.of<BooksBloc>(context);
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
                                image: FileImage(image!),
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
                      if (value!.isEmpty) return "please enter book name";
                      name = value;
                      return null;
                    },
                    decoration: InputDecoration(
                      labelText: "name",
                    ),
                  ),
                  SizedBox(
                    height: 12,
                  ),
                  TextFormField(
                    validator: (value) {
                      if (value!.isEmpty) return "please enter writer name";
                      writer = value;
                      return null;
                    },
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
                      if (value!.isEmpty) return "please enter number of pages";
                      if (int.tryParse(value) == null) {
                        return "number of pages must be a number";
                      }
                      pageCount = int.parse(value);
                      return null;
                    },
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
        label: Text("Add Book"),
        onPressed: () {
          if (_formKey.currentState!.validate()) {
            _addBook(bloc);
            Navigator.of(context).pop();
          }
        },
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  void _addBook(BooksBloc bloc) {
    bloc.addBook(Book(
        name: name!,
        pageCount: pageCount!,
        writer: writer!,
        imagePath: image?.path));
  }
}
