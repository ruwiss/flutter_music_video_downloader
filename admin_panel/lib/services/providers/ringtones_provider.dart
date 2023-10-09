import 'package:flutter/material.dart';

class RingtonesProvider with ChangeNotifier {
  List ringtones = [];

  void setRingtones(List ringtones) {
    this.ringtones = ringtones;
    notifyListeners();
  }

  void addRingtone(Map ringtone) {
    ringtones.add(ringtone);
    notifyListeners();
  }

  void removeRingtone(int id) {
    ringtones.removeWhere((e) => e['id'] == id);
    notifyListeners();
  }
}
