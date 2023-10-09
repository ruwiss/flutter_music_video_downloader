import 'package:admin_panel/pages/home/tabs/block_tab.dart';
import 'package:admin_panel/pages/home/tabs/lang_tab.dart';
import 'package:admin_panel/pages/home/tabs/log_tab.dart';
import 'package:admin_panel/pages/home/tabs/login_tab.dart';
import 'package:admin_panel/pages/home/tabs/playlist_tab.dart';
import 'package:admin_panel/pages/home/tabs/settings_tab.dart';
import 'package:admin_panel/services/providers/base_provider.dart';
import 'package:admin_panel/utils/strings.dart';
import 'package:admin_panel/widgets/global/menu_widget.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'tabs/ringtones_tab.dart';

class HomePage extends StatelessWidget {
  HomePage({super.key});

  final _scaffoldKey = GlobalKey<ScaffoldState>();

  Widget _contentWidget() {
    BorderSide borderSide =
        BorderSide(color: Colors.white.withOpacity(.1), width: 2);
    return Expanded(
      child: Container(
        decoration: BoxDecoration(
          border:
              Border(bottom: borderSide, top: borderSide, right: borderSide),
          color: const Color(0xFF21252B),
        ),
        child: Consumer<BaseProvider>(
          builder: (context, value, child) {
            switch (value.currentTab) {
              case KTabs.settings:
                return const SettingsTab();
              case KTabs.blockMusic:
                return const BlockMusicTab();
              case KTabs.playListRequests:
                return const LanguageTab();
              case KTabs.editPlaylists:
                return const PlaylistTab();
              case KTabs.editRingtones:
                return const RingtonesTab();
              case KTabs.log:
                return const LogTab();
              default:
                return const LoginTab();
            }
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    return SafeArea(
      child: Scaffold(
        key: _scaffoldKey,
        drawer: width < 750 ? MenuWidget(drawerKey: _scaffoldKey) : null,
        body: Center(
          child: Container(
            constraints: const BoxConstraints(maxWidth: 1000),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (width >= 750) const MenuWidget(),
                ...[
                  if (width < 750)
                    Container(
                      alignment: Alignment.topCenter,
                      decoration: BoxDecoration(
                        color: const Color(0xFF1E1F22),
                        border: Border.all(
                            color: Colors.white.withOpacity(.1), width: 2),
                      ),
                      child: IconButton(
                        onPressed: () =>
                            _scaffoldKey.currentState?.openDrawer(),
                        icon: const Icon(Icons.menu),
                      ),
                    ),
                  _contentWidget(),
                ]
              ],
            ),
          ),
        ),
      ),
    );
  }
}
