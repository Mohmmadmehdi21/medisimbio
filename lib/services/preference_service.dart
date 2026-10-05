import 'package:shared_preferences/shared_preferences.dart';

/// Local Preference Persistence Service for MediSimbio.
/// Manages persistent device preferences such as [hasSeenOnboarding], [isBiometricEnabled], and [getSelectedLanguage].
class PreferenceService {
  static const String _keyHasSeenOnboarding = 'has_seen_onboarding';
  static const String _keyBiometricEnabled = 'biometric_enabled';
  static const String _keySelectedLanguage = 'selected_language';

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

  /// Check whether biometric security lock is enabled for this device.
  static Future<bool> isBiometricEnabled() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getBool(_keyBiometricEnabled) ?? false;
    } catch (_) {
      return false;
    }
  }

  /// Set biometric security lock preference.
  static Future<void> setBiometricEnabled(bool enabled) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_keyBiometricEnabled, enabled);
    } catch (_) {}
  }

  /// Get currently selected app language.
  static Future<String> getSelectedLanguage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString(_keySelectedLanguage) ?? 'English (US)';
    } catch (_) {
      return 'English (US)';
    }
  }

  /// Set selected app language preference.
  static Future<void> setSelectedLanguage(String language) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_keySelectedLanguage, language);
    } catch (_) {}
  }
}
