import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class AdsHelper {
  static bool showAds = false;

  static Future<void> initialize() async {
    await MobileAds.instance.initialize();
  }

  // ✅ Banner Ad
  // static BannerAd? loadBannerAd({
  //   required void Function(Ad) onAdLoaded,
  //   required void Function(Ad, LoadAdError) onAdFailed,
  // }) async {
  //   if (!showAds) {
  //     // Ads disabled — don't even create/load a banner
  //     return null;
  //   }
  //
  //   final banner = BannerAd(
  //     adUnitId: "ca-app-pub-9644497797156593/6446465481",
  //     size: AdSize.banner,
  //     request: const AdRequest(),
  //     listener: BannerAdListener(
  //       onAdLoaded: onAdLoaded,
  //       onAdFailedToLoad: onAdFailed,
  //     ),
  //   )..load();
  //   return banner;
  // }

  static BannerAd? loadBannerAd({
    required void Function(Ad) onAdLoaded,
    required void Function(Ad, LoadAdError) onAdFailed,
    String adUnitId = "ca-app-pub-9644497797156593/6446465481",
    AdSize size = AdSize.banner,
    AdRequest request = const AdRequest(),
  }) {
    if (!showAds) {
      return null;
    }

    final banner = BannerAd(
      adUnitId: adUnitId,
      size: size,
      request: request,
      listener: BannerAdListener(
        onAdLoaded: onAdLoaded,
        onAdFailedToLoad: onAdFailed,
      ),
    )..load();

    return banner;
  }

  static Future<void> showInterstitialAd({
    VoidCallback? onDismissed,
    VoidCallback? onFailedToLoad,
    String adUnitId = "ca-app-pub-9644497797156593/5787989934",
    AdRequest request = const AdRequest(),
  }) async {
    if (!showAds) {
      // Skip ad flow and continue the app logic
      onDismissed?.call();
      return;
    }

    await InterstitialAd.load(
      adUnitId: adUnitId,
      request: request,
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (InterstitialAd ad) {
          ad.fullScreenContentCallback = FullScreenContentCallback(
            onAdDismissedFullScreenContent: (ad) {
              ad.dispose();
              onDismissed?.call();
            },
            onAdFailedToShowFullScreenContent: (ad, error) {
              ad.dispose();
              onFailedToLoad?.call();
            },
          );
          ad.show();
        },
        onAdFailedToLoad: (LoadAdError error) {
          debugPrint('Interstitial failed to load: $error');
          onFailedToLoad?.call();
        },
      ),
    );
  }

  static Future<void> showRewardedAd({
    required Function(RewardItem reward) onRewardEarned,
    String adUnitId = "ca-app-pub-9644497797156593/3342608232",
    AdRequest request = const AdRequest(),
  }) async {
    if (!showAds) {
      // Ads disabled — no reward is granted automatically
      // (If you want to grant a synthetic reward, handle it in the caller)
      return;
    }

    await RewardedAd.load(
      adUnitId: adUnitId,
      request: request,
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: (RewardedAd ad) {
          ad.fullScreenContentCallback = FullScreenContentCallback(
            onAdDismissedFullScreenContent: (ad) {
              ad.dispose();
            },
            onAdFailedToShowFullScreenContent: (ad, error) {
              ad.dispose();
            },
          );
          ad.show(onUserEarnedReward: (ad, reward) {
            onRewardEarned(reward);
          });
        },
        onAdFailedToLoad: (LoadAdError error) {
          debugPrint('RewardedAd failed to load: $error');
        },
      ),
    );
  }

  // ✅ Interstitial Ad
  // static Future<void> showInterstitialAd({
  //   VoidCallback? onDismissed,
  //   VoidCallback? onFailedToLoad,
  // }) async {
  //   await InterstitialAd.load(
  //     adUnitId: "ca-app-pub-9644497797156593/5787989934",
  //     request: const AdRequest(),
  //     adLoadCallback: InterstitialAdLoadCallback(
  //       onAdLoaded: (InterstitialAd ad) {
  //         ad.fullScreenContentCallback = FullScreenContentCallback(
  //           onAdDismissedFullScreenContent: (ad) {
  //             ad.dispose();
  //             onDismissed?.call();
  //           },
  //           onAdFailedToShowFullScreenContent: (ad, error) {
  //             ad.dispose();
  //             onFailedToLoad?.call(); // fallback
  //           },
  //         );
  //         ad.show();
  //       },
  //       onAdFailedToLoad: (LoadAdError error) {
  //         debugPrint('Interstitial failed: $error');
  //         onFailedToLoad?.call(); // fallback
  //       },
  //     ),
  //   );
  // }
  //
  // // ✅ Rewarded Ad (e.g. earn hearts, streak freeze, etc.)
  // static Future<void> showRewardedAd({
  //   required Function(RewardItem reward) onRewardEarned,
  // }) async {
  //   await RewardedAd.load(
  //     adUnitId: "ca-app-pub-9644497797156593/3342608232",
  //     request: const AdRequest(),
  //     rewardedAdLoadCallback: RewardedAdLoadCallback(
  //       onAdLoaded: (RewardedAd ad) {
  //         ad.fullScreenContentCallback = FullScreenContentCallback(
  //           onAdDismissedFullScreenContent: (ad) {
  //             ad.dispose();
  //           },
  //           onAdFailedToShowFullScreenContent: (ad, error) {
  //             ad.dispose();
  //           },
  //         );
  //         ad.show(onUserEarnedReward: (ad, reward) {
  //           onRewardEarned(reward);
  //         });
  //       },
  //       onAdFailedToLoad: (LoadAdError error) {
  //         debugPrint('RewardedAd failed to load: $error');
  //       },
  //     ),
  //   );
  // }
}

class BannerAdWidget extends StatefulWidget {
  const BannerAdWidget({super.key});

  @override
  State<BannerAdWidget> createState() => _BannerAdWidgetState();
}

class _BannerAdWidgetState extends State<BannerAdWidget> {
  BannerAd? _bannerAd;

  @override
  void initState() {
    super.initState();
    _bannerAd = AdsHelper.loadBannerAd(
      onAdLoaded: (ad) => setState(() {}),
      onAdFailed: (ad, error) => ad.dispose(),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_bannerAd == null) return const SizedBox.shrink();
    return Container(
      alignment: Alignment.center,
      width: _bannerAd!.size.width.toDouble(),
      height: _bannerAd!.size.height.toDouble(),
      child: AdWidget(ad: _bannerAd!),
    );
  }

  @override
  void dispose() {
    _bannerAd?.dispose();
    super.dispose();
  }
}
