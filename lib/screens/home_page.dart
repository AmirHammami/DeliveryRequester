import 'package:flutter/material.dart';
import 'package:requester/screens/delivered_orders_page.dart';
import 'package:share/share.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:provider/provider.dart';
import 'package:geolocator/geolocator.dart';

import '../providers/user_provider.dart';
import './make_order_page.dart';
import './orders_page.dart';
import './delivered_orders_page.dart';
import './settings_page.dart';
import './support_page.dart';
import './contact_page.dart';
import './about_page.dart';

class HomePage extends StatefulWidget {
  final VoidCallback onSignedout;
  final String currentUserId;
  static double currentLat = 0.0;
  static double currentLong = 0.0;

  HomePage({this.onSignedout, this.currentUserId});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>
    with SingleTickerProviderStateMixin {
  DatabaseReference databaseRef;
  FirebaseDatabase database;
  int _currentIndex = 0;
  String _title;


  List<Widget> _children = [];

  GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey();

  @override
  initState() {
    _startup().then((value) {}).catchError((e) {
      print(e.toString());
    });
    super.initState();

    _children = [
      MakeOrderPage(databaseRef: databaseRef, tabTapped: onTabTapped),
      OrdersPage(databaseRef: databaseRef),
      DeliveredOrdersPage(databaseRef: databaseRef),
    ];
    _title = 'طلب جديد';

    setState(() {});
  }

  Future<void> _startup() async {
    database = FirebaseDatabase.instance;
    database.setPersistenceEnabled(true);
    database.setPersistenceCacheSizeBytes(10000000);
    databaseRef = database.reference();

    //currentUserName = prefs.getString('displayName');

    await Provider.of<UserProvider>(
      context,
      listen: false,
    ).init();

    var geolocator = Geolocator();
    await geolocator
        .getCurrentPosition(desiredAccuracy: LocationAccuracy.best)
        .then((value) {
      Position position = value;
      if (position != null) _updateLocation(position);
      var locationOptions =
          LocationOptions(accuracy: LocationAccuracy.high, distanceFilter: 10);
      geolocator.getPositionStream(locationOptions).listen((Position position) {
        if (position != null) _updateLocation(position);
      });
    });
  }

  _updateLocation(Position position) {
    if (position.latitude > 0.0 && position.longitude > 0.0) {
      if (mounted)
        setState(() {
          HomePage.currentLat = position.latitude;
          HomePage.currentLong = position.longitude;
        });
      databaseRef
          .child('requesters')
          .child(Provider.of<UserProvider>(
            context,
            listen: false,
          ).currentUserId)
          .update({
            'lat': position.latitude,
            'long': position.longitude,
          })
          .then((v) {})
          .catchError((e) {
            print(e.toString());
          });
    }
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      key: _scaffoldKey,
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            DrawerHeader(
              child: InkWell(
                onTap: () {
                  Navigator.push(
                    context,
                    new MaterialPageRoute(
                      builder: (context) => new SettingsPage(),
                    ),
                  );
                },
                child: Center(
                    child: Column(children: <Widget>[
                  Material(
                    child: Icon(
                      Icons.account_circle,
                      size: 80.0,
                      color: Theme.of(context).accentColor,
                    ),
                    borderRadius: BorderRadius.all(Radius.circular(40.0)),
                    clipBehavior: Clip.hardEdge,
                  ),
                  Padding(
                    padding: EdgeInsets.all(6),
                    child: Text('', //currentUserName ?? '',
                        style: TextStyle(
                            fontSize: 17,
                            color: Theme.of(context).accentColor)),
                  ),
                ])),
              ),
              decoration: BoxDecoration(),
            ),
            ListTile(
              title: Text('مساعدة'),
              trailing: new Icon(
                Icons.help,
                color: Theme.of(context).accentColor,
              ),
              onTap: () {
                Navigator.push(
                    context,
                    new MaterialPageRoute(
                        builder: (context) => new SupportPage()));
              },
            ),
            ListTile(
              title: Text('اتصل بنا'),
              trailing: new Icon(
                Icons.phone,
                color: Theme.of(context).accentColor,
              ),
              onTap: () {
                Navigator.push(
                    context,
                    new MaterialPageRoute(
                        builder: (context) => new ContactPage()));
                // Update the state of the app.
                // ...
              },
            ),
            ListTile(
              title: Text('من نحن'),
              trailing: new Icon(
                Icons.local_shipping,
                color: Theme.of(context).accentColor,
              ),
              onTap: () {
                Navigator.push(context,
                    new MaterialPageRoute(builder: (context) => new About()));
              },
            ),
            ListTile(
              title: Text('دعوة'),
              trailing: new Icon(
                Icons.share,
                color: Theme.of(context).accentColor,
              ),
              onTap: () { },
            ),
            ListTile(
              title: Text('خروج'),
              trailing: new Icon(
                Icons.exit_to_app,
                color: Theme.of(context).accentColor,
              ),
              onTap: () {
                widget.onSignedout();
              },
            ),
          ],
        ),
      ),
      appBar: AppBar(
        title: Text(
          _title,
          style: TextStyle(color: Colors.black),
        ),
        //backgroundColor: Colors.white,
      ),
      body: _children[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        onTap: onTabTapped,
        currentIndex: _currentIndex,
        selectedItemColor: Theme.of(context).primaryColor,
        type: BottomNavigationBarType.fixed,
        items: [
          new BottomNavigationBarItem(
            icon: Icon(Icons.comment),
            title: Text('طلب جديد'),
          ),
          new BottomNavigationBarItem(
            icon: Icon(Icons.storage),
            title: Text('الطلبات'),
          ),
          new BottomNavigationBarItem(
            icon: Icon(Icons.apps),
            title: Text('المنتهية'),
          ),
        ],
      ),
    );
  }

  void onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
      switch (index) {
        case 0:
          {
            _title = 'طلب جديد';
          }
          break;
        case 1:
          {
            _title = 'الطلبات';
          }
          break;
        case 2:
          {
            _title = 'المنتهية';
          }
          break;
      }
    });
  }
}
