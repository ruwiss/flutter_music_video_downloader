enum DownloadType { mp3, mp4 }

enum ItemStatus {
  listen,
  listening,
  paused,
  normal,
  waiting,
  converting,
  downloading,
  failed,
  succeeded
}

class DownloadModel {
  final String ytId;
  DownloadType? type;
  ItemStatus status;
  int progress;

  DownloadModel(
      {required this.ytId,
      this.type,
      required this.status,
      required this.progress});
}
