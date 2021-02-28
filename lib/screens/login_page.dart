import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class LoginPage extends StatefulWidget {
  LoginPage({this.onSignedIn, this.login});

  final ValueChanged<FirebaseUser> onSignedIn;
  final bool login;

  @override
  State<StatefulWidget> createState() {
    return new _LoginPageState(login: this.login);
  }
}

enum FormType { login, register }

class _LoginPageState extends State<LoginPage> {
  final FirebaseAuth fAuth = FirebaseAuth.instance;
  final formKey = new GlobalKey<FormState>();
  String email;
  String _pin;
  String _name;
  bool useEmail = false;
  bool login = true;
  bool _obscureText = true;
  bool _nameOk = false;

  _LoginPageState({this.login});

  void _toggle() {
    setState(() {
      _obscureText = !_obscureText;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: new AppBar(
          actions: <Widget>[
            IconButton(
              icon: Icon(
                Icons.help,
                color: Colors.white,
              ),
              onPressed: () {},
            ),
          ],
          title: Text('مرحبا'),
          centerTitle: true,
        ),
        body: new GestureDetector(
            onTap: () {
              FocusScope.of(context).requestFocus(new FocusNode());
            },
            child: SingleChildScrollView(
              child: Center(
                child: new Container(
                  padding: EdgeInsets.all(16.0),
                  child: new Form(
                    key: formKey,
                    child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        //crossAxisAlignment: CrossAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Padding(
                            padding: EdgeInsets.all(8),
                            child: Container(
                              height: 150,
                              width: 80,
                              decoration: new BoxDecoration(
                                image: new DecorationImage(
                                  image: ExactAssetImage(
                                      'assets/images/delivery.jpeg'),
                                  fit: BoxFit.fitHeight,
                                ),
                              ),
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.all(8),
                            child: Center(
                              child: Text('سجل طلب • تابع • استلم',
                                  style: TextStyle(
                                      fontSize: 17,
                                      color: Theme.of(context).accentColor)),
                            ),
                          ),
                          Card(
                            /*shape: new RoundedRectangleBorder(
            side: new BorderSide(
                color: Theme.of(context).accentColor, width: 2.0),
            borderRadius: BorderRadius.circular(4.0)),
        */
                            shape: RoundedRectangleBorder(
                              side: new BorderSide(
                                  color: Theme.of(context).accentColor,
                                  width: 2.0),
                              borderRadius: BorderRadius.circular(15),
                            ),
                            elevation: 4,
                            margin: EdgeInsets.all(10),
                            child: Padding(
                              padding: const EdgeInsets.all(15.0),
                              child: Column(
                                children: <Widget>[
                                  TextField(
                                    decoration: InputDecoration(
                                        labelText: "Enter email address"),

                                    //onSaved: (value) => phoneNo = value,
                                    onChanged: (value) {
                                      this.email = value.trim();
                                    },
                                  ),
                                  Row(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: <Widget>[
                                Expanded(
                                  child: new TextField(
                                    decoration: InputDecoration(
                                      //icon: IconButton(icon: new Icon(Icons.remove_red_eye)),
                                      labelText:
                                          '${login ? "Enter" : "Choose a"} password',
                                    ),
                                    obscureText: _obscureText,

                                    //onSaved: (value) => phoneNo = value,
                                    onChanged: (value) {
                                      this._pin = value.trim();
                                    },
                                  ),
                                ),
                                new FlatButton(
                                    onPressed: _toggle,
                                    child:
                                        new Text(_obscureText ? "Show" : "Hide"))
                              ],
                          ),
                              
                            
                        
                          
                          login
                              ? Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: <Widget>[
                                      Padding(
                                          padding: new EdgeInsets.all(8.0),
                                          child: InkWell(
                                              onTap: () async {
                                                try {
                                                  await FirebaseAuth.instance
                                                      .sendPasswordResetEmail(
                                                          email: email);
                                                  showDialog(
                                                    context: context,
                                                    builder:
                                                        (BuildContext context) {
                                                      return AlertDialog(
                                                        title: Text(
                                                            'Password reset'),
                                                        content: Text(
                                                            'A password reset link has been sent to $email. Check $email for further instructions on resetting your password'),
                                                        actions: <Widget>[
                                                          new FlatButton(
                                                            onPressed: () {
                                                              Navigator.of(
                                                                      context)
                                                                  .pop();
                                                            },
                                                            child: Text('OK'),
                                                          ),
                                                        ],
                                                      );
                                                    },
                                                  );
                                                } catch (e) {
                                                  showMessageDialog(e.message);
                                                }
                                              },
                                              child: new Text(
                                                  'Forgot password?',
                                                  style: TextStyle(
                                                      color: Theme.of(context)
                                                          .accentColor))))
                                    ])
                              : Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: <Widget>[
                                    TextField(
                                      decoration: InputDecoration(
                                        labelText: 'الاسم',
                                      ),
                                      onChanged: (value) {
                                        //print("Name field: $value");
                                        setState(() {
                                          this._name = value.trim();
                                          this._nameOk = _name.isNotEmpty;
                                        });
                                      },
                                    ),
                                  ],
                                ),
                                  ],
                              ),
                            ),
                    ),
                          Padding(
                            padding: EdgeInsets.all(8),
                            
                            child: OutlineButton(
                            shape: RoundedRectangleBorder(
                              side: new BorderSide(
                                  color: Theme.of(context).accentColor,
                                  width: 2.0),
                              borderRadius: BorderRadius.circular(15),
                            ),
                              //shape: StadiumBorder(),
                              borderSide: BorderSide(
                                  color: Theme.of(context).accentColor, width: 2.0, ),
                              //textColor: Theme.of(context).accentColor,
                              onPressed: (login || (!login && _nameOk))
                                  ? verifyEmail
                                  : () {
                                      showMessageDialog('Please type name');
                                    },
                              color: Theme.of(context).accentColor,
                              child: Text('${login ? "Login " : " Sign up"}',
                                  style: TextStyle(
                                      color: Theme.of(context).accentColor,)),
                            ),
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              Text(
                                  '${login ? "New to Delivery ?" : "Already have an account?"}'),
                              InkWell(
                                child: Text('${login ? " Sign up" : " Log in"}',
                                    style: TextStyle(
                                        color: Theme.of(context).accentColor)),
                                onTap: () {
                                  setState(() {
                                    login = !login;
                                  });
                                },
                              )
                            ],
                          ),
                        ]),
                  ),
                ),
              ),
            )));
  }

  showSimple(title, content) {
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return new AlertDialog(
            title: Text(title),
            content: SingleChildScrollView(
              child: ListBody(children: <Widget>[
                Container(
                  child: LinearProgressIndicator(),
                ),
                Text(content)
              ]),
            ),
            contentPadding: EdgeInsets.all(10.0),
          );
        });
  }

  showMessageDialog(String message) {
    print(message);
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Note'),
          content: Text(message ?? 'Try again'),
          actions: <Widget>[
            new FlatButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('OK'),
            ),
          ],
        );
      },
    );
  }

  saveUserDetails(FirebaseUser user) async {
    DatabaseReference dRef = FirebaseDatabase.instance.reference();
    Firestore fRef = Firestore.instance;
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('id', user.uid);
    await prefs.setString('displayName', _name);
    await prefs.setString('photoUrl', user.photoUrl);

    final snapShot = await fRef.collection('requesters').document(user.uid).get();
    login = true;

    if (snapShot == null || !snapShot.exists) {
      login = false;
    }

    if (login) {
      print('Old requester');
      Map<String, dynamic> map =
          (await fRef.collection('requesters').document(user.uid)?.get()).data;

      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setString('id', user.uid);
      await prefs.setString(
          'displayName', map != null ? map['displayName'] : _name);
      await prefs.setString('photoUrl', map != null ? map['photoUrl'] : null);
    } else {
      print('New requester');
      await dRef.child('requesters').child(user.uid).set(
          {'id': user.uid, 'photoUrl': user.photoUrl, 'displayName': _name});
      await fRef.collection('requesters').document(user.uid).setData(
          {'id': user.uid, 'displayName': _name, 'photoUrl': user.photoUrl});
      await fRef.collection('users').document(user.uid).setData({
        'displayName': _name,
        'photoUrl': user.photoUrl,
      });
    }
  }

  Future<void> verifyEmail() async {
    if (login) {
      showSimple('Log in', 'Verifying user credentials...');
      try {
        FirebaseUser user = (await fAuth.signInWithEmailAndPassword(
                email: email, password: _pin))
            .user;
        if (user.isEmailVerified) {
          await saveUserDetails(user);
          Navigator.of(context).pop();
          widget.onSignedIn(user);
        } else {
          await user.sendEmailVerification();
          Navigator.of(context).pop();
          showMessageDialog(
              'Email is not verified, check $email for verification link');
        }
      } catch (e) {
        Navigator.of(context).pop();
        print(e.toString());
        showMessageDialog(e.message);
      }
    } else {
      showSimple('A moment', 'Creating your account...');
      try {
        FirebaseUser user = (await fAuth.createUserWithEmailAndPassword(
                email: email, password: this._pin))
            .user;
        await user.sendEmailVerification();
        Navigator.of(context).pop();
      } catch (e) {
        Navigator.of(context).pop();
        print(e.toString());
        //Navigator.of(context).pop();
        showMessageDialog(e.message);
        return;
      }

      showDialog(
          context: context,
          barrierDismissible: false,
          builder: (BuildContext context) {
            return new StreamBuilder<FirebaseUser>(
              stream: fAuth.onAuthStateChanged,
              builder: (BuildContext context, snapshot) {
                if (snapshot.hasData) {
                  return snapshot.data.isEmailVerified
                      ? AlertDialog(
                          title: Text('Verification'),
                          content: Text('$email is verified'),
                          contentPadding: EdgeInsets.all(10.0),
                          actions: <Widget>[
                            new FlatButton(
                              onPressed: () {
                                Navigator.of(context).pop();
                              },
                              child: Text('Change email'),
                            ),
                            new FlatButton(
                              onPressed: () {
                                setState(() {
                                  login = true;
                                });
                                Navigator.of(context).pop();
                              },
                              child: Text('Log in'),
                            ),
                          ],
                        ) //MainPage()
                      : AlertDialog(
                          title: Text('Verification'),
                          content: Text('Check $email for verification link.'),
                          contentPadding: EdgeInsets.all(10.0),
                          actions: <Widget>[
                            new FlatButton(
                              onPressed: () {
                                Navigator.of(context).pop();
                              },
                              child: Text('Change email'),
                            ),
                            new FlatButton(
                              onPressed: () {
                                setState(() {
                                  login = true;
                                });
                                Navigator.of(context).pop();
                              },
                              child: Text('Log in'),
                            ),
                          ],
                        ); // VerifyEmailPage(user: snapshot.data);
                } else {
                  return AlertDialog(
                    title: Text('Waiting'),
                    content: CircularProgressIndicator(),
                    contentPadding: EdgeInsets.all(10.0),
                    actions: <Widget>[
                      new FlatButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        child: Text('Change email'),
                      ),
                      new FlatButton(
                        onPressed: () {
                          //Navigator.of(context).pop();
                        },
                        child: Text('OK'),
                      ),
                    ],
                  );
                }
              },
            );
          });
    }
  }
}
