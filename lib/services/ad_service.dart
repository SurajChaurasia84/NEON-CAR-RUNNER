import 'package:unity_ads_plugin/unity_ads_plugin.dart';

class AdService {
  // Original IDs as provided by the user
  static const String androidGameId = '6091434'; 
  
  static const String rewardedPlacement = 'Rewarded_Android';
  static const String interstitialPlacement = 'Interstitial_Android';
  static const String bannerPlacement = 'Banner_Android';

  static Future<void> init() async {
    print('DEBUG: Initializing Unity Ads for Android Only...');
    print('DEBUG: Using Game ID: $androidGameId');
    
    await UnityAds.init(
      gameId: androidGameId,
      testMode: false, // MUST be true for non-live apps
      onComplete: () {
        print('SUCCESS: Unity Ads Initialized for Android: $androidGameId');
        loadRewardedAd();
        loadInterstitialAd();
      },
      onFailed: (error, message) {
        print('ERROR: Unity Ads Initialization FAILED for ID: $androidGameId');
        print('ERROR TYPE: $error');
        print('ERROR MESSAGE: $message');
      },
    );
  }

  static Future<void> loadRewardedAd() async {
    print('DEBUG: Loading Rewarded Ad ($rewardedPlacement)...');
    await UnityAds.load(
      placementId: rewardedPlacement,
      onComplete: (placementId) => print('SUCCESS: Rewarded Ad Loaded: $placementId'),
      onFailed: (placementId, error, message) => print('ERROR: Rewarded Ad ($placementId) Load Failed: $error $message'),
    );
  }

  static void showRewardedAd({required Function onRewardComplete}) {
    UnityAds.showVideoAd(
      placementId: rewardedPlacement,
      onComplete: (placementId) {
        print('SUCCESS: Rewarded Ad Completed');
        onRewardComplete();
        loadRewardedAd();
      },
      onFailed: (placementId, error, message) {
        print('ERROR: Rewarded Ad Show Failed: $error $message');
        loadRewardedAd();
      },
      onSkipped: (placementId) {
        print('INFO: Rewarded Ad Skipped');
        loadRewardedAd();
      },
    );
  }

  static Future<void> loadInterstitialAd() async {
    await UnityAds.load(
      placementId: interstitialPlacement,
      onComplete: (placementId) => print('SUCCESS: Interstitial Ad Loaded: $placementId'),
      onFailed: (placementId, error, message) => print('ERROR: Interstitial Ad ($placementId) Load Failed: $error $message'),
    );
  }

  static void showInterstitialAd() {
    UnityAds.showVideoAd(
      placementId: interstitialPlacement,
      onComplete: (placementId) {
        loadInterstitialAd();
      },
      onFailed: (placementId, error, message) {
        loadInterstitialAd();
      },
      onSkipped: (placementId) {
        loadInterstitialAd();
      },
    );
  }
}
