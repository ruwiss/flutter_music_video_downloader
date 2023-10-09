import 'package:flutter/material.dart';
import 'package:melotune/utils/colors.dart';
import '../../../utils/strings.dart';
import 'package:url_launcher/url_launcher.dart';

class DrawerWidget extends StatelessWidget {
  const DrawerWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
        width: 140,
        height: 450,
        alignment: Alignment.center,
        padding: const EdgeInsets.symmetric(vertical: 15),
        decoration: BoxDecoration(
            color: KColors.drawerBackground,
            borderRadius:
                const BorderRadius.horizontal(left: Radius.circular(30)),
            border: Border.all(
                color: KColors.drawerColor.withOpacity(.1), width: 3)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              KStrings.menuTitle,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: KColors.drawerColor,
                fontWeight: FontWeight.w500,
              ),
            ),
            Divider(
                color: KColors.drawerColor.withOpacity(.1),
                thickness: 2,
                height: 30),
            const SizedBox(height: 5),
            _menuItem(
                text: KStrings.downloadMenu,
                icon: Icons.download,
                onTap: () {
                  Navigator.pop(context);
                  Navigator.pushNamed(context, "/downloads");
                }),
            _menuItem(
                text: KStrings.playlistMenu,
                icon: Icons.playlist_play,
                onTap: () {
                  Navigator.pop(context);
                  Navigator.pushNamed(context, "/playLists");
                }),
            _menuItem(
                text: KStrings.ringtonesPage,
                icon: Icons.music_note_rounded,
                onTap: () {
                  Navigator.pop(context);
                  Navigator.pushNamed(context, "/ringtones");
                }),
            _menuItem(
              text: KStrings.voteMenu,
              icon: Icons.star,
              onTap: () {
                Navigator.pop(context);

                launchUrl(Uri.parse(KStrings.playStoreLink),
                    mode: LaunchMode.externalApplication);
              },
            ),
            const Expanded(child: SizedBox()),
            const Text(
              "v${KStrings.appVersion}",
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.black54, fontSize: 12),
            ),
          ],
        ));
  }

  InkWell _menuItem(
      {required String text, required IconData icon, required Function onTap}) {
    return InkWell(
      borderRadius: BorderRadius.circular(5),
      onTap: () => onTap(),
      child: Container(
        alignment: Alignment.center,
        padding: const EdgeInsets.all(8),
        margin: const EdgeInsets.only(right: 3, left: 10, bottom: 12),
        decoration: BoxDecoration(
            color: KColors.drawerButton,
            borderRadius: BorderRadius.circular(5)),
        child: Row(
          children: [
            Expanded(
              child: Text(
                text,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: KColors.drawerColor,
                ),
              ),
            ),
            Icon(icon, size: 22, color: KColors.appPrimary),
          ],
        ),
      ),
    );
  }
}
