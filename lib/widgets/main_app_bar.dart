import 'package:flutter/material.dart';

class MainAppBar extends StatelessWidget implements PreferredSizeWidget {
  const MainAppBar({
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    EdgeInsets padding = MediaQuery.of(context).padding;
    return Container(
      padding: padding.add(EdgeInsets.symmetric(horizontal: 8)),
      height: preferredSize.height + padding.top,
      child: Row(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          SizedBox(
            width: 40,
            height: 40,
            child: RaisedButton(
              elevation: 10,
              onPressed: () {},
              padding: EdgeInsets.all(0),
              shape: ContinuousRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
              child: Container(
                child: Icon(Icons.menu),
              ),
            ),
          ),
          SizedBox(width: 16,),
          Expanded(
            child: SizedBox(
              height: 40,
              child: Material(
                color: Colors.grey[200],
                type: MaterialType.card,
                elevation: 5,
                shape: ContinuousRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
                child: Container(
                  margin: EdgeInsets.only(left: 16),
                  alignment: Alignment.centerLeft,
                  child: Text("Book Reader", style: TextStyle(fontSize: 16),),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(56);
}
