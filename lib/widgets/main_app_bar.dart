import 'package:flutter/material.dart';

class MainAppBar extends StatelessWidget {
  const MainAppBar({
    Key key,
    this.icon,
    this.onPress,
  }) : super(key: key);

  final IconData icon;
  final Function() onPress;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8),
      child: Row(
        children: <Widget>[
          Container(
            width: 40,
            height: 40,
            child: Material(
              elevation: 10,
              shape: ContinuousRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
              child: InkWell(
                onTap: () {
                  if(onPress != null)
                    onPress();
                },
                child: Container(
                  child: Icon(icon ?? Icons.menu),
                ),
              ),
            ),
          ),
          SizedBox(
            width: 16,
          ),
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
                  child: Text(
                    "Book Reader",
                    style: TextStyle(fontSize: 16),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Size get preferredSize => Size.fromHeight(56);
}