import 'package:flutter/material.dart';
import 'package:connectivity/connectivity.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:provider/provider.dart';

import '../providers/user_provider.dart';
import '../widgets/order.dart';
import './home_page.dart';

//https://flutter.dev/docs/cookbook/forms/validation

class MakeOrderPage extends StatefulWidget {
  final Function tabTapped;
  final DatabaseReference databaseRef;

  MakeOrderPage({this.databaseRef, this.tabTapped});

  @override
  _MakeOrderPageState createState() =>
      _MakeOrderPageState(databaseRef: this.databaseRef);
}

class _MakeOrderPageState extends State<MakeOrderPage> {
  final DatabaseReference databaseRef;

  _MakeOrderPageState({this.databaseRef});

  final _scaffoldKey = GlobalKey<ScaffoldState>();
  final _formKey = GlobalKey<FormState>();

  String currentUserId, currentUserName;
  UserProvider userProvider;

  String _orderContent = '';
  final TextEditingController _orderCtnt = new TextEditingController();
  @override
  Widget build(BuildContext context) {
    userProvider = Provider.of<UserProvider>(
      context,
      listen: true,
    );

    currentUserId = userProvider.currentUserId;
    currentUserName = userProvider.currentUserName;

    return Scaffold(
      key: _scaffoldKey,
      body: _buildContents(),
      backgroundColor: Colors.grey[200],
    );
  }

  Widget _buildContents() {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Card(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: _buildForm(),
          ),
        ),
      ),
    );
  }

  Widget _buildForm() {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: _buildFormChildren(),
      ),
    );
  }

  List<Widget> _buildFormChildren() {
    return [
      TextFormField(
        controller: _orderCtnt,
        decoration: InputDecoration(
          labelText: 'اكتب نص الطلب هنا',
          fillColor: Colors.white,
          labelStyle:
              TextStyle(color: Colors.blueAccent, fontWeight: FontWeight.w600),
          enabledBorder: OutlineInputBorder(
            borderSide: const BorderSide(color: Colors.white30, width: 2.0),
            borderRadius: BorderRadius.circular(30.0),
          ),
          /*suffixIcon: IconButton(
            icon: Icon(
              Icons.comment,
              color: Colors.greenAccent,
              size: 40.0,
            ),
            onPressed: () {},
          ),*/
        ),
        //initialValue: _orderContent,
        minLines: 15,
        keyboardType: TextInputType.multiline,
        maxLines: null,
        validator: (value) =>
            value.isNotEmpty ? null : 'لابد من كتابة نص الطلب',
        onSaved: (value) {
          setState(() {
            this._orderContent = value;
          });
        },
      ),
      SizedBox(
        height: 20,
      ),
      MaterialButton(
        //key: Key('request'),
        //) RaisedButton(
        //disabledColor:Colors.lightBlue,
        color: Theme.of(context).primaryColor,
        onPressed: () {
          // Validate returns true if the form is valid, otherwise false.
          if (_formKey.currentState.validate()) {
            _formKey.currentState.save();
            // If the form is valid, display a snackbar. In the real world,
            // you'd often call a server or save the information in a database.

            _showDialog();
            //print("OrderContent + " + this._orderContent);
            //Scaffold.of(context).showSnackBar(SnackBar(
            //    content: Text('Processing Data' + this._orderContent)));
          }
        },
        child: Padding(
          padding: EdgeInsets.all(9),
          child: Text('تسجيل الطلب',
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold)),
        ),
      ),
      /*OutlineButton(
        shape: StadiumBorder(),
        textColor: Colors.blue,
        child: Text('تسجيل الطلب'),
        borderSide:
            BorderSide(color: Colors.blue, style: BorderStyle.solid, width: 1),
        onPressed: () {
          // Validate returns true if the form is valid, otherwise false.
          if (_formKey.currentState.validate()) {
            _formKey.currentState.save();
            // If the form is valid, display a snackbar. In the real world,
            // you'd often call a server or save the information in a database.

            _showDialog();
            //print("OrderContent + " + this._orderContent);
            //Scaffold.of(context).showSnackBar(SnackBar(
            //    content: Text('Processing Data' + this._orderContent)));
          }
        },
      ),*/
    ];
  }

  _showDialog() async {
    if (this._orderContent != "")
      showDialog<String>(
        context: context,
        builder: (BuildContext context) {
          return new AlertDialog(
            contentPadding: const EdgeInsets.all(16.0),
            title: Text(
              'تأكيد',
              style: TextStyle(color: Theme.of(context).accentColor),
            ),
            content: Text(
              'سيتم تسجيل الطلب',
            ),
            actions: <Widget>[
              new FlatButton(
                  child: const Text('الغاء'),
                  onPressed: () {
                    Navigator.of(context).pop();
                  }),
              new FlatButton(
                child: const Text('تسجيل'),
                onPressed: () {
                  _requestDelivery(
                          new Order(
                              type: Order.REQUESTED,
                              destlat: HomePage.currentLat,
                              destlong: HomePage.currentLong,
                              userId: currentUserId,
                              userName: currentUserName,
                              driverId: '00001111',
                              driverName: 'توصيل',
                              driverPhone: '',
                              ordertext: this._orderContent,
                              timestamp: DateTime.now().millisecondsSinceEpoch),
                          context)
                      .then((v) {
                    Navigator.of(context).pop();

                    //_tabController.animateTo(2);
                  });
                },
              ),
            ],
          );
        },
      );
    else {
      showDialog<void>(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text(
              'حصل خطأ',
              style: TextStyle(color: Theme.of(context).accentColor),
            ),
            content: SingleChildScrollView(
              child: ListBody(
                children: <Widget>[
                  Text('حاول مرة أخرى'),
                ],
              ),
            ),
            actions: <Widget>[
              FlatButton(
                child: Text('إلغاء'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        },
      );
    }
  }

  static showModal(text, sent_context) {
    showDialog(
        context: sent_context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return new AlertDialog(
            title: Text(text),
            content: LinearProgressIndicator(),
            contentPadding: EdgeInsets.all(10.0),
          );
        });
  }

  _requestDelivery(Order order, BuildContext context) async {
    bool isConnected = await check();

    if (isConnected != null && isConnected) {
      // Internet Present Case
      showModal('تسجيل...', context);
      String key = 'O:${DateTime.now().millisecondsSinceEpoch}';

      await databaseRef
          .child('drivers')
          .child(order.driverId) // '00001111'
          .child('requests')
          .update({
        key: order.toMap(),
      }); //.timeout(Duration(seconds: 10));

      await databaseRef
          .child('requesters')
          .child(currentUserId)
          .child('requests')
          .update({
        key: order.toMap(),
      }); //.timeout(Duration(seconds: 10));

      setState(() {
          this._orderContent = '';
          _formKey.currentState.reset();
          _orderCtnt.clear();
      });
    
      Navigator.of(context).pop();
      //_tabController.animateTo(2);
      widget.tabTapped(1);

    } else {
      // No-Internet Case
      SnackBar snackbar = SnackBar(
          content: Text(
        'فضلا٬ تأكد من الاتصال بالنت...',
        overflow: TextOverflow.ellipsis,
      ));
      _scaffoldKey.currentState.showSnackBar(snackbar);
    }
  }

  Future<bool> check() async {
    var connectivityResult = await (Connectivity().checkConnectivity());
    if (connectivityResult == ConnectivityResult.mobile) {
      return true;
    } else if (connectivityResult == ConnectivityResult.wifi) {
      return true;
    }
    return false;
  }
}