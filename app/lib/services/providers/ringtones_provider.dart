import 'package:assets_audio_player/assets_audio_player.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:melotune/locator.dart';
import 'package:melotune/services/models/ringtone_model.dart';
import 'package:melotune/services/providers/player_provider.dart';
import '../../utils/strings.dart';

class RingtonesProvider with ChangeNotifier {
  bool adShown = false;
  final player = AssetsAudioPlayer();
  RingtoneDownloadModel? downloadModel;
  List<RingtoneModel> ringtones = [];
  String currentPlayingUrl = "";

  RingtonesProvider() {
    _listenPlayerState();
  }

  void setRingtones(List<RingtoneModel> ringtones) {
    this.ringtones = ringtones;
    notifyListeners();
  }

  void setCurrentPlayingUrl(String? url) {
    currentPlayingUrl = url ?? "";
    notifyListeners();
  }

  void _listenPlayerState() {
    player.playerState.listen(
      (state) {
        if (state == PlayerState.stop) {
          setCurrentPlayingUrl(null);
        }
      },
    );
  }

  void stopAudio() {
    setCurrentPlayingUrl(null);
    player.stop();
  }

  Future playAudio(RingtoneModel ringtone) async {
    final url = KHost.playRingtone(ringtone.id);
    if (url == currentPlayingUrl) {
      stopAudio();
      return;
    }
    setCurrentPlayingUrl(url);
    locator.get<PlayerProvider>().playerStopButton();
    try {
      Fluttertoast.showToast(msg: KStrings.loading);
      await player.open(
        Audio.network(
          url,
          metas: Metas(
            id: ringtone.id.toString(),
            title: ringtone.title,
            image: MetasImage(path: ringtone.image, type: ImageType.network),
          ),
        ),
        showNotification: true,
        notificationSettings: const NotificationSettings(
          nextEnabled: false,
          prevEnabled: false,
        ),
      );

      notifyListeners();
    } catch (e) {
      player.stop();
    }
  }

  void setDownloadModel(RingtoneDownloadModel? downloadModel) {
    this.downloadModel = downloadModel;
    notifyListeners();
  }
}
