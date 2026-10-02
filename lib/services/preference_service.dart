import 'package:shared_preferences/shared_preferences.dart';

/// Local Preference Persistence Service for MediSimbio.
/// Manages persistent device preferences such as [hasSeenOnboarding].
class PreferenceService {
  static const String _keyHasSeenOnboarding = 'has_seen_onboarding';

  /// Check whether the user has completed or skipped the onboarding flow on this device.
  static Future<bool> hasSeenOnboarding() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getBool(_keyHasSeenOnboarding) ?? false;
    } catch (_) {
      return false;
    }
  }

  /// Mark onboarding as completed so it is not presented again on subsequent launches.
  static Future<void> setHasSeenOnboarding({bool value = true}) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_keyHasSeenOnboarding, value);
    } catch (_) {}
  }
}
