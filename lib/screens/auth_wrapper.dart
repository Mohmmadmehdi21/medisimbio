import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:medisimbio_ui/models/patient_profile.dart';
import 'package:medisimbio_ui/screens/create_med_id_screen.dart';
import 'package:medisimbio_ui/screens/home_screen.dart';
import 'package:medisimbio_ui/screens/login_screen.dart';
import 'package:medisimbio_ui/screens/onboarding_screen.dart';
import 'package:medisimbio_ui/screens/profile_setup_screen.dart';
import 'package:medisimbio_ui/services/firebase_service.dart';
import 'package:medisimbio_ui/services/preference_service.dart';
import 'package:medisimbio_ui/services/profile_service.dart';

/// Single source of truth for app startup & route guards:
/// 1. hasSeenOnboarding (persistent local preference)
/// 2. isAuthenticated (Firebase currentUser)
/// 3. hasMedId (persisted Firestore state)
/// 4. profileCompleted (persisted Firestore state)
class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    final firebaseService = FirebaseService();
    final profileService = ProfileService();

    return FutureBuilder<bool>(
      future: PreferenceService.hasSeenOnboarding(),
      builder: (context, onboardingSnapshot) {
        if (onboardingSnapshot.connectionState == ConnectionState.waiting) {
          return const _LoadingScaffold();
        }

        final hasSeenOnboarding = onboardingSnapshot.data ?? false;
        if (!hasSeenOnboarding) {
          return const OnboardingScreen();
        }

        // Onboarding completed — check Firebase Authentication state
        return StreamBuilder<User?>(
          stream: firebaseService.authStateChanges,
          builder: (context, authSnapshot) {
            if (authSnapshot.connectionState == ConnectionState.waiting) {
              return const _LoadingScaffold();
            }

            final user = authSnapshot.data;
            if (user == null) {
              return const LoginScreen();
            }

            // Authenticated user exists — stream profile state from Firestore
            return StreamBuilder<PatientProfile?>(
              stream: profileService.streamProfile(user.uid),
              builder: (context, profileSnapshot) {
                if (profileSnapshot.connectionState ==
                    ConnectionState.waiting) {
                  return const _LoadingScaffold();
                }

                final profile = profileSnapshot.data;

                // Step 1: Check Med ID existence (First-time creation requirement)
                if (profile == null || profile.medId.isEmpty) {
                  return const CreateMedIdScreen();
                }

                // Step 2: Check Profile Setup completion
                if (!profile.profileCompleted) {
                  return const ProfileSetupScreen();
                }

                // Step 3: All onboarding & setup completed -> Home Dashboard
                return const HomeScreen();
              },
            );
          },
        );
      },
    );
  }
}

class _LoadingScaffold extends StatelessWidget {
  const _LoadingScaffold();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Color(0xFFF8FCFA),
      body: Center(
        child: CircularProgressIndicator(
          color: Color(0xFF0B7A6E),
        ),
      ),
    );
  }
}
