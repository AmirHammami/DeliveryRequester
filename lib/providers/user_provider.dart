import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UserProvider with ChangeNotifier {
  String _currentUserId;
  String _currentUserName;

  SharedPreferences prefs;

  void init() async {
    prefs = await SharedPreferences.getInstance();
    this._currentUserId = prefs.getString('id');
    this._currentUserName = prefs.getString('displayName');
  }

  String get currentUserId {
    return this._currentUserId;
  }
  
  void setCurrentUserId(String userId) {
    this._currentUserId = userId;
    notifyListeners();
  }

  String get currentUserName {
    return _currentUserName;
  }

  void setCurrentUserName(String name) {
    this._currentUserName = name;
    notifyListeners();
  }







}
