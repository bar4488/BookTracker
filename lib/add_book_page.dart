import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class AddBookPage extends StatefulWidget {
  final String title = "Add Book";
  @override
  _AddBookPageState createState() => _AddBookPageState();
}

class _AddBookPageState extends State<AddBookPage> {
  File image;

  Future getImage() async {
    var image = await ImagePicker.pickImage(source: ImageSource.gallery);

    setState(() {
      this.image = image;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Container(
        margin: EdgeInsets.only(left: 12, right: 12, top: 22),
        child: Column(
          children: <Widget>[
            GestureDetector(
              onTap: () {
                getImage();
                print("ok");
              },
              child: Container(
                width: 108,
                height: 164,
                child: image != null ? Image.file(
                  image,
                  fit: BoxFit.cover,
                  width: 108,
                  height: 164,
                ) : null,
                decoration: BoxDecoration(border: Border.all(color: Colors.black)),
              ),
            ),
            TextField(
              decoration: InputDecoration(
                labelText: "name",
              ),
            ),
            SizedBox(
              height: 12,
            ),
            TextField(
              decoration: InputDecoration(
                labelText: "writer",
              ),
            ),
            SizedBox(
              height: 12,
            ),
            TextField(
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
    );
  }
}
