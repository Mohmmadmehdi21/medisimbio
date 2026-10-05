import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:medisimbio_ui/models/emergency_qr_record.dart';
import 'package:medisimbio_ui/models/patient_profile.dart';
import 'package:medisimbio_ui/services/emergency_qr_service.dart';
import 'package:medisimbio_ui/services/firebase_service.dart';
import 'package:medisimbio_ui/services/profile_service.dart';

/// Screen 1: Main Emergency QR Screen
class EmergencyQrScreen extends StatefulWidget {
  const EmergencyQrScreen({super.key});

  @override
  State<EmergencyQrScreen> createState() => _EmergencyQrScreenState();
}

class _EmergencyQrScreenState extends State<EmergencyQrScreen> {
  final FirebaseService _firebaseService = FirebaseService();
  final ProfileService _profileService = ProfileService();
  final EmergencyQrService _qrService = EmergencyQrService();

  bool _isLoading = true;
  bool _isRegenerating = false;
  String? _errorMessage;
  EmergencyQrRecord? _qrRecord;
  PatientProfile? _profile;

  @override
  void initState() {
    super.initState();
    _loadQrData();
  }

  Future<void> _loadQrData() async {
    final user = _firebaseService.currentUser;
    if (user == null) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _errorMessage = 'No authenticated user session found.';
        });
      }
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      _profile = await _profileService.getProfile(user.uid);
      final medId = _profile?.medId.isNotEmpty == true
          ? _profile!.medId
          : 'MD-PENDING';

      _qrRecord = await _qrService.getOrCreateEmergencyQr(
        user.uid,
        medId: medId,
      );
    } catch (e) {
      _errorMessage = 'Unable to load Emergency QR. Please try again.';
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _regenerateQr() async {
    final user = _firebaseService.currentUser;
    if (user == null) return;

    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: const Text(
          'Rotate Emergency QR?',
          style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF173330)),
        ),
        content: const Text(
          'This will invalidate your current QR reference and issue a new secure identity token for first responders.',
          style: TextStyle(color: Color(0xFF5A716E), fontSize: 13),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel', style: TextStyle(color: Color(0xFF5A716E))),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF0B7A6E),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text('Regenerate'),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    setState(() => _isRegenerating = true);
    try {
      final medId = _profile?.medId.isNotEmpty == true
          ? _profile!.medId
          : 'MD-PENDING';

      final fresh = await _qrService.regenerateEmergencyQr(
        user.uid,
        medId: medId,
      );

      if (mounted) {
        setState(() => _qrRecord = fresh);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Emergency QR rotated and updated successfully.'),
            backgroundColor: Color(0xFF0B7A6E),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to regenerate Emergency QR.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isRegenerating = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FCFA),
      appBar: AppBar(
        title: const Text(
          'Emergency QR',
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
        child: _isLoading
            ? const Center(
                child: CircularProgressIndicator(color: Color(0xFF0B7A6E)),
              )
            : _errorMessage != null
                ? _ErrorStateWidget(
                    message: _errorMessage!,
                    onRetry: _loadQrData,
                  )
                : SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      children: [
                        // HEADER BANNER
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(18),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                Colors.red.shade700,
                                Colors.red.shade900,
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.red.withAlpha(50),
                                blurRadius: 12,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: Colors.white.withAlpha(40),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.qr_code_2_outlined,
                                  color: Colors.white,
                                  size: 32,
                                ),
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'Emergency Identity QR',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      'Scan this QR to access limited emergency information through MediSimbio\'s secure emergency access system.',
                                      style: TextStyle(
                                        color: Colors.white.withAlpha(230),
                                        fontSize: 12,
                                        height: 1.3,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 24),

                        // MAIN QR CARD
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(24),
                            border: Border.all(color: const Color(0xFFE2EEEA)),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withAlpha(10),
                                blurRadius: 16,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Column(
                            children: [
                              Text(
                                _profile?.name.isNotEmpty == true
                                    ? _profile!.name
                                    : 'Patient',
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF173330),
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Med ID: ${_qrRecord?.medId ?? "MD-PENDING"}',
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF0B7A6E),
                                ),
                              ),

                              const SizedBox(height: 20),

                              // QR CODE VIEW
                              Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(color: const Color(0xFFD9E4E1)),
                                  boxShadow: [
                                    BoxShadow(
                                      color: const Color(0xFF0B7A6E).withAlpha(15),
                                      blurRadius: 12,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: QrImageView(
                                  data: _qrRecord?.qrPayload ??
                                      'medisimbio://emergency/qr/unavailable',
                                  version: QrVersions.auto,
                                  size: 190.0,
                                  dataModuleStyle: const QrDataModuleStyle(
                                    dataModuleShape: QrDataModuleShape.square,
                                    color: Color(0xFF0B7A6E),
                                  ),
                                  eyeStyle: const QrEyeStyle(
                                    eyeShape: QrEyeShape.square,
                                    color: Color(0xFF0B7A6E),
                                  ),
                                  embeddedImageStyle: const QrEmbeddedImageStyle(
                                    size: Size(30, 30),
                                  ),
                                ),
                              ),

                              const SizedBox(height: 18),

                              // REFERENCE ID & STATUS BADGE
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  _StatusBadge(
                                    status: _qrRecord?.effectiveStatus ??
                                        EmergencyQrStatus.active,
                                  ),
                                  const SizedBox(width: 8),
                                  Flexible(
                                    child: Text(
                                      'Ref: ${_qrRecord?.emergencyQrId ?? ""}',
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                        fontSize: 11,
                                        color: Color(0xFF5A716E),
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 20),

                        // PRIVACY DISCLOSURE CARD
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: const Color(0xFFE2EEEA)),
                          ),
                          child: const Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Icon(
                                Icons.privacy_tip_outlined,
                                color: Color(0xFF0B7A6E),
                                size: 22,
                              ),
                              SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Zero Raw Data Embedding',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 14,
                                        color: Color(0xFF173330),
                                      ),
                                    ),
                                    SizedBox(height: 4),
                                    Text(
                                      'This QR contains only a secure reference identity token. Full medical records, prescriptions, and lab reports are NOT stored in the QR code.',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Color(0xFF5A716E),
                                        height: 1.4,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 24),

                        // ACTION BUTTONS
                        Row(
                          children: [
                            Expanded(
                              child: OutlinedButton.icon(
                                onPressed: _isRegenerating ? null : _regenerateQr,
                                icon: const Icon(Icons.sync, size: 18),
                                label: _isRegenerating
                                    ? const SizedBox(
                                        height: 16,
                                        width: 16,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          color: Color(0xFF0B7A6E),
                                        ),
                                      )
                                    : const Text(
                                        'Rotate QR',
                                        style: TextStyle(fontWeight: FontWeight.bold),
                                      ),
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: const Color(0xFF0B7A6E),
                                  side: const BorderSide(color: Color(0xFF0B7A6E)),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(14),
                                  ),
                                  padding: const EdgeInsets.symmetric(vertical: 14),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: ElevatedButton.icon(
                                onPressed: () {
                                  if (_profile != null && _qrRecord != null) {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) => EmergencyPolicyPreviewScreen(
                                          profile: _profile!,
                                          record: _qrRecord!,
                                        ),
                                      ),
                                    );
                                  }
                                },
                                icon: const Icon(Icons.visibility_outlined, size: 18),
                                label: const Text(
                                  'View Info Policy',
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF0B7A6E),
                                  foregroundColor: Colors.white,
                                  elevation: 0,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(14),
                                  ),
                                  padding: const EdgeInsets.symmetric(vertical: 14),
                                ),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 12),

                        // TEST SCANNER SIMULATION BUTTON
                        SizedBox(
                          width: double.infinity,
                          child: TextButton.icon(
                            onPressed: () {
                              if (_profile != null && _qrRecord != null) {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => EmergencyQrScannerSimulatorScreen(
                                      qrRecord: _qrRecord!,
                                      patientProfile: _profile!,
                                    ),
                                  ),
                                );
                              }
                            },
                            icon: const Icon(Icons.security, size: 16),
                            label: const Text('Simulate Provider Scan Verification'),
                            style: TextButton.styleFrom(
                              foregroundColor: const Color(0xFF5A716E),
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

/// Screen 2: Policy Preview — What an authorized provider can access under emergency policy
class EmergencyPolicyPreviewScreen extends StatelessWidget {
  final PatientProfile profile;
  final EmergencyQrRecord record;

  const EmergencyPolicyPreviewScreen({
    super.key,
    required this.profile,
    required this.record,
  });

  @override
  Widget build(BuildContext context) {
    final medId = profile.medId.isNotEmpty ? profile.medId : record.medId;
    final bloodGroup = profile.bloodGroup.isNotEmpty ? profile.bloodGroup : 'Not Available';
    final allergies = profile.allergies.isNotEmpty ? profile.allergies : 'None Reported';
    final conditions = profile.existingConditions.isNotEmpty ? profile.existingConditions : 'None Reported';
    final emergencyName = profile.emergencyName.isNotEmpty ? profile.emergencyName : 'Not Set';
    final emergencyRel = profile.emergencyRelationship.isNotEmpty ? profile.emergencyRelationship : '';
    final emergencyMobile = profile.emergencyMobile.isNotEmpty ? profile.emergencyMobile : 'Not Set';

    return Scaffold(
      backgroundColor: const Color(0xFFF8FCFA),
      appBar: AppBar(
        title: const Text(
          'Emergency Information Policy',
          style: TextStyle(
            color: Color(0xFF173330),
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Color(0xFF173330)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        physics: const BouncingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF0B7A6E).withAlpha(15),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFF0B7A6E).withAlpha(40)),
              ),
              child: const Row(
                children: [
                  Icon(Icons.policy_outlined, color: Color(0xFF0B7A6E), size: 24),
                  SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Minimum Necessary Emergency Policy',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                            color: Color(0xFF173330),
                          ),
                        ),
                        SizedBox(height: 2),
                        Text(
                          'Authorized first responders only see vital emergency contact and critical medical alerts.',
                          style: TextStyle(fontSize: 12, color: Color(0xFF5A716E)),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // ALLOWED EMERGENCY FIELDS LIST
            _InfoTile(
              icon: Icons.qr_code_2,
              iconColor: const Color(0xFF0B7A6E),
              title: 'Med ID Reference',
              value: medId,
            ),
            const SizedBox(height: 12),

            _InfoTile(
              icon: Icons.bloodtype_outlined,
              iconColor: Colors.red,
              title: 'Blood Group',
              value: bloodGroup,
            ),
            const SizedBox(height: 12),

            _InfoTile(
              icon: Icons.warning_amber_rounded,
              iconColor: Colors.amber.shade800,
              title: 'Critical Allergies',
              value: allergies,
            ),
            const SizedBox(height: 12),

            _InfoTile(
              icon: Icons.healing_outlined,
              iconColor: Colors.purple,
              title: 'Important Conditions',
              value: conditions,
            ),
            const SizedBox(height: 12),

            _InfoTile(
              icon: Icons.contact_emergency_outlined,
              iconColor: Colors.deepOrange,
              title: 'Emergency Contact',
              value: emergencyRel.isNotEmpty
                  ? '$emergencyName ($emergencyRel) • $emergencyMobile'
                  : '$emergencyName • $emergencyMobile',
            ),

            const SizedBox(height: 24),

            // LOCKED / PROTECTED DATA DISCLOSURE
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: const Color(0xFFE2EEEA)),
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.lock, color: Colors.green, size: 20),
                      SizedBox(width: 8),
                      Text(
                        'Strictly Protected Data Categories',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                          color: Color(0xFF173330),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 10),
                  Text(
                    'The following records remain LOCKED and require explicit Phase 1K patient consent:',
                    style: TextStyle(fontSize: 12, color: Color(0xFF5A716E)),
                  ),
                  SizedBox(height: 8),
                  _ProtectedItem(label: 'Full Medical Records & Clinical Notes'),
                  _ProtectedItem(label: 'Doctor Prescriptions & Medication Logs'),
                  _ProtectedItem(label: 'Laboratory Test Results & Diagnostic Reports'),
                  _ProtectedItem(label: 'Pharmacy History & Dispensing Records'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Screen 3: Test Scanner Simulator — Verification for Provider Authorization & Fail-Closed Behavior
class EmergencyQrScannerSimulatorScreen extends StatefulWidget {
  final EmergencyQrRecord qrRecord;
  final PatientProfile patientProfile;

  const EmergencyQrScannerSimulatorScreen({
    super.key,
    required this.qrRecord,
    required this.patientProfile,
  });

  @override
  State<EmergencyQrScannerSimulatorScreen> createState() =>
      _EmergencyQrScannerSimulatorScreenState();
}

class _EmergencyQrScannerSimulatorScreenState
    extends State<EmergencyQrScannerSimulatorScreen> {
  final EmergencyQrService _qrService = EmergencyQrService();
  String _selectedRole = 'PARAMEDIC';
  bool _isResolving = false;
  LimitedEmergencyInfo? _resolvedInfo;
  String? _accessError;

  Future<void> _simulateScan() async {
    setState(() {
      _isResolving = true;
      _resolvedInfo = null;
      _accessError = null;
    });

    try {
      final info = await _qrService.resolveEmergencyQr(
        emergencyQrId: widget.qrRecord.emergencyQrId,
        patientId: widget.qrRecord.patientId,
        requesterId: _selectedRole == 'PARAMEDIC' ? 'REQ-PARAMEDIC-01' : 'REQ-GUEST',
        requesterRole: _selectedRole,
      );

      if (mounted) {
        setState(() => _resolvedInfo = info);
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _accessError = e.toString().replaceAll('Exception: ', '');
        });
      }
    } finally {
      if (mounted) setState(() => _isResolving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FCFA),
      appBar: AppBar(
        title: const Text(
          'Provider Scan Simulation',
          style: TextStyle(
            color: Color(0xFF173330),
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Color(0xFF173330)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Simulate Emergency QR Scan Resolution',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Color(0xFF173330),
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              'Test how MediSimbio backend policies verify scanner identity and fail closed when unauthorized.',
              style: TextStyle(fontSize: 12, color: Color(0xFF5A716E)),
            ),

            const SizedBox(height: 18),

            // ROLE SELECTION DROPDOWN
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: const Color(0xFFE2EEEA)),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: _selectedRole,
                  isExpanded: true,
                  onChanged: (val) {
                    if (val != null) {
                      setState(() {
                        _selectedRole = val;
                        _resolvedInfo = null;
                        _accessError = null;
                      });
                    }
                  },
                  items: const [
                    DropdownMenuItem(
                      value: 'PARAMEDIC',
                      child: Text('Authorized Paramedic / Responder'),
                    ),
                    DropdownMenuItem(
                      value: 'EMERGENCY_DOCTOR',
                      child: Text('Authorized Emergency Room Doctor'),
                    ),
                    DropdownMenuItem(
                      value: 'UNAUTHORIZED_USER',
                      child: Text('Unauthorized / Unknown Scanner'),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton.icon(
                onPressed: _isResolving ? null : _simulateScan,
                icon: const Icon(Icons.qr_code_scanner, color: Colors.white),
                label: _isResolving
                    ? const SizedBox(
                        height: 18,
                        width: 18,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : const Text(
                        'Simulate Scan Resolution',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0B7A6E),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 24),

            // SCAN RESULT DISPLAY
            if (_resolvedInfo != null)
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: const Color(0xFF0B7A6E).withAlpha(60)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withAlpha(8),
                      blurRadius: 10,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.verified, color: Color(0xFF0B7A6E), size: 22),
                        SizedBox(width: 8),
                        Text(
                          'Authorized Emergency Resolution',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                            color: Color(0xFF0B7A6E),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text('Patient: ${_resolvedInfo!.patientName}', style: const TextStyle(fontWeight: FontWeight.w600)),
                    Text('Med ID: ${_resolvedInfo!.medId}'),
                    Text('Blood Group: ${_resolvedInfo!.bloodGroup ?? "Not Available"}'),
                    Text('Allergies: ${_resolvedInfo!.allergies ?? "None Reported"}'),
                    Text('Conditions: ${_resolvedInfo!.existingConditions ?? "None Reported"}'),
                    Text('Emergency Contact: ${_resolvedInfo!.emergencyName ?? "Not Set"} (${_resolvedInfo!.emergencyMobile ?? ""})'),
                    const SizedBox(height: 8),
                    Text(
                      'Policy: ${_resolvedInfo!.policyName}',
                      style: const TextStyle(fontSize: 11, color: Color(0xFF8C9E9A)),
                    ),
                  ],
                ),
              ),

            if (_accessError != null)
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF2F2),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.red.shade200),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.block, color: Colors.red, size: 22),
                        SizedBox(width: 8),
                        Text(
                          'Access Denied (Failed Closed)',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                            color: Colors.red,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _accessError!,
                      style: const TextStyle(fontSize: 13, color: Color(0xFF900000)),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      '0 Bytes of patient medical data were exposed to the unauthorized scanner.',
                      style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.red),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _InfoTile extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String value;

  const _InfoTile({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2EEEA)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: iconColor.withAlpha(25),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: iconColor, size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontSize: 12, color: Color(0xFF5A716E)),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF173330),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ProtectedItem extends StatelessWidget {
  final String label;

  const _ProtectedItem({required this.label});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          const Icon(Icons.shield, color: Colors.green, size: 16),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: Color(0xFF173330),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final String status;

  const _StatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    Color bg;
    Color fg;
    String label = status;

    switch (status) {
      case EmergencyQrStatus.active:
        bg = const Color(0xFFE6F4F1);
        fg = const Color(0xFF0B7A6E);
        label = 'Active QR';
        break;
      case EmergencyQrStatus.disabled:
        bg = const Color(0xFFFEE2E2);
        fg = Colors.red;
        label = 'Disabled';
        break;
      case EmergencyQrStatus.expired:
      default:
        bg = const Color(0xFFF1F5F9);
        fg = Colors.blueGrey;
        label = 'Expired';
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: fg,
          fontSize: 11,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

class _ErrorStateWidget extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _ErrorStateWidget({
    required this.message,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(32.0),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              size: 48,
              color: Colors.red,
            ),
            const SizedBox(height: 16),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: Color(0xFF173330),
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh, color: Colors.white),
              label: const Text('Retry'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF0B7A6E),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
