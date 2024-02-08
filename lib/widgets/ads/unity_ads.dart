import 'package:flutter/material.dart';
import 'package:unity_ads_plugin/unity_ads_plugin.dart';

class UnityAdManager {
  static Future<void> loadUnityAd(String placementID) async {
    await UnityAds.load(
      placementId: placementID,
      onComplete: (placementId) => debugPrint('Load Complete $placementId'),
      onFailed: (placementId, error, message) =>
          debugPrint('Load Failed $placementId: $error $message'),
    );
  }

  static Future<void> showAds(String placementID) async {
    await UnityAds.showVideoAd(
      placementId: placementID,
      onStart: (placementId) => debugPrint('Video Ad $placementId started'),
      onClick: (placementId) => debugPrint('Video Ad $placementId click'),
      onSkipped: (placementId) => debugPrint('Video Ad $placementId skipped'),
      onComplete: (placementId) async {
        await loadUnityAd(placementID);
      },
      onFailed: (placementId, error, message) async {
        await loadUnityAd(placementID);
      },
    );
  }
}
