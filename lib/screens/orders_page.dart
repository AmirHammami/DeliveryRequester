import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';

import './intransit_orders_page.dart';
import './new_orders_page.dart';

class OrdersPage extends StatefulWidget {
  final DatabaseReference databaseRef;

  OrdersPage({this.databaseRef});

  @override
  _OrdersPageState createState() =>
      _OrdersPageState(databaseRef: this.databaseRef);
}

class _OrdersPageState extends State<OrdersPage>
    with SingleTickerProviderStateMixin {
  final DatabaseReference databaseRef;

  _OrdersPageState({this.databaseRef});

  // Create a tab controller
  TabController _tabController;

  @override
  void initState() {
    super.initState();

    // Initialize the Tab Controller
    _tabController = TabController(length: 2, vsync: this);

  }

  @override
  void dispose() {
    // Dispose of the Tab Controller
    _tabController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        // Appbar
        appBar: new PreferredSize(
          preferredSize: Size.fromHeight(kToolbarHeight),
          child: new Container(
            height: 50.0,
            child: getTabBar(),
          ),
        ),
        // Set the TabBar view as the body of the Scaffold
        body: getTabBarView(<Widget>[
          NewOrdersPage(databaseRef: databaseRef),
          InTransitOrdersPage(databaseRef: databaseRef),
        ]));
  }

  TabBar getTabBar() {
    return TabBar(
      //indicatorColor: Colors.lime,
      unselectedLabelColor: Colors.blue[200],
      labelColor: Colors.blue[800],
      indicatorWeight: 2,
      indicatorColor: Colors.blue[800],
      tabs: <Tab>[
        Tab(
          //icon: Icon(Icons.adb),
          text: "الجديدة",
        ),
        Tab(
          // set icon to the tab
          //icon: Icon(Icons.favorite),
          text: "في الطريق",
        ),
      ],
      // setup the controller
      controller: _tabController,
    );
  }

  TabBarView getTabBarView(var tabs) {
    return TabBarView(
      // Add tabs as widgets
      children: tabs,
      // set the controller
      controller: _tabController,
    );
  }
}
