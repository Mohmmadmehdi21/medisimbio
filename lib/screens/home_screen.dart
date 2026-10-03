import 'package:flutter/material.dart';
import 'package:medisimbio_ui/models/appointment.dart';
import 'package:medisimbio_ui/models/patient_profile.dart';
import 'package:medisimbio_ui/screens/ai_health_screens.dart';
import 'package:medisimbio_ui/screens/auth_wrapper.dart';
import 'package:medisimbio_ui/screens/care_screens.dart';
import 'package:medisimbio_ui/screens/edit_profile_screen.dart';
import 'package:medisimbio_ui/screens/existing_med_id_screen.dart';
import 'package:medisimbio_ui/screens/feature_placeholder_screens.dart';
import 'package:medisimbio_ui/services/appointment_service.dart';
import 'package:medisimbio_ui/services/firebase_service.dart';
import 'package:medisimbio_ui/services/profile_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final FirebaseService _firebaseService = FirebaseService();
  final ProfileService _profileService = ProfileService();
  final AppointmentService _appointmentService = AppointmentService();
  int _currentIndex = 0;

  void _onBottomNavTapped(int index) {
    if (index == 0) {
      setState(() => _currentIndex = 0);
    } else if (index == 1) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const CareServicesScreen()),
      );
    } else if (index == 2) {
      _navigateToFeature(
        'Medical Records',
        Icons.folder_shared_outlined,
        Colors.blue,
      );
    } else if (index == 3) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const AiHealthStartScreen()),
      );
    } else if (index == 4) {
      _openProfileScreen();
    }
  }

  void _navigateToFeature(String title, IconData icon, Color color) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => FeaturePlaceholderScreen(
          title: title,
          icon: icon,
          accentColor: color,
        ),
      ),
    );
  }

  void _openProfileScreen() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const ProfileViewScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = _firebaseService.currentUser;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FCFA),
      body: SafeArea(
        child: user == null
            ? const Center(child: Text('No authenticated session'))
            : StreamBuilder<PatientProfile?>(
                stream: _profileService.streamProfile(user.uid),
                builder: (context, snapshot) {
                  final profile = snapshot.data;
                  final userName = (profile?.name.isNotEmpty == true)
                      ? profile!.name
                      : (user.displayName ?? 'Patient');
                  final medId = (profile?.medId.isNotEmpty == true)
                      ? profile!.medId
                      : 'Not Generated';

                  return SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20.0, vertical: 16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // TOP HEADER
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            // Medisimbio Logo
                            Flexible(
                              child: Image.asset(
                                'assets/images/medisimbio.png',
                                height: 32,
                                fit: BoxFit.contain,
                                errorBuilder: (context, error, stackTrace) =>
                                    const Text(
                                  'Medisimbio',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontSize: 22,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF0B7A6E),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  onPressed: () {
                                    _navigateToFeature(
                                      'Notifications',
                                      Icons.notifications_outlined,
                                      const Color(0xFF0B7A6E),
                                    );
                                  },
                                  icon: const Icon(
                                    Icons.notifications_outlined,
                                    color: Color(0xFF173330),
                                  ),
                                  tooltip: 'Notifications',
                                ),
                                const SizedBox(width: 4),
                                GestureDetector(
                                  onTap: _openProfileScreen,
                                  child: CircleAvatar(
                                    radius: 20,
                                    backgroundColor:
                                        const Color(0xFF0B7A6E).withAlpha(30),
                                    backgroundImage: user.photoURL != null &&
                                            user.photoURL!.isNotEmpty
                                        ? NetworkImage(user.photoURL!)
                                        : null,
                                    child: user.photoURL == null ||
                                            user.photoURL!.isEmpty
                                        ? const Icon(Icons.person,
                                            color: Color(0xFF0B7A6E), size: 22)
                                        : null,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),

                        const SizedBox(height: 20),

                        // GREETING
                        Text(
                          'Good Day, $userName',
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF173330),
                          ),
                        ),
                        const SizedBox(height: 4),
                        GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (_) => const ExistingMedIdScreen()),
                            );
                          },
                          child: Text(
                            'Med ID: $medId',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF0B7A6E),
                            ),
                          ),
                        ),

                        const SizedBox(height: 24),

                        // QUICK ACTION GRID (2 rows x 3 columns)
                        GridView.count(
                          crossAxisCount: 3,
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          mainAxisSpacing: 10,
                          crossAxisSpacing: 10,
                          childAspectRatio: 0.95,
                          children: [
                            _QuickActionCard(
                              title: 'AI Health',
                              icon: Icons.psychology_outlined,
                              accentColor: Colors.purple,
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (_) =>
                                          const AiHealthStartScreen()),
                                );
                              },
                            ),
                            _QuickActionCard(
                              title: 'Find Doctor',
                              icon: Icons.person_search_outlined,
                              accentColor: const Color(0xFF0B7A6E),
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (_) =>
                                          const DoctorDiscoveryScreen()),
                                );
                              },
                            ),
                            _QuickActionCard(
                              title: 'Hospitals',
                              icon: Icons.local_hospital_outlined,
                              accentColor: Colors.indigo,
                              onTap: () => _navigateToFeature(
                                'Hospitals',
                                Icons.local_hospital_outlined,
                                Colors.indigo,
                              ),
                            ),
                            _QuickActionCard(
                              title: 'Appointments',
                              icon: Icons.calendar_today_outlined,
                              accentColor: Colors.orange,
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (_) =>
                                          const MyAppointmentsScreen()),
                                );
                              },
                            ),
                            _QuickActionCard(
                              title: 'Records',
                              icon: Icons.folder_shared_outlined,
                              accentColor: Colors.blue,
                              onTap: () => _navigateToFeature(
                                'Medical Records',
                                Icons.folder_shared_outlined,
                                Colors.blue,
                              ),
                            ),
                            _QuickActionCard(
                              title: 'Pharmacy',
                              icon: Icons.local_pharmacy_outlined,
                              accentColor: Colors.deepOrange,
                              onTap: () => _navigateToFeature(
                                'Pharmacy',
                                Icons.local_pharmacy_outlined,
                                Colors.deepOrange,
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 24),

                        // NEXT APPOINTMENT SECTION (Real Stream + Clean Empty State)
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Next Appointment',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF173330),
                              ),
                            ),
                            TextButton(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (_) =>
                                          const MyAppointmentsScreen()),
                                );
                              },
                              child: const Text(
                                'View All',
                                style: TextStyle(
                                  color: Color(0xFF0B7A6E),
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),

                        StreamBuilder<Appointment?>(
                          stream: _appointmentService
                              .streamLatestAppointment(user.uid),
                          builder: (context, apptSnapshot) {
                            final appt = apptSnapshot.data;

                            if (appt == null) {
                              return Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(
                                      color: const Color(0xFFE2EEEA)),
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
                                      padding: const EdgeInsets.all(10),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFF0B7A6E)
                                            .withAlpha(25),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: const Icon(
                                        Icons.calendar_today_outlined,
                                        color: Color(0xFF0B7A6E),
                                        size: 24,
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    const Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            'No Upcoming Appointments',
                                            style: TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.bold,
                                              color: Color(0xFF173330),
                                            ),
                                          ),
                                          SizedBox(height: 2),
                                          Text(
                                            'Book appointments with certified healthcare providers.',
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: Color(0xFF5A716E),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            }

                            // Displays REAL Appointment from Firestore
                            return GestureDetector(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (_) =>
                                          const MyAppointmentsScreen()),
                                );
                              },
                              child: Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(
                                      color: const Color(0xFF0B7A6E)
                                          .withAlpha(50)),
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
                                      padding: const EdgeInsets.all(10),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFF0B7A6E)
                                            .withAlpha(25),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: const Icon(
                                        Icons.event_available,
                                        color: Color(0xFF0B7A6E),
                                        size: 24,
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            appt.doctorName,
                                            style: const TextStyle(
                                              fontSize: 15,
                                              fontWeight: FontWeight.bold,
                                              color: Color(0xFF173330),
                                            ),
                                          ),
                                          const SizedBox(height: 2),
                                          Text(
                                            '${appt.specialty} • ${appt.dateTime}',
                                            style: const TextStyle(
                                              fontSize: 12,
                                              color: Color(0xFF0B7A6E),
                                              fontWeight: FontWeight.w600,
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
                          },
                        ),

                        const SizedBox(height: 24),

                        // HEALTH SNAPSHOT SECTION
                        const Text(
                          'Health Snapshot',
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
                              child: _HealthSnapshotCard(
                                title: 'BP',
                                value: profile?.bloodGroup.isNotEmpty == true
                                    ? '--/--'
                                    : 'Not Set',
                                unit: 'mmHg',
                                icon: Icons.favorite_outline,
                                color: Colors.redAccent,
                              ),
                            ),
                            const SizedBox(width: 12),
                            const Expanded(
                              child: _HealthSnapshotCard(
                                title: 'Heart Rate',
                                value: '--',
                                unit: 'bpm',
                                icon: Icons.monitor_heart_outlined,
                                color: Color(0xFF0B7A6E),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),
                      ],
                    ),
                  );
                },
              ),
      ),

      // BOTTOM NAVIGATION BAR
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: _onBottomNavTapped,
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.white,
        selectedItemColor: const Color(0xFF0B7A6E),
        unselectedItemColor: const Color(0xFF8C9E9A),
        selectedLabelStyle:
            const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
        unselectedLabelStyle: const TextStyle(fontSize: 12),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_rounded),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.medical_services_outlined),
            label: 'Care',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.folder_shared_outlined),
            label: 'Records',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.psychology_outlined),
            label: 'AI',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline_rounded),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}

/// Profile & Logout View Screen
class ProfileViewScreen extends StatefulWidget {
  const ProfileViewScreen({super.key});

  @override
  State<ProfileViewScreen> createState() => _ProfileViewScreenState();
}

class _ProfileViewScreenState extends State<ProfileViewScreen> {
  final FirebaseService _firebaseService = FirebaseService();
  final ProfileService _profileService = ProfileService();
  bool _isLoggingOut = false;

  Future<void> _showLogoutConfirmationDialog() async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              title: const Text(
                'Logout',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF173330),
                ),
              ),
              content: const Text(
                'Are you sure you want to logout?',
                style: TextStyle(
                  fontSize: 14,
                  color: Color(0xFF5A716E),
                ),
              ),
              actions: [
                TextButton(
                  onPressed:
                      _isLoggingOut ? null : () => Navigator.pop(dialogContext),
                  child: const Text(
                    'Cancel',
                    style: TextStyle(color: Color(0xFF5A716E)),
                  ),
                ),
                ElevatedButton(
                  onPressed: _isLoggingOut
                      ? null
                      : () async {
                          final rootNavigator = Navigator.of(context);
                          final messenger = ScaffoldMessenger.of(context);
                          setDialogState(() => _isLoggingOut = true);
                          try {
                            await _firebaseService.signOut();

                            if (dialogContext.mounted) {
                              Navigator.pop(dialogContext);
                            }
                            rootNavigator.pushAndRemoveUntil(
                              MaterialPageRoute(
                                  builder: (_) => const AuthWrapper()),
                              (route) => false,
                            );
                          } catch (e) {
                            setDialogState(() => _isLoggingOut = false);
                            if (dialogContext.mounted) {
                              Navigator.pop(dialogContext);
                            }
                            messenger.showSnackBar(
                              SnackBar(
                                content: Text('Logout failed: $e'),
                                backgroundColor: Colors.red,
                              ),
                            );
                          }
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red.shade700,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  child: _isLoggingOut
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : const Text('Logout'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = _firebaseService.currentUser;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FCFA),
      appBar: AppBar(
        title: const Text(
          'My Profile',
          style:
              TextStyle(color: Color(0xFF173330), fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Color(0xFF173330)),
      ),
      body: user == null
          ? const Center(child: Text('No authenticated user'))
          : StreamBuilder<PatientProfile?>(
              stream: _profileService.streamProfile(user.uid),
              builder: (context, snapshot) {
                final profile = snapshot.data;
                final name = (profile?.name.isNotEmpty == true)
                    ? profile!.name
                    : (user.displayName ?? 'Patient Name');
                final email = (profile?.email.isNotEmpty == true)
                    ? profile!.email
                    : (user.email ?? 'No email');
                final mobile = (profile?.mobile.isNotEmpty == true)
                    ? profile!.mobile
                    : (user.phoneNumber ?? 'No mobile');
                final medId = (profile?.medId.isNotEmpty == true)
                    ? profile!.medId
                    : 'Not Generated';

                return ListView(
                  padding: const EdgeInsets.all(24),
                  children: [
                    Container(
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
                      child: Column(
                        children: [
                          CircleAvatar(
                            radius: 40,
                            backgroundColor:
                                const Color(0xFF0B7A6E).withAlpha(25),
                            backgroundImage: user.photoURL != null &&
                                    user.photoURL!.isNotEmpty
                                ? NetworkImage(user.photoURL!)
                                : null,
                            child:
                                user.photoURL == null || user.photoURL!.isEmpty
                                    ? const Icon(Icons.person,
                                        size: 40, color: Color(0xFF0B7A6E))
                                    : null,
                          ),
                          const SizedBox(height: 12),
                          Text(
                            name,
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF173330),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            email,
                            style: const TextStyle(
                              fontSize: 13,
                              color: Color(0xFF5A716E),
                            ),
                          ),
                          Text(
                            mobile,
                            style: const TextStyle(
                              fontSize: 13,
                              color: Color(0xFF5A716E),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    ListTile(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                        side: const BorderSide(color: Color(0xFFE2EEEA)),
                      ),
                      tileColor: Colors.white,
                      leading: const Icon(Icons.qr_code_2,
                          color: Color(0xFF0B7A6E), size: 28),
                      title: const Text(
                        'Med ID Card',
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF173330)),
                      ),
                      subtitle: Text(medId,
                          style: const TextStyle(
                              color: Color(0xFF0B7A6E),
                              fontWeight: FontWeight.w600)),
                      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) => const ExistingMedIdScreen()),
                        );
                      },
                    ),
                    const SizedBox(height: 12),
                    ListTile(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                        side: const BorderSide(color: Color(0xFFE2EEEA)),
                      ),
                      tileColor: Colors.white,
                      leading: const Icon(Icons.edit_note_outlined,
                          color: Color(0xFF0B7A6E), size: 28),
                      title: const Text(
                        'Edit Profile Information',
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF173330)),
                      ),
                      subtitle: const Text('Update personal & health details',
                          style: TextStyle(fontSize: 12)),
                      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) => const EditProfileScreen()),
                        );
                      },
                    ),
                    const SizedBox(height: 32),
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: OutlinedButton.icon(
                        onPressed: _showLogoutConfirmationDialog,
                        icon: Icon(Icons.logout, color: Colors.red.shade700),
                        label: Text(
                          'Logout',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.red.shade700,
                          ),
                        ),
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(
                              color: Colors.red.shade300, width: 1.5),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(26),
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
    );
  }
}

class _QuickActionCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color accentColor;
  final VoidCallback onTap;

  const _QuickActionCard({
    required this.title,
    required this.icon,
    required this.accentColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
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
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: accentColor.withAlpha(25),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: accentColor, size: 22),
            ),
            const SizedBox(height: 6),
            Flexible(
              child: Text(
                title,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF173330),
                  height: 1.1,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _HealthSnapshotCard extends StatelessWidget {
  final String title;
  final String value;
  final String unit;
  final IconData icon;
  final Color color;

  const _HealthSnapshotCard({
    required this.title,
    required this.value,
    required this.unit,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
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
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withAlpha(25),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style:
                      const TextStyle(fontSize: 12, color: Color(0xFF5A716E)),
                ),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    Text(
                      value,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF173330),
                      ),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      unit,
                      style: const TextStyle(
                          fontSize: 10, color: Color(0xFF5A716E)),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
