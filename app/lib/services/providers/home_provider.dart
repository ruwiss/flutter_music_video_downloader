import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:melotune/services/models/playlist_model.dart';

class HomeProvider with ChangeNotifier {
  Map appSettings = {};

  bool loadMore = false;

  List<PlayListModel> playList = [];
  PlayListModel? currentPlaylist;

  PlayListModel? searchContent;
  bool searchContentLoading = false;

  int expandedListIndex = 0;

  List<String> mp3DownloadsCache = [];
  List<String> mp4DownloadsCache = [];

  List<String> autoCompleData = [];

  void setAppSettings(Map settings) {
    appSettings = settings;
    notifyListeners();
  }

  String getAppSetting(String name) => appSettings[name];

  void setCurrentPlayList(PlayListModel? model) {
    currentPlaylist = model ?? playList[0];
    notifyListeners();
  }

  PlayListItemModel? findCurrentPlayListItem(PlayListModel pList, String id) {
    int index = pList.items.indexWhere((e) => e.id != null && e.id == id);
    log("index: $index");
    if (index == -1) {
      index = pList.items.indexWhere((e) => e.path == id);
      log("index: $index");
    }
    if (index == -1) return null;
    return pList.items[index];
  }

  (PlayListModel?, PlayListItemModel?) findCurrentPlayList(String id) {
    PlayListModel? playlist;
    PlayListItemModel? playlistItem;
    for (var i in playList) {
      final item = findCurrentPlayListItem(i, id);
      if (item != null) {
        playlist = i;
        playlistItem = item;
        break;
      }
    }
    return (playlist, playlistItem);
  }

  void setLoadMore(bool v) {
    loadMore = v;
    notifyListeners();
  }

  void setPlayLists(List<PlayListModel> list) {
    playList = list;
    setCurrentPlayList(playList[0]);
    notifyListeners();
  }

  void setExpandedListIndex(int index) {
    if (expandedListIndex == index) {
      expandedListIndex = playList.length - 1;
    } else {
      expandedListIndex = index;
    }

    notifyListeners();
  }

  void search(PlayListModel model) {
    searchContent = model;
    currentPlaylist = model;
    notifyListeners();
  }

  void setSearchLoading(bool val) {
    searchContentLoading = val;
    notifyListeners();
  }

  void unSearch() {
    searchContent = null;
    setCurrentPlayList(null);
    notifyListeners();
  }

  void setDownloadsCache(List<String> mp3List, List<String> mp4List) {
    mp3DownloadsCache = mp3List;
    mp4DownloadsCache = mp4List;
    notifyListeners();
  }

  void setAutoCompleteData(List data) {
    autoCompleData = data.map((e) => e.toString()).toList();
    notifyListeners();
  }
}
