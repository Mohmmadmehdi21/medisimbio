import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:medisimbio_ui/services/preference_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Phase 1N — Settings & Security Unit Tests', () {
    setUp(() {
      SharedPreferences.setMockInitialValues({});
    });

    test('PreferenceService handles Biometric lock state persistence', () async {
      final initialBio = await PreferenceService.isBiometricEnabled();
      expect(initialBio, isFalse);

      await PreferenceService.setBiometricEnabled(true);
      final updatedBio = await PreferenceService.isBiometricEnabled();
      expect(updatedBio, isTrue);

      await PreferenceService.setBiometricEnabled(false);
      final resetBio = await PreferenceService.isBiometricEnabled();
      expect(resetBio, isFalse);
    });

    test('PreferenceService handles App Language persistence', () async {
      final defaultLang = await PreferenceService.getSelectedLanguage();
      expect(defaultLang, equals('English (US)'));

      await PreferenceService.setSelectedLanguage('Spanish');
      final spanishLang = await PreferenceService.getSelectedLanguage();
      expect(spanishLang, equals('Spanish'));

      await PreferenceService.setSelectedLanguage('Hindi');
      final hindiLang = await PreferenceService.getSelectedLanguage();
      expect(hindiLang, equals('Hindi'));
    });
  });
}
