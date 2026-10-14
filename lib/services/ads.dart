import 'dart:io';

import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import '../app_state.dart';

/// AdMob setup.
/// IMPORTANT: replace the TEST ids below with your real AdMob ad unit ids
/// before publishing (and the App ID in AndroidManifest / Info.plist).
class Ads {
  static const _androidBanner = 'ca-app-pub-3940256099942544/6300978111'; // TEST
  static const _iosBanner = 'ca-app-pub-3940256099942544/2934735716'; // TEST
  static const _androidInterstitial = 'ca-app-pub-3940256099942544/1033173712'; // TEST
  static const _iosInterstitial = 'ca-app-pub-3940256099942544/4411468910'; // TEST

  static bool _inited = false;
  static InterstitialAd? _interstitial;
  static int _drinkCounter = 0;

  static String get bannerId => Platform.isIOS ? _iosBanner : _androidBanner;
  static String get interstitialId => Platform.isIOS ? _iosInterstitial : _androidInterstitial;

  static Future<void> init() async {
    if (_inited) return;
    _inited = true;
    try {
      await MobileAds.instance.initialize();
      _loadInterstitial();
    } catch (_) {}
  }

  static void _loadInterstitial() {
    if (AppState.instance.premium) return;
    InterstitialAd.load(
      adUnitId: interstitialId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) => _interstitial = ad,
        onAdFailedToLoad: (_) => _interstitial = null,
      ),
    );
  }

  /// Shows an interstitial every 6th logged drink (never for premium users).
  static void onDrinkLogged() {
    if (AppState.instance.premium) return;
    _drinkCounter++;
    if (_drinkCounter % 6 != 0) return;
    final ad = _interstitial;
    if (ad == null) {
      _loadInterstitial();
      return;
    }
    ad.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (a) {
        a.dispose();
        _interstitial = null;
        _loadInterstitial();
      },
      onAdFailedToShowFullScreenContent: (a, e) {
        a.dispose();
        _interstitial = null;
        _loadInterstitial();
      },
    );
    ad.show();
  }
}

class BannerAdBox extends StatefulWidget {
  const BannerAdBox({super.key});

  @override
  State<BannerAdBox> createState() => _BannerAdBoxState();
}

class _BannerAdBoxState extends State<BannerAdBox> {
  BannerAd? _ad;
  bool _loaded = false;

  @override
  void initState() {
    super.initState();
    if (AppState.instance.premium) return;
    _ad = BannerAd(
      adUnitId: Ads.bannerId,
      size: AdSize.banner,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (_) {
          if (mounted) setState(() => _loaded = true);
        },
        onAdFailedToLoad: (ad, err) {
          ad.dispose();
          _ad = null;
        },
      ),
    )..load();
  }

  @override
  void dispose() {
    _ad?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (AppState.instance.premium || !_loaded || _ad == null) return const SizedBox.shrink();
    return SafeArea(
      top: false,
      child: SizedBox(
        width: _ad!.size.width.toDouble(),
        height: _ad!.size.height.toDouble(),
        child: AdWidget(ad: _ad!),
      ),
    );
  }
}
