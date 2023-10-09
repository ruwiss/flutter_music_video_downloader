import 'dart:developer';

import 'package:assets_audio_player/assets_audio_player.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:melotune/locator.dart';
import 'package:melotune/services/extensions/string_extensions.dart';
import 'package:melotune/services/models/playlist_model.dart';
import 'package:melotune/services/providers/home_provider.dart';
import 'package:melotune/services/providers/ringtones_provider.dart';
import 'package:melotune/utils/strings.dart';
import '../functions/download_list.dart';

enum PlayerStatus { playing, paused, loading }

class PlayerProvider with ChangeNotifier {
  final player = AssetsAudioPlayer();
  bool stopButtonClicked = false;

  PlayListItemModel? currentPlaying;
  PlayerStatus? playerStatus;

  bool isShuffle = false;

  PlayerProvider() {
    listenPlayerState();
  }

  bool get isPlaying => currentPlaying != null;

  bool get isPlayingFromPlaylist =>
      player.current.hasValue &&
      player.current.value != null &&
      player.current.value!.playlist.audios.isNotEmpty;

  void listenPlayerState() {
    player.playlistAudioFinished.listen((playing) {
      if (!stopButtonClicked && isShuffle) {
        player.playlist?.audios.removeWhere((e) =>
            e.metas.extra!['id'] == playing.audio.audio.metas.extra!['id']);
      }
      if (!stopButtonClicked && playing.hasNext) {
        Fluttertoast.showToast(msg: KStrings.nextMusic);
      }
      player.stop();
    });

    player.playerState.listen(
      (state) {
        if (state == PlayerState.play) {
          if (!stopButtonClicked && isShuffle) {
            player.playlist?.audios.shuffle();
          }
          setPlayerStatus(PlayerStatus.playing);
          final extra = player.getCurrentAudioextra;
          setCurrentPlaying(PlayListItemModel.fromJson(extra));
        } else if (state == PlayerState.pause) {
          setPlayerStatus(PlayerStatus.paused);
        } else if (state == PlayerState.stop) {
          if (stopButtonClicked) stopButtonClicked = false;
          setCurrentPlaying(null);
          setPlayerStatus(null);
        }
        notifyListeners();
      },
    );
  }

  void setShuffle() async {
    isShuffle = !isShuffle;
    notifyListeners();
  }

  void setPlayerStatus(PlayerStatus? status) {
    playerStatus = status;
    notifyListeners();
  }

  void setCurrentPlaying(PlayListItemModel? item) {
    currentPlaying = item;
    if (item == null) playerStatus = null;
    notifyListeners();
  }

  Future playerStopButton() async {
    stopButtonClicked = true;
    await player.stop();
  }

  void playerNext() async {
    await player.next();
    final exras = player.getCurrentAudioextra;
    final bool isFile = exras['path'] != null;
    if (!isFile) {
      final homeProvider = locator.get<HomeProvider>();
      currentPlaying = homeProvider.findCurrentPlayListItem(
          homeProvider.currentPlaylist!, player.getCurrentAudioextra["id"]);
    } else {
      final path = exras['path'];
      currentPlaying = PlayListItemModel.fromPath(path);
      notifyListeners();
    }
    notifyListeners();
  }

  void playerPrev() async {
    await player.previous();
    final exras = player.getCurrentAudioextra;
    final bool isFile = exras['path'] != null;
    if (!isFile) {
      final homeProvider = locator.get<HomeProvider>();
      currentPlaying = homeProvider.findCurrentPlayListItem(
          homeProvider.currentPlaylist!, player.getCurrentAudioextra["id"]);
    } else {
      final path = exras['path'];
      currentPlaying = PlayListItemModel.fromPath(path);
      notifyListeners();
    }
  }

  Future playMedia(List<PlayListItemModel> playlistItems,
      PlayListItemModel playlistItem) async {
    setCurrentPlaying(playlistItem);
    setPlayerStatus(PlayerStatus.loading);

    final homeProvider = locator.get<HomeProvider>();
    final bool isSearch = homeProvider.searchContent != null;

    List<Audio> pList = [];
    for (var e in playlistItems) {
      final bool isFile = e.path != null;
      final dynamicAudio = isFile ? Audio.file : Audio.network;
      final data = isFile ? e.path! : KHost.getListenUrl(e.id!);
      pList.add(
        dynamicAudio(
          data,
          metas: Metas(
            title: e.title,
            image: isFile
                ? null
                : MetasImage(path: e.thumbnail, type: ImageType.network),
            extra: {
              "id": e.id,
              "path": e.path,
              "title": e.title,
              "thumbnail": e.thumbnail,
            },
          ),
        ),
      );
    }

    int startIndex = pList.indexWhere((e) =>
        e.metas.extra!['id'] != null &&
        e.metas.extra!['id'] == playlistItem.id);

    if (startIndex == -1) {
      startIndex = pList.indexWhere((e) =>
          e.metas.extra!['path'] != null &&
          e.metas.extra!['path'] == playlistItem.path);
    }

    try {
      await player.open(
        Playlist(
          audios: pList,
          startIndex: startIndex,
        ),
        showNotification: true,
        loopMode: LoopMode.playlist,
        notificationSettings: NotificationSettings(
          nextEnabled: !isSearch,
          prevEnabled: !isSearch,
          customStopAction: (player) => player.stop(),
          customPrevAction: (player) => playerPrev(),
          customNextAction: (player) => playerNext(),
        ),
      );
    } catch (e) {
      player.stop();
      Fluttertoast.showToast(msg: KStrings.listenError);
      setCurrentPlaying(null);
    }
  }

  void playPauseOrResume(
      {PlayListItemModel? item, List<PlayListItemModel>? list}) async {
    locator.get<RingtonesProvider>().stopAudio();

    final homeProvider = locator.get<HomeProvider>();
    // Search
    if (homeProvider.searchContent != null) {
      playMedia([item!], item);
      return;
    }

    var (p, i) = (list, item);
    if (list == null) {
      final (pp, ii) =
          homeProvider.findCurrentPlayList(item?.id ?? item!.path!);
      p = pp?.items;
      i = ii;
    }

    final (playlist, playlistItem) =
        await locator.get<DownloadList>().convertUrlToFileIfAvailable(p!, i!);

    if (currentPlaying != null) {
      if (isPlayingFromPlaylist) {
        playMedia(playlist, playlistItem);
      } else {
        player.playOrPause();
      }
    } else {
      playMedia(playlist, playlistItem);
    }
  }

  bool isPlayingYtId(String ytId) {
    return currentPlaying != null && currentPlaying!.id == ytId;
  }

  bool isCurrentPlaying(PlayListItemModel item) {
    return currentPlaying != null &&
        currentPlaying!.title.reFormatTitle() == item.title.reFormatTitle();
  }
}
