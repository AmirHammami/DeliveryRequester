import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:provider/provider.dart';

import '../providers/user_provider.dart';
import '../widgets/order.dart';

class DeliveredOrdersPage extends StatefulWidget {
  final DatabaseReference databaseRef;

  DeliveredOrdersPage({this.databaseRef});

  @override
  _DeliveredOrdersPageState createState() =>
      _DeliveredOrdersPageState(databaseRef: this.databaseRef);
}

class _DeliveredOrdersPageState extends State<DeliveredOrdersPage> {
  final DatabaseReference databaseRef;

  _DeliveredOrdersPageState({this.databaseRef});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      //backgroundColor: Colors.red,
      body: Container(
        padding: new EdgeInsets.symmetric(horizontal: 20.0),
        width : double.infinity,
        child: new Column(
          //modified
          children: <Widget>[
            //new
            new Flexible(
              //new
              child: _buildDeliveredOrders(), //new
            ), //new
          ], //new
        ),
      ),
    );
  }
  bool delivered = true;
  Widget _buildDeliveredOrders() {
    return SingleChildScrollView(
        child: Column(children: <Widget>[
      StreamBuilder(
        stream: databaseRef
            .child('requesters')
            .child(Provider.of<UserProvider>(
              context,
              listen: true,
            ).currentUserId)
            .child('delivered')
            .onValue,
        builder: (context, snap) {
          if (snap.hasData &&
              !snap.hasError &&
              snap.data.snapshot.value != null) {
            List<OrderItem> items = [];
            Map<String, dynamic> map =
                snap.data.snapshot.value.cast<String, dynamic>();
            map.forEach((key, values) {
              if (values != null) {
                if (values['type'] == Order.DELIVERED)
                  items.add(Order(
                    type: values['type'],
                    key: key,
                    userId: values['userId'],
                    userName: values['userName'],
                    driverId: values['driverId'],
                    driverName: values['driverName'],
                    driverPhone: values['driverPhone'],
                    ordertext: values['ordertext'],
                    timestamp: values['timestamp'],
                  ).toOrderItem());
              }
            });
            items.sort((a, b) => b.date.compareTo(a.date));
            return items.isNotEmpty
                ? Column(children: <Widget>[
                    InkWell(
                        child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              Text('طلبات منتهية',
                                  style: TextStyle(fontSize: 16)),
                              IconButton(
                                  icon: Icon(delivered
                                      ? Icons.arrow_drop_up
                                      : Icons.arrow_drop_down),
                                  onPressed: () {
                                    if (mounted)
                                      setState(() {
                                        delivered = !delivered;
                                      });
                                  })
                            ]),
                        onTap: () {
                          if (mounted)
                            setState(() {
                              delivered = !delivered;
                            });
                        }),
                    delivered
                        ? Column(
                            mainAxisSize: MainAxisSize.min,
                            children: items,
                          )
                        : Container(width: 0, height: 0),
                    //Divider(),
                  ])
                : Padding(
                    padding: EdgeInsets.all(16),
                    child: Text(
                        'لا يوجد طلبات منتهية')); //Container(width: 0, height: 0);
          } else {
            return Padding(
                padding: EdgeInsets.all(16),
                child: Text('لا يوجد طلبات منتهية'));
          }
        },
      ),
    ]));
  }
}
