import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:melotune/locator.dart';
import 'package:melotune/services/backend/data_service.dart';
import 'package:melotune/services/extensions/string_extensions.dart';
import 'package:melotune/services/functions/admob_ads/admob_banner.dart';
import 'package:melotune/services/functions/admob_ads/admob_interstitial.dart';
import 'package:melotune/services/functions/firebase_analytics.dart';
import 'package:melotune/services/models/download_model.dart';
import 'package:melotune/services/models/playlist_model.dart';
import 'package:melotune/services/providers/download_provider.dart';
import 'package:melotune/services/providers/home_provider.dart';
import 'package:melotune/services/providers/player_provider.dart';
import 'package:melotune/utils/colors.dart';
import 'package:melotune/utils/images.dart';
import 'package:melotune/utils/strings.dart';
import 'package:melotune/widgets/features/home/media_action_button.dart';
import 'package:melotune/widgets/features/home/appbar.dart';
import 'package:melotune/widgets/global/add_to_playlist_widget.dart';
import 'package:melotune/widgets/global/loading_indicator.dart';
import 'package:melotune/widgets/global/player_widget.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../widgets/features/home/drawer_widget.dart';
import '../widgets/features/home/search_bar.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  FocusNode? _searchBarFocus;
  bool _internetConnection = false;
  BannerAd? _bannerAd;
  final _scrollController = ScrollController();
  bool _isLoading = true;

  Future<bool> _onWillPop() async {
    final homeProvider = locator.get<HomeProvider>();
    if (homeProvider.searchContent != null) {
      homeProvider.unSearch();
      return false;
    } else {
      return true;
    }
  }

  void _loadAds() {
    final homeProvider = locator.get<HomeProvider>();
    final bannerAd = BannerAdManager(adUnitId: KAppId.bannerAd1);

    bannerAd.loadAd(onLoaded: (ad) {
      _bannerAd = ad;
      setState(() {});
    });
    if (homeProvider.getAppSetting("appOpenAd").parseBool()) {
      final interstitialAd =
          InterstitialAdManager(adUnitId: KAppId.interstitalAd1);
      interstitialAd.load(
        onLoaded: (ad) {
          ad.show();
        },
      );
    }
  }

  Future<bool> _haveConnection() async {
    try {
      final r1 = await InternetAddress.lookup("google.com");
      _internetConnection = r1.isNotEmpty && r1[0].rawAddress.isNotEmpty;
    } on SocketException catch (_) {
      _internetConnection = false;
    }

    return _internetConnection;
  }

  void _fetchData() async {
    _isLoading = true;
    setState(() {});
    if (await _haveConnection()) {
      _internetConnection = true;
      AnalyticsService.setUser();
      await locator.get<DataService>().fetch();
      _loadAds();
      setState(() => _isLoading = false);
    } else {
      _isLoading = false;
      setState(() {});
    }
  }

  @override
  void initState() {
    _fetchData();
    super.initState();
  }

  @override
  void dispose() {
    locator.get<PlayerProvider>().player.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const HomeAppBar(),
      endDrawer: const DrawerWidget(),
      body: _isLoading
          ? Center(child: loadingIndicator())
          : WillPopScope(
              onWillPop: _onWillPop,
              child: Column(
                children: [
                  Expanded(
                    child: Stack(
                      alignment: Alignment.bottomCenter,
                      children: [
                        Consumer<HomeProvider>(
                            builder: (context, value, child) =>
                                _homeWidget(value)),
                        if (!Provider.of<HomeProvider>(context)
                            .searchContentLoading)
                          const PlayerWidget()
                      ],
                    ),
                  ),
                  if (_bannerAd != null) _bannerAdWidget(),
                ],
              ),
            ),
    );
  }

  Widget _homeWidget(HomeProvider value) {
    if (!_internetConnection) {
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Spacer(),
          const Icon(Icons.signal_wifi_connected_no_internet_4,
              color: Colors.black38, size: 70),
          Padding(
            padding: const EdgeInsets.all(15),
            child: Text(KStrings.internetProblem, textAlign: TextAlign.center),
          ),
          const Spacer(),
          TextButton(
              onPressed: () => _fetchData(), child: Text(KStrings.reconnect))
        ],
      );
    }
    if (value.searchContentLoading) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 50),
          child: loadingIndicator(),
        ),
      );
    } else if (value.searchContent != null) {
      return _contentGenerator(value.searchContent!, isSearch: true);
    } else {
      return ListView.builder(
        shrinkWrap: true,
        controller: _scrollController,
        itemCount: value.playList.length,
        itemBuilder: (context, index) {
          final PlayListModel playLists = value.playList[index];
          final playerProvider = Provider.of<PlayerProvider>(context);
          final bool isExpanded = value.expandedListIndex == index;
          final bool isLastItem = index == value.playList.length - 1;

          return Column(
            children: [
              if (index == 0) SearchBarWidget(myFocusNode: _searchBarFocus),
              InkWell(
                onTap: () {
                  value.setLoadMore(false);
                  _scrollController.animateTo(0,
                      duration: const Duration(milliseconds: 500),
                      curve: Curves.fastOutSlowIn);
                  value.setExpandedListIndex(index);
                },
                child: Container(
                  width: double.infinity,
                  margin: EdgeInsets.only(
                    bottom:
                        playerProvider.isPlaying && isLastItem && !isExpanded
                            ? 80
                            : 0,
                  ),
                  padding: const EdgeInsets.all(10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(playLists.playListName,
                          style: Theme.of(context).textTheme.titleMedium),
                      const Icon(Icons.arrow_drop_down_rounded)
                    ],
                  ),
                ),
              ),
              Visibility(
                visible: value.expandedListIndex == index,
                child: _contentGenerator(playLists),
              )
            ],
          );
        },
      );
    }
  }

  Widget _bannerAdWidget() {
    return Container(
      color: Colors.white,
      width: 468,
      height: 60,
      child: AdWidget(ad: _bannerAd!),
    );
  }

  Widget _searchInfoText(HomeProvider provider, String query) {
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Text(
        provider.searchContent != null
            ? "YouTube ${KStrings.searchInfo}"
            : '"${query.length > 23 ? '${query.substring(0, 22)}...' : query}" ${KStrings.searchInfo}',
        style: const TextStyle(fontSize: 14, color: Colors.black87),
      ),
    );
  }

  Widget _thumbnailItem(PlayListItemModel item) {
    return InkWell(
      onTap: () => launchUrl(Uri.parse(KStrings.youtubeUrl(item.id!))),
      child: Stack(
        alignment: Alignment.bottomLeft,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: CachedNetworkImage(
              imageUrl: item.thumbnail,
              placeholder: (context, url) => Image.asset(KImages.blankImage),
              width: 75,
              height: 50,
              fit: BoxFit.cover,
            ),
          ),
          if (item.duration.isNotEmpty)
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 2,
                vertical: 1,
              ),
              color: Colors.black54,
              child: Text(
                item.duration,
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 8,
                    fontWeight: FontWeight.w500),
              ),
            )
        ],
      ),
    );
  }

  Widget _mediaDownloadButtons({
    required HomeProvider provider,
    required PlayListItemModel item,
    required DownloadModel modelListen,
    required DownloadModel modelMp4,
    required DownloadModel modelMp3,
  }) {
    return Row(
      children: [
        MediaActionButton(
          downloadModel: modelListen,
          playListItemModel: item,
          type: MediaType.listen,
          status:
              modelListen.type == null ? modelListen.status : ItemStatus.listen,
        ),
        MediaActionButton(
          downloadModel: modelMp4,
          playListItemModel: item,
          type: MediaType.mp4,
          status: provider.mp4DownloadsCache.contains(item.id)
              ? ItemStatus.succeeded
              : modelMp4.type == DownloadType.mp4
                  ? modelMp4.status
                  : ItemStatus.normal,
        ),
        MediaActionButton(
          downloadModel: modelMp3,
          playListItemModel: item,
          type: MediaType.mp3,
          status:
              provider.mp3DownloadsCache.contains(item.id) || item.path != null
                  ? ItemStatus.succeeded
                  : modelMp3.type == DownloadType.mp3
                      ? modelMp3.status
                      : ItemStatus.normal,
        ),
      ],
    );
  }

  Widget _loadMoreButton() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: InkWell(
        borderRadius: BorderRadius.circular(10),
        onTap: () =>
            Provider.of<HomeProvider>(context, listen: false).setLoadMore(true),
        child: Container(
          width: 180,
          padding: const EdgeInsets.all(5),
          decoration: BoxDecoration(
              color: Colors.blueGrey.withOpacity(.1),
              borderRadius: BorderRadius.circular(10)),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [const Icon(Icons.add), Text(KStrings.loadMore)],
          ),
        ),
      ),
    );
  }

  Widget _contentGenerator(PlayListModel playLists, {bool isSearch = false}) {
    final homeProvider = Provider.of<HomeProvider>(context);
    final bool loadMore = homeProvider.loadMore;
    final String searchQuery = playLists.playListName;

    if (isSearch && playLists.items.isEmpty) {
      return Column(
        children: [
          const Icon(
            Icons.not_interested,
            color: Colors.black38,
            size: 40,
          ),
          const SizedBox(height: 15),
          Text(KStrings.noResults,
              style: const TextStyle(fontSize: 18, color: KColors.softBlack)),
          const SizedBox(height: 80),
        ],
      );
    }

    final int itemCount = loadMore ? playLists.items.length : 10;

    return ListView.separated(
      shrinkWrap: true,
      physics: isSearch
          ? const BouncingScrollPhysics()
          : const NeverScrollableScrollPhysics(),
      itemCount: itemCount,
      itemBuilder: (context, index) {
        late final PlayListItemModel item;
        if (isSearch) {
          item = playLists.items[index];
        } else {
          item = playLists.items.toList()[index];
        }
        return Column(
          children: [
            if (isSearch && index == 0)
              _searchInfoText(homeProvider, searchQuery),
            AddToPlayListWidget(
              item: item,
              child: Container(
                padding: const EdgeInsets.all(12),
                child: Row(
                  children: [
                    _thumbnailItem(item),
                    const SizedBox(width: 13),
                    Expanded(
                      child: Text(
                        item.title,
                        maxLines: 2,
                        softWrap: true,
                        overflow: TextOverflow.clip,
                        style: const TextStyle(fontSize: 12),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Consumer<DownloadProvider>(
                      builder: (context, value, child) {
                        final HomeProvider homeProvider =
                            Provider.of<HomeProvider>(context);

                        final DownloadModel modelListen =
                            value.getModel(item.id!, MediaType.listen);
                        final DownloadModel modelMp3 =
                            value.getModel(item.id!, MediaType.mp3);
                        final DownloadModel modelMp4 =
                            value.getModel(item.id!, MediaType.mp4);

                        return _mediaDownloadButtons(
                          provider: homeProvider,
                          item: item,
                          modelListen: modelListen,
                          modelMp4: modelMp4,
                          modelMp3: modelMp3,
                        );
                      },
                    )
                  ],
                ),
              ),
            ),
            if (!loadMore && index == 9 && !isSearch) _loadMoreButton()
          ],
        );
      },
      separatorBuilder: (context, index) => const SizedBox(
        width: 350,
        child: Divider(
          thickness: 0.6,
        ),
      ),
    );
  }
}
