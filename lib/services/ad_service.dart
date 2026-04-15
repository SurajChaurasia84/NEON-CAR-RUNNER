import 'package:unity_ads_plugin/unity_ads_plugin.dart';

class AdService {
  static const String gameIdAndroid = '4123456'; // Placeholder Android Game ID
  static const String gameIdIOS = '4123457';     // Placeholder iOS Game ID
  
  static const String rewardedAndroid = 'Rewarded_Android';
  static const String interstitialAndroid = 'Interstitial_Android';

  static Future<void> init() async {
    await UnityAds.init(
      gameId: gameIdAndroid, // In a real app, use logic to switch based on platform
      testMode: true,
      onComplete: () => print('Unity Ads Initialized'),
      onFailed: (error, message) => print('Unity Ads Failed: $error $message'),
    );
  }

  static Future<void> loadRewardedAd() async {
    await UnityAds.load(
      placementId: rewardedAndroid,
      onComplete: (placementId) => print('Rewarded Ad Loaded'),
      onFailed: (placementId, error, message) => print('Rewarded Ad Failed: $error $message'),
    );
  }

  static void showRewardedAd({required Function onRewardComplete}) {
    UnityAds.showVideoAd(
      placementId: rewardedAndroid,
      onComplete: (placementId) {
        print('Rewarded Ad Completed');
        onRewardComplete();
        loadRewardedAd(); // Load next ad
      },
      onFailed: (placementId, error, message) {
        print('Rewarded Ad Failed to Show: $error $message');
        loadRewardedAd();
      },
      onSkipped: (placementId) {
        print('Rewarded Ad Skipped');
        loadRewardedAd();
      },
    );
  }

  static Future<void> loadInterstitialAd() async {
    await UnityAds.load(
      placementId: interstitialAndroid,
      onComplete: (placementId) => print('Interstitial Ad Loaded'),
      onFailed: (placementId, error, message) => print('Interstitial Ad Failed: $error $message'),
    );
  }

  static void showInterstitialAd() {
    UnityAds.showVideoAd(
      placementId: interstitialAndroid,
      onComplete: (placementId) {
        print('Interstitial Ad Completed');
        loadInterstitialAd();
      },
      onFailed: (placementId, error, message) {
        print('Interstitial Ad Failed to Show: $error $message');
        loadInterstitialAd();
      },
      onSkipped: (placementId) {
        print('Interstitial Ad Skipped');
        loadInterstitialAd();
      },
    );
  }
}
