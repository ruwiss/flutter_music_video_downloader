import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'dart:developer';

class InterstitialAdManager {
  InterstitialAdManager({required this.adUnitId});
  final String adUnitId;

  void load({Function(InterstitialAd)? onLoaded, Function()? onError}) {
    InterstitialAd.load(
      adUnitId: adUnitId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          if (onLoaded != null) onLoaded(ad);
        },
        onAdFailedToLoad: (LoadAdError error) {
          if (onError != null) onError();
          log("Interstitial Ad Load Error : ${error.message}");
        },
      ),
    );
  }
}