import 'dart:io';
import 'package:melotune/services/extensions/string_extensions.dart';
import 'package:melotune/services/models/playlist_model.dart';
import 'package:melotune/services/providers/downloads_provider.dart';
import '../../locator.dart';
import 'downloader.dart';

class DownloadList {
  final _musicPath = "/storage/emulated/0/Music";
  final _videoPath = "/storage/emulated/0/Movies";

  Future<bool> _storagePermission() async {
    final bool granted = await locator.get<Downloader>().storagePermission();
    return granted;
  }

  Future<List<FileSystemEntity>> listOfFiles(DownloadsCategory category) async {
    if (!await _storagePermission()) return [];

    final bool isMp3 = category == DownloadsCategory.musics;

    try {
      final List<FileSystemEntity> list =
          Directory(isMp3 ? _musicPath : _videoPath).listSync();
      list.sort(
          (a, b) => b.statSync().modified.compareTo(a.statSync().modified));
      list.removeWhere((element) =>
          !element.path.contains(".") ||
          element.path.split(".").last != (isMp3 ? 'mp3' : 'mp4'));

      return list;
    } on PathNotFoundException catch (_) {
      return [];
    }
  }

  Future<FileSystemEntity?> searchForFile(
      PlayListItemModel playlistItem) async {
    final title = playlistItem.title.reFormatTitle();

    if (!await _storagePermission()) return null;

    final List<FileSystemEntity> files = Directory(_musicPath).listSync();
    final index = files
        .indexWhere((f) => f.path.getNameFromPath().reFormatTitle() == title);

    return index == -1 ? null : files[index];
  }

  Future<(List<PlayListItemModel>, PlayListItemModel)>
      convertUrlToFileIfAvailable(
          List<PlayListItemModel> list, PlayListItemModel item) async {
    if (!await _storagePermission()) return (list, item);

    list.insert(0, item);

    final List<FileSystemEntity> files = Directory(_musicPath).listSync();
    for (var i = 0; i < list.length; i++) {
      final title = list[i].title.reFormatTitle();
      final index = files
          .indexWhere((f) => f.path.getNameFromPath().reFormatTitle() == title);
      if (index != -1) {
        list[i].path = files[index].path;
      }
    }
    item = list[0];
    list.removeAt(0);
    return (list, item);
  }
}
