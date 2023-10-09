import 'package:flutter/material.dart';

class BaseProvider with ChangeNotifier {
  bool auth = false;
  String currentTab = "";

  void setAuth() {
    auth = true;
    notifyListeners();
  }

  void setCurrentTab(String tab) {
    if (auth) {
      currentTab = tab;
      notifyListeners();
    }
  }
}
