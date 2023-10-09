import 'dart:convert';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:in_app_review/in_app_review.dart';
import 'package:melotune/locator.dart';
import 'package:melotune/services/functions/admob_ads/admob_interstitial.dart';
import 'package:melotune/services/providers/home_provider.dart';
import 'package:melotune/utils/strings.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocalDB {
  late SharedPreferences _prefs;

  InterstitialAd? _interstitialAd;

  LocalDB() {
    SharedPreferences.getInstance().then((value) {
      _prefs = value;
      getDownloads();
    });
  }

  void saveMp3(String ytId) {
    List<String> mp3List = _prefs.getStringList("mp3") ?? [];
    mp3List.add(ytId);
    _prefs.setStringList("mp3", mp3List);
  }

  void saveMp4(String ytId) {
    List<String> mp4List = _prefs.getStringList("mp4") ?? [];
    mp4List.add(ytId);
    _prefs.setStringList("mp4", mp4List);
  }

  void saveRingtone(int id) {
    List<String> ringtones = _prefs.getStringList("ringtones") ?? [];
    ringtones.add(id.toString());
    _prefs.setStringList("ringtones", ringtones);
  }

  List<int> getRingtones() {
    final list = _prefs.getStringList("ringtones") ?? [];
    return list.map((e) => int.parse(e)).toList();
  }

  void getDownloads() {
    final List<String> mp3List = _prefs.getStringList("mp3") ?? [];
    final List<String> mp4List = _prefs.getStringList("mp4") ?? [];
    locator.get<HomeProvider>().setDownloadsCache(mp3List, mp4List);
  }

  void checkForAfterDownloadsAction() async {
    int count = _prefs.getInt("downloadCount") ?? 0;
    count++;
    final homeProvider = locator.get<HomeProvider>();
    final limit = int.parse(homeProvider.getAppSetting("showAdAfterCount"));
    if (count == limit) {
      final adManager = InterstitialAdManager(adUnitId: KAppId.interstitalAd1);
      adManager.load(onLoaded: (ad) => _interstitialAd = ad);
    } else if (count > limit) {
      _interstitialAd?.show();
      count = 0;
    }
    if (count == 4 && _prefs.getBool("review") == null) {
      final InAppReview inAppReview = InAppReview.instance;
      if (await inAppReview.isAvailable()) {
        _prefs.setBool("review", true);
        inAppReview.requestReview();
      }
    }
    _prefs.setInt("downloadCount", count);
  }

  void saveFetchedData(Map data) {
    _prefs.setString("fetchData", jsonEncode(data));
    _prefs.setString("_fetchDataTime", DateTime.now().toIso8601String());
  }

  Map? getFetchedData() {
    final String? stringData = _prefs.getString("fetchData");
    if (stringData == null) return null;
    return jsonDecode(stringData);
  }

  bool checkFetchedTimeForSaveDB() {
    final now = DateTime.now();
    final String? fetchedTimeStr = _prefs.getString("_fetchDataTime");
    if (fetchedTimeStr == null) return true;
    final fetchedTime = DateTime.parse(fetchedTimeStr);
    return now.month != fetchedTime.month ||
        now.day != fetchedTime.day ||
        !_prefs.containsKey("fetchData");
  }

  // Tüm Playlistlerin isimlerini getirir
  List<String>? getAllPlayLists({bool reversed = false}) {
    final list = _prefs.getStringList("PlayLists");
    return reversed ? list?.reversed.toList() : list;
  }

  // Yeni bir playlist oluşturup diğer Playlistlerin içine yenisini ekler
  Future createPlayList(String name) async {
    await _prefs.setStringList(name, []);
    final lists = getAllPlayLists();
    if (lists == null) {
      await _prefs.setStringList("PlayLists", []);
    }
    _addPlayListToPlayLists(name);
  }

  // Playlist isimlerinin içine yeni playlist ekler
  Future _addPlayListToPlayLists(String name) async {
    final lists = getAllPlayLists()!;
    if (lists.contains(name)) return;
    lists.add(name);
    await _prefs.setStringList("PlayLists", lists);
  }

  // Playlist içeriğini silip, diğer playlistlerin içinden ismini siler
  Future removePlayList(String name) async {
    await _prefs.remove(name);
    final lists = getAllPlayLists()!;
    lists.remove(name);
    await _prefs.setStringList("PlayLists", lists);
  }

  // Playlist içeriğini [müzikleri] getirir
  List<String> getPlayList(String name, {bool reversed = false}) {
    final list = _prefs.getStringList(name)!;
    return reversed ? list.reversed.toList() : list;
  }

  // Playlist içerisine müzik ekler
  Future<bool> addMusicToPlayList(String playListName, String json) async {
    final list = getPlayList(playListName);
    if (list.contains(json)) return false;
    list.add(json);
    await _prefs.setStringList(playListName, list);
    return true;
  }

  // Playlist içinden müzik siler
  Future<bool> removeMusicFromPlayList(String playListName, String json) async {
    final list = getPlayList(playListName);
    list.remove(json);
    await _prefs.setStringList(playListName, list);
    return true;
  }

  // ReOrder PlayList items
  Future reOrderPlayListItems(
      String playListName, List<String> contents) async {
    await _prefs.setStringList(playListName, contents);
  }
}
