import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:medisimbio_ui/models/patient_profile.dart';
import 'package:medisimbio_ui/services/firebase_service.dart';
import 'package:medisimbio_ui/services/profile_service.dart';

/// Dedicated screen for displaying an existing user's Med ID details.
/// Opened via Profile -> Med ID Card.
/// Does NOT generate a new Med ID and does NOT route into registration/profile setup.
class ExistingMedIdScreen extends StatelessWidget {
  const ExistingMedIdScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final firebaseService = FirebaseService();
    final profileService = ProfileService();
    final user = firebaseService.currentUser;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FCFA),
      appBar: AppBar(
        title: const Text(
          'My Med ID',
          style: TextStyle(
            color: Color(0xFF173330),
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Color(0xFF173330)),
      ),
      body: SafeArea(
        child: user == null
            ? const Center(child: Text('No authenticated user'))
            : StreamBuilder<PatientProfile?>(
                stream: profileService.streamProfile(user.uid),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                      child:
                          CircularProgressIndicator(color: Color(0xFF0B7A6E)),
                    );
                  }

                  final profile = snapshot.data;
                  final medId = (profile?.medId.isNotEmpty == true)
                      ? profile!.medId
                      : 'MD-XXXX-XXXX';
                  final name = (profile?.name.isNotEmpty == true)
                      ? profile!.name
                      : (user.displayName ?? 'Patient');

                  return SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        // Main Card
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(24),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withAlpha(12),
                                blurRadius: 20,
                                offset: const Offset(0, 6),
                              ),
                            ],
                            border: Border.all(color: const Color(0xFFE2EEEA)),
                          ),
                          child: Column(
                            children: [
                              Text(
                                name,
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF173330),
                                ),
                              ),
                              const SizedBox(height: 4),
                              const Text(
                                'Official MediSimbio Healthcare Identity',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 13,
                                  color: Color(0xFF5A716E),
                                ),
                              ),
                              const SizedBox(height: 24),

                              // QR Code Container
                              Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(
                                      color: const Color(0xFFD9E4E1)),
                                ),
                                child: QrImageView(
                                  data: medId,
                                  version: QrVersions.auto,
                                  size: 200.0,
                                  backgroundColor: Colors.white,
                                  eyeStyle: const QrEyeStyle(
                                    eyeShape: QrEyeShape.square,
                                    color: Color(0xFF0B7A6E),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 20),

                              // Med ID Text
                              Text(
                                medId,
                                style: const TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 1.5,
                                  color: Color(0xFF173330),
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 28),

                        // Action Buttons Row: Download & Share
                        Row(
                          children: [
                            Expanded(
                              child: SizedBox(
                                height: 48,
                                child: OutlinedButton.icon(
                                  onPressed: () {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text(
                                            'QR code downloaded successfully!'),
                                      ),
                                    );
                                  },
                                  icon: const Icon(Icons.download_outlined,
                                      size: 18),
                                  label: const Text(
                                    'Download',
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  style: OutlinedButton.styleFrom(
                                    foregroundColor: const Color(0xFF0B7A6E),
                                    side: const BorderSide(
                                        color: Color(0xFF0B7A6E), width: 1.5),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(24),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: SizedBox(
                                height: 48,
                                child: OutlinedButton.icon(
                                  onPressed: () {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(
                                            'Sharing Med ID: $medId (Ready for share_plus)'),
                                      ),
                                    );
                                  },
                                  icon: const Icon(Icons.share_outlined,
                                      size: 18),
                                  label: const Text(
                                    'Share',
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  style: OutlinedButton.styleFrom(
                                    foregroundColor: const Color(0xFF0B7A6E),
                                    side: const BorderSide(
                                        color: Color(0xFF0B7A6E), width: 1.5),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(24),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                },
              ),
      ),
    );
  }
}
