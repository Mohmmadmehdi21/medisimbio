import 'package:medisimbio_ui/models/doctor.dart';

class DoctorRepository {
  // Available doctor catalog
  static final List<Doctor> _doctors = [
    Doctor(
      id: 'doc_1',
      name: 'Dr. Sarah Jenkins',
      specialty: 'Cardiology',
      hospitalName: 'Apollo Medical Center',
      rating: 4.9,
      reviewCount: 128,
      experienceYears: 12,
      consultationFee: 75.0,
      imageUrl: '',
      about:
          'Specialist cardiologist focusing on preventive heart care, hypertension, and cardiovascular wellness.',
      availableDates: ['Today', 'Tomorrow', 'Oct 5', 'Oct 6'],
      availableSlots: ['09:00 AM', '10:30 AM', '02:00 PM', '04:30 PM'],
    ),
    Doctor(
      id: 'doc_2',
      name: 'Dr. Rajesh Sharma',
      specialty: 'General Medicine',
      hospitalName: 'City Healthcare Clinic',
      rating: 4.8,
      reviewCount: 94,
      experienceYears: 15,
      consultationFee: 50.0,
      imageUrl: '',
      about:
          'Experienced physician providing comprehensive primary healthcare, diagnostic consultations, and routine wellness checkups.',
      availableDates: ['Today', 'Tomorrow', 'Oct 4', 'Oct 5'],
      availableSlots: ['09:30 AM', '11:00 AM', '03:00 PM', '05:00 PM'],
    ),
    Doctor(
      id: 'doc_3',
      name: 'Dr. Emily Chen',
      specialty: 'Dermatology',
      hospitalName: 'Skin & Aesthetics Institute',
      rating: 4.9,
      reviewCount: 210,
      experienceYears: 10,
      consultationFee: 90.0,
      imageUrl: '',
      about:
          'Board-certified dermatologist specializing in skin disorders, clinical dermatology, and aesthetic consultations.',
      availableDates: ['Tomorrow', 'Oct 5', 'Oct 7'],
      availableSlots: ['10:00 AM', '01:30 PM', '04:00 PM'],
    ),
    Doctor(
      id: 'doc_4',
      name: 'Dr. Michael Vance',
      specialty: 'Orthopedics',
      hospitalName: 'St. Jude Orthopedic Care',
      rating: 4.7,
      reviewCount: 76,
      experienceYears: 14,
      consultationFee: 85.0,
      imageUrl: '',
      about:
          'Consultant orthopedic surgeon with expertise in joint care, sports injuries, and musculoskeletal health.',
      availableDates: ['Oct 4', 'Oct 5', 'Oct 8'],
      availableSlots: ['11:30 AM', '02:30 PM', '05:30 PM'],
    ),
  ];

  Future<List<Doctor>> getDoctors({
    String searchQuery = '',
    String selectedSpecialty = 'All',
  }) async {
    // Simulate lightweight async fetch
    await Future.delayed(const Duration(milliseconds: 150));

    return _doctors.where((doc) {
      final matchesQuery = searchQuery.isEmpty ||
          doc.name.toLowerCase().contains(searchQuery.toLowerCase()) ||
          doc.specialty.toLowerCase().contains(searchQuery.toLowerCase()) ||
          doc.hospitalName.toLowerCase().contains(searchQuery.toLowerCase());

      final matchesSpecialty = selectedSpecialty == 'All' ||
          doc.specialty.toLowerCase() == selectedSpecialty.toLowerCase();

      return matchesQuery && matchesSpecialty;
    }).toList();
  }

  Future<Doctor?> getDoctorById(String id) async {
    await Future.delayed(const Duration(milliseconds: 50));
    try {
      return _doctors.firstWhere((d) => d.id == id);
    } catch (_) {
      return null;
    }
  }

  List<String> getAvailableSpecialties() {
    final list = _doctors.map((d) => d.specialty).toSet().toList();
    list.sort();
    return ['All', ...list];
  }
}
