import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:melotune/locator.dart';
import 'package:melotune/services/functions/local_db.dart';
import 'package:melotune/services/helpers/custom_dialogs.dart';
import 'package:melotune/services/models/playlist_model.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:melotune/services/providers/player_provider.dart';
import 'package:provider/provider.dart';
import '../services/functions/admob_ads/admob_interstitial.dart';
import '../services/providers/home_provider.dart';
import '../utils/colors.dart';
import '../utils/strings.dart';
import '../widgets/global/player_widget.dart';

class PlayListsPage extends StatefulWidget {
  const PlayListsPage({super.key});

  @override
  State<PlayListsPage> createState() => _PlayListsPageState();
}

class _PlayListsPageState extends State<PlayListsPage> {
  InterstitialAd? _interstitialAd;
  List<String> _contents = [];
  String? _currentPlaylist;

  void _setCurrentPlayList(String? name) {
    _currentPlaylist = name;
    setState(() {});
  }

  void _playMusic(PlayListItemModel item) {
    _interstitialAd?.show();
    List<PlayListItemModel> items = _contents
        .map((e) => PlayListItemModel.fromJson(jsonDecode(e)))
        .toList();
    locator.get<PlayerProvider>().playPauseOrResume(item: item, list: items);
  }

  void _removePlayList() async {
    CustomDialogs.showConfirmDialog(
      context,
      title: KStrings.areYouSure,
      message: KStrings.deletePlayListInfo,
      onConfirm: () async {
        await locator.get<LocalDB>().removePlayList(_currentPlaylist!);
        _setCurrentPlayList(null);
        Fluttertoast.showToast(msg: KStrings.deletedPlaylist);
      },
      buttonColor: KColors.appPrimary,
    );
  }

  void _removeMusic(PlayListItemModel item) async {
    CustomDialogs.showConfirmDialog(
      context,
      title: KStrings.areYouSure,
      message: KStrings.deleteMusicFromPlayListInfo,
      onConfirm: () async {
        await locator.get<LocalDB>().removeMusicFromPlayList(
            _currentPlaylist!, jsonEncode(item.toJson()));
        setState(() {});
        Fluttertoast.showToast(msg: KStrings.deletedMusicFromPlayList);
      },
      buttonColor: Colors.redAccent,
    );
  }

  void _loadInterstitialAd() {
    final interstitialAd =
        InterstitialAdManager(adUnitId: KAppId.interstitalAd2);
    interstitialAd.load(onLoaded: (ad) => _interstitialAd = ad);
  }

  @override
  void initState() {
    _loadInterstitialAd();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _appBarWidget(),
      body: Column(
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 5),
              child:
                  _currentPlaylist == null ? _playLists() : _playListContents(),
            ),
          ),
          if (!Provider.of<HomeProvider>(context).searchContentLoading)
            const PlayerWidget()
        ],
      ),
    );
  }

  AppBar _appBarWidget() {
    return AppBar(
      backgroundColor: KColors.appPrimary,
      iconTheme: const IconThemeData(color: Colors.white),
      title: Text(
        _currentPlaylist == null ? KStrings.playlistMenu : KStrings.musicsTab,
        style: const TextStyle(color: Colors.white),
      ),
      leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            if (_currentPlaylist == null) {
              Navigator.of(context).pop();
            } else {
              _setCurrentPlayList(null);
            }
          }),
      actions: [
        if (_currentPlaylist != null)
          IconButton(
            icon: const Icon(Icons.playlist_remove, size: 30),
            onPressed: () => _removePlayList(),
          ),
      ],
      centerTitle: true,
    );
  }

  Widget _divider() {
    return SizedBox(
      width: 250,
      child: Divider(color: Colors.grey.shade300, height: 10),
    );
  }

  Widget _playLists() {
    final localDB = locator.get<LocalDB>();
    final playlists = localDB.getAllPlayLists(reversed: true) ?? [];
    if (playlists.isEmpty) {
      return Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(20),
            child: Text(
              KStrings.createPlaylistInfo,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 18, color: Colors.black54),
            ),
          ),
          const Expanded(
            child: Icon(Icons.playlist_add, size: 160, color: Colors.black12),
          ),
        ],
      );
    }
    return ListView.separated(
      itemCount: playlists.length,
      itemBuilder: (context, index) {
        final lengthOfContent = localDB.getPlayList(playlists[index]).length;
        return InkWell(
          onTap: () => _setCurrentPlayList(playlists[index]),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    playlists[index],
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.black54,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                const SizedBox(width: 5),
                Chip(
                  label: Text("$lengthOfContent"),
                  backgroundColor: Colors.grey.shade300,
                  side: BorderSide.none,
                  labelStyle: const TextStyle(fontSize: 13),
                  padding: const EdgeInsets.all(3),
                ),
              ],
            ),
          ),
        );
      },
      separatorBuilder: (context, index) => _divider(),
    );
  }

  Widget _playListContents() {
    final localDB = locator.get<LocalDB>();
    _contents = localDB.getPlayList(_currentPlaylist!, reversed: true);
    return ReorderableListView.builder(
      itemCount: _contents.length,
      onReorder: (oldIndex, newIndex) async {
        locator.get<PlayerProvider>().playerStopButton();
        final item = _contents[oldIndex];
        _contents.removeAt(oldIndex);
        if (newIndex <= _contents.length - 1) {
          _contents.insert(newIndex, item);
        } else {
          _contents.add(item);
        }

        await locator.get<LocalDB>().reOrderPlayListItems(
            _currentPlaylist!, _contents.reversed.toList());
      },
      itemBuilder: (context, index) {
        final item = PlayListItemModel.fromJson(jsonDecode(_contents[index]));
        return InkWell(
          key: Key('$index'),
          onTap: () => _playMusic(item),
          child: Slidable(
            endActionPane: ActionPane(
              motion: const ScrollMotion(),
              children: [
                SlidableAction(
                  onPressed: (context) => _removeMusic(item),
                  icon: Icons.delete,
                  backgroundColor: Colors.redAccent,
                  foregroundColor: Colors.white,
                )
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.all(15),
              child: Row(
                children: [
                  Consumer<PlayerProvider>(
                    builder: (context, value, child) {
                      if (value.isCurrentPlaying(item)) {
                        return const Icon(Icons.play_arrow,
                            size: 28, color: KColors.appPrimary);
                      }
                      return const Icon(Icons.queue_music,
                          size: 28, color: Colors.black45);
                    },
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      item.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 16,
                        color: Colors.black54,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
