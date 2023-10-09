import 'package:admin_panel/locator.dart';
import 'package:admin_panel/services/backend/data_service.dart';
import 'package:admin_panel/services/providers/playlist_provider.dart';
import 'package:admin_panel/widgets/global/input_widget.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class PlaylistTab extends StatefulWidget {
  const PlaylistTab({super.key});

  @override
  State<PlaylistTab> createState() => _PlaylistTabState();
}

class _PlaylistTabState extends State<PlaylistTab> {
  final _langController = TextEditingController();
  final _titleController = TextEditingController();
  final _urlController = TextEditingController();

  @override
  void initState() {
    locator.get<DataService>().getPlaylistData();
    super.initState();
  }

  @override
  void dispose() {
    _langController.dispose();
    _titleController.dispose();
    _urlController.dispose();
    super.dispose();
  }

  Widget _changeIndexButton(
      {required List playlists,
      required Map playlist,
      required int currentIndex}) {
    final bool upVisible = playlists.indexOf(playlist) != 0;
    final bool downVisible =
        playlists.indexOf(playlist) != playlists.length - 1;

    Widget arrow(IconData icon) => InkWell(
          onTap: () {
            PlaylistProvider playlistProvider = locator.get<PlaylistProvider>();
            if (icon == Icons.keyboard_arrow_up) {
              playlistProvider.changeIndex(
                  playlists, playlist, currentIndex - 1);
            } else {
              playlistProvider.changeIndex(
                  playlists, playlist, currentIndex + 1);
            }
          },
          child: Icon(icon, size: 20),
        );
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (upVisible) arrow(Icons.keyboard_arrow_up),
        if (downVisible) arrow(Icons.keyboard_arrow_down)
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10, top: 5, right: 10, left: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Text(Provider.of<PlaylistProvider>(context).insertTime),
              const SizedBox(width: 10),
              OutlinedButton(
                  onPressed: () =>
                      locator.get<DataService>().savePlaylistData(),
                  child: const Text("Kaydet")),
            ],
          ),
          const SizedBox(height: 5),
          Expanded(
            child: ScrollConfiguration(
              behavior:
                  ScrollConfiguration.of(context).copyWith(scrollbars: false),
              child: SingleChildScrollView(
                child: Consumer<PlaylistProvider>(
                  builder: (context, value, child) => Column(
                    children: List.generate(value.playlistContent.keys.length,
                        (index) {
                      final String lang =
                          value.playlistContent.keys.elementAt(index);
                      final List playLists = value.playlistContent[lang];
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Container(
                            padding: const EdgeInsets.only(
                                top: 4, bottom: 4, left: 10),
                            color: Colors.amber.withOpacity(.1),
                            child: Text(lang),
                          ),
                          ...List.generate(playLists.length, (i) {
                            final Map playList = playLists[i];
                            return ListTile(
                              title: Text(playList['name']),
                              subtitle: Text(
                                playList['playlist_id'],
                                style: const TextStyle(color: Colors.white54),
                              ),
                              leading: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  _changeIndexButton(
                                      playlists: playLists,
                                      playlist: playList,
                                      currentIndex: i),
                                ],
                              ),
                              trailing: IconButton(
                                onPressed: () => value.removeFromPlaylist(
                                    lang, playList['url']),
                                icon: const Icon(
                                  Icons.close,
                                  size: 18,
                                  color: Colors.white54,
                                ),
                              ),
                            );
                          })
                        ],
                      );
                    }),
                  ),
                ),
              ),
            ),
          ),
          Row(
            children: [
              Expanded(
                  flex: 1,
                  child: InputWidget(
                    hintText: "Ülke",
                    controller: _langController,
                  )),
              const SizedBox(width: 5),
              Expanded(
                  flex: 2,
                  child: InputWidget(
                      hintText: "Başlık", controller: _titleController)),
              const SizedBox(width: 5),
              Expanded(
                  flex: 3,
                  child:
                      InputWidget(hintText: "URL", controller: _urlController)),
              IconButton(
                  onPressed: () {
                    locator.get<PlaylistProvider>().addPlaylist(
                        _langController.text,
                        _titleController.text,
                        _urlController.text);
                    _langController.clear();
                    _titleController.clear();
                    _urlController.clear();
                  },
                  icon: const Icon(Icons.arrow_circle_up_outlined, size: 30)),
            ],
          ),
        ],
      ),
    );
  }
}
