import 'package:flutter/material.dart';
import 'package:melotune/services/models/download_model.dart';
import 'package:melotune/widgets/features/home/media_action_button.dart';

class DownloadProvider with ChangeNotifier {
  List<DownloadModel> downloadQueue = [];

  DownloadModel getModel(String ytId, MediaType type) {
    final bool isMp3 = type == MediaType.mp3;
    final bool isMp4 = type == MediaType.mp4;
    return downloadQueue.singleWhere(
        (element) =>
            element.ytId == ytId &&
            ((element.type == DownloadType.mp3 && isMp3) ||
                (element.type == DownloadType.mp4 && isMp4)),
        orElse: () => DownloadModel(
            ytId: ytId,
            progress: 0,
            status: ItemStatus.normal,
            type: isMp3
                ? DownloadType.mp3
                : isMp4
                    ? DownloadType.mp4
                    : null));
  }

  void addItemToQueue(DownloadModel model) {
    removeFromQueue(model.ytId,
        model.type == DownloadType.mp3 ? MediaType.mp3 : MediaType.mp4);
    downloadQueue.add(model);
    notifyListeners();
  }

  void removeFromQueue(String ytId, MediaType type) {
    final int index = findElementInQueue(ytId, type);
    if (index != -1) {
      downloadQueue.removeAt(index);
    }
  }

  int findElementInQueue(String ytId, MediaType type) {
    final bool isMp3 = type == MediaType.mp3;
    final bool isMp4 = type == MediaType.mp4;
    return downloadQueue.indexWhere((element) =>
        element.ytId == ytId &&
        ((element.type == DownloadType.mp3 && isMp3) ||
            (element.type == DownloadType.mp4 && isMp4)));
  }

  void changeItemStatus(
      String ytId, MediaType type, int progress, ItemStatus status) {
    final int index = downloadQueue.indexWhere(
      (element) =>
          element.ytId == ytId &&
          ((element.type == DownloadType.mp3 && type == MediaType.mp3) ||
              (element.type == DownloadType.mp4 && type == MediaType.mp4)),
    );
    if (index != -1) {
      final DownloadModel model = downloadQueue[index];
      model.progress = progress;
      model.status = status;
    }
    notifyListeners();
  }
}
