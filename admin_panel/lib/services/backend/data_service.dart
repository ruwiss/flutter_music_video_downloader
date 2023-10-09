import 'dart:convert';
import 'package:admin_panel/locator.dart';
import 'package:admin_panel/services/providers/block_provider.dart';
import 'package:admin_panel/services/providers/playlist_provider.dart';
import 'package:admin_panel/services/providers/ringtones_provider.dart';
import 'package:admin_panel/utils/strings.dart';
import 'package:dio/dio.dart';

class DataService {
  final _dio = Dio();

  Future<List> getAppSettings() async {
    final response = await _dio.get(KHost.settings);
    if (response.statusCode != 200) return [];

    return response.data;
  }

  void getBlockedMusics() async {
    final response = await _dio.get(KHost.block);
    if (response.statusCode != 200) return;

    locator.get<BlockProvider>().setBlockedList(
        (response.data as List).map((e) => e.toString()).toList());
  }

  Future<bool> setAppSettings(String name, String value) async {
    final response =
        await _dio.post(KHost.settings, data: {"name": name, "value": value});
    return response.statusCode == 200 && response.data == "OK";
  }

  Future<bool> deleteAppSetting(String name) async {
    final response = await _dio.delete(KHost.settings, data: {"name": name});
    return response.statusCode == 200 && response.data == "OK";
  }

  void setBlockedMusics() {
    _dio
        .post(KHost.block,
            data:
                jsonEncode({"block": locator.get<BlockProvider>().blockedList}))
        .then((value) {
      if (value.statusCode == 200 && value.data == "OK") {
        locator.get<BlockProvider>().setInsertTime();
      }
    });
  }

  Future<List> getLanguageRequests() async {
    final response = await _dio.get(KHost.langRequests);
    if (response.statusCode != 200) return [];
    return response.data;
  }

  void getPlaylistData() async {
    final response = await _dio.get(KHost.playlistContent);
    if (response.statusCode != 200) return;
    Map<String, List<Map>> groupedData = {};

    for (var item in response.data) {
      String lang = item['lang'];
      if (groupedData.containsKey(lang)) {
        groupedData[lang]!.add(item);
      } else {
        groupedData[lang] = [item];
      }
    }
    locator.get<PlaylistProvider>().setPlaylistContent(groupedData);
  }

  void savePlaylistData() {
    _dio
        .post(
      KHost.playlistContent,
      data: jsonEncode(
          {"fetch": locator.get<PlaylistProvider>().playlistContent}),
    )
        .then(
      (value) {
        if (value.statusCode == 200 && value.data == "OK") {
          locator.get<PlaylistProvider>().setInsertTime();
        }
      },
    );
  }

  Future<String> getLogData() async {
    final response = await _dio.get(KHost.logData);
    if (response.statusCode != 200) return "";
    return response.data['log'];
  }

  Future<bool> clearLogData() async {
    final response = await _dio.delete(KHost.logData);
    return response.statusCode == 200 && response.data == "OK";
  }

  Future getRingtones() async {
    final response = await _dio.get(KHost.ringtoneRequest);
    if (response.statusCode == 200) {
      locator.get<RingtonesProvider>().setRingtones(response.data);
    }
  }

  Future removeRingtone(int id) async {
    final response = await _dio.delete(KHost.ringtoneRequest, data: {"id": id});
    if (response.statusCode == 200 && response.data == "OK") {
      locator.get<RingtonesProvider>().removeRingtone(id);
    }
  }

  Future insertRingtone(String title, String url, String image) async {
    final data = {
      "title": title,
      "url": url,
      "image": image,
    };
    final response = await _dio.post(KHost.ringtoneRequest, data: data);

    if (response.statusCode == 200 && response.data == "OK") {
      locator.get<RingtonesProvider>().addRingtone(data);
    }
  }
}
