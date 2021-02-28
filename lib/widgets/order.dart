import 'package:intl/intl.dart' as intl;
import 'package:flutter/material.dart';
import 'package:connectivity/connectivity.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:geolocator/geolocator.dart';

import '../screens/home_page.dart';
import '../screens/map_page.dart';

class Order {
  final String key;
  final String userId;
  final String userName;
  final String userPhone;
  final String driverId;
  final String driverName;
  final String driverPhone;

  final String ordertext;
  var timestamp;
  final double destlat;
  final double destlong;
  final int type;
  static final int REQUESTED = 1;
  static final int TRANSIT = 2;
  static final int DELIVERED = 3;

  Order({
    this.key,
    this.userId,
    this.userName,
    this.userPhone,
    this.driverId,
    this.driverName,
    this.driverPhone,
    this.ordertext,
    this.destlat,
    this.destlong,
    this.timestamp,
    this.type,
  });

  Map<String, dynamic> toMap() {
    return {
      'type': type,
      'userId': userId,
      'userName': userName,
      'userPhone': userPhone,
      'driverId': driverId,
      'driverName': driverName,
      'driverPhone': driverPhone,
      'ordertext': ordertext,
      'timestamp': timestamp,
      'destlat': destlat,
      'destlong': destlong,
    };
  }

  OrderItem toOrderItem() {
    return new OrderItem(
        driverPhone: driverPhone,
        type: type,
        driverId: driverId,
        userId: userId,
        orderKey: key,
        driver: driverName,
        ordertext: ordertext,
        date: intl.DateFormat('dd MMM kk:mm')
            .format(DateTime.fromMillisecondsSinceEpoch((timestamp))));
  }
}

class OrderItem extends StatefulWidget {
  OrderItem({
    this.type,
    this.orderKey,
    this.userId,
    this.driverId,
    this.driver,
    this.driverPhone,
    this.ordertext,
    this.date,
  });

  final int type;
  final String driver;
  final String driverId;
  final String driverPhone;
  final String userId;
  final String date;
  final String ordertext;
  final String orderKey;

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'driverId': driverId,
      'driver': driver,
      'ordertext': ordertext,
      'date': date
    };
  }

  @override
  State<StatefulWidget> createState() {
    return _OrderItemState();
  }
}

class _OrderItemState extends State<OrderItem> {
  int distance;
  double lat;
  double long;

  _OrderItemState();

  @override
  void initState() {
    super.initState();

    if (widget.type != Order.DELIVERED)
      FirebaseDatabase.instance
          .reference()
          .child('drivers')
          .child(widget.driverId)
          .onValue
          .listen((e) {
        Map<String, dynamic> map = e.snapshot.value.cast<String, dynamic>();
        lat = map['lat'].toDouble();
        long = map['long'].toDouble();
        Geolocator()
            .distanceBetween(HomePage.currentLat,
                HomePage.currentLong, lat, long)
            .then((value) {
          if (mounted)
            setState(() {
              distance = value.toInt();
            });
        });
      });
  }

  info(name, distance, phone, driverId, ordertext) {
    showDialog(
        context: context,
        builder: (context) {
          return Dialog(
            child: SizedBox(
                //height: MediaQuery.of(context).size.height * 0.5,
                child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: <Widget>[
                  InfoOrder(
                    lat: lat,
                    long: long,
                    name: name,
                    phone: phone,
                    id: driverId,
                    selected: true,
                  ),
                  Expanded(
                    child: Card(
                      shape: new RoundedRectangleBorder(
                          side: new BorderSide(
                              color: Theme.of(context).accentColor, width: 2.0),
                          borderRadius: BorderRadius.circular(4.0)),
                      child: new Container(
                          padding: EdgeInsets.all(16.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Flexible(
                                  child: new Text(
                                ordertext,
                                style: new TextStyle(
                                    fontSize: 13.0,
                                    //fontWeight: FontWeight.w200,
                                    color: Colors.black),
                              ))
                            ],
                          )),
                    ),
                  ),
                ])),
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      elevation: 3,
      margin: EdgeInsets.all(5),
      child: Padding(
        padding: EdgeInsets.only(top: 8, left: 8, right: 8),
        child: Column(
          children: <Widget>[
            new InkWell(
              onTap: () {
                info(
                  widget.driver,
                  '${distance != null ? ((distance) / 1000).toStringAsFixed(2) + ' km' : ''}',
                  widget.driverPhone,
                  widget.driverId,
                  widget.ordertext,
                );
              },
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  new Container(
                    margin: const EdgeInsets.only(right: 8),
                    child: InkWell(
                      onTap: () {
                        info(
                          widget.driver,
                          '${distance != null ? ((distance) / 1000).toStringAsFixed(2) + ' km' : ''}',
                          widget.driverPhone,
                          widget.driverId,
                          widget.ordertext,
                        );
                      },
                      child: Material(
                        child: new CircleAvatar(
                            child: widget.driver == null
                                ? Icon(
                                    Icons.account_circle,
                                    size: 50.0,
                                    color: Theme.of(context).accentColor,
                                  )
                                : new Text(
                                    widget.driver == '' ? '' : widget.driver[0],
                                    style: TextStyle(fontSize: 30)),
                            radius: 25),
                        borderRadius: BorderRadius.all(Radius.circular(25.0)),
                        clipBehavior: Clip.hardEdge,
                      ),
                    ),
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(right: 10.0),
                      child: new Column(
                        mainAxisSize: MainAxisSize.max,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: <Widget>[
                          new Text(
                            '${widget.driver ?? ''} \n${distance != null ? ((distance) / 1000).toStringAsFixed(2) + ' km' : ''}',
                            //'${widget.driver ?? ''}',
                            maxLines: 2,
                            style:
                                TextStyle(color: Theme.of(context).accentColor),
                          ),
                        ],
                      ),
                    ),
                  ),
                  new Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: <Widget>[
                      Text(widget.date),
                    ],
                  ),
                ],
              ),
            ),
            widget.type != Order.DELIVERED
                ? new Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: <Widget>[
                      widget.type == Order.REQUESTED
                          ? FlatButton.icon(
                              label: Text('إلغاء'),
                              icon: Icon(
                                Icons.cancel,
                                color: Theme.of(context).accentColor,
                              ),
                              onPressed: () {
                                if (widget.type == Order.REQUESTED)
                                  _cancelOrder(widget.orderKey, context);
                              },
                            )
                          : Container(
                              width: 0,
                              height: 0,
                            ),
                      widget.type == Order.REQUESTED
                          ? Container(
                              width: 0,
                              height: 0,
                            )
                          : widget.type == Order.TRANSIT
                              ? FlatButton.icon(
                                  label: Text('تابع'),
                                  icon: Icon(
                                    Icons.pin_drop,
                                    color: Theme.of(context).accentColor,
                                  ),
                                  onPressed: () {
                                    
                                    Navigator.push(
                                        context,
                                        new MaterialPageRoute(
                                            builder: (context) => new MapPage(
                                                driverId: widget.driverId,
                                                driver: widget.driver,
                                                ulat: HomePage
                                                            .currentLat ==
                                                        null
                                                    ? 0.0
                                                    : HomePage
                                                        .currentLat,
                                                ulong: HomePage
                                                            .currentLong ==
                                                        null
                                                    ? 0.0
                                                    : HomePage
                                                        .currentLong,
                                                dlat: lat == null ? 0.0 : lat,
                                                dlong: long == null
                                                    ? 0.0
                                                    : long)));
                                  },
                                )
                              : Container(width: 0, height: 0),
                    ],
                  )
                : Container(width: 0, height: 0)
          ],
        ),
      ),
    );
  }

  _cancelOrder(String orderKey, BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('تأكيد'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text('هل أنت متأكد من الغاء الطلب \n$orderKey?'),
              Text('${widget.driver}')
            ],
          ),
          actions: <Widget>[
            FlatButton.icon(
              onPressed: () => Navigator.of(context).pop(),
              icon: Icon(Icons.arrow_back),
              label: Text('رجوع'),
            ),
            FlatButton.icon(
              onPressed: () {
                _deleteOrder(orderKey, context).then((v) {
                  //Fluttertoast.showToast(msg: 'Delete successful');
                  Fluttertoast.showToast(
                    msg: "تم حذف الطلب بنجاح",
                    toastLength: Toast.LENGTH_SHORT,
                    //webBgColor: "#e74c3c",
                    backgroundColor: Colors.green,
                    timeInSecForIosWeb: 5,
                    gravity: ToastGravity.CENTER,
                  );
                  //Navigator.of(context).pop();
                });
              },
              icon: Icon(Icons.cancel),
              label: Text('إلغاء'),
            ),
          ],
        );
      },
    );
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

  _deleteOrder(String orderKey, context) async {
    bool isConnected = await check();
    if (isConnected != null && isConnected) {
      //_TabbedGuyState.showModal('إلغاء...', context);
      FirebaseDatabase database = new FirebaseDatabase();
      DatabaseReference dataRef = database.reference();
      await dataRef
          .child('drivers')
          .child(widget.driverId)
          .child('requests')
          .child(orderKey)
          .remove();
      await dataRef
          .child('requesters')
          .child(widget.userId)
          .child('requests')
          .child(orderKey)
          .remove();
      Navigator.of(context).pop();
    } else {
      // No-Internet Case
      SnackBar snackbar = SnackBar(
          content: Text(
        'فضلا٬ تأكد من الاتصال بالنت...',
        overflow: TextOverflow.ellipsis,
      ));
      //_TabbedGuyState._scaffoldKey.currentState.showSnackBar(snackbar);
    }
  }
}

class InfoOrder extends StatefulWidget {
  InfoOrder({
    this.distance,
    this.id,
    this.name,
    this.phone,
    this.lat,
    this.long,
    this.deselect,
    this.select,
    this.selected = false,
  });

  final String name;
  final String phone;
  final String id;
  double lat;
  double long;
  String distance;
  bool selected;
  VoidCallback deselect;
  VoidCallback select;

  @override
  State<StatefulWidget> createState() {
    return InfoOrderstate(
        distance: distance, lat: this.lat, long: this.long,
        );
  }
}

class InfoOrderstate extends State<InfoOrder> {
  double lat;
  double long;
  String distance;

  InfoOrderstate({this.distance, this.long, this.lat});

  @override
  void initState() {
    super.initState();
     if (lat != null)
      Geolocator()
          .distanceBetween(HomePage.currentLat,
              HomePage.currentLong, lat, long)
          .then((value) {
        if (mounted)
          setState(() {
            distance = (value / 1000).toStringAsFixed(2) + ' km';
          });
      });
  }

  _launchURL() async {
    if (await canLaunch('tel:${widget.phone}')) {
      await launch('tel:${widget.phone}');
    } else {
      throw 'Could not launch tel:${widget.phone}';
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.selected)
      return Card(
        shape: new RoundedRectangleBorder(
            side: new BorderSide(
                color: Theme.of(context).accentColor, width: 2.0),
            borderRadius: BorderRadius.circular(4.0)),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            ListTile(
              leading: Material(
                child: new CircleAvatar(
                    child: widget.name == null
                        ? Icon(
                            Icons.account_circle,
                            size: 60.0,
                            //color: greyColor,
                          )
                        : new Text(widget.name[0],
                            style: TextStyle(fontSize: 30)),
                    radius: 30),
                borderRadius: BorderRadius.all(Radius.circular(25.0)),
                clipBehavior: Clip.hardEdge,
              ),
              title: Text(widget.name ?? ''),
              subtitle: Text(distance?? ''),
              trailing: IconButton(
                  icon: Icon(Icons.close),
                  onPressed: () {
                    if (mounted)
                      setState(() {
                        if (widget.deselect != null)
                          widget.deselect();
                        else
                          Navigator.of(context).pop();
                      });
                  }),
              selected: true,
              onTap: () {
                widget.deselect();
              },
            ),
            new Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                Expanded(
                  child: widget.lat != null
                      ? FlatButton.icon(
                          label: Text(
                            'طريق',
                            style: TextStyle(
                                fontSize: 12,
                                color: Theme.of(context).accentColor),
                          ),
                          icon: Icon(
                            Icons.pin_drop,
                            color: Theme.of(context).accentColor,
                          ),
                          onPressed: () {
                            
                            Navigator.push(
                                context,
                                new MaterialPageRoute(
                                    builder: (context) => new MapPage(
                                        driverId: widget.id,
                                        driver: widget.name,
                                        ulat: HomePage.currentLat == null
                                            ? 0.0
                                            : HomePage.currentLat,
                                        ulong:
                                            HomePage.currentLong == null
                                                ? 0.0
                                                : HomePage.currentLong,
                                        dlat: lat == null ? 0.0 : lat,
                                        dlong: long == null ? 0.0 : long)));
                          
                          })
                      : Container(
                          width: 0,
                          height: 0,
                        ),
                ),
                /*Expanded(
                  child: FlatButton.icon(
                      label: Text('دردشة', style: TextStyle(fontSize: 12)),
                      icon: Icon(
                        Icons.textsms,
                        color: Theme.of(context).accentColor,
                      ),
                      onPressed: () {
                        /*
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => Chat(
                                      peerName: widget.name,
                                      peerId: widget.id,
                                      peerAvatar: avatar,
                                    )));*/
                        /*_infoOn(orderKey,driverId)*/
                      }),
                ),*/
                widget.phone != null
                    ? Expanded(
                        child: FlatButton.icon(
                            label:
                                Text('اتصال', style: TextStyle(fontSize: 12)),
                            icon: Icon(
                              Icons.phone,
                              color: Theme.of(context).accentColor,
                            ),
                            onPressed: _launchURL),
                      )
                    : Container(
                        width: 0,
                        height: 0,
                      ),
              ],
            ),
          ],
        ),
      );
    else
      return SizedBox(
        width: 140,
        child: Material(
          child: InkWell(
            onTap: () {
              widget.select();
            },
            child: new Card(
              child: new Stack(
                children: <Widget>[
                  widget.phone == null
                      ? Container(
                          width: 0,
                          height: 0,
                        )
                      : Align(
                          child: IconButton(
                              icon: Icon(
                                Icons.phone,
                                color: Theme.of(context).accentColor,
                              ),
                              onPressed: _launchURL),
                          alignment: AlignmentDirectional.bottomEnd,
                        ),
                  Align(
                    child: IconButton(
                        icon: Icon(
                          Icons.textsms,
                          color: Theme.of(context).accentColor,
                        ),
                        onPressed: () {
                          /*
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => Chat(
                                        peerName: widget.name,
                                        peerId: widget.id,
                                        peerAvatar: avatar,
                                      )));*/
                        }),
                    alignment: AlignmentDirectional.bottomStart,
                  ),
                  Center(
                      child: Container(
                    padding: new EdgeInsets.all(4.0),
                    child: new Column(
                      //crossAxisAlignment: CrossAxisAlignment.center,
                      children: <Widget>[
                        Expanded(
                          child: Center(
                            child: Material(
                              child: new CircleAvatar(
                                  child: widget.name == null
                                      ? Icon(
                                          Icons.account_circle,
                                          size: 70.0,
                                          //color: greyColor,
                                        )
                                      : new Text(widget.name[0],
                                          style: TextStyle(fontSize: 35)),
                                  radius: 35),
                              borderRadius:
                                  BorderRadius.all(Radius.circular(35.0)),
                              clipBehavior: Clip.hardEdge,
                            ),
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.only(top: 4.0),
                          child: new Text(
                              widget.name == null
                                  ? ''
                                  : widget.name.split(' ')[0],
                              maxLines: 1),
                        ),
                        Padding(
                          padding: EdgeInsets.only(
                            top: 4.0,
                          ),
                          child: new Text(''
                              //distance ?? '',
                              ),
                        ),
                      ],
                    ),
                  ))
                ],
              ),
            ),
          ),
        ),
      );
  }
}
