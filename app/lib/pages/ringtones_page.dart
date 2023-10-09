import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:melotune/locator.dart';
import 'package:melotune/services/backend/data_service.dart';
import 'package:melotune/services/functions/downloader.dart';
import 'package:melotune/services/functions/local_db.dart';
import 'package:melotune/services/models/ringtone_model.dart';
import 'package:melotune/services/providers/ringtones_provider.dart';
import 'package:provider/provider.dart';
import '../services/functions/admob_ads/admob_interstitial.dart';
import '../utils/colors.dart';
import '../utils/images.dart';
import '../utils/strings.dart';

class RingtonesPage extends StatefulWidget {
  const RingtonesPage({super.key});

  @override
  State<RingtonesPage> createState() => _RingtonesPageState();
}

class _RingtonesPageState extends State<RingtonesPage> {
  List<int> _downloadedFiles = [];
  InterstitialAd? _interstitialAd;

  void _loadInterstitialAd() {
    if (!locator.get<RingtonesProvider>().adShown) {
      final interstitialAd =
          InterstitialAdManager(adUnitId: KAppId.interstitalAd2);
      interstitialAd.load(onLoaded: (ad) => _interstitialAd = ad);
    }
  }

  @override
  void initState() {
    _loadInterstitialAd();
    locator.get<DataService>().getRingtones();
    _downloadedFiles = locator.get<LocalDB>().getRingtones();
    super.initState();
  }

  @override
  void dispose() {
    final ringtonesProvider = locator.get<RingtonesProvider>();
    ringtonesProvider.stopAudio();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _appBarWidget(),
      body: Consumer<RingtonesProvider>(
        builder: (context, value, child) => value.ringtones.isEmpty
            ? const Center(
                child: CircularProgressIndicator(color: KColors.appPrimary))
            : GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 15,
                  mainAxisSpacing: 15,
                ),
                itemCount: value.ringtones.length,
                itemBuilder: (BuildContext context, int index) {
                  return _gridItem(value, value.ringtones[index]);
                },
              ),
      ),
    );
  }

  Widget _gridItem(RingtonesProvider provider, RingtoneModel ringtone) {
    final String url = KHost.playRingtone(ringtone.id);
    final isDownloading = provider.downloadModel != null &&
        provider.downloadModel!.id == ringtone.id;
    RingtoneDownloadStatus? downloadStatus = provider.downloadModel?.status;
    return Padding(
      padding: const EdgeInsets.all(8),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: () => provider.playAudio(ringtone),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: Stack(
            children: [
              SizedBox(
                width: double.infinity,
                height: double.infinity,
                child: CachedNetworkImage(
                  imageUrl: ringtone.image,
                  placeholder: (context, url) =>
                      Image.asset(KImages.blankImage, fit: BoxFit.cover),
                  fit: BoxFit.cover,
                ),
              ),
              Container(
                width: double.infinity,
                height: double.infinity,
                alignment: Alignment.bottomCenter,
                color: isDownloading
                    ? Colors.black45
                    : provider.currentPlayingUrl == url
                        ? KColors.appPrimary.withOpacity(.4)
                        : Colors.blueAccent.withOpacity(.2),
                child: Text(
                  " ${ringtone.title} ",
                  maxLines: 1,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 15,
                    overflow: TextOverflow.clip,
                    backgroundColor: Colors.white.withOpacity(.6),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              if (!_downloadedFiles.contains(ringtone.id) && !isDownloading)
                Positioned(
                  right: 0,
                  top: 0,
                  child: IconButton(
                    onPressed: () async {
                      if (_interstitialAd != null) {
                        _interstitialAd!.show();
                        provider.adShown = true;
                      }
                      if (await locator
                          .get<Downloader>()
                          .downloadRingtone(ringtoneModel: ringtone)) {
                        _downloadedFiles.add(ringtone.id);
                        setState(() {});
                      }
                    },
                    icon: const Icon(
                      Icons.file_download,
                      size: 40,
                      color: Colors.white,
                    ),
                  ),
                ),
              if (isDownloading)
                Align(
                  alignment: Alignment.center,
                  child: Text(
                    switch (downloadStatus!) {
                      (RingtoneDownloadStatus.waiting) => "⏳",
                      (RingtoneDownloadStatus.downloading) =>
                        provider.downloadModel!.progress.toString(),
                      (RingtoneDownloadStatus.error) => "⚠️",
                      (RingtoneDownloadStatus.success) =>
                        KStrings.downloadedToast,
                    },
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  AppBar _appBarWidget() {
    return AppBar(
      backgroundColor: KColors.appPrimary,
      iconTheme: const IconThemeData(color: Colors.white),
      title: Text(
        KStrings.ringtonesPage,
        style: const TextStyle(color: Colors.white),
      ),
      centerTitle: true,
    );
  }
}
