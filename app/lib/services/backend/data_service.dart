import 'dart:convert';
import 'dart:developer';
import 'package:dio/dio.dart';
import 'package:melotune/locator.dart';
import 'package:melotune/services/functions/firebase_analytics.dart';
import 'package:melotune/services/functions/local_db.dart';
import 'package:melotune/services/models/playlist_model.dart';
import 'package:melotune/services/models/ringtone_model.dart';
import 'package:melotune/services/providers/home_provider.dart';
import 'package:melotune/services/providers/ringtones_provider.dart';
import 'package:melotune/utils/strings.dart';

class DataService {
  final _dio = Dio();

  Future<void> fetch() async {
    await fetchAppSettings();
    await fetchPlaylistData();
  }

  Future<void> fetchAppSettings() async {
    final response = await _dio.get(KHost.getAppSettings);
    if (response.statusCode == 200) {
      final homeProvider = locator.get<HomeProvider>();
      homeProvider.setAppSettings(response.data);
    } else {
      log(response.statusMessage ?? response.data);
    }
  }

  Future<void> fetchPlaylistData() async {
    // Günde 1 kez veri çekimi için kayıt kontrolü
    final localDB = locator.get<LocalDB>();
    Map data = {};
    if (locator.get<LocalDB>().checkFetchedTimeForSaveDB()) {
      final response = await _dio.get(KHost.getPlaylistsUrl);

      if (response.statusCode == 200) {
        data = response.data;

        // local db'ye kayıt
        localDB.saveFetchedData(data);
      } else {
        log(response.statusMessage ?? response.data);
      }
    } else {
      data = localDB.getFetchedData()!;
    }

    final homeProvider = locator.get<HomeProvider>();
    final List<PlayListModel> list = [];
    for (var i in data['playLists']) {
      list.add(PlayListModel.fromJson(i));
    }
    homeProvider.setPlayLists(list);
  }

  Future<void> search(String query) async {
    AnalyticsService.analytics
        .logEvent(name: "search", parameters: {"query": query});

    if (query.isEmpty) {
      return;
    }
    final homeProvider = locator.get<HomeProvider>();

    if (query.contains("http") && query.contains("/")) {
      query = query.split("/").last;
    }

    homeProvider.setSearchLoading(true);
    final response = await _dio.get(KHost.getSearchUrl(query));

    if (response.statusCode == 200) {
      if (response.data is List && response.data.isEmpty) {
        homeProvider.search(PlayListModel(playListName: query, items: []));
      } else {
        PlayListModel searchContent =
            PlayListModel.fromJson({query: response.data}, query: query);

        homeProvider.search(searchContent);
      }
    }
    homeProvider.setSearchLoading(false);
  }

  Future<List<String>> getAutoCompleteData(String query) async {
    List autoCompleteData = [];
    try {
      final response = await _dio.get(KHost.getAutoCompleteUrl(query),
          options: Options(responseType: ResponseType.bytes));
      final dataByte = String.fromCharCodes(response.data);
      autoCompleteData = jsonDecode(dataByte)[query];
    } catch (e) {
      log(e.toString());
    }
    return autoCompleteData.map((e) => e.toString()).toList();
  }

  Future getRingtones() async {
    final response = await _dio.get(KHost.getRingtones);
    if (response.statusCode == 200) {
      List<RingtoneModel> list = [];
      for (var i in response.data) {
        list.add(RingtoneModel.fromJson(i));
      }
      locator.get<RingtonesProvider>().setRingtones(list);
    }
  }
}
