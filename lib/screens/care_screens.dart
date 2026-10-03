import 'package:flutter/material.dart';
import 'package:medisimbio_ui/models/appointment.dart';
import 'package:medisimbio_ui/models/doctor.dart';
import 'package:medisimbio_ui/screens/feature_placeholder_screens.dart';
import 'package:medisimbio_ui/services/appointment_service.dart';
import 'package:medisimbio_ui/services/doctor_repository.dart';
import 'package:medisimbio_ui/services/firebase_service.dart';
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
        status: 'CONFIRMED',
        isLiveTrackingActive: false,
        createdAt: DateTime.now(),
      );

      await _appointmentService.saveAppointment(appointment);

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
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to book appointment: ${e.toString()}'),
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

/// APPOINTMENT DETAILS SCREEN
class AppointmentDetailsScreen extends StatelessWidget {
  final Appointment appointment;

  const AppointmentDetailsScreen({super.key, required this.appointment});

  @override
  Widget build(BuildContext context) {
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
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(24),
                children: [
                  // Status Badge & Doctor Card
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
                                color: const Color(0xFF0B7A6E).withAlpha(25),
                                borderRadius: BorderRadius.circular(14),
                              ),
                              child: Text(
                                appointment.status.toUpperCase(),
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
                                    appointment.doctorName,
                                    style: const TextStyle(
                                      fontSize: 17,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF173330),
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    appointment.specialty,
                                    style: const TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                      color: Color(0xFF0B7A6E),
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    appointment.hospitalName,
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
                        _buildDetailRow('Appointment ID', appointment.id),
                        const Divider(height: 24),
                        _buildDetailRow('Date & Time', appointment.dateTime),
                        const Divider(height: 24),
                        _buildDetailRow('Consultation Mode',
                            appointment.consultationType),
                        if (appointment.consultationFee > 0) ...[
                          const Divider(height: 24),
                          _buildDetailRow(
                            'Consultation Fee',
                            '\$${appointment.consultationFee.toInt()}',
                            isFee: true,
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Action Buttons: Track & Cancel/Reschedule
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                children: [
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => LiveTrackingScreen(
                                appointment: appointment),
                          ),
                        );
                      },
                      icon: const Icon(Icons.location_searching, size: 20),
                      label: const Text(
                        'Track Appointment',
                        style: TextStyle(
                          fontSize: 15,
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
                  const SizedBox(height: 10),
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: OutlinedButton.icon(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => AppointmentNavigationScreen(
                                appointment: appointment),
                          ),
                        );
                      },
                      icon: const Icon(Icons.directions_outlined,
                          size: 18, color: Color(0xFF0B7A6E)),
                      label: const Text(
                        'Get Directions',
                        style: TextStyle(
                          fontSize: 14,
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
                  const SizedBox(height: 10),
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: OutlinedButton(
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              'To cancel or reschedule, please contact ${appointment.hospitalName} directly.',
                              style: const TextStyle(fontSize: 13),
                            ),
                            backgroundColor: const Color(0xFF173330),
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                      },
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Color(0xFF8C9E9A)),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(24),
                        ),
                      ),
                      child: const Text(
                        'Cancel / Reschedule',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF5A716E),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
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

/// LIVE TRACKING SCREEN (Provider Data Only - NO fake maps/markers/tokens)
class LiveTrackingScreen extends StatelessWidget {
  final Appointment appointment;

  const LiveTrackingScreen({super.key, required this.appointment});

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
          stream: AppointmentService().streamAppointmentById(
            appointment.uid,
            appointment.id,
          ),
          builder: (context, snapshot) {
            final liveAppt = snapshot.data ?? appointment;
            final bool isTrackingAvailable = liveAppt.isLiveTrackingActive &&
                (liveAppt.tokenNumber != null ||
                    liveAppt.currentServingToken != null ||
                    liveAppt.queuePosition != null ||
                    liveAppt.estimatedWaitMinutes != null);

            if (!isTrackingAvailable) {
              return _buildUnavailableView(context, liveAppt);
            }

            return _buildProviderTrackingView(context, liveAppt);
          },
        ),
      ),
    );
  }

  Widget _buildUnavailableView(BuildContext context, Appointment appt) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        children: [
          Expanded(
            child: ListView(
              children: [
                const SizedBox(height: 32),

                // Unavailable State Icon
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
                  'Live tracking is currently unavailable for this appointment.\nLive queue and appointment status will appear when the healthcare provider enables live tracking.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    color: Color(0xFF5A716E),
                    height: 1.4,
                  ),
                ),

                const SizedBox(height: 32),

                // Appointment Summary Box (Real values only)
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

  Widget _buildProviderTrackingView(BuildContext context, Appointment appt) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        children: [
          Expanded(
            child: ListView(
              children: [
                // Doctor Info Header Card
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
                                  : '--',
                              isPrimary: true,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _buildTrackingMetricBox(
                              label: 'Currently Serving',
                              value: appt.currentServingToken != null
                                  ? '#${appt.currentServingToken}'
                                  : '--',
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
                                  : '--',
                              isPrimary: false,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _buildTrackingMetricBox(
                              label: 'Queue Position',
                              value: appt.queuePosition != null
                                  ? '#${appt.queuePosition}'
                                  : '--',
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
