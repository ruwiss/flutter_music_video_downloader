import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:melotune/locator.dart';
import 'package:melotune/services/functions/local_db.dart';
import 'package:melotune/services/helpers/context_menu_region.dart';
import 'package:melotune/services/models/playlist_model.dart';
import 'package:melotune/utils/colors.dart';
import '../../utils/strings.dart';

class AddToPlayListWidget extends StatelessWidget {
  const AddToPlayListWidget(
      {super.key,
      required this.child,
      required this.item,
      this.enabled = true});
  final Widget child;
  final PlayListItemModel item;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return enabled
        ? ContextMenuRegion(
            contextMenuBuilder: (BuildContext context, Offset offset) {
              return AdaptiveTextSelectionToolbar.buttonItems(
                anchors: TextSelectionToolbarAnchors(primaryAnchor: offset),
                buttonItems: [
                  ContextMenuButtonItem(
                    onPressed: () {
                      ContextMenuController.removeAny();
                      showDialog(
                        context: context,
                        builder: (context) => _playListDialog(context),
                      );
                    },
                    label: KStrings.addToPlayList,
                  ),
                ],
              );
            },
            child: child,
          )
        : child;
  }

  Widget _divider() {
    return SizedBox(
      width: 250,
      child: Divider(color: Colors.grey.shade300),
    );
  }

  Dialog _createPlayListDialog(BuildContext context) {
    final tInput = TextEditingController();
    return Dialog(
      child: Padding(
        padding: const EdgeInsets.all(15),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: tInput,
              autofocus: true,
              style: const TextStyle(
                fontSize: 18,
                color: KColors.softBlack,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
              decoration: InputDecoration(
                hintText: KStrings.playListName,
                border: InputBorder.none,
              ),
            ),
            ElevatedButton(
              onPressed: () async {
                if (tInput.text.isEmpty) return;
                Navigator.of(context).pop();
                await await locator
                    .get<LocalDB>()
                    .createPlayList(tInput.text.trim());
                if (context.mounted) {
                  showDialog(
                    context: context,
                    builder: (context) => _playListDialog(context),
                  );
                }
              },
              child: Text(
                KStrings.createPlayListButton,
                style: const TextStyle(fontSize: 15),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Dialog _playListDialog(BuildContext context) {
    final localDB = locator.get<LocalDB>();
    final List items = localDB.getAllPlayLists(reversed: true) ?? [];
    return Dialog(
      child: Padding(
        padding: const EdgeInsets.all(15),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              KStrings.selectPlaylist,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w500,
                color: KColors.softBlack,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              item.title,
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.clip,
              style: const TextStyle(fontSize: 12),
            ),
            const SizedBox(height: 2),
            _divider(),
            if (items.isEmpty)
              Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Text(KStrings.noHavePlayList,
                    style:
                        const TextStyle(fontSize: 13, color: Colors.black54)),
              ),
            ListView.separated(
              itemCount: items.length,
              shrinkWrap: true,
              itemBuilder: (context, index) {
                final contentLength = localDB.getPlayList(items[index]).length;
                return InkWell(
                  onTap: () async {
                    Navigator.pop(context);
                    final saved = await localDB.addMusicToPlayList(
                        items[index], jsonEncode(item.toJson()));
                    if (saved) {
                      Fluttertoast.showToast(msg: KStrings.addedToPlayList);
                    } else {
                      Fluttertoast.showToast(msg: KStrings.alreadyAdded);
                    }
                  },
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Flexible(
                        child: Text(
                          "  ${items[index]}",
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontSize: 14),
                        ),
                      ),
                      Chip(
                        label: Text("$contentLength"),
                        backgroundColor: Colors.grey.shade300,
                        side: BorderSide.none,
                        labelStyle: const TextStyle(fontSize: 13),
                        padding: const EdgeInsets.all(3),
                      ),
                    ],
                  ),
                );
              },
              separatorBuilder: (context, index) => _divider(),
            ),
            const SizedBox(height: 5),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                showDialog(
                  context: context,
                  builder: (context) => _createPlayListDialog(context),
                );
              },
              child: Text(
                KStrings.createPlayListButton,
                style: const TextStyle(fontSize: 15),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
