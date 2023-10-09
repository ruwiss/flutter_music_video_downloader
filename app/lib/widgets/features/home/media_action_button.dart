import 'package:flutter/material.dart';
import 'package:melotune/locator.dart';
import 'package:melotune/services/functions/downloader.dart';
import 'package:melotune/services/models/download_model.dart';
import 'package:melotune/services/models/playlist_model.dart';
import 'package:melotune/services/providers/download_provider.dart';
import 'package:melotune/services/providers/player_provider.dart';
import 'package:melotune/utils/colors.dart';
import 'package:melotune/utils/images.dart';
import 'package:provider/provider.dart';

enum MediaType { listen, mp3, mp4 }

class MediaActionButton extends StatelessWidget {
  final DownloadModel downloadModel;
  final PlayListItemModel playListItemModel;
  final ItemStatus status;
  final MediaType type;

  const MediaActionButton({
    super.key,
    required this.downloadModel,
    required this.playListItemModel,
    required this.status,
    required this.type,
  });

  @override
  Widget build(BuildContext context) {
    final bool isDownloading = status == ItemStatus.downloading;
    return GestureDetector(
      onTap: () async {
        if (type == MediaType.listen) {
          locator
              .get<PlayerProvider>()
              .playPauseOrResume(item: playListItemModel);
        } else {
          if (status == ItemStatus.normal || status == ItemStatus.succeeded) {
            locator.get<Downloader>().download(
                downloadModel: downloadModel,
                playListItemModel: playListItemModel);
          }
        }
      },
      child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 6),
          child: Column(
            children: [
              Stack(
                alignment: Alignment.bottomCenter,
                children: [
                  if (isDownloading || status == ItemStatus.converting)
                    Container(
                        height: (downloadModel.progress / 100) * 30,
                        width: 25,
                        color: status == ItemStatus.downloading
                            ? KColors.appPrimary
                            : KColors.softBlack),
                  Builder(
                    builder: (context) {
                      if (status == ItemStatus.failed) {
                        return const Icon(Icons.running_with_errors,
                            color: Colors.redAccent, size: 33);
                      } else if (status == ItemStatus.waiting) {
                        return Padding(
                            padding: const EdgeInsets.only(bottom: 8),
                            child: _icon(KImages.waiting));
                      } else {
                        return _getCurrentImage(
                            Provider.of<PlayerProvider>(context),
                            Provider.of<DownloadProvider>(context));
                      }
                    },
                  ),
                  if (status == ItemStatus.converting)
                    const Padding(
                      padding: EdgeInsets.only(bottom: 4),
                      child: Icon(Icons.wifi_protected_setup_sharp,
                          size: 26, color: Colors.white),
                    ),
                ],
              ),
              type != MediaType.listen
                  ? Text(
                      isDownloading
                          ? "${downloadModel.progress.toString()}%"
                          : status == ItemStatus.succeeded
                              ? "OK"
                              : type == MediaType.mp3
                                  ? "MP3"
                                  : type == MediaType.mp4
                                      ? "MP4"
                                      : "",
                      style: TextStyle(
                          fontSize: 12,
                          fontWeight:
                              isDownloading || status == ItemStatus.succeeded
                                  ? FontWeight.w500
                                  : null,
                          color: isDownloading
                              ? Colors.indigo
                              : status == ItemStatus.succeeded
                                  ? KColors.appPrimary
                                  : null),
                    )
                  : const SizedBox(height: 15)
            ],
          )),
    );
  }

  Widget _icon(String image) => Image.asset(image, width: 33);

  Widget _getCurrentImage(
      PlayerProvider playerProvider, DownloadProvider downloadProvider) {
    if (type == MediaType.listen) {
      bool isCurrent = playerProvider.isCurrentPlaying(playListItemModel);

      if (isCurrent && playerProvider.playerStatus != null) {
        if (playerProvider.playerStatus == PlayerStatus.playing) {
          return _icon(KImages.pauseMusic);
        } else if (playerProvider.playerStatus == PlayerStatus.paused) {
          return _icon(KImages.resumeMusic);
        } else if (playerProvider.playerStatus == PlayerStatus.loading) {
          return _icon(KImages.waiting);
        }
      } else {
        return _icon(KImages.listenMusic);
      }
    } else if (type == MediaType.mp3 || type == MediaType.mp4) {
      final DownloadModel model =
          downloadProvider.getModel(downloadModel.ytId, type);
      if (model.status == ItemStatus.normal ||
          model.status == ItemStatus.succeeded) {
        return _icon(
            type == MediaType.mp3 ? KImages.downloadMp3 : KImages.downloadMp4);
      } else if (model.status == ItemStatus.downloading ||
          model.status == ItemStatus.converting) {
        return _icon(KImages.downloading);
      }
    }
    return _icon(KImages.waiting);
  }
}
