import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'dart:developer';

class BannerAdManager {
  BannerAdManager({required this.adUnitId});
  final String adUnitId;

  void loadAd({Function(BannerAd)? onLoaded}) {
     BannerAd(
      adUnitId: adUnitId,
      request: const AdRequest(),
      size: AdSize.banner,
      listener: BannerAdListener(
        onAdLoaded: (ad) {
          if (onLoaded != null) onLoaded(ad as BannerAd);
        },
        onAdFailedToLoad: (ad, err) {
          log('BannerAd failed to load: $err');
          ad.dispose();
        },
      ),
    ).load();
  }
}