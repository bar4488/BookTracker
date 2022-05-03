import 'auth.dart';
import 'package:flutter/material.dart';

class LoginPage extends StatefulWidget {
  const LoginPage(this.auth, {Key? key}) : super(key: key);

  final Auth? auth;

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () => Future<bool>.value(false),
      child: Scaffold(
        body: Center(
          child: ElevatedButton(
            child: Text("Login with google"),
            onPressed: () async {
              bool res = await widget.auth!.authenticateWithGoogle();
              if (res) {
                Navigator.pop(context);
              }
            },
          ),
        ),
      ),
    );
  }
}
