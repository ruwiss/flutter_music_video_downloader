import 'package:admin_panel/services/extensions/time_extension.dart';
import 'package:flutter/material.dart';

class BlockProvider with ChangeNotifier {
  List<String> blockedList = [];
  String insertTime = "";

  void setBlockedList(List<String> blockedList) {
    this.blockedList = blockedList;
    notifyListeners();
  }

  void addToBlockedList(String blockedId) {
    blockedList.add(blockedId);
    notifyListeners();
  }

  void removeFromBlockedList(String removeId) {
    if (removeId.isNotEmpty) {
      blockedList.removeWhere((element) => element == removeId);
      notifyListeners();
    }
  }

  void setInsertTime() {
    DateTime date = DateTime.now();
    insertTime =
        "Kaydedildi: ${date.dateToHours()}";
    notifyListeners();
  }
}
