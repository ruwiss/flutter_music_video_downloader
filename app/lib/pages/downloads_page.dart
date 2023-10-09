import 'dart:io';
import 'package:flutter/material.dart';
import 'package:melotune/locator.dart';
import 'package:melotune/services/extensions/string_extensions.dart';
import 'package:melotune/services/functions/download_list.dart';
import 'package:melotune/services/models/playlist_model.dart';
import 'package:melotune/services/providers/downloads_provider.dart';
import 'package:melotune/services/providers/player_provider.dart';
import 'package:melotune/utils/colors.dart';
import 'package:melotune/utils/strings.dart';
import 'package:melotune/widgets/features/downloads/downloads_tab.dart';
import 'package:melotune/widgets/global/add_to_playlist_widget.dart';
import 'package:melotune/widgets/global/player_widget.dart';
import 'package:open_filex/open_filex.dart';
import 'package:provider/provider.dart';

class DownloadsPage extends StatelessWidget {
  const DownloadsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _appBarWidget(),
      body: Column(
        children: [
          const SizedBox(height: 8),
          Expanded(
            child: Stack(
              children: [
                _listContent(context),
                if (Provider.of<PlayerProvider>(context).currentPlaying != null)
                  const Align(
                    alignment: Alignment.bottomCenter,
                    child: PlayerWidget(),
                  ),
              ],
            ),
          ),
          const DownloadsTab(),
        ],
      ),
    );
  }

  AppBar _appBarWidget() {
    return AppBar(
      backgroundColor: KColors.appPrimary,
      iconTheme: const IconThemeData(color: Colors.white),
      title: Text(
        KStrings.downloadsPage,
        style: const TextStyle(color: Colors.white),
      ),
      centerTitle: true,
    );
  }

  Widget _listContent(BuildContext context) {
    final downloadsProvider = Provider.of<DownloadsProvider>(context);
    final DownloadList downloadList = locator.get<DownloadList>();
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: FutureBuilder<List<FileSystemEntity>>(
        future: downloadList.listOfFiles(downloadsProvider.categorySelection),
        builder: (context, snapshot) {
          if (snapshot.hasError || !snapshot.hasData) return const SizedBox();

          final List<FileSystemEntity> list = snapshot.data!;
          if (list.isEmpty) {
            return Column(
              children: [
                const Padding(
                  padding: EdgeInsets.only(top: 70, bottom: 20),
                  child: Icon(
                    Icons.restore_from_trash,
                    size: 80,
                    color: Colors.black26,
                  ),
                ),
                Text(
                  KStrings.noItem,
                  style: const TextStyle(
                    color: KColors.softBlack,
                  ),
                ),
              ],
            );
          }
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: List.generate(
              list.length,
              (index) {
                return _fileItem(context, list, index);
              },
            ),
          );
        },
      ),
    );
  }

  Widget _fileItem(
      BuildContext context, List<FileSystemEntity> files, int index) {
    final FileSystemEntity file = files[index];
    final String name = file.path.split("/").last.replaceAll(".mp3", "");
    final bool isMp3 = file.path.split(".").last == "mp3";
    final playerProvider = Provider.of<PlayerProvider>(context);
    bool isCurrentPlaying = false;
    if (playerProvider.currentPlaying != null) {
      isCurrentPlaying =
          playerProvider.currentPlaying!.title == file.path.getNameFromPath();
    }

    return AddToPlayListWidget(
      item: PlayListItemModel.fromPath(file.path),
      enabled: isMp3,
      child: GestureDetector(
        onTap: () {
          if (isMp3) {
            final pathList = files.map((e) => e.path).toList();
            List<PlayListItemModel> playlistItems = [];
            for (var path in pathList) {
              playlistItems.add(PlayListItemModel.fromPath(path));
            }

            playerProvider.playPauseOrResume(
              item: PlayListItemModel.fromPath(file.path),
              list: playlistItems,
            );
          } else {
            OpenFilex.open(file.path);
          }
        },
        child: Container(
          padding: EdgeInsets.only(
              left: 15, right: 10, top: isMp3 ? 0 : 12, bottom: isMp3 ? 0 : 12),
          margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: isCurrentPlaying
                    ? KColors.downloadsPlayingGradient
                    : KColors.downloadsGradient,
                begin: isCurrentPlaying
                    ? Alignment.bottomCenter
                    : Alignment.topCenter,
                end: isCurrentPlaying
                    ? Alignment.topCenter
                    : Alignment.bottomCenter,
              ),
              borderRadius:
                  const BorderRadius.horizontal(right: Radius.circular(10)),
              border: Border.all(color: KColors.appPrimary, width: 1.5)),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  name,
                  maxLines: 1,
                  softWrap: true,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                      fontSize: 15.5,
                      fontWeight: isCurrentPlaying ? FontWeight.w500 : null),
                ),
              ),
              if (isMp3)
                IconButton(
                  onPressed: () => OpenFilex.open(file.path),
                  icon: const Icon(Icons.file_open, color: Colors.black54),
                )
            ],
          ),
        ),
      ),
    );
  }
}
