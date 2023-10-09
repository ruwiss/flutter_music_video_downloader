import 'package:admin_panel/services/extensions/time_extension.dart';
import 'package:flutter/material.dart';

class PlaylistProvider with ChangeNotifier {
  Map playlistContent = {};
  String insertTime = "";

  void setPlaylistContent(Map data) {
    playlistContent = data;
    notifyListeners();
  }

  void addPlaylist(String lang, String title, String url) {
    if (!url.contains("/playlist?list=")) return;
    if (!playlistContent.keys.contains(lang)) {
      playlistContent[lang] = [];
    }
    final playlistId = url.split("/playlist?list=")[1];
    playlistContent[lang]!.add({"playlist_id": playlistId, "name": title});
    notifyListeners();
  }

  void removeFromPlaylist(String lang, String url) {
    playlistContent[lang]!.removeWhere((element) => element['url'] == url);
    if (playlistContent[lang]!.isEmpty) playlistContent.remove(lang);
    notifyListeners();
  }

  void changeIndex(List playlists, Map playlist, int newIndex) {
    playlists.remove(playlist);
    playlists.insert(newIndex, playlist);
    notifyListeners();
  }

  void setInsertTime() {
    DateTime date = DateTime.now();
    insertTime = "Kaydedildi: ${date.dateToHours()}";
    notifyListeners();
  }
}
