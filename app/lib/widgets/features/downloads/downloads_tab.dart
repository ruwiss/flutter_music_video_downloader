import 'package:flutter/material.dart';
import 'package:melotune/services/providers/downloads_provider.dart';
import 'package:melotune/utils/colors.dart';
import 'package:melotune/utils/strings.dart';
import 'package:provider/provider.dart';

class DownloadsTab extends StatelessWidget {
  const DownloadsTab({super.key});

  @override
  Widget build(BuildContext context) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _tabItem(DownloadsCategory.musics),
          _tabItem(DownloadsCategory.videos),
        ],
      ),
    );
  }

  Widget _tabItem(DownloadsCategory category) {
    return Consumer<DownloadsProvider>(
      builder: (context, value, child) => Expanded(
        child: InkWell(
          onTap: () => value.changeCategory(category),
          child: Container(
            alignment: Alignment.center,
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: value.categorySelection == category
                  ? Colors.grey.shade300
                  : Colors.grey.shade200,
              border: Border(
                bottom: BorderSide(color: Colors.indigo.shade200, width: 2),
              ),
            ),
            child: Text(
              switch (category) {
                (DownloadsCategory.musics) => KStrings.musicsTab,
                (DownloadsCategory.videos) => KStrings.videosTab,
              },
              style: const TextStyle(
                  color: KColors.softBlack, fontWeight: FontWeight.w500),
            ),
          ),
        ),
      ),
    );
  }
}
