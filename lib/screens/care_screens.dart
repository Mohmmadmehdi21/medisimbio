import 'package:flutter/material.dart';
import 'package:medisimbio_ui/models/app_notification.dart';
import 'package:medisimbio_ui/models/appointment.dart';
import 'package:medisimbio_ui/models/doctor.dart';
import 'package:medisimbio_ui/screens/feature_placeholder_screens.dart';
import 'package:medisimbio_ui/services/appointment_service.dart';
import 'package:medisimbio_ui/services/doctor_repository.dart';
import 'package:medisimbio_ui/services/firebase_service.dart';
import 'package:medisimbio_ui/services/notification_service.dart';
import 'package:url_launcher/url_launcher.dart';

/// 5.1 CARE SERVICES SCREEN
class CareServicesScreen extends StatelessWidget {
  const CareServicesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FCFA),
      appBar: AppBar(
        title: const Text(
          'Care Services',
          style:
              TextStyle(color: Color(0xFF173330), fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Color(0xFF173330)),
      ),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          const Text(
            'Healthcare Services',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Color(0xFF173330),
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Select a service to book appointments or consultations.',
            style: TextStyle(fontSize: 14, color: Color(0xFF5A716E)),
          ),

          const SizedBox(height: 24),

          // 1. Doctors Card
          _CareServiceTile(
            title: 'Doctors & Specialists',
            subtitle: 'Book appointments with certified healthcare providers',
            icon: Icons.person_search_outlined,
            accentColor: const Color(0xFF0B7A6E),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (_) => const DoctorDiscoveryScreen()),
              );
            },
          ),

          const SizedBox(height: 16),

          // 2. Labs Card (Diagnostic Tests)
          _CareServiceTile(
            title: 'Labs & Diagnostics',
            subtitle: 'Book diagnostic tests & lab sample collection',
            icon: Icons.biotech_outlined,
            accentColor: Colors.blue,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const FeaturePlaceholderScreen(
                    title: 'Labs & Diagnostics',
                    icon: Icons.biotech_outlined,
                    accentColor: Colors.blue,
                  ),
                ),
              );
            },
          ),

          const SizedBox(height: 16),

          // 3. Pharmacies Card
          _CareServiceTile(
            title: 'Pharmacies & Medicines',
            subtitle: 'Order prescribed medicines & doorstep delivery',
            icon: Icons.local_pharmacy_outlined,
            accentColor: Colors.deepOrange,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const FeaturePlaceholderScreen(
                    title: 'Pharmacies & Medicines',
                    icon: Icons.local_pharmacy_outlined,
                    accentColor: Colors.deepOrange,
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _CareServiceTile extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color accentColor;
  final VoidCallback onTap;

  const _CareServiceTile({
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
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
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
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: accentColor.withAlpha(25),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: accentColor, size: 30),
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
                  const SizedBox(height: 4),
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
                size: 16, color: Color(0xFF8C9E9A)),
          ],
        ),
      ),
    );
  }
}

/// 5.2 DOCTOR DISCOVERY SCREEN
class DoctorDiscoveryScreen extends StatefulWidget {
  const DoctorDiscoveryScreen({super.key});

  @override
  State<DoctorDiscoveryScreen> createState() => _DoctorDiscoveryScreenState();
}

class _DoctorDiscoveryScreenState extends State<DoctorDiscoveryScreen> {
  final DoctorRepository _doctorRepository = DoctorRepository();
  final TextEditingController _searchController = TextEditingController();

  List<Doctor> _doctors = [];
  List<String> _specialties = ['All'];
  String _selectedSpecialty = 'All';
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _specialties = _doctorRepository.getAvailableSpecialties();
    _fetchDoctors();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _fetchDoctors() async {
    setState(() => _isLoading = true);
    final results = await _doctorRepository.getDoctors(
      searchQuery: _searchController.text.trim(),
      selectedSpecialty: _selectedSpecialty,
    );
    if (mounted) {
      setState(() {
        _doctors = results;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FCFA),
      appBar: AppBar(
        title: const Text(
          'Find Doctor',
          style:
              TextStyle(color: Color(0xFF173330), fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Color(0xFF173330)),
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Search & Specialty Filters Header
            Container(
              color: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              child: Column(
                children: [
                  // Search Bar
                  TextField(
                    controller: _searchController,
                    onChanged: (_) => _fetchDoctors(),
                    decoration: InputDecoration(
                      hintText:
                          'Search by doctor name, specialty, or clinic...',
                      prefixIcon:
                          const Icon(Icons.search, color: Color(0xFF0B7A6E)),
                      filled: true,
                      fillColor: const Color(0xFFF8FCFA),
                      contentPadding: const EdgeInsets.symmetric(vertical: 12),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: const BorderSide(color: Color(0xFFD9E4E1)),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: const BorderSide(color: Color(0xFFD9E4E1)),
                      ),
                    ),
                  ),

                  const SizedBox(height: 12),

                  // Specialty Filter Chips
                  SizedBox(
                    height: 38,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: _specialties.length,
                      separatorBuilder: (_, __) => const SizedBox(width: 8),
                      itemBuilder: (context, index) {
                        final specialty = _specialties[index];
                        final isSelected = _selectedSpecialty == specialty;
                        return ChoiceChip(
                          label: Text(specialty),
                          selected: isSelected,
                          selectedColor: const Color(0xFF0B7A6E),
                          backgroundColor: const Color(0xFFF0F6F4),
                          labelStyle: TextStyle(
                            color: isSelected
                                ? Colors.white
                                : const Color(0xFF173330),
                            fontWeight: isSelected
                                ? FontWeight.bold
                                : FontWeight.normal,
                          ),
                          onSelected: (selected) {
                            if (selected) {
                              setState(() => _selectedSpecialty = specialty);
                              _fetchDoctors();
                            }
                          },
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 12),

            // Doctor List / Loading / Empty State
            Expanded(
              child: _isLoading
                  ? const Center(
                      child:
                          CircularProgressIndicator(color: Color(0xFF0B7A6E)),
                    )
                  : _doctors.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.person_off_outlined,
                                  size: 64, color: Color(0xFF8C9E9A)),
                              const SizedBox(height: 16),
                              const Text(
                                'No doctors found',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF173330),
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Try matching your search or filter keywords.',
                                style: TextStyle(
                                    fontSize: 13, color: Colors.grey.shade600),
                              ),
                            ],
                          ),
                        )
                      : ListView.separated(
                          padding: const EdgeInsets.all(20),
                          itemCount: _doctors.length,
                          separatorBuilder: (_, __) =>
                              const SizedBox(height: 14),
                          itemBuilder: (context, index) {
                            final doctor = _doctors[index];
                            return _DoctorCard(
                              doctor: doctor,
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) =>
                                        DoctorProfileScreen(doctor: doctor),
                                  ),
                                );
                              },
                            );
                          },
                        ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DoctorCard extends StatelessWidget {
  final Doctor doctor;
  final VoidCallback onTap;

  const _DoctorCard({required this.doctor, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
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
            CircleAvatar(
              radius: 32,
              backgroundColor: const Color(0xFF0B7A6E).withAlpha(25),
              child:
                  const Icon(Icons.person, size: 36, color: Color(0xFF0B7A6E)),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    doctor.name,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF173330),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${doctor.specialty} • ${doctor.experienceYears} yrs exp',
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFF0B7A6E),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    doctor.hospitalName,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFF5A716E),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      const Icon(Icons.star, size: 14, color: Colors.amber),
                      const SizedBox(width: 4),
                      Text(
                        '${doctor.rating} (${doctor.reviewCount})',
                        style: const TextStyle(
                            fontSize: 12, fontWeight: FontWeight.bold),
                      ),
                      const Spacer(),
                      Text(
                        '\$${doctor.consultationFee.toInt()}',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF0B7A6E),
                        ),
                      ),
                    ],
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

/// 6.1 DOCTOR PROFILE SCREEN
class DoctorProfileScreen extends StatelessWidget {
  final Doctor doctor;

  const DoctorProfileScreen({super.key, required this.doctor});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FCFA),
      appBar: AppBar(
        title: const Text(
          'Doctor Profile',
          style:
              TextStyle(color: Color(0xFF173330), fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Color(0xFF173330)),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(24),
                children: [
                  // Doctor Header Box
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: const Color(0xFFE2EEEA)),
                    ),
                    child: Column(
                      children: [
                        CircleAvatar(
                          radius: 44,
                          backgroundColor:
                              const Color(0xFF0B7A6E).withAlpha(25),
                          child: const Icon(Icons.person,
                              size: 48, color: Color(0xFF0B7A6E)),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          doctor.name,
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF173330),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          doctor.specialty,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF0B7A6E),
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          doctor.hospitalName,
                          style: const TextStyle(
                              fontSize: 13, color: Color(0xFF5A716E)),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Experience / Rating / Fee Info Grid
                  Row(
                    children: [
                      Expanded(
                        child: _DoctorInfoStatTile(
                          label: 'Experience',
                          value: '${doctor.experienceYears} Years',
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _DoctorInfoStatTile(
                          label: 'Rating',
                          value: '${doctor.rating} ★',
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _DoctorInfoStatTile(
                          label: 'Fee',
                          value: '\$${doctor.consultationFee.toInt()}',
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  const Text(
                    'About Doctor',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF173330),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    doctor.about,
                    style:
                        const TextStyle(fontSize: 14, color: Color(0xFF5A716E)),
                  ),

                  const SizedBox(height: 24),

                  const Text(
                    'Consultation Modes',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF173330),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: const Color(0xFFE2EEEA)),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.video_call_outlined,
                            color: Color(0xFF0B7A6E)),
                        const SizedBox(width: 10),
                        Text(
                          doctor.consultationMode,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF173330),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Select Date & Time Action Button
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: SizedBox(
                width: double.infinity,
                height: 54,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) =>
                            AppointmentBookingScreen(doctor: doctor),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0B7A6E),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(27),
                    ),
                  ),
                  child: const Text(
                    'Select Date & Time',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DoctorInfoStatTile extends StatelessWidget {
  final String label;
  final String value;

  const _DoctorInfoStatTile({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE2EEEA)),
      ),
      child: Column(
        children: [
          Text(
            label,
            style: const TextStyle(fontSize: 11, color: Color(0xFF5A716E)),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Color(0xFF0B7A6E),
            ),
          ),
        ],
      ),
    );
  }
}

/// 6.2 APPOINTMENT BOOKING SCREEN (Select Date & Time)
class AppointmentBookingScreen extends StatefulWidget {
  final Doctor doctor;

  const AppointmentBookingScreen({super.key, required this.doctor});

  @override
  State<AppointmentBookingScreen> createState() =>
      _AppointmentBookingScreenState();
}

class _AppointmentBookingScreenState extends State<AppointmentBookingScreen> {
  late String _selectedDate;
  late String _selectedTime;
  String _consultationType = 'In-Person';

  @override
  void initState() {
    super.initState();
    _selectedDate = widget.doctor.availableDates.isNotEmpty
        ? widget.doctor.availableDates.first
        : 'Today';
    _selectedTime = widget.doctor.availableSlots.isNotEmpty
        ? widget.doctor.availableSlots.first
        : '10:00 AM';
  }

  void _proceedToReview() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => BookingReviewScreen(
          doctor: widget.doctor,
          selectedDate: _selectedDate,
          selectedTime: _selectedTime,
          consultationType: _consultationType,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FCFA),
      appBar: AppBar(
        title: const Text(
          'Select Date & Time',
          style:
              TextStyle(color: Color(0xFF173330), fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Color(0xFF173330)),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(24),
                children: [
                  // Select Date Section
                  const Text(
                    'Select Date',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF173330),
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    height: 50,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: widget.doctor.availableDates.length,
                      separatorBuilder: (_, __) => const SizedBox(width: 10),
                      itemBuilder: (context, index) {
                        final date = widget.doctor.availableDates[index];
                        final isSelected = _selectedDate == date;
                        return ChoiceChip(
                          label: Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 8),
                            child: Text(date),
                          ),
                          selected: isSelected,
                          selectedColor: const Color(0xFF0B7A6E),
                          backgroundColor: Colors.white,
                          labelStyle: TextStyle(
                            color: isSelected
                                ? Colors.white
                                : const Color(0xFF173330),
                            fontWeight: isSelected
                                ? FontWeight.bold
                                : FontWeight.normal,
                          ),
                          onSelected: (selected) {
                            if (selected) setState(() => _selectedDate = date);
                          },
                        );
                      },
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Select Time Slot Section
                  const Text(
                    'Available Time Slots',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF173330),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: widget.doctor.availableSlots.map((slot) {
                      final isSelected = _selectedTime == slot;
                      return ChoiceChip(
                        label: Text(slot),
                        selected: isSelected,
                        selectedColor: const Color(0xFF0B7A6E),
                        backgroundColor: Colors.white,
                        labelStyle: TextStyle(
                          color: isSelected
                              ? Colors.white
                              : const Color(0xFF173330),
                          fontWeight:
                              isSelected ? FontWeight.bold : FontWeight.normal,
                        ),
                        onSelected: (selected) {
                          if (selected) setState(() => _selectedTime = slot);
                        },
                      );
                    }).toList(),
                  ),

                  const SizedBox(height: 24),

                  // Consultation Mode Section
                  const Text(
                    'Consultation Mode',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF173330),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: GestureDetector(
                          onTap: () =>
                              setState(() => _consultationType = 'In-Person'),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                vertical: 12, horizontal: 12),
                            decoration: BoxDecoration(
                              color: _consultationType == 'In-Person'
                                  ? const Color(0xFF0B7A6E).withAlpha(25)
                                  : Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: _consultationType == 'In-Person'
                                    ? const Color(0xFF0B7A6E)
                                    : const Color(0xFFE2EEEA),
                                width: 1.5,
                              ),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.person_pin_circle_outlined,
                                  size: 18,
                                  color: _consultationType == 'In-Person'
                                      ? const Color(0xFF0B7A6E)
                                      : const Color(0xFF5A716E),
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  'In-Person',
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.bold,
                                    color: _consultationType == 'In-Person'
                                        ? const Color(0xFF0B7A6E)
                                        : const Color(0xFF173330),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: GestureDetector(
                          onTap: () => setState(
                              () => _consultationType = 'Video Consultation'),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                vertical: 12, horizontal: 12),
                            decoration: BoxDecoration(
                              color: _consultationType == 'Video Consultation'
                                  ? const Color(0xFF0B7A6E).withAlpha(25)
                                  : Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: _consultationType == 'Video Consultation'
                                    ? const Color(0xFF0B7A6E)
                                    : const Color(0xFFE2EEEA),
                                width: 1.5,
                              ),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.videocam_outlined,
                                  size: 18,
                                  color:
                                      _consultationType == 'Video Consultation'
                                          ? const Color(0xFF0B7A6E)
                                          : const Color(0xFF5A716E),
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  'Video',
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.bold,
                                    color: _consultationType ==
                                            'Video Consultation'
                                        ? const Color(0xFF0B7A6E)
                                        : const Color(0xFF173330),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Proceed to Review Button
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: SizedBox(
                width: double.infinity,
                height: 54,
                child: ElevatedButton(
                  onPressed: _proceedToReview,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0B7A6E),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(27),
                    ),
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Proceed to Review',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(width: 8),
                      Icon(Icons.arrow_forward_rounded, size: 18),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// 6.2.1 BOOKING REVIEW SCREEN
class BookingReviewScreen extends StatefulWidget {
  final Doctor doctor;
  final String selectedDate;
  final String selectedTime;
  final String consultationType;

  const BookingReviewScreen({
    super.key,
    required this.doctor,
    required this.selectedDate,
    required this.selectedTime,
    required this.consultationType,
  });

  @override
  State<BookingReviewScreen> createState() => _BookingReviewScreenState();
}

class _BookingReviewScreenState extends State<BookingReviewScreen> {
  final FirebaseService _firebaseService = FirebaseService();
  final AppointmentService _appointmentService = AppointmentService();
  bool _isSaving = false;

  Future<void> _confirmBooking() async {
    final user = _firebaseService.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No authenticated user found.')),
      );
      return;
    }

    if (_isSaving) return;
    setState(() => _isSaving = true);

    try {
      final appointmentId = DateTime.now().millisecondsSinceEpoch.toString();
      final formattedDateTime = '${widget.selectedDate}, ${widget.selectedTime}';

      final appointment = Appointment(
        id: appointmentId,
        uid: user.uid,
        doctorId: widget.doctor.id,
        doctorName: widget.doctor.name,
        specialty: widget.doctor.specialty,
        hospitalName: widget.doctor.hospitalName,
        dateTime: formattedDateTime,
        consultationType: widget.consultationType,
        consultationFee: widget.doctor.consultationFee,
        status: AppointmentStatus.confirmed,
        isLiveTrackingActive: false,
        createdAt: DateTime.now(),
      );

      await _appointmentService.saveAppointment(appointment);

      // Save real appointment notification
      final notifService = NotificationService();
      await notifService.createNotification(
        user.uid,
        AppNotification(
          notificationId: 'NOTIF-APPT-$appointmentId',
          patientId: user.uid,
          category: NotificationCategory.appointment,
          title: 'Appointment Confirmed',
          message:
              'Your appointment with Dr. ${widget.doctor.name} is confirmed for $formattedDateTime.',
          createdAt: DateTime.now(),
          referenceId: appointmentId,
        ),
      );

      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) =>
              AppointmentConfirmationScreen(appointment: appointment),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => BookingFailedScreen(
            doctor: widget.doctor,
            onRetry: () => _confirmBooking(),
          ),
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
      appBar: AppBar(
        title: const Text(
          'Booking Review',
          style:
              TextStyle(color: Color(0xFF173330), fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Color(0xFF173330)),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(24),
                children: [
                  const Text(
                    'Review Appointment Details',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF173330),
                    ),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'Please verify your selected appointment schedule before final confirmation.',
                    style: TextStyle(fontSize: 13, color: Color(0xFF5A716E)),
                  ),

                  const SizedBox(height: 20),

                  // Doctor Summary Header Card
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: const Color(0xFFE2EEEA)),
                    ),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 28,
                          backgroundColor:
                              const Color(0xFF0B7A6E).withAlpha(25),
                          child: const Icon(Icons.person,
                              size: 32, color: Color(0xFF0B7A6E)),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                widget.doctor.name,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF173330),
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                widget.doctor.specialty,
                                style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF0B7A6E),
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                widget.doctor.hospitalName,
                                style: const TextStyle(
                                    fontSize: 12, color: Color(0xFF5A716E)),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Selected Data Review Card (EXACT REAL VALUES)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: const Color(0xFFE2EEEA)),
                    ),
                    child: Column(
                      children: [
                        _buildReviewRow('Doctor', widget.doctor.name),
                        const Divider(height: 24),
                        _buildReviewRow('Specialization', widget.doctor.specialty),
                        const Divider(height: 24),
                        _buildReviewRow(
                            'Hospital / Clinic', widget.doctor.hospitalName),
                        const Divider(height: 24),
                        _buildReviewRow('Selected Date', widget.selectedDate),
                        const Divider(height: 24),
                        _buildReviewRow('Selected Time', widget.selectedTime),
                        const Divider(height: 24),
                        _buildReviewRow(
                            'Consultation Mode', widget.consultationType),
                        const Divider(height: 24),
                        _buildReviewRow(
                          'Consultation Fee',
                          '\$${widget.doctor.consultationFee.toInt()}',
                          isFee: true,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Confirm Appointment Action Button
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: SizedBox(
                width: double.infinity,
                height: 54,
                child: ElevatedButton(
                  onPressed: _isSaving ? null : _confirmBooking,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0B7A6E),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(27),
                    ),
                  ),
                  child: _isSaving
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2.5,
                          ),
                        )
                      : const Text(
                          'Confirm Appointment',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReviewRow(String label, String value, {bool isFee = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 13, color: Color(0xFF5A716E)),
        ),
        const SizedBox(width: 12),
        Flexible(
          child: Text(
            value,
            textAlign: TextAlign.end,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: isFee ? const Color(0xFF0B7A6E) : const Color(0xFF173330),
            ),
          ),
        ),
      ],
    );
  }
}

/// CALENDAR INTEGRATION HELPER
class CalendarHelper {
  static Future<void> addToCalendar(
      BuildContext context, Appointment appointment) async {
    final title = 'Appointment with Dr. ${appointment.doctorName}';
    final details =
        'Specialty: ${appointment.specialty}\nHospital/Clinic: ${appointment.hospitalName}\nConsultation Mode: ${appointment.consultationType}';
    final location = appointment.hospitalAddress ?? appointment.hospitalName;

    final Uri calendarUri = Uri.parse(
      'https://calendar.google.com/calendar/render?action=TEMPLATE'
      '&text=${Uri.encodeComponent(title)}'
      '&details=${Uri.encodeComponent(details)}'
      '&location=${Uri.encodeComponent(location)}',
    );

    try {
      final bool launched = await launchUrl(
        calendarUri,
        mode: LaunchMode.externalApplication,
      );
      if (!launched && context.mounted) {
        _showCalendarUnavailable(context);
      }
    } catch (_) {
      if (context.mounted) {
        _showCalendarUnavailable(context);
      }
    }
  }

  static void _showCalendarUnavailable(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Calendar integration is currently unavailable.'),
        backgroundColor: Color(0xFF173330),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}

/// BOOKING FAILED SCREEN
class BookingFailedScreen extends StatelessWidget {
  final Doctor doctor;
  final VoidCallback onRetry;

  const BookingFailedScreen({
    super.key,
    required this.doctor,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FCFA),
      appBar: AppBar(
        title: const Text(
          'Booking Failed',
          style: TextStyle(
              color: Color(0xFF173330), fontWeight: FontWeight.bold),
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
              const Spacer(),
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.red.withAlpha(25),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.error_outline,
                    color: Colors.red, size: 64),
              ),
              const SizedBox(height: 24),
              const Text(
                'Unable to book this appointment.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF173330),
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                'The selected slot may no longer be available or network connectivity was lost. Please try again.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14, color: Color(0xFF5A716E), height: 1.4),
              ),
              const SizedBox(height: 32),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFE2EEEA)),
                ),
                child: Row(
                  children: [
                    CircleAvatar(
                      backgroundColor: const Color(0xFF0B7A6E).withAlpha(25),
                      child: const Icon(Icons.person, color: Color(0xFF0B7A6E)),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            doctor.name,
                            style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF173330)),
                          ),
                          Text(
                            doctor.specialty,
                            style: const TextStyle(
                                fontSize: 13, color: Color(0xFF0B7A6E)),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const Spacer(),
              Row(
                children: [
                  Expanded(
                    child: SizedBox(
                      height: 52,
                      child: OutlinedButton(
                        onPressed: () => Navigator.pop(context),
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: Color(0xFF8C9E9A)),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(26)),
                        ),
                        child: const Text('Back',
                            style: TextStyle(
                                color: Color(0xFF173330),
                                fontWeight: FontWeight.bold)),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: SizedBox(
                      height: 52,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.pop(context);
                          onRetry();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF0B7A6E),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(26)),
                        ),
                        child: const Text('Try Again',
                            style: TextStyle(fontWeight: FontWeight.bold)),
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

/// 6.3 APPOINTMENT CONFIRMATION SCREEN
class AppointmentConfirmationScreen extends StatelessWidget {
  final Appointment appointment;

  const AppointmentConfirmationScreen({super.key, required this.appointment});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FCFA),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            children: [
              const Spacer(),

              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: const Color(0xFF0B7A6E).withAlpha(25),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check_circle,
                  color: Color(0xFF0B7A6E),
                  size: 64,
                ),
              ),

              const SizedBox(height: 24),

              const Text(
                'Appointment Confirmed!',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF173330),
                ),
              ),
              const SizedBox(height: 6),
              const Text(
                'Your appointment details have been successfully saved to Firestore.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14, color: Color(0xFF5A716E)),
              ),

              const SizedBox(height: 32),

              // Confirmed Appointment Card showing EXACT values
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: const Color(0xFFE2EEEA)),
                ),
                child: Column(
                  children: [
                    _buildInfoRow('Doctor', appointment.doctorName),
                    const Divider(height: 20),
                    _buildInfoRow('Specialty', appointment.specialty),
                    const Divider(height: 20),
                    _buildInfoRow(
                        'Hospital / Clinic', appointment.hospitalName),
                    const Divider(height: 20),
                    _buildInfoRow('Date & Time', appointment.dateTime),
                    const Divider(height: 20),
                    _buildInfoRow('Mode', appointment.consultationType),
                  ],
                ),
              ),

              const Spacer(),

              // Add to Calendar Button
              SizedBox(
                width: double.infinity,
                height: 48,
                child: OutlinedButton.icon(
                  onPressed: () => CalendarHelper.addToCalendar(context, appointment),
                  icon: const Icon(Icons.calendar_today_outlined,
                      size: 18, color: Color(0xFF0B7A6E)),
                  label: const Text(
                    'Add to Calendar',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF0B7A6E),
                    ),
                  ),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Color(0xFF0B7A6E), width: 1.5),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),

              // Bottom Action Buttons
              Row(
                children: [
                  Expanded(
                    child: SizedBox(
                      height: 52,
                      child: OutlinedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => AppointmentDetailsScreen(
                                  appointment: appointment),
                            ),
                          );
                        },
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(
                              color: Color(0xFF0B7A6E), width: 1.5),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(26),
                          ),
                        ),
                        child: const Text(
                          'View Details',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF0B7A6E),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: SizedBox(
                      height: 52,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.popUntil(context, (route) => route.isFirst);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF0B7A6E),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(26),
                          ),
                        ),
                        child: const Text(
                          'Dashboard',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
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

  Widget _buildInfoRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label,
            style: const TextStyle(fontSize: 13, color: Color(0xFF5A716E))),
        Flexible(
          child: Text(
            value,
            textAlign: TextAlign.end,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Color(0xFF173330),
            ),
          ),
        ),
      ],
    );
  }
}

/// APPOINTMENT DETAILS SCREEN (Reactive + Phase 1P Final Actions)
class AppointmentDetailsScreen extends StatefulWidget {
  final Appointment appointment;

  const AppointmentDetailsScreen({super.key, required this.appointment});

  @override
  State<AppointmentDetailsScreen> createState() =>
      _AppointmentDetailsScreenState();
}

class _AppointmentDetailsScreenState extends State<AppointmentDetailsScreen> {
  final FirebaseService _firebaseService = FirebaseService();
  final AppointmentService _appointmentService = AppointmentService();

  void _showCancelConfirmation(BuildContext context, Appointment appt) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (sheetContext) => _CancelAppointmentSheet(
        appointment: appt,
        appointmentService: _appointmentService,
        firebaseService: _firebaseService,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = _firebaseService.currentUser;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FCFA),
      appBar: AppBar(
        title: const Text(
          'Appointment Details',
          style:
              TextStyle(color: Color(0xFF173330), fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Color(0xFF173330)),
      ),
      body: user == null
          ? _buildDetailsBody(context, widget.appointment)
          : StreamBuilder<Appointment?>(
              stream: _appointmentService.streamAppointmentById(
                  user.uid, widget.appointment.id),
              builder: (context, snapshot) {
                final appt = snapshot.data ?? widget.appointment;
                return _buildDetailsBody(context, appt);
              },
            ),
    );
  }

  Widget _buildDetailsBody(BuildContext context, Appointment appt) {
    final isCancelled =
        appt.status.toUpperCase() == AppointmentStatus.cancelled;
    final isCompleted =
        appt.status.toUpperCase() == AppointmentStatus.completed;
    final isRescheduled =
        appt.status.toUpperCase() == AppointmentStatus.rescheduled;

    Color statusBgColor = const Color(0xFF0B7A6E).withAlpha(25);
    Color statusTextColor = const Color(0xFF0B7A6E);

    if (isCancelled) {
      statusBgColor = Colors.red.withAlpha(25);
      statusTextColor = Colors.red.shade700;
    } else if (isCompleted) {
      statusBgColor = Colors.grey.withAlpha(40);
      statusTextColor = const Color(0xFF173330);
    } else if (isRescheduled) {
      statusBgColor = Colors.orange.withAlpha(25);
      statusTextColor = Colors.orange.shade800;
    }

    return SafeArea(
      child: Column(
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(24),
              children: [
                if (isCancelled) ...[
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.red.withAlpha(20),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.red.shade200),
                    ),
                    child: const Row(
                      children: [
                        Icon(Icons.cancel_outlined, color: Colors.red),
                        SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'This appointment has been cancelled.',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Colors.red,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                ] else if (isCompleted) ...[
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFF0B7A6E).withAlpha(20),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                          color: const Color(0xFF0B7A6E).withAlpha(40)),
                    ),
                    child: const Row(
                      children: [
                        Icon(Icons.check_circle_outline,
                            color: Color(0xFF0B7A6E)),
                        SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'This appointment has been completed.',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF173330),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                ],

                // Doctor & Status Card
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: const Color(0xFFE2EEEA)),
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Status',
                            style: TextStyle(
                                fontSize: 13, color: Color(0xFF5A716E)),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: statusBgColor,
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: Text(
                              appt.status.toUpperCase(),
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: statusTextColor,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const Divider(height: 24),
                      Row(
                        children: [
                          CircleAvatar(
                            radius: 28,
                            backgroundColor:
                                const Color(0xFF0B7A6E).withAlpha(25),
                            child: const Icon(Icons.person,
                                size: 32, color: Color(0xFF0B7A6E)),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  appt.doctorName,
                                  style: const TextStyle(
                                    fontSize: 17,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF173330),
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  appt.specialty,
                                  style: const TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                    color: Color(0xFF0B7A6E),
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  appt.hospitalName,
                                  style: const TextStyle(
                                      fontSize: 12, color: Color(0xFF5A716E)),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // Comprehensive Details Box
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: const Color(0xFFE2EEEA)),
                  ),
                  child: Column(
                    children: [
                      _buildDetailRow('Appointment ID', appt.id),
                      const Divider(height: 24),
                      _buildDetailRow('Date & Time', appt.dateTime),
                      const Divider(height: 24),
                      _buildDetailRow(
                          'Consultation Mode', appt.consultationType),
                      if (appt.consultationFee > 0) ...[
                        const Divider(height: 24),
                        _buildDetailRow(
                          'Consultation Fee',
                          '\$${appt.consultationFee.toInt()}',
                          isFee: true,
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Action Buttons Bottom Bar
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              children: [
                if (!isCancelled && !isCompleted) ...[
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) =>
                                LiveTrackingScreen(appointment: appt),
                          ),
                        );
                      },
                      icon: const Icon(Icons.location_searching, size: 18),
                      label: const Text(
                        'Track Appointment',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF0B7A6E),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(24),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                ],

                Row(
                  children: [
                    Expanded(
                      child: SizedBox(
                        height: 48,
                        child: OutlinedButton.icon(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => AppointmentNavigationScreen(
                                    appointment: appt),
                              ),
                            );
                          },
                          icon: const Icon(Icons.directions_outlined,
                              size: 18, color: Color(0xFF0B7A6E)),
                          label: const Text(
                            'Directions',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF0B7A6E),
                            ),
                          ),
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(
                                color: Color(0xFF0B7A6E), width: 1.5),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(24),
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: SizedBox(
                        height: 48,
                        child: OutlinedButton.icon(
                          onPressed: () =>
                              CalendarHelper.addToCalendar(context, appt),
                          icon: const Icon(Icons.calendar_today_outlined,
                              size: 18, color: Color(0xFF0B7A6E)),
                          label: const Text(
                            'Add to Calendar',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF0B7A6E),
                            ),
                          ),
                          style: OutlinedButton.styleFrom(
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

                if (!isCancelled && !isCompleted) ...[
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: SizedBox(
                          height: 48,
                          child: OutlinedButton.icon(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => RescheduleAppointmentScreen(
                                      appointment: appt),
                                ),
                              );
                            },
                            icon: const Icon(Icons.edit_calendar,
                                size: 18, color: Color(0xFF0B7A6E)),
                            label: const Text(
                              'Reschedule',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF0B7A6E),
                              ),
                            ),
                            style: OutlinedButton.styleFrom(
                              side: const BorderSide(
                                  color: Color(0xFF0B7A6E), width: 1.5),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(24),
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: SizedBox(
                          height: 48,
                          child: OutlinedButton.icon(
                            onPressed: () =>
                                _showCancelConfirmation(context, appt),
                            icon: const Icon(Icons.cancel_outlined,
                                size: 18, color: Colors.red),
                            label: const Text(
                              'Cancel',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: Colors.red,
                              ),
                            ),
                            style: OutlinedButton.styleFrom(
                              side: BorderSide(
                                  color: Colors.red.shade400, width: 1.5),
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
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, {bool isFee = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 13, color: Color(0xFF5A716E)),
        ),
        const SizedBox(width: 12),
        Flexible(
          child: Text(
            value,
            textAlign: TextAlign.end,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: isFee ? const Color(0xFF0B7A6E) : const Color(0xFF173330),
            ),
          ),
        ),
      ],
    );
  }
}

/// CANCEL APPOINTMENT BOTTOM SHEET
class _CancelAppointmentSheet extends StatefulWidget {
  final Appointment appointment;
  final AppointmentService appointmentService;
  final FirebaseService firebaseService;

  const _CancelAppointmentSheet({
    required this.appointment,
    required this.appointmentService,
    required this.firebaseService,
  });

  @override
  State<_CancelAppointmentSheet> createState() =>
      __CancelAppointmentSheetState();
}

class __CancelAppointmentSheetState extends State<_CancelAppointmentSheet> {
  bool _isProcessing = false;

  Future<void> _processCancellation() async {
    final user = widget.firebaseService.currentUser;
    if (user == null) return;

    if (_isProcessing) return;
    setState(() => _isProcessing = true);

    try {
      await widget.appointmentService.cancelAppointment(
        uid: user.uid,
        appointmentId: widget.appointment.id,
      );

      // Create real cancellation notification
      final notifService = NotificationService();
      await notifService.createNotification(
        user.uid,
        AppNotification(
          notificationId: 'NOTIF-CANCEL-${widget.appointment.id}',
          patientId: user.uid,
          category: NotificationCategory.appointment,
          title: 'Appointment Cancelled',
          message:
              'Your appointment with Dr. ${widget.appointment.doctorName} has been cancelled.',
          createdAt: DateTime.now(),
          referenceId: widget.appointment.id,
        ),
      );

      if (!mounted) return;
      Navigator.pop(context); // close sheet
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => CancelSuccessScreen(appointment: widget.appointment),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      Navigator.pop(context); // close sheet
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Unable to cancel the appointment. Please try again.'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } finally {
      if (mounted) setState(() => _isProcessing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: const Color(0xFFE2EEEA),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.red.withAlpha(20),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.warning_amber_rounded,
                  color: Colors.red, size: 40),
            ),
            const SizedBox(height: 16),
            const Text(
              'Cancel this appointment?',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF173330),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Are you sure you want to cancel your appointment with Dr. ${widget.appointment.doctorName} on ${widget.appointment.dateTime}?',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 14, color: Color(0xFF5A716E), height: 1.4),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: SizedBox(
                    height: 48,
                    child: OutlinedButton(
                      onPressed: _isProcessing
                          ? null
                          : () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Color(0xFF8C9E9A)),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(24),
                        ),
                      ),
                      child: const Text(
                        'Keep Appointment',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF173330),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: SizedBox(
                    height: 48,
                    child: ElevatedButton(
                      onPressed: _isProcessing ? null : _processCancellation,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(24),
                        ),
                      ),
                      child: _isProcessing
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                          : const Text(
                              'Cancel Appointment',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
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

/// CANCEL SUCCESS SCREEN
class CancelSuccessScreen extends StatelessWidget {
  final Appointment appointment;

  const CancelSuccessScreen({super.key, required this.appointment});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FCFA),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            children: [
              const Spacer(),
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.red.withAlpha(20),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.check_circle_outline,
                    color: Colors.red, size: 64),
              ),
              const SizedBox(height: 24),
              const Text(
                'Appointment Cancelled',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF173330),
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Your appointment has been successfully cancelled in MediSimbio.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14, color: Color(0xFF5A716E)),
              ),
              const SizedBox(height: 32),
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: const Color(0xFFE2EEEA)),
                ),
                child: Column(
                  children: [
                    _buildRow('Doctor', appointment.doctorName),
                    const Divider(height: 20),
                    _buildRow('Hospital / Clinic', appointment.hospitalName),
                    const Divider(height: 20),
                    _buildRow('Date & Time', appointment.dateTime),
                    const Divider(height: 20),
                    _buildRow('Status', 'CANCELLED', isStatus: true),
                  ],
                ),
              ),
              const Spacer(),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.popUntil(context, (route) => route.isFirst);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0B7A6E),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(26),
                    ),
                  ),
                  child: const Text(
                    'Back to Dashboard',
                    style: TextStyle(
                        fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRow(String label, String value, {bool isStatus = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label,
            style: const TextStyle(fontSize: 13, color: Color(0xFF5A716E))),
        Text(
          value,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: isStatus ? Colors.red : const Color(0xFF173330),
          ),
        ),
      ],
    );
  }
}

/// RESCHEDULE APPOINTMENT SCREEN
class RescheduleAppointmentScreen extends StatefulWidget {
  final Appointment appointment;

  const RescheduleAppointmentScreen({super.key, required this.appointment});

  @override
  State<RescheduleAppointmentScreen> createState() =>
      _RescheduleAppointmentScreenState();
}

class _RescheduleAppointmentScreenState
    extends State<RescheduleAppointmentScreen> {
  DateTime _selectedDate = DateTime.now().add(const Duration(days: 1));
  String _selectedSlot = '10:00 AM';

  final List<String> _availableSlots = [
    '09:00 AM',
    '10:00 AM',
    '11:00 AM',
    '02:00 PM',
    '03:00 PM',
    '04:00 PM',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FCFA),
      appBar: AppBar(
        title: const Text(
          'Reschedule Appointment',
          style:
              TextStyle(color: Color(0xFF173330), fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Color(0xFF173330)),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: ListView(
                  children: [
                    // Doctor Info Summary
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: const Color(0xFFE2EEEA)),
                      ),
                      child: Row(
                        children: [
                          CircleAvatar(
                            backgroundColor:
                                const Color(0xFF0B7A6E).withAlpha(20),
                            radius: 24,
                            child: const Icon(Icons.person,
                                color: Color(0xFF0B7A6E)),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  widget.appointment.doctorName,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF173330),
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Current: ${widget.appointment.dateTime}',
                                  style: const TextStyle(
                                      fontSize: 13, color: Color(0xFF5A716E)),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Date Selection
                    const Text(
                      'Select New Date',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF173330),
                      ),
                    ),
                    const SizedBox(height: 12),

                    SizedBox(
                      height: 70,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: 7,
                        itemBuilder: (context, index) {
                          final date =
                              DateTime.now().add(Duration(days: index + 1));
                          final isSelected =
                              _selectedDate.day == date.day &&
                                  _selectedDate.month == date.month;

                          return GestureDetector(
                            onTap: () {
                              setState(() {
                                _selectedDate = date;
                              });
                            },
                            child: Container(
                              width: 60,
                              margin: const EdgeInsets.only(right: 12),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? const Color(0xFF0B7A6E)
                                    : Colors.white,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: isSelected
                                      ? const Color(0xFF0B7A6E)
                                      : const Color(0xFFE2EEEA),
                                ),
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    _getDayAbbr(date.weekday),
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: isSelected
                                          ? Colors.white70
                                          : const Color(0xFF5A716E),
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    '${date.day}',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: isSelected
                                          ? Colors.white
                                          : const Color(0xFF173330),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Slot Selection
                    const Text(
                      'Select New Time Slot',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF173330),
                      ),
                    ),
                    const SizedBox(height: 12),

                    Wrap(
                      spacing: 12,
                      runSpacing: 12,
                      children: _availableSlots.map((slot) {
                        final isSelected = _selectedSlot == slot;
                        return ChoiceChip(
                          label: Text(slot),
                          selected: isSelected,
                          onSelected: (selected) {
                            if (selected) {
                              setState(() {
                                _selectedSlot = slot;
                              });
                            }
                          },
                          selectedColor: const Color(0xFF0B7A6E),
                          labelStyle: TextStyle(
                            color: isSelected
                                ? Colors.white
                                : const Color(0xFF173330),
                            fontWeight: isSelected
                                ? FontWeight.bold
                                : FontWeight.normal,
                          ),
                          backgroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                            side: BorderSide(
                              color: isSelected
                                  ? const Color(0xFF0B7A6E)
                                  : const Color(0xFFE2EEEA),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),

              // Review Reschedule Action Button
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: () {
                    final formattedDate =
                        '${_selectedDate.year}-${_selectedDate.month.toString().padLeft(2, '0')}-${_selectedDate.day.toString().padLeft(2, '0')} at $_selectedSlot';

                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => RescheduleReviewScreen(
                          appointment: widget.appointment,
                          newDateTime: formattedDate,
                        ),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0B7A6E),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(26),
                    ),
                  ),
                  child: const Text(
                    'Review Reschedule',
                    style: TextStyle(
                        fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _getDayAbbr(int weekday) {
    switch (weekday) {
      case 1:
        return 'MON';
      case 2:
        return 'TUE';
      case 3:
        return 'WED';
      case 4:
        return 'THU';
      case 5:
        return 'FRI';
      case 6:
        return 'SAT';
      case 7:
        return 'SUN';
      default:
        return '';
    }
  }
}

/// RESCHEDULE REVIEW SCREEN
class RescheduleReviewScreen extends StatefulWidget {
  final Appointment appointment;
  final String newDateTime;

  const RescheduleReviewScreen({
    super.key,
    required this.appointment,
    required this.newDateTime,
  });

  @override
  State<RescheduleReviewScreen> createState() => _RescheduleReviewScreenState();
}

class _RescheduleReviewScreenState extends State<RescheduleReviewScreen> {
  bool _isProcessing = false;

  Future<void> _confirmReschedule() async {
    setState(() {
      _isProcessing = true;
    });

    try {
      await AppointmentService().rescheduleAppointment(
        uid: widget.appointment.uid,
        appointmentId: widget.appointment.id,
        newDateTime: widget.newDateTime,
      );

      if (!mounted) return;

      // Send notification
      final notif = AppNotification(
        notificationId: DateTime.now().millisecondsSinceEpoch.toString(),
        patientId: widget.appointment.uid,
        category: NotificationCategory.appointment,
        title: 'Appointment Rescheduled',
        message:
            'Your appointment with Dr. ${widget.appointment.doctorName} has been rescheduled to ${widget.newDateTime}.',
        createdAt: DateTime.now(),
        isRead: false,
        referenceId: widget.appointment.id,
      );
      await NotificationService().createNotification(widget.appointment.uid, notif);

      final updatedAppt = widget.appointment.copyWith(
        dateTime: widget.newDateTime,
        status: AppointmentStatus.rescheduled,
      );

      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => RescheduleSuccessScreen(appointment: updatedAppt),
        ),
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Unable to reschedule this appointment.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isProcessing = false;
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
          'Review Reschedule',
          style:
              TextStyle(color: Color(0xFF173330), fontWeight: FontWeight.bold),
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
                    // Current Appointment Card
                    const Text(
                      'CURRENT APPOINTMENT',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF8C9E9A),
                        letterSpacing: 1.1,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: const Color(0xFFE2EEEA)),
                      ),
                      child: Column(
                        children: [
                          _buildReviewRow('Doctor', widget.appointment.doctorName),
                          const Divider(height: 16),
                          _buildReviewRow('Clinic / Hospital', widget.appointment.hospitalName),
                          const Divider(height: 16),
                          _buildReviewRow('Date & Time', widget.appointment.dateTime),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),
                    const Center(
                      child: Icon(Icons.arrow_downward, color: Color(0xFF0B7A6E)),
                    ),
                    const SizedBox(height: 24),

                    // New Appointment Card
                    const Text(
                      'NEW APPOINTMENT',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF0B7A6E),
                        letterSpacing: 1.1,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: const Color(0xFF0B7A6E), width: 1.5),
                      ),
                      child: Column(
                        children: [
                          _buildReviewRow('Doctor', widget.appointment.doctorName),
                          const Divider(height: 16),
                          _buildReviewRow('Clinic / Hospital', widget.appointment.hospitalName),
                          const Divider(height: 16),
                          _buildReviewRow('New Date & Time', widget.newDateTime, isHighlighted: true),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // Confirm Button
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: _isProcessing ? null : _confirmReschedule,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0B7A6E),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(26),
                    ),
                  ),
                  child: _isProcessing
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : const Text(
                          'Confirm Reschedule',
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

  Widget _buildReviewRow(String label, String value, {bool isHighlighted = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(fontSize: 13, color: Color(0xFF5A716E))),
        Text(
          value,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: isHighlighted ? const Color(0xFF0B7A6E) : const Color(0xFF173330),
          ),
        ),
      ],
    );
  }
}

/// RESCHEDULE SUCCESS SCREEN
class RescheduleSuccessScreen extends StatelessWidget {
  final Appointment appointment;

  const RescheduleSuccessScreen({super.key, required this.appointment});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FCFA),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            children: [
              const Spacer(),
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: const Color(0xFF0B7A6E).withAlpha(20),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.check_circle_outline,
                    color: Color(0xFF0B7A6E), size: 64),
              ),
              const SizedBox(height: 24),
              const Text(
                'Appointment Rescheduled',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF173330),
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Your appointment date and time have been updated.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14, color: Color(0xFF5A716E)),
              ),
              const SizedBox(height: 32),
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: const Color(0xFFE2EEEA)),
                ),
                child: Column(
                  children: [
                    _buildRow('Doctor', appointment.doctorName),
                    const Divider(height: 20),
                    _buildRow('Hospital / Clinic', appointment.hospitalName),
                    const Divider(height: 20),
                    _buildRow('New Date & Time', appointment.dateTime),
                    const Divider(height: 20),
                    _buildRow('Status', 'RESCHEDULED', isStatus: true),
                  ],
                ),
              ),
              const Spacer(),
              Row(
                children: [
                  Expanded(
                    child: SizedBox(
                      height: 52,
                      child: OutlinedButton.icon(
                        onPressed: () {
                          CalendarHelper.addToCalendar(context, appointment);
                        },
                        icon: const Icon(Icons.calendar_today,
                            size: 18, color: Color(0xFF0B7A6E)),
                        label: const Text(
                          'Add to Calendar',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF0B7A6E),
                          ),
                        ),
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: Color(0xFF0B7A6E)),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(26),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: SizedBox(
                      height: 52,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.popUntil(context, (route) => route.isFirst);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF0B7A6E),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(26),
                          ),
                        ),
                        child: const Text(
                          'Back to Dashboard',
                          style: TextStyle(
                              fontSize: 13, fontWeight: FontWeight.bold),
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

  Widget _buildRow(String label, String value, {bool isStatus = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label,
            style: const TextStyle(fontSize: 13, color: Color(0xFF5A716E))),
        Text(
          value,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: isStatus ? Colors.orange : const Color(0xFF173330),
          ),
        ),
      ],
    );
  }
}

/// LIVE TRACKING SCREEN (Provider Data Only - NO fake maps/markers/tokens)
class LiveTrackingScreen extends StatefulWidget {
  final Appointment appointment;

  const LiveTrackingScreen({super.key, required this.appointment});

  @override
  State<LiveTrackingScreen> createState() => _LiveTrackingScreenState();
}

class _LiveTrackingScreenState extends State<LiveTrackingScreen> {
  int _retryKey = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FCFA),
      appBar: AppBar(
        title: const Text(
          'Live Appointment',
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
        child: StreamBuilder<Appointment?>(
          key: ValueKey(_retryKey),
          stream: AppointmentService().streamAppointmentById(
            widget.appointment.uid,
            widget.appointment.id,
          ),
          builder: (context, snapshot) {
            // Priority 1: Backend / Connection Error
            if (snapshot.hasError) {
              return _buildErrorView(context, snapshot.error);
            }

            if (snapshot.connectionState == ConnectionState.waiting &&
                !snapshot.hasData) {
              return const Center(
                child: CircularProgressIndicator(color: Color(0xFF0B7A6E)),
              );
            }

            final liveAppt = snapshot.data ?? widget.appointment;

            // Priority 2: COMPLETED
            if (liveAppt.status == AppointmentStatus.completed) {
              return _buildCompletedView(context, liveAppt);
            }

            // Priority 3: NO LIVE TRACKING
            if (!liveAppt.isLiveTrackingActive) {
              return _buildNoLiveTrackingView(context, liveAppt);
            }

            // Freshness Rule: Stale if last updated >= 5 mins ago
            final bool isStale = liveAppt.trackingLastUpdated != null &&
                DateTime.now()
                        .difference(liveAppt.trackingLastUpdated!)
                        .inMinutes >=
                    5;

            // Priority 4: YOUR TURN
            final bool isYourTurn =
                (liveAppt.status == AppointmentStatus.inConsultation) ||
                    (liveAppt.tokenNumber != null &&
                        liveAppt.currentServingToken != null &&
                        liveAppt.tokenNumber == liveAppt.currentServingToken);

            if (isYourTurn) {
              return _buildYourTurnView(context, liveAppt, isStale: isStale);
            }

            // Priority 5: LIVE (Active Queue Tracking)
            return _buildLiveTrackingView(context, liveAppt, isStale: isStale);
          },
        ),
      ),
    );
  }

  // --- STATE VIEWS ---

  Widget _buildErrorView(BuildContext context, dynamic error) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        children: [
          Expanded(
            child: ListView(
              children: [
                const SizedBox(height: 40),
                Center(
                  child: Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.red.withAlpha(20),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.cloud_off_outlined,
                      color: Colors.red,
                      size: 64,
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                const Text(
                  'Unable to Load Live Tracking',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF173330),
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  'Could not retrieve live tracking data from the server.\nPlease check your connection and try again.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    color: Color(0xFF5A716E),
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
          Row(
            children: [
              Expanded(
                child: SizedBox(
                  height: 52,
                  child: OutlinedButton(
                    onPressed: () {
                      setState(() {
                        _retryKey++;
                      });
                    },
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Color(0xFF0B7A6E)),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(26),
                      ),
                    ),
                    child: const Text(
                      'Retry',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF0B7A6E),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: SizedBox(
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
                      'Back to Details',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
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
  }

  Widget _buildCompletedView(BuildContext context, Appointment appt) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        children: [
          Expanded(
            child: ListView(
              children: [
                const SizedBox(height: 32),
                Center(
                  child: Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.grey.withAlpha(30),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.task_alt,
                      color: Color(0xFF173330),
                      size: 64,
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                const Text(
                  'Appointment Completed',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF173330),
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'This appointment has been completed. Live tracking is no longer active.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    color: Color(0xFF5A716E),
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 32),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: const Color(0xFFE2EEEA)),
                  ),
                  child: Column(
                    children: [
                      _buildSummaryRow('Doctor', appt.doctorName),
                      const Divider(height: 20),
                      _buildSummaryRow('Clinic / Hospital', appt.hospitalName),
                      const Divider(height: 20),
                      _buildSummaryRow('Date & Time', appt.dateTime),
                      const Divider(height: 20),
                      _buildSummaryRow('Status', 'COMPLETED'),
                    ],
                  ),
                ),
              ],
            ),
          ),
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
                'Back to Details',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNoLiveTrackingView(BuildContext context, Appointment appt) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        children: [
          Expanded(
            child: ListView(
              children: [
                const SizedBox(height: 32),
                Center(
                  child: Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: const Color(0xFF0B7A6E).withAlpha(20),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.sensors_off_outlined,
                      color: Color(0xFF0B7A6E),
                      size: 64,
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                const Text(
                  'Live Tracking Unavailable',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF173330),
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  'Live tracking is not available for this appointment.\nLive queue and appointment status will appear when the healthcare provider enables live tracking.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    color: Color(0xFF5A716E),
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 32),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: const Color(0xFFE2EEEA)),
                  ),
                  child: Column(
                    children: [
                      _buildSummaryRow('Doctor', appt.doctorName),
                      const Divider(height: 20),
                      _buildSummaryRow('Specialty', appt.specialty),
                      const Divider(height: 20),
                      _buildSummaryRow('Clinic / Hospital', appt.hospitalName),
                      const Divider(height: 20),
                      _buildSummaryRow('Date & Time', appt.dateTime),
                    ],
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
                'Back to Details',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildYourTurnView(BuildContext context, Appointment appt,
      {required bool isStale}) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        children: [
          Expanded(
            child: ListView(
              children: [
                if (isStale) _buildStaleBanner(),

                // Your Turn Card
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: const Color(0xFF0B7A6E),
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF0B7A6E).withAlpha(60),
                        blurRadius: 16,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white.withAlpha(40),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.notifications_active,
                          color: Colors.white,
                          size: 48,
                        ),
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'Your Turn',
                        style: TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'The provider has indicated that it is your turn. Please proceed to the consultation room.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.white70,
                          height: 1.4,
                        ),
                      ),
                      const SizedBox(height: 20),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 10),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          appt.tokenNumber != null
                              ? 'Token #${appt.tokenNumber}'
                              : 'Token Available',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF0B7A6E),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: const Color(0xFFE2EEEA)),
                  ),
                  child: Column(
                    children: [
                      _buildSummaryRow('Doctor', appt.doctorName),
                      const Divider(height: 20),
                      _buildSummaryRow('Clinic / Hospital', appt.hospitalName),
                      const Divider(height: 20),
                      _buildSummaryRow('Consultation Type', appt.consultationType),
                    ],
                  ),
                ),
              ],
            ),
          ),
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
                'Back to Details',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLiveTrackingView(BuildContext context, Appointment appt,
      {required bool isStale}) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        children: [
          Expanded(
            child: ListView(
              children: [
                if (isStale) _buildStaleBanner(),

                // Doctor Info Card
                Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: const Color(0xFFE2EEEA)),
                  ),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 26,
                        backgroundColor:
                            const Color(0xFF0B7A6E).withAlpha(25),
                        child: const Icon(Icons.person,
                            size: 30, color: Color(0xFF0B7A6E)),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              appt.doctorName,
                              style: const TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF173330),
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              '${appt.specialty} • ${appt.hospitalName}',
                              style: const TextStyle(
                                fontSize: 13,
                                color: Color(0xFF5A716E),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // Real Provider Queue Tracking Card
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: const Color(0xFFE2EEEA)),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withAlpha(4),
                        blurRadius: 10,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Current Status Badge
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Current Status',
                            style: TextStyle(
                              fontSize: 13,
                              color: Color(0xFF5A716E),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: const Color(0xFF0B7A6E).withAlpha(25),
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: Text(
                              appt.status.toUpperCase(),
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF0B7A6E),
                              ),
                            ),
                          ),
                        ],
                      ),

                      const Divider(height: 24),

                      // Your Token & Currently Serving Grid
                      Row(
                        children: [
                          Expanded(
                            child: _buildTrackingMetricBox(
                              label: 'Your Token',
                              value: appt.tokenNumber != null
                                  ? '#${appt.tokenNumber}'
                                  : 'Token unavailable',
                              isPrimary: appt.tokenNumber != null,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _buildTrackingMetricBox(
                              label: 'Currently Serving',
                              value: appt.currentServingToken != null
                                  ? '#${appt.currentServingToken}'
                                  : 'Queue unavailable',
                              isPrimary: false,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 16),

                      // Estimated Wait & Queue Position Grid
                      Row(
                        children: [
                          Expanded(
                            child: _buildTrackingMetricBox(
                              label: 'Estimated Wait',
                              value: appt.estimatedWaitMinutes != null
                                  ? '${appt.estimatedWaitMinutes} min'
                                  : 'Waiting time unavailable',
                              isPrimary: false,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _buildTrackingMetricBox(
                              label: 'Queue Position',
                              value: appt.queuePosition != null
                                  ? '#${appt.queuePosition}'
                                  : 'Queue position unavailable',
                              isPrimary: false,
                            ),
                          ),
                        ],
                      ),

                      if (appt.trackingLastUpdated != null) ...[
                        const Divider(height: 24),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            const Icon(Icons.sync,
                                size: 14, color: Color(0xFF8C9E9A)),
                            const SizedBox(width: 4),
                            Text(
                              'Last updated: ${appt.trackingLastUpdated!.hour}:${appt.trackingLastUpdated!.minute.toString().padLeft(2, '0')}',
                              style: const TextStyle(
                                fontSize: 11,
                                color: Color(0xFF8C9E9A),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
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
                'Back to Details',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStaleBanner() {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.amber.withAlpha(30),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.amber.shade300),
      ),
      child: const Row(
        children: [
          Icon(Icons.warning_amber_rounded, color: Colors.amber, size: 20),
          SizedBox(width: 10),
          Expanded(
            child: Text(
              'Tracking information may be outdated.',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Color(0xFF173330),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label,
            style: const TextStyle(fontSize: 13, color: Color(0xFF5A716E))),
        Flexible(
          child: Text(
            value,
            textAlign: TextAlign.end,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Color(0xFF173330),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTrackingMetricBox({
    required String label,
    required String value,
    required bool isPrimary,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
      decoration: BoxDecoration(
        color: isPrimary
            ? const Color(0xFF0B7A6E).withAlpha(15)
            : const Color(0xFFF8FCFA),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isPrimary ? const Color(0xFF0B7A6E) : const Color(0xFFE2EEEA),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              color: Color(0xFF5A716E),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: isPrimary ? const Color(0xFF0B7A6E) : const Color(0xFF173330),
            ),
          ),
        ],
      ),
    );
  }
}

/// MY APPOINTMENTS LIST SCREEN
class MyAppointmentsScreen extends StatelessWidget {
  const MyAppointmentsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseService().currentUser;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FCFA),
      appBar: AppBar(
        title: const Text(
          'My Appointments',
          style:
              TextStyle(color: Color(0xFF173330), fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Color(0xFF173330)),
      ),
      body: user == null
          ? const Center(child: Text('No authenticated user'))
          : StreamBuilder<List<Appointment>>(
              stream: AppointmentService().streamUserAppointments(user.uid),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(color: Color(0xFF0B7A6E)),
                  );
                }

                final appointments = snapshot.data ?? [];
                if (appointments.isEmpty) {
                  return const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.calendar_today_outlined,
                            size: 64, color: Color(0xFF8C9E9A)),
                        SizedBox(height: 16),
                        Text(
                          'No Appointments Found',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF173330),
                          ),
                        ),
                        SizedBox(height: 6),
                        Text(
                          'You have no saved appointments in Firestore.',
                          style: TextStyle(color: Color(0xFF5A716E)),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.separated(
                  padding: const EdgeInsets.all(20),
                  itemCount: appointments.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final appt = appointments[index];
                    return InkWell(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) =>
                                AppointmentDetailsScreen(appointment: appt),
                          ),
                        );
                      },
                      borderRadius: BorderRadius.circular(16),
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
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
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Text(
                                    appt.doctorName,
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF173330),
                                    ),
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 10, vertical: 4),
                                  decoration: BoxDecoration(
                                    color:
                                        const Color(0xFF0B7A6E).withAlpha(25),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    appt.status,
                                    style: const TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF0B7A6E),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '${appt.specialty} • ${appt.hospitalName}',
                              style: const TextStyle(
                                  fontSize: 13, color: Color(0xFF5A716E)),
                            ),
                            const SizedBox(height: 6),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Date & Time: ${appt.dateTime}',
                                  style: const TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                    color: Color(0xFF173330),
                                  ),
                                ),
                                const Icon(Icons.arrow_forward_ios,
                                    size: 14, color: Color(0xFF8C9E9A)),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
    );
  }
}

/// CLINIC / HOSPITAL NAVIGATION SCREEN (Phase 1C - Provider/Dynamic Data Only)
class AppointmentNavigationScreen extends StatelessWidget {
  final Appointment appointment;

  const AppointmentNavigationScreen({super.key, required this.appointment});

  Future<void> _openExternalNavigation(BuildContext context) async {
    Uri? uri;
    if (appointment.latitude != null && appointment.longitude != null) {
      uri = Uri.parse(
          'https://www.google.com/maps/search/?api=1&query=${appointment.latitude},${appointment.longitude}');
    } else if (appointment.hospitalAddress != null &&
        appointment.hospitalAddress!.trim().isNotEmpty) {
      final encodedAddress =
          Uri.encodeComponent(appointment.hospitalAddress!.trim());
      uri = Uri.parse(
          'https://www.google.com/maps/search/?api=1&query=$encodedAddress');
    } else if (appointment.hospitalName.trim().isNotEmpty) {
      final encodedName = Uri.encodeComponent(appointment.hospitalName.trim());
      uri = Uri.parse(
          'https://www.google.com/maps/search/?api=1&query=$encodedName');
    }

    if (uri != null) {
      try {
        final bool launched = await launchUrl(
          uri,
          mode: LaunchMode.externalApplication,
        );
        if (!launched && context.mounted) {
          _showNavigationError(context);
        }
      } catch (_) {
        if (context.mounted) {
          _showNavigationError(context);
        }
      }
    } else {
      _showNavigationError(context);
    }
  }

  void _showNavigationError(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Unable to open navigation. Please try again.'),
        backgroundColor: Color(0xFF173330),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool hasValidLocation = (appointment.latitude != null &&
            appointment.longitude != null) ||
        (appointment.hospitalAddress != null &&
            appointment.hospitalAddress!.trim().isNotEmpty) ||
        appointment.hospitalName.trim().isNotEmpty;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FCFA),
      appBar: AppBar(
        title: const Text(
          'Clinic Location',
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
                    // Destination Card Header
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
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF0B7A6E).withAlpha(20),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(Icons.local_hospital_outlined,
                                    color: Color(0xFF0B7A6E), size: 28),
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'Destination',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Color(0xFF5A716E),
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      appointment.hospitalName,
                                      style: const TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: Color(0xFF173330),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          if (appointment.hospitalAddress != null &&
                              appointment.hospitalAddress!.trim().isNotEmpty) ...[
                            const Divider(height: 24),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Icon(Icons.location_on_outlined,
                                    size: 18, color: Color(0xFF0B7A6E)),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    appointment.hospitalAddress!,
                                    style: const TextStyle(
                                      fontSize: 13,
                                      color: Color(0xFF5A716E),
                                      height: 1.3,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ],
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Distance & ETA Box (Real Dynamic Values Only - Displays '--' if unprovided)
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: const Color(0xFFE2EEEA)),
                      ),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: _buildMetricTile(
                                  label: 'Distance',
                                  value: '--',
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: _buildMetricTile(
                                  label: 'Estimated arrival',
                                  value: '--',
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          const Text(
                            'Exact distance and estimated arrival time will update automatically when external navigation is launched.',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 12,
                              color: Color(0xFF8C9E9A),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 20),

                    if (!hasValidLocation)
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.amber.withAlpha(25),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: Colors.amber.shade200),
                        ),
                        child: const Row(
                          children: [
                            Icon(Icons.info_outline, color: Colors.amber),
                            SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                'Location information is currently unavailable for this clinic/hospital.',
                                style: TextStyle(
                                  fontSize: 13,
                                  color: Color(0xFF173330),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // Open Navigation Action Button
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton.icon(
                  onPressed: () => _openExternalNavigation(context),
                  icon: const Icon(Icons.navigation_outlined, size: 20),
                  label: const Text(
                    'Open Navigation',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0B7A6E),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(26),
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

  Widget _buildMetricTile({required String label, required String value}) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FCFA),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE2EEEA)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(fontSize: 12, color: Color(0xFF5A716E)),
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF173330),
            ),
          ),
        ],
      ),
    );
  }
}
