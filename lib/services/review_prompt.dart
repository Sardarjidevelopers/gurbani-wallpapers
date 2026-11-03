import 'package:flutter/foundation.dart';
import 'package:in_app_review/in_app_review.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Asks for a Play Store rating once, after the person has made a few
/// wallpapers. Uses Google's own in-app review dialog; nobody is rewarded for
/// rating and the person can simply dismiss it.
class ReviewPrompt {
  static const successesBeforeAsking = 3;
  static const countKey = 'wallpaper_successes';
  static const askedKey = 'review_requested';

  static Future<void> recordSuccess() async {
    if (kIsWeb) return;
    try {
      final prefs = await SharedPreferences.getInstance();
      if (prefs.getBool(askedKey) ?? false) return;
      final count = (prefs.getInt(countKey) ?? 0) + 1;
      await prefs.setInt(countKey, count);
      if (count < successesBeforeAsking) return;

      final review = InAppReview.instance;
      if (await review.isAvailable()) {
        await prefs.setBool(askedKey, true);
        await review.requestReview();
      }
    } catch (_) {
      // Never let a rating prompt get in the way of saving a wallpaper.
    }
  }
}
