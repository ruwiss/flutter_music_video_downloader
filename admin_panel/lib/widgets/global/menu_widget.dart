import 'package:admin_panel/locator.dart';
import 'package:admin_panel/services/providers/base_provider.dart';
import 'package:admin_panel/utils/images.dart';
import 'package:admin_panel/utils/strings.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class MenuWidget extends StatelessWidget {
  final GlobalKey<ScaffoldState>? drawerKey;
  const MenuWidget({super.key, this.drawerKey});

  Widget _menuButton(BuildContext context, {required String title}) {
    bool isCurrent = Provider.of<BaseProvider>(context).currentTab == title;
    return Padding(
      padding: const EdgeInsets.only(bottom: 5),
      child: InkWell(
        onTap: () {
          if (drawerKey != null) drawerKey!.currentState?.closeDrawer();
          locator.get<BaseProvider>().setCurrentTab(title);
        },
        child: Container(
          padding: const EdgeInsets.all(10),
          color: isCurrent ? Colors.blueGrey.shade900 : null,
          alignment: Alignment.center,
          child: Text(
            title,
            style: TextStyle(color: isCurrent ? Colors.white70 : null),
          ),
        ),
      ),
    );
  }

  Widget _menuBar() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(
          color: Colors.blueGrey.shade900,
          borderRadius: const BorderRadius.only(topLeft: Radius.circular(8))),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(
            KImages.logo,
            height: 30,
          ),
          const SizedBox(width: 8),
          const Text("MeloTune")
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    bool isDrawer = width < 750;
    return Container(
      width: 200,
      margin: EdgeInsets.only(left: isDrawer ? 0 : 30),
      decoration: BoxDecoration(
          borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(10), bottomLeft: Radius.circular(5)),
          border: Border.all(color: Colors.white.withOpacity(.1), width: 2),
          color: isDrawer ? const Color(0xFF1E1F22) : Colors.black12),
      child: Column(
        children: [
          _menuBar(),
          _menuButton(context, title: KTabs.settings),
          _menuButton(context, title: KTabs.blockMusic),
          _menuButton(context, title: KTabs.playListRequests),
          _menuButton(context, title: KTabs.editPlaylists),
          _menuButton(context, title: KTabs.editRingtones),
          _menuButton(context, title: KTabs.log),
        ],
      ),
    );
  }
}
