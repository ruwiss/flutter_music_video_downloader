import 'package:melotune/services/extensions/string_extensions.dart';

class PlayListModel {
  final String playListName;
  final List<PlayListItemModel> items;

  PlayListModel({required this.playListName, required this.items});

  factory PlayListModel.fromJson(dynamic json, {String? query}) {
    List<PlayListItemModel> items = [];

    if (query == null) {
      for (var i in json.values) {
        i.forEach((ytId, val) {
          items.add(
            PlayListItemModel(
              id: ytId,
              title: val['title'],
              thumbnail: val['thumbnail'],
              duration: val['duration'] ?? "",
            ),
          );
        });
      }
      return PlayListModel(playListName: json.keys.first, items: items);
    } else {
      for (var i in json.values.first) {
        items.add(
          PlayListItemModel(
            id: i["videoId"],
            title: i['title'],
            thumbnail: i['thumbnail'],
            duration: i['duration'] ?? "",
          ),
        );
      }
      return PlayListModel(playListName: query, items: items);
    }
  }
}

class PlayListItemModel {
  String? id;
  String? path;
  final String title;
  final String thumbnail;
  final String duration;

  PlayListItemModel({
    this.id,
    this.path,
    required this.title,
    required this.thumbnail,
    this.duration = "",
  });

  PlayListItemModel.fromJson(Map<String, dynamic> json)
      : id = json['id'],
        path = json['path'],
        title = json['title'],
        thumbnail = json['thumbnail'],
        duration = json['duration'] ?? "";

  Map toJson() => {
        "id": id,
        "path": path,
        "title": title,
        "thumbnail": thumbnail,
        "duration": duration,
      };

  factory PlayListItemModel.fromPath(String path) {
    return PlayListItemModel(
      id: null,
      path: path,
      title: path.getNameFromPath(),
      thumbnail: "",
      duration: "",
    );
  }
}
