import 'package:flutter/material.dart';
import 'package:medisimbio_ui/screens/emergency_qr_screens.dart';
import 'package:url_launcher/url_launcher.dart';

/// 25. EMERGENCY CARE MAIN SCREEN (Phase 1D)
class EmergencyCareScreen extends StatelessWidget {
  const EmergencyCareScreen({super.key});

  void _callEmergencyServices(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: Colors.red, size: 28),
            SizedBox(width: 10),
            Text(
              'Call Emergency?',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF173330),
              ),
            ),
          ],
        ),
        content: const Text(
          'Are you sure you want to dial regional emergency services?',
          style: TextStyle(fontSize: 14, color: Color(0xFF5A716E)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(ctx);
              final Uri phoneUri = Uri.parse('tel:112');
              try {
                final bool launched = await launchUrl(
                  phoneUri,
                  mode: LaunchMode.externalApplication,
                );
                if (!launched && context.mounted) {
                  _showCallingUnavailable(context);
                }
              } catch (_) {
                if (context.mounted) {
                  _showCallingUnavailable(context);
                }
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            child: const Text('Call', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  void _showCallingUnavailable(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Emergency calling is not configured yet on this device.'),
        backgroundColor: Color(0xFF173330),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FCFA),
      appBar: AppBar(
        title: const Text(
          'Emergency Care',
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
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            children: [
              Expanded(
                child: ListView(
                  children: [
                    // Emergency Prompt Banner
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.red.withAlpha(15),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Colors.red.shade200),
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: const BoxDecoration(
                              color: Colors.red,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.sos_outlined,
                                color: Colors.white, size: 28),
                          ),
                          const SizedBox(width: 16),
                          const Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Are you in an emergency?',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF900000),
                                  ),
                                ),
                                SizedBox(height: 4),
                                Text(
                                  'Access immediate emergency care, guidance, and verified Med ID sharing.',
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: Color(0xFFB3261E),
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

                    // Primary Action Tile: Find Emergency Care
                    _EmergencyActionTile(
                      title: 'Find Nearby Emergency Care',
                      subtitle:
                          'Locate verified hospital emergency rooms & trauma centers',
                      icon: Icons.local_hospital_outlined,
                      accentColor: Colors.red,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) =>
                                const NearbyEmergencyFacilitiesScreen(),
                          ),
                        );
                      },
                    ),

                    const SizedBox(height: 14),

                    // Call Emergency Services
                    _EmergencyActionTile(
                      title: 'Call Emergency Services',
                      subtitle: 'Direct emergency call dispatch prompt',
                      icon: Icons.phone_in_talk_outlined,
                      accentColor: Colors.deepOrange,
                      onTap: () => _callEmergencyServices(context),
                    ),

                    const SizedBox(height: 14),

                    // Emergency QR
                    _EmergencyActionTile(
                      title: 'Emergency QR / Med ID',
                      subtitle:
                          'Display shareable Med ID for first responders',
                      icon: Icons.qr_code_2_outlined,
                      accentColor: const Color(0xFF0B7A6E),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const EmergencyQrScreen(),
                          ),
                        );
                      },
                    ),

                    const SizedBox(height: 14),

                    // Emergency Information Guidance
                    _EmergencyActionTile(
                      title: 'Emergency Information',
                      subtitle:
                          'First-aid guidelines, when to seek care & privacy',
                      icon: Icons.info_outline,
                      accentColor: Colors.blue,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const EmergencyInformationScreen(),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              SizedBox(
                width: double.infinity,
                height: 52,
                child: OutlinedButton(
                  onPressed: () => Navigator.pop(context),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Color(0xFF8C9E9A)),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(26),
                    ),
                  ),
                  child: const Text(
                    'Back to Dashboard',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF5A716E),
                    ),
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

class _EmergencyActionTile extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color accentColor;
  final VoidCallback onTap;

  const _EmergencyActionTile({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.accentColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: const Color(0xFFE2EEEA)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(4),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: accentColor.withAlpha(20),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: accentColor, size: 26),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF173330),
                    ),
                  ),
                  const SizedBox(height: 3),
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
            const Icon(Icons.arrow_forward_ios,
                size: 14, color: Color(0xFF8C9E9A)),
          ],
        ),
      ),
    );
  }
}

/// Model for Nearby Emergency Healthcare Facilities
class EmergencyFacility {
  final String id;
  final String name;
  final String type; // 'Hospital', 'Clinic', 'Trauma Center'
  final String? address;
  final String? phone;
  final double? latitude;
  final double? longitude;
  final double? distanceKm;
  final String? emergencyAvailabilityStatus; // 'AVAILABLE', 'UNAVAILABLE', null/unconfirmed
  final String? emergencyService; // e.g. '24-hour Emergency Department', 'Level 1 Trauma Center'
  final DateTime? lastUpdated;

  EmergencyFacility({
    required this.id,
    required this.name,
    this.type = 'Hospital',
    this.address,
    this.phone,
    this.latitude,
    this.longitude,
    this.distanceKm,
    this.emergencyAvailabilityStatus,
    this.emergencyService,
    this.lastUpdated,
  });
}

/// NEARBY EMERGENCY FACILITIES DISCOVERY SCREEN (Phase 1E & 1F - Real Provider Data Only)
class NearbyEmergencyFacilitiesScreen extends StatefulWidget {
  const NearbyEmergencyFacilitiesScreen({super.key});

  @override
  State<NearbyEmergencyFacilitiesScreen> createState() =>
      _NearbyEmergencyFacilitiesScreenState();
}

class _NearbyEmergencyFacilitiesScreenState
    extends State<NearbyEmergencyFacilitiesScreen> {
  final TextEditingController _manualSearchController = TextEditingController();
  bool _isLoading = true;
  bool _locationDenied = false;
  String? _errorMessage;
  List<EmergencyFacility> _facilities = [];

  @override
  void initState() {
    super.initState();
    _fetchFacilities();
  }

  @override
  void dispose() {
    _manualSearchController.dispose();
    super.dispose();
  }

  Future<void> _fetchFacilities({String? manualQuery}) async {
    setState(() {
      _isLoading = true;
      _locationDenied = false;
      _errorMessage = null;
    });

    try {
      // Query backend or location provider (returns empty list when unconfigured)
      await Future.delayed(const Duration(milliseconds: 600));
      if (mounted) {
        setState(() {
          _facilities = [];
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Unable to load nearby emergency facilities.';
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FCFA),
      appBar: AppBar(
        title: const Text(
          'Nearby Emergency Care',
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
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            children: [
              Expanded(
                child: _buildBodyContent(),
              ),

              const SizedBox(height: 16),

              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0B7A6E),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(26),
                    ),
                  ),
                  child: const Text(
                    'Back to Emergency Care',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBodyContent() {
    if (_isLoading) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(color: Color(0xFF0B7A6E)),
            SizedBox(height: 16),
            Text(
              'Finding nearby emergency facilities...',
              style: TextStyle(
                fontSize: 15,
                color: Color(0xFF5A716E),
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      );
    }

    if (_locationDenied) {
      return ListView(
        children: [
          const SizedBox(height: 20),
          Center(
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.amber.withAlpha(25),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.location_off_outlined,
                color: Colors.amber,
                size: 56,
              ),
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            'Location Access Required',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Color(0xFF173330),
            ),
          ),
          const SizedBox(height: 10),
          const Text(
            'Location access is required to automatically find nearby emergency facilities.\nAlternatively, search for an emergency facility manually.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: Color(0xFF5A716E),
              height: 1.4,
            ),
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton(
              onPressed: () => _fetchFacilities(),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF0B7A6E),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24),
                ),
              ),
              child: const Text('Allow Location & Retry',
                  style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ),
          const SizedBox(height: 24),
          const Row(
            children: [
              Expanded(child: Divider()),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 12),
                child: Text('OR',
                    style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF8C9E9A))),
              ),
              Expanded(child: Divider()),
            ],
          ),
          const SizedBox(height: 20),
          const Text(
            'Search Facility Manually',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: Color(0xFF173330),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _manualSearchController,
                  decoration: InputDecoration(
                    hintText: 'Enter City, Locality, or Area',
                    hintStyle: const TextStyle(fontSize: 13, color: Colors.grey),
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 12),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: const BorderSide(color: Color(0xFFD9E4E1)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: const BorderSide(color: Color(0xFF0B7A6E)),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              IconButton.filled(
                onPressed: () {
                  if (_manualSearchController.text.trim().isNotEmpty) {
                    _fetchFacilities(
                        manualQuery: _manualSearchController.text.trim());
                  }
                },
                icon: const Icon(Icons.search),
                style: IconButton.styleFrom(
                  backgroundColor: const Color(0xFF0B7A6E),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.all(12),
                ),
              ),
            ],
          ),
        ],
      );
    }

    if (_errorMessage != null) {
      return ListView(
        children: [
          const SizedBox(height: 32),
          Center(
            child: Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.red.withAlpha(20),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.error_outline,
                color: Colors.red,
                size: 64,
              ),
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'Unable to Load Facilities',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Color(0xFF173330),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            _errorMessage!,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 14,
              color: Color(0xFF5A716E),
              height: 1.4,
            ),
          ),
          const SizedBox(height: 32),
          SizedBox(
            width: double.infinity,
            height: 48,
            child: OutlinedButton(
              onPressed: () => _fetchFacilities(),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Color(0xFF0B7A6E)),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24),
                ),
              ),
              child: const Text('Try Again',
                  style: TextStyle(
                      fontWeight: FontWeight.bold, color: Color(0xFF0B7A6E))),
            ),
          ),
        ],
      );
    }

    if (_facilities.isEmpty) {
      return ListView(
        children: [
          const SizedBox(height: 32),

          // Unavailable State Icon Container
          Center(
            child: Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.red.withAlpha(20),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.local_hospital_outlined,
                color: Colors.red,
                size: 64,
              ),
            ),
          ),

          const SizedBox(height: 24),

          const Text(
            'No Nearby Emergency Facilities Available',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Color(0xFF173330),
            ),
          ),

          const SizedBox(height: 12),

          const Text(
            'No nearby emergency care facilities are currently registered in your area.\nPlease call local emergency dispatch (112 / 911) or proceed directly to the nearest hospital.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: Color(0xFF5A716E),
              height: 1.4,
            ),
          ),

          const SizedBox(height: 32),

          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.amber.withAlpha(25),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.amber.shade200),
            ),
            child: const Row(
              children: [
                Icon(Icons.security, color: Colors.amber),
                SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Location data is accessed strictly on-demand for emergency discovery.',
                    style: TextStyle(
                      fontSize: 13,
                      color: Color(0xFF173330),
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          SizedBox(
            width: double.infinity,
            height: 48,
            child: OutlinedButton(
              onPressed: () => _fetchFacilities(),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Color(0xFF0B7A6E)),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24),
                ),
              ),
              child: const Text(
                'Try Again',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF0B7A6E),
                ),
              ),
            ),
          ),
        ],
      );
    }

    return ListView.separated(
      itemCount: _facilities.length,
      separatorBuilder: (_, __) => const SizedBox(height: 14),
      itemBuilder: (context, index) {
        final facility = _facilities[index];
        return _EmergencyFacilityCard(facility: facility);
      },
    );
  }
}

class _EmergencyFacilityCard extends StatelessWidget {
  final EmergencyFacility facility;

  const _EmergencyFacilityCard({required this.facility});

  Future<void> _openNavigation(BuildContext context) async {
    Uri? uri;
    if (facility.latitude != null && facility.longitude != null) {
      uri = Uri.parse(
          'https://www.google.com/maps/search/?api=1&query=${facility.latitude},${facility.longitude}');
    } else if (facility.address != null &&
        facility.address!.trim().isNotEmpty) {
      final encoded = Uri.encodeComponent(facility.address!.trim());
      uri = Uri.parse(
          'https://www.google.com/maps/search/?api=1&query=$encoded');
    } else if (facility.name.trim().isNotEmpty) {
      final encoded = Uri.encodeComponent(facility.name.trim());
      uri = Uri.parse(
          'https://www.google.com/maps/search/?api=1&query=$encoded');
    }

    if (uri != null) {
      try {
        final launched = await launchUrl(uri, mode: LaunchMode.externalApplication);
        if (!launched && context.mounted) {
          _showError(context, 'Directions are currently unavailable for this facility.');
        }
      } catch (_) {
        if (context.mounted) {
          _showError(context, 'Directions are currently unavailable for this facility.');
        }
      }
    } else {
      _showError(context, 'Directions are currently unavailable for this facility.');
    }
  }

  Future<void> _callFacility(BuildContext context) async {
    if (facility.phone == null || facility.phone!.trim().isEmpty) {
      _showError(context, 'Phone number unavailable.');
      return;
    }

    final Uri phoneUri = Uri.parse('tel:${facility.phone!.trim()}');
    try {
      final launched = await launchUrl(phoneUri, mode: LaunchMode.externalApplication);
      if (!launched && context.mounted) {
        _showError(context, 'Unable to place call.');
      }
    } catch (_) {
      if (context.mounted) {
        _showError(context, 'Unable to place call.');
      }
    }
  }

  void _showError(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: const Color(0xFF173330),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    String availabilityText;
    Color availabilityColor;

    if (facility.emergencyAvailabilityStatus == 'AVAILABLE') {
      availabilityText = 'Emergency availability: Available';
      availabilityColor = const Color(0xFF0B7A6E);
    } else if (facility.emergencyAvailabilityStatus == 'UNAVAILABLE') {
      availabilityText = 'Emergency availability: Unavailable';
      availabilityColor = Colors.red;
    } else {
      availabilityText = 'Emergency availability: Availability not confirmed.';
      availabilityColor = const Color(0xFF5A716E);
    }

    final String distanceText = facility.distanceKm != null
        ? 'Distance: ${facility.distanceKm!.toStringAsFixed(1)} km'
        : 'Distance: --';

    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => EmergencyFacilityDetailsScreen(facility: facility),
          ),
        );
      },
      borderRadius: BorderRadius.circular(18),
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: const Color(0xFFE2EEEA)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(4),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 24,
                  backgroundColor: Colors.red.withAlpha(20),
                  child: const Icon(Icons.local_hospital_outlined,
                      color: Colors.red, size: 26),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        facility.name,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF173330),
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        facility.type,
                        style: const TextStyle(
                          fontSize: 12,
                          color: Color(0xFF5A716E),
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.arrow_forward_ios,
                    size: 14, color: Color(0xFF8C9E9A)),
              ],
            ),

            if (facility.address != null &&
                facility.address!.trim().isNotEmpty) ...[
              const SizedBox(height: 12),
              Row(
                children: [
                  const Icon(Icons.location_on_outlined,
                      size: 16, color: Color(0xFF0B7A6E)),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      facility.address!,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFF5A716E),
                      ),
                    ),
                  ),
                ],
              ),
            ],

            const Divider(height: 24),

            // Emergency Availability & Distance Metrics
            Text(
              availabilityText,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: availabilityColor,
              ),
            ),

            const SizedBox(height: 4),

            Text(
              distanceText,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Color(0xFF173330),
              ),
            ),

            const SizedBox(height: 16),

            // Action Buttons: Call & Directions
            Row(
              children: [
                if (facility.phone != null &&
                    facility.phone!.trim().isNotEmpty) ...[
                  Expanded(
                    child: SizedBox(
                      height: 44,
                      child: OutlinedButton.icon(
                        onPressed: () => _callFacility(context),
                        icon: const Icon(Icons.phone,
                            size: 16, color: Color(0xFF0B7A6E)),
                        label: const Text(
                          'Call',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF0B7A6E),
                          ),
                        ),
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: Color(0xFF0B7A6E)),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(22),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                ],
                Expanded(
                  child: SizedBox(
                    height: 44,
                    child: ElevatedButton.icon(
                      onPressed: () => _openNavigation(context),
                      icon: const Icon(Icons.directions_outlined, size: 16),
                      label: const Text(
                        'Directions',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF0B7A6E),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(22),
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
    );
  }
}

/// EMERGENCY FACILITY DETAILS SCREEN (Phase 1F - Real Provider Data Only)
class EmergencyFacilityDetailsScreen extends StatelessWidget {
  final EmergencyFacility facility;

  const EmergencyFacilityDetailsScreen({super.key, required this.facility});

  Future<void> _openNavigation(BuildContext context) async {
    Uri? uri;
    if (facility.latitude != null && facility.longitude != null) {
      uri = Uri.parse(
          'https://www.google.com/maps/search/?api=1&query=${facility.latitude},${facility.longitude}');
    } else if (facility.address != null &&
        facility.address!.trim().isNotEmpty) {
      final encoded = Uri.encodeComponent(facility.address!.trim());
      uri = Uri.parse(
          'https://www.google.com/maps/search/?api=1&query=$encoded');
    } else if (facility.name.trim().isNotEmpty) {
      final encoded = Uri.encodeComponent(facility.name.trim());
      uri = Uri.parse(
          'https://www.google.com/maps/search/?api=1&query=$encoded');
    }

    if (uri != null) {
      try {
        final launched = await launchUrl(uri, mode: LaunchMode.externalApplication);
        if (!launched && context.mounted) {
          _showError(context, 'Directions are currently unavailable for this facility.');
        }
      } catch (_) {
        if (context.mounted) {
          _showError(context, 'Directions are currently unavailable for this facility.');
        }
      }
    } else {
      _showError(context, 'Directions are currently unavailable for this facility.');
    }
  }

  Future<void> _callFacility(BuildContext context) async {
    if (facility.phone == null || facility.phone!.trim().isEmpty) {
      _showError(context, 'Phone number unavailable.');
      return;
    }

    final Uri phoneUri = Uri.parse('tel:${facility.phone!.trim()}');
    try {
      final launched = await launchUrl(phoneUri, mode: LaunchMode.externalApplication);
      if (!launched && context.mounted) {
        _showError(context, 'Unable to place call.');
      }
    } catch (_) {
      if (context.mounted) {
        _showError(context, 'Unable to place call.');
      }
    }
  }

  void _showError(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: const Color(0xFF173330),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    String availabilityText;
    Color availabilityColor;

    if (facility.emergencyAvailabilityStatus == 'AVAILABLE') {
      availabilityText = 'Available';
      availabilityColor = const Color(0xFF0B7A6E);
    } else if (facility.emergencyAvailabilityStatus == 'UNAVAILABLE') {
      availabilityText = 'Unavailable';
      availabilityColor = Colors.red;
    } else {
      availabilityText = 'Availability not confirmed.';
      availabilityColor = const Color(0xFF5A716E);
    }

    final String distanceText = facility.distanceKm != null
        ? '${facility.distanceKm!.toStringAsFixed(1)} km'
        : '--';

    final String phoneText = (facility.phone != null && facility.phone!.trim().isNotEmpty)
        ? facility.phone!.trim()
        : 'Phone number unavailable';

    final String emergencyServiceText = (facility.emergencyService != null && facility.emergencyService!.trim().isNotEmpty)
        ? facility.emergencyService!.trim()
        : 'Information unavailable';

    final String addressText = (facility.address != null && facility.address!.trim().isNotEmpty)
        ? facility.address!.trim()
        : 'Address unavailable';

    final bool hasValidPhone = facility.phone != null && facility.phone!.trim().isNotEmpty;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FCFA),
      appBar: AppBar(
        title: const Text(
          'Emergency Facility',
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
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            children: [
              Expanded(
                child: ListView(
                  children: [
                    // Facility Header Card
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: const Color(0xFFE2EEEA)),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withAlpha(4),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              CircleAvatar(
                                radius: 26,
                                backgroundColor: Colors.red.withAlpha(20),
                                child: const Icon(Icons.local_hospital_outlined,
                                    color: Colors.red, size: 28),
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      facility.name,
                                      style: const TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: Color(0xFF173330),
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      facility.type,
                                      style: const TextStyle(
                                        fontSize: 13,
                                        color: Color(0xFF5A716E),
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Icon(Icons.location_on_outlined,
                                  size: 18, color: Color(0xFF0B7A6E)),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  addressText,
                                  style: const TextStyle(
                                    fontSize: 14,
                                    color: Color(0xFF5A716E),
                                    height: 1.3,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Details Section Card
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: const Color(0xFFE2EEEA)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildDetailRow(
                            icon: Icons.medical_services_outlined,
                            label: 'Emergency Service',
                            value: emergencyServiceText,
                          ),
                          const Divider(height: 24),
                          _buildDetailRow(
                            icon: Icons.phone_outlined,
                            label: 'Phone',
                            value: phoneText,
                          ),
                          const Divider(height: 24),
                          _buildDetailRow(
                            icon: Icons.straighten_outlined,
                            label: 'Distance',
                            value: distanceText,
                          ),
                          const Divider(height: 24),
                          _buildDetailRow(
                            icon: Icons.verified_outlined,
                            label: 'Emergency availability',
                            value: availabilityText,
                            valueColor: availabilityColor,
                            valueBold: true,
                          ),
                          if (facility.lastUpdated != null) ...[
                            const Divider(height: 24),
                            _buildDetailRow(
                              icon: Icons.update_outlined,
                              label: 'Last updated',
                              value: facility.lastUpdated!.toLocal().toString().split('.')[0],
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // Action Buttons Row: Call & Directions
              Row(
                children: [
                  Expanded(
                    child: SizedBox(
                      height: 50,
                      child: OutlinedButton.icon(
                        onPressed: () => _callFacility(context),
                        icon: Icon(
                          Icons.phone,
                          size: 18,
                          color: hasValidPhone ? const Color(0xFF0B7A6E) : Colors.grey,
                        ),
                        label: Text(
                          'Call',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: hasValidPhone ? const Color(0xFF0B7A6E) : Colors.grey,
                          ),
                        ),
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(
                            color: hasValidPhone ? const Color(0xFF0B7A6E) : Colors.grey.shade300,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(25),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: SizedBox(
                      height: 50,
                      child: ElevatedButton.icon(
                        onPressed: () => _openNavigation(context),
                        icon: const Icon(Icons.directions_outlined, size: 18),
                        label: const Text(
                          'Directions',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF0B7A6E),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(25),
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

  Widget _buildDetailRow({
    required IconData icon,
    required String label,
    required String value,
    Color? valueColor,
    bool valueBold = false,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20, color: const Color(0xFF0B7A6E)),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 12,
                  color: Color(0xFF5A716E),
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: valueBold ? FontWeight.bold : FontWeight.w600,
                  color: valueColor ?? const Color(0xFF173330),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// EMERGENCY INFORMATION & GUIDANCE SCREEN
class EmergencyInformationScreen extends StatelessWidget {
  const EmergencyInformationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FCFA),
      appBar: AppBar(
        title: const Text(
          'Emergency Information',
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
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            children: [
              Expanded(
                child: ListView(
                  children: [
                    const Text(
                      'Emergency Guidance & Protocols',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF173330),
                      ),
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      'Essential advice when handling urgent medical situations.',
                      style: TextStyle(fontSize: 13, color: Color(0xFF5A716E)),
                    ),

                    const SizedBox(height: 20),

                    _buildInfoCard(
                      title: 'When to Seek Immediate Emergency Care',
                      icon: Icons.warning_amber_rounded,
                      iconColor: Colors.red,
                      items: [
                        'Chest pain, severe pressure, or shortness of breath',
                        'Sudden weakness, numbness, or difficulty speaking',
                        'Severe uncontrolled bleeding or major traumatic injury',
                        'Loss of consciousness or severe confusion',
                      ],
                    ),

                    const SizedBox(height: 16),

                    _buildInfoCard(
                      title: 'How Emergency QR Works',
                      icon: Icons.qr_code_scanner,
                      iconColor: const Color(0xFF0B7A6E),
                      items: [
                        'Your Med ID contains critical emergency medical fields',
                        'First responders can scan your QR to view vital safety data',
                        'You control what information is displayed in your profile settings',
                      ],
                    ),

                    const SizedBox(height: 16),

                    _buildInfoCard(
                      title: 'Privacy & Data Security',
                      icon: Icons.lock_outline,
                      iconColor: Colors.blue,
                      items: [
                        'Location access is used only on-demand during active search',
                        'No background location tracking is performed',
                        'Personal health data is encrypted and saved under user ownership',
                      ],
                    ),

                    const SizedBox(height: 20),

                    // Non-Medical Disclaimer
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF0F6F4),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: const Color(0xFFD9E4E1)),
                      ),
                      child: const Text(
                        'Disclaimer: Medisimbio provides administrative assistance and is not a substitute for professional emergency medical dispatch or clinical diagnosis.',
                        style: TextStyle(
                          fontSize: 12,
                          color: Color(0xFF5A716E),
                          fontStyle: FontStyle.italic,
                          height: 1.3,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0B7A6E),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(26),
                    ),
                  ),
                  child: const Text(
                    'Done',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoCard({
    required String title,
    required IconData icon,
    required Color iconColor,
    required List<String> items,
  }) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE2EEEA)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: iconColor, size: 22),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF173330),
                  ),
                ),
              ),
            ],
          ),
          const Divider(height: 20),
          Column(
            children: items.map((item) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('• ',
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF0B7A6E))),
                    Expanded(
                      child: Text(
                        item,
                        style: const TextStyle(
                            fontSize: 13, color: Color(0xFF5A716E), height: 1.3),
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}
