import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class ContactPage extends StatefulWidget {
  @override
  _ContactPageState createState() => new _ContactPageState();
}

class _ContactPageState extends State<ContactPage> {
  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(
        title: new Text('Contact Us'),
        actions: <Widget>[
          IconButton(
            icon: Icon(
              Icons.phone,
              color: Colors.white,
            ),
            onPressed: () async {
            },
          )
        ],
      ),
      body: new Container(
        margin: const EdgeInsets.symmetric(horizontal: 16.0),
        child: new Center(
          child: Column(children: <Widget>[
            Container(height: 60),
            Icon(Icons.local_shipping,size:80,color: Theme.of(context).primaryColor,),
           
          ]),
        ),
      ),
    );
  }
}

class Hyperlink extends StatelessWidget {
  final String _url;
  final String _text;

  Hyperlink(this._url, this._text);

  _launchURL() async {
    if (await canLaunch(_url)) {
      await launch(_url);
    } else {
      throw 'Could not launch $_url';
    }
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      child: Text(
        _text,
        style: TextStyle(
          decoration: TextDecoration.underline,
          color: Theme.of(context).accentColor,
        ),
      ),
      onTap: _launchURL,
    );
  }
}
