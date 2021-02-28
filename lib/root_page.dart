import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import './screens/home_page.dart';
import './screens/login_page.dart';

class RootPage extends StatefulWidget {
  @override
  _RootPageState createState() => _RootPageState();
}

enum AuthStatus { notSignedIn, signedIn, loading }

class _RootPageState extends State<RootPage> {
  AuthStatus authStatus = AuthStatus.loading;
  String currentUserId;
  bool login = true;

  @override
  void initState() {
    super.initState();
    //FirebaseAuth.instance.signOut();
    FirebaseAuth.instance.currentUser().then((user) {
      setState(() {
        authStatus =
            user == null ? AuthStatus.notSignedIn : AuthStatus.signedIn;
        if (user != null) {
          currentUserId = user.uid;
          if (user.email[0] != '+' && !user.isEmailVerified) {
            login = true;
            authStatus = AuthStatus.notSignedIn;
          }
        }
      });
    });
  }

  void _signedIn(FirebaseUser user) async {
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return new AlertDialog(
            title: Text('A moment'),
            content: SingleChildScrollView(
              child: ListBody(children: <Widget>[
                Container(
                  child: LinearProgressIndicator(),
                ),
                Text('Setting things up...')
              ]),
            ),
            contentPadding: EdgeInsets.all(10.0),
          );
        });

    Navigator.of(context).pop();
    setState(() {
      currentUserId = user.uid;
      authStatus = AuthStatus.signedIn;
    });
  }

  void _signedOut() async {
    try {
      await FirebaseAuth.instance.signOut();
    } catch (e) {
      print(e.toString);
    }
    setState(() {
      authStatus = AuthStatus.notSignedIn;
    });
  }

  @override
  Widget build(BuildContext context) {
    switch (authStatus) {
      case AuthStatus.notSignedIn:
        return new LoginPage(
          onSignedIn: _signedIn,
          login: this.login,
        );
      case AuthStatus.signedIn:
        return new HomePage(
          onSignedout: _signedOut,
          currentUserId: this.currentUserId,
        );
      case AuthStatus.loading:
        return new Scaffold(
          body: Center(
              child: Container(
            constraints: BoxConstraints.expand(
              height:
                  Theme.of(context).textTheme.display1.fontSize * 1.1 + 200.0,
            ),
            padding: const EdgeInsets.all(8.0),
            color: Colors.blue[600],
            alignment: Alignment.center,
            child: Text('توصيل سهل',
                style: Theme.of(context)
                    .textTheme
                    .display1
                    .copyWith(color: Colors.white)),
            transform: Matrix4.rotationZ(0.1),
          )),
        );
    }

    return new LoginPage();
  }
}
