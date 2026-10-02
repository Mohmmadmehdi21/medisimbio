import 'package:flutter/material.dart';
import 'package:medisimbio_ui/screens/auth_wrapper.dart';
import 'package:medisimbio_ui/screens/profile_sub_screens.dart';
import 'package:medisimbio_ui/services/firebase_service.dart';
import 'package:medisimbio_ui/services/profile_service.dart';

class ProfileSetupScreen extends StatefulWidget {
  const ProfileSetupScreen({super.key});

  @override
  State<ProfileSetupScreen> createState() => _ProfileSetupScreenState();
}

class _ProfileSetupScreenState extends State<ProfileSetupScreen> {
  final FirebaseService _firebaseService = FirebaseService();
  final ProfileService _profileService = ProfileService();
  bool _isSaving = false;

  Future<void> _completeProfileSetup() async {
    final user = _firebaseService.currentUser;
    if (user == null) return;

    setState(() => _isSaving = true);

    try {
      // Mark profile setup as completed in Firestore
      await _profileService.setProfileCompleted(user.uid, completed: true);

      if (!mounted) return;
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const AuthWrapper()),
        (route) => false,
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to save profile setup: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FCFA),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              const Text(
                'Complete Your Profile',
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF173330),
                ),
              ),
              const SizedBox(height: 6),
              const Text(
                'Add your details to personalize your healthcare experience.',
                style: TextStyle(
                  fontSize: 14,
                  color: Color(0xFF5A716E),
                ),
              ),
              const SizedBox(height: 24),

              // 5 Profile Setup Cards
              Expanded(
                child: ListView(
                  children: [
                    _ProfileItemCard(
                      icon: Icons.person_outline,
                      iconColor: const Color(0xFF0B7A6E),
                      backgroundColor: const Color(0xFF0B7A6E).withAlpha(25),
                      title: 'Personal Information',
                      subtitle: 'Name, DOB and basic details',
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) =>
                                  const PersonalInformationScreen()),
                        );
                      },
                    ),
                    const SizedBox(height: 12),
                    _ProfileItemCard(
                      icon: Icons.medical_services_outlined,
                      iconColor: Colors.amber.shade800,
                      backgroundColor: Colors.amber.shade100.withAlpha(100),
                      title: 'Health Information',
                      subtitle: 'Blood group, allergies and health details',
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) => const HealthInformationScreen()),
                        );
                      },
                    ),
                    const SizedBox(height: 12),
                    _ProfileItemCard(
                      icon: Icons.contact_emergency_outlined,
                      iconColor: Colors.deepOrange,
                      backgroundColor: Colors.orange.shade100.withAlpha(100),
                      title: 'Emergency Contact',
                      subtitle: 'Someone we can contact in an emergency',
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) => const EmergencyContactScreen()),
                        );
                      },
                    ),
                    const SizedBox(height: 12),
                    _ProfileItemCard(
                      icon: Icons.settings_outlined,
                      iconColor: Colors.purple,
                      backgroundColor: Colors.purple.shade100.withAlpha(100),
                      title: 'Preferences',
                      subtitle: 'Language and app preferences',
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) => const PreferencesScreen()),
                        );
                      },
                    ),
                    const SizedBox(height: 12),
                    _ProfileItemCard(
                      icon: Icons.camera_alt_outlined,
                      iconColor: Colors.blue,
                      backgroundColor: Colors.blue.shade100.withAlpha(100),
                      title: 'Profile Photo',
                      subtitle: 'Add your profile picture',
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) => const ProfilePhotoScreen()),
                        );
                      },
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // Continue Button
              SizedBox(
                width: double.infinity,
                height: 54,
                child: ElevatedButton(
                  onPressed: _isSaving ? null : _completeProfileSetup,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0B7A6E),
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(27),
                    ),
                  ),
                  child: _isSaving
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'Continue to Home',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            SizedBox(width: 8),
                            Icon(Icons.arrow_forward, size: 20),
                          ],
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ProfileItemCard extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final Color backgroundColor;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _ProfileItemCard({
    required this.icon,
    required this.iconColor,
    required this.backgroundColor,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFE2EEEA)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(6),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: backgroundColor,
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: iconColor, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF173330),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFF5A716E),
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.arrow_forward_ios,
              size: 16,
              color: Color(0xFF8C9E9A),
            ),
          ],
        ),
      ),
    );
  }
}
