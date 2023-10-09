import 'package:flutter/material.dart';

enum DownloadsCategory { musics, videos }

class DownloadsProvider with ChangeNotifier {
  DownloadsCategory categorySelection = DownloadsCategory.musics;

  void changeCategory(DownloadsCategory category) {
    categorySelection = category;
    notifyListeners();
  }
}
