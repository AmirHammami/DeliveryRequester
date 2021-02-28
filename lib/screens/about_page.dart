import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class About extends StatefulWidget {
  @override
  _AboutState createState() => new _AboutState();
}

class _AboutState extends State<About> {
  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(
        title: new Text('About us'),
        actions: <Widget>[
          IconButton(
            icon: Icon(
              Icons.language,
              color: Colors.white,
            ),
            onPressed: () async {
            },
          )
        ],
      ),
      body: new Center(
        child: Column(children: <Widget>[
          Container(height: 60),
          Icon(Icons.local_shipping,size:80,color: Theme.of(context).primaryColor,),
          
        ]),
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
          color: Theme
              .of(context)
              .accentColor,
        ),
      ),
      onTap: _launchURL,
    );
  }
}
