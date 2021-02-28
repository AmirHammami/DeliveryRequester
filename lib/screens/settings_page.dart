import 'dart:async';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';

import 'package:shared_preferences/shared_preferences.dart';


class SettingsPage extends StatefulWidget {


  @override
  _SettingsPageState createState() =>
      new _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {

  Firestore firestore;
  DatabaseReference database;


  bool _changed = false;
  SharedPreferences prefs;
  TextEditingController controllerNickname;
  TextEditingController controllerAboutMe;
  String id;
  String displayName;
  String aboutMe;
  String photoUrl;

  bool isLoading = false;
  File avatarImageFile;

  final FocusNode focusNodeNickname = new FocusNode();
  final FocusNode focusNodeAboutMe = new FocusNode();

  void _submit() {}

  @override
  initState() {
    super.initState();
    FirebaseDatabase.instance.setPersistenceEnabled(true);
    FirebaseDatabase.instance.setPersistenceCacheSizeBytes(10000000);
    database = FirebaseDatabase.instance.reference();
    
    Firestore.instance.settings(persistenceEnabled: true);
    firestore = Firestore.instance;

    readLocal();
  }

  void readLocal() async {
    prefs = await SharedPreferences.getInstance();
    
    id = prefs.getString('id') ?? '';
    displayName = prefs.getString('displayName') ?? '';
    aboutMe = prefs.getString('aboutMe') ?? '';
    photoUrl = prefs.getString('photoUrl') ?? '';

    controllerNickname = new TextEditingController(text: displayName);
    controllerAboutMe = new TextEditingController(text: aboutMe);

    // Force refresh input
    setState(() {});

  }

  void handleUpdateData() {
    focusNodeNickname.unfocus();
    focusNodeAboutMe.unfocus();


    setState(() {
      isLoading = true;
    });
    firestore.collection('users').document(id).updateData({
      'displayName': displayName,
      'aboutMe': aboutMe,
      'photoUrl': photoUrl.isEmpty?null:photoUrl
    });
    firestore.collection('buyers').document(id).updateData({
      'displayName': displayName,
      'aboutMe': aboutMe,
      'photoUrl': photoUrl.isEmpty?null:photoUrl
    }).then((data) async {
      await prefs.setString('displayName', displayName);
      await prefs.setString('aboutMe', aboutMe);
      await prefs.setString('photoUrl', photoUrl);
      setState(() {
        isLoading = false;
      });
      //Fluttertoast.showToast(msg: "Update success");
      Navigator.of(context).pop();
    }).catchError((err) {
      setState(() {
        isLoading = false;
      });

      //Fluttertoast.showToast(msg: err.toString());
    });
  }

  List<Widget> _buildForm(BuildContext context) {
    Form form = new Form(
      child: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            // Avatar
            Container(
              child: Center(
                child: Stack(
                  children: <Widget>[
                     Icon(
                                Icons.account_circle,
                                size: 90.0,
                                color: Colors.blue,
                              )
                        ,
                   
                  ],
                ),
              ),
              width: double.infinity,
              margin: EdgeInsets.all(20.0),
            ),
            Container(
              child: Text(
                'Name',
                //style: TextStyle(fontStyle: FontStyle.italic, fontWeight: FontWeight.bold, color: primaryColor),
              ),
              margin: EdgeInsets.only(left: 10.0, bottom: 5.0, top: 10.0),
            ),
            Container(
              child: Theme(
                //data: Theme.of(context).copyWith(primaryColor: primaryColor),
                child: TextField(
                  decoration: InputDecoration(
                    //hintText: 'First name',
                    contentPadding: new EdgeInsets.all(5.0),
                    //hintStyle: TextStyle(color: greyColor),
                  ),
                  controller: controllerNickname,
                  onChanged: (value) {
                    setState(() {
                      _changed = true;
                    });
                    displayName = value;
                  },
                  focusNode: focusNodeNickname,
                ),
              ),
              margin: EdgeInsets.only(left: 30.0, right: 30.0),
            ),

            // About me
            Container(
              child: Text(
                'About me',
                //style: TextStyle(fontStyle: FontStyle.italic, fontWeight: FontWeight.bold, color: primaryColor),
              ),
              margin: EdgeInsets.only(left: 10.0, top: 30.0, bottom: 5.0),
            ),
            Container(
              child: Theme(
                //data: Theme.of(context).copyWith(primaryColor: primaryColor),
                child: TextField(
                  decoration: InputDecoration(
                    
                    contentPadding: EdgeInsets.all(5.0),
                    //hintStyle: TextStyle(color: greyColor),
                  ),
                  controller: controllerAboutMe,
                  onChanged: (value) {
                    setState(() {
                      _changed = true;
                    });
                    aboutMe = value;
                  },
                  focusNode: focusNodeAboutMe,
                ),
              ),
              margin: EdgeInsets.only(left: 30.0, right: 30.0),
            ),

            Container(
              height: 8,
            ),
            _changed
                ? new ListTile(
                    leading: Icon(Icons.warning),
                    title: const Text('Tap '),
                  )
                : isLoading
                    ? Center(
                        child: CircularProgressIndicator(),
                      )
                    : Container(
                        width: 0,
                        height: 0,
                      ),
          ],
        ),
        padding: EdgeInsets.only(left: 15.0, right: 15.0),
      ),
    );

    var l = new List<Widget>();
    l.add(form);
    return l;
  }

  _leave() {
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(
        leading: IconButton(
            icon: IconButton(
                icon: Icon(Icons.arrow_back),
                onPressed: () {
                  if (_changed)
                    showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                              title: Text('Unsaved changes will be lost'),
                              actions: <Widget>[
                                FlatButton(
                                  child: Text('Lose'),
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                    _leave();
                                    //Navigator.of(context).pop();
                                  },
                                ),
                                FlatButton(
                                    child: Text('Save'),
                                    onPressed: () {
                                      Navigator.of(context).pop();
                                      handleUpdateData();
                                    }),
                              ]);
                        });
                  else
                    Navigator.of(context).pop();
                }),
            onPressed: () {
              //Navigator.of(context).pop();
            }),
        title: new Text('Profile'),
        actions: <Widget>[
          IconButton(
            icon: Icon(
              Icons.save,
              color: Colors.white,
            ),
            onPressed: handleUpdateData,
          )
        ],
      ),
      body: new Stack(
        children: _buildForm(context),
      ),
    );
  }
}
