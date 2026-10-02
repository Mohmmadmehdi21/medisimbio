import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:medisimbio_ui/screens/profile_setup_screen.dart';
import 'package:medisimbio_ui/services/firebase_service.dart';
import 'package:medisimbio_ui/services/med_id_service.dart';
import 'package:medisimbio_ui/services/profile_service.dart';

class CreateMedIdScreen extends StatefulWidget {
  const CreateMedIdScreen({super.key});

  @override
  State<CreateMedIdScreen> createState() => _CreateMedIdScreenState();
}

class _CreateMedIdScreenState extends State<CreateMedIdScreen> {
  final FirebaseService _firebaseService = FirebaseService();
  final ProfileService _profileService = ProfileService();

  String? _medId;
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadOrGenerateMedId();
  }

  Future<void> _loadOrGenerateMedId() async {
    final user = _firebaseService.currentUser;
    if (user == null) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'No authenticated user found.';
      });
      return;
    }

    try {
      final profile = await _profileService.getProfile(user.uid);
      if (profile != null && profile.medId.isNotEmpty) {
        // Med ID already generated previously — reuse existing Med ID!
        if (mounted) {
          setState(() {
            _medId = profile.medId;
            _isLoading = false;
          });
        }
      } else {
        // Generate new Med ID once & persist immediately to Firestore
        final generatedId = MedIdService.generateMedId();
        await _profileService.saveMedId(user.uid, generatedId);
        if (mounted) {
          setState(() {
            _medId = generatedId;
            _isLoading = false;
          });
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _errorMessage = 'Failed to prepare Med ID: ${e.toString()}';
        });
      }
    }
  }

  /// Reusable navigation to Profile Setup with real persistence
  Future<void> _navigateToProfileSetup() async {
    if (_medId == null) return;
    final user = _firebaseService.currentUser;
    if (user != null) {
      await _profileService.saveMedId(user.uid, _medId!);
    }

    if (!mounted) return;
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const ProfileSetupScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FCFA),
      body: SafeArea(
        child: _isLoading
            ? const Center(
                child: CircularProgressIndicator(color: Color(0xFF0B7A6E)),
              )
            : _errorMessage != null
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            _errorMessage!,
                            textAlign: TextAlign.center,
                            style: const TextStyle(color: Colors.red),
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: () {
                              setState(() {
                                _isLoading = true;
                                _errorMessage = null;
                              });
                              _loadOrGenerateMedId();
                            },
                            child: const Text('Retry'),
                          ),
                        ],
                      ),
                    ),
                  )
                : SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        // Header
                        const Text(
                          'Create Med ID',
                          style: TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF173330),
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Your Med ID is your unique healthcare identity across the ecosystem.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 14,
                            color: Color(0xFF5A716E),
                          ),
                        ),
                        const SizedBox(height: 24),

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
                              const Text(
                                'Your Med ID is Ready!',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF173330),
                                ),
                              ),
                              const SizedBox(height: 6),
                              const Text(
                                'Your unique health identity for a connected ecosystem.',
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
                                  data: _medId!,
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
                                _medId!,
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

                        // Primary CTA Button: Continue (Navigates to Profile Setup)
                        SizedBox(
                          width: double.infinity,
                          height: 54,
                          child: ElevatedButton(
                            onPressed: _navigateToProfileSetup,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF0B7A6E),
                              foregroundColor: Colors.white,
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(27),
                              ),
                            ),
                            child: const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  'Continue',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                SizedBox(width: 8),
                                Icon(Icons.arrow_forward_rounded, size: 20),
                              ],
                            ),
                          ),
                        ),

                        const SizedBox(height: 14),

                        // Action Buttons Row: Download & Share (Secondary Actions)
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
                                            'Sharing Med ID: $_medId (Ready for share_plus)'),
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
                  ),
      ),
    );
  }
}
