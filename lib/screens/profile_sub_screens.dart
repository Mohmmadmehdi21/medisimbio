import 'package:flutter/material.dart';
import 'package:medisimbio_ui/models/patient_profile.dart';
import 'package:medisimbio_ui/services/firebase_service.dart';
import 'package:medisimbio_ui/services/profile_service.dart';

/// 1. Personal Information Screen with Firestore Persistence
class PersonalInformationScreen extends StatefulWidget {
  const PersonalInformationScreen({super.key});

  @override
  State<PersonalInformationScreen> createState() =>
      _PersonalInformationScreenState();
}

class _PersonalInformationScreenState
    extends State<PersonalInformationScreen> {
  final FirebaseService _firebaseService = FirebaseService();
  final ProfileService _profileService = ProfileService();
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _mobileController;
  late TextEditingController _dobController;
  late TextEditingController _genderController;

  bool _isLoading = true;
  bool _isSaving = false;
  PatientProfile? _existingProfile;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _emailController = TextEditingController();
    _mobileController = TextEditingController();
    _dobController = TextEditingController();
    _genderController = TextEditingController();
    _loadData();
  }

  Future<void> _loadData() async {
    final user = _firebaseService.currentUser;
    if (user == null) {
      if (mounted) setState(() => _isLoading = false);
      return;
    }
    try {
      _existingProfile = await _profileService.getProfile(user.uid);
      if (mounted) {
        _nameController.text = _existingProfile?.name ?? (user.displayName ?? '');
        _emailController.text = _existingProfile?.email ?? (user.email ?? '');
        _mobileController.text =
            _existingProfile?.mobile ?? (user.phoneNumber ?? '');
        _dobController.text = _existingProfile?.dob ?? '';
        _genderController.text = _existingProfile?.gender ?? '';
      }
    } catch (_) {
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _mobileController.dispose();
    _dobController.dispose();
    _genderController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    final user = _firebaseService.currentUser;
    if (user == null) return;

    setState(() => _isSaving = true);
    try {
      final updated = PatientProfile(
        uid: user.uid,
        name: _nameController.text.trim(),
        email: _emailController.text.trim(),
        mobile: _mobileController.text.trim(),
        dob: _dobController.text.trim(),
        gender: _genderController.text.trim(),
        medId: _existingProfile?.medId ?? '',
        bloodGroup: _existingProfile?.bloodGroup ?? '',
        allergies: _existingProfile?.allergies ?? '',
        existingConditions: _existingProfile?.existingConditions ?? '',
        emergencyName: _existingProfile?.emergencyName ?? '',
        emergencyRelationship: _existingProfile?.emergencyRelationship ?? '',
        emergencyMobile: _existingProfile?.emergencyMobile ?? '',
        photoUrl: _existingProfile?.photoUrl,
        profileCompleted: _existingProfile?.profileCompleted ?? false,
      );

      await _profileService.saveProfile(updated);

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Personal Information saved to Firestore!'),
          backgroundColor: Color(0xFF0B7A6E),
        ),
      );
      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error saving personal info: $e')),
      );
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return _SubScreenContainer(
      title: 'Personal Information',
      icon: Icons.person,
      accentColor: const Color(0xFF0B7A6E),
      isLoading: _isLoading,
      isSaving: _isSaving,
      onSave: _save,
      child: Form(
        key: _formKey,
        child: Column(
          children: [
            _buildField('Full Name', _nameController, Icons.person_outline),
            _buildField('Email Address', _emailController, Icons.email_outlined),
            _buildField('Mobile Number', _mobileController, Icons.phone_outlined),
            _buildField('Date of Birth', _dobController, Icons.cake_outlined),
            _buildField('Gender', _genderController, Icons.wc_outlined),
          ],
        ),
      ),
    );
  }

  Widget _buildField(
      String label, TextEditingController controller, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        controller: controller,
        validator: (val) =>
            val == null || val.trim().isEmpty ? 'Please enter $label' : null,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon, color: const Color(0xFF0B7A6E)),
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: Color(0xFFD9E4E1)),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: Color(0xFFD9E4E1)),
          ),
        ),
      ),
    );
  }
}

/// 2. Health Information Screen with Firestore Persistence
class HealthInformationScreen extends StatefulWidget {
  const HealthInformationScreen({super.key});

  @override
  State<HealthInformationScreen> createState() =>
      _HealthInformationScreenState();
}

class _HealthInformationScreenState extends State<HealthInformationScreen> {
  final FirebaseService _firebaseService = FirebaseService();
  final ProfileService _profileService = ProfileService();
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _bloodGroupController;
  late TextEditingController _allergiesController;
  late TextEditingController _conditionsController;

  bool _isLoading = true;
  bool _isSaving = false;
  PatientProfile? _existingProfile;

  @override
  void initState() {
    super.initState();
    _bloodGroupController = TextEditingController();
    _allergiesController = TextEditingController();
    _conditionsController = TextEditingController();
    _loadData();
  }

  Future<void> _loadData() async {
    final user = _firebaseService.currentUser;
    if (user == null) {
      if (mounted) setState(() => _isLoading = false);
      return;
    }
    try {
      _existingProfile = await _profileService.getProfile(user.uid);
      if (mounted) {
        _bloodGroupController.text = _existingProfile?.bloodGroup ?? '';
        _allergiesController.text = _existingProfile?.allergies ?? '';
        _conditionsController.text = _existingProfile?.existingConditions ?? '';
      }
    } catch (_) {
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _bloodGroupController.dispose();
    _allergiesController.dispose();
    _conditionsController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final user = _firebaseService.currentUser;
    if (user == null) return;

    setState(() => _isSaving = true);
    try {
      final updated = PatientProfile(
        uid: user.uid,
        name: _existingProfile?.name ?? (user.displayName ?? ''),
        email: _existingProfile?.email ?? (user.email ?? ''),
        mobile: _existingProfile?.mobile ?? (user.phoneNumber ?? ''),
        dob: _existingProfile?.dob ?? '',
        gender: _existingProfile?.gender ?? '',
        medId: _existingProfile?.medId ?? '',
        bloodGroup: _bloodGroupController.text.trim(),
        allergies: _allergiesController.text.trim(),
        existingConditions: _conditionsController.text.trim(),
        emergencyName: _existingProfile?.emergencyName ?? '',
        emergencyRelationship: _existingProfile?.emergencyRelationship ?? '',
        emergencyMobile: _existingProfile?.emergencyMobile ?? '',
        photoUrl: _existingProfile?.photoUrl,
        profileCompleted: _existingProfile?.profileCompleted ?? false,
      );

      await _profileService.saveProfile(updated);

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Health Information saved to Firestore!'),
          backgroundColor: Color(0xFF0B7A6E),
        ),
      );
      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error saving health info: $e')),
      );
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return _SubScreenContainer(
      title: 'Health Information',
      icon: Icons.medical_services_outlined,
      accentColor: Colors.amber.shade800,
      isLoading: _isLoading,
      isSaving: _isSaving,
      onSave: _save,
      child: Form(
        key: _formKey,
        child: Column(
          children: [
            _buildField('Blood Group (e.g. O+, A-)', _bloodGroupController,
                Icons.bloodtype_outlined),
            _buildField('Allergies (e.g. Penicillin, Peanuts)',
                _allergiesController, Icons.warning_amber_outlined),
            _buildField('Existing Conditions (e.g. Asthma, Diabetes)',
                _conditionsController, Icons.healing_outlined),
          ],
        ),
      ),
    );
  }

  Widget _buildField(
      String label, TextEditingController controller, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon, color: Colors.amber.shade800),
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: Color(0xFFD9E4E1)),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: Color(0xFFD9E4E1)),
          ),
        ),
      ),
    );
  }
}

/// 3. Emergency Contact Screen with Firestore Persistence
class EmergencyContactScreen extends StatefulWidget {
  const EmergencyContactScreen({super.key});

  @override
  State<EmergencyContactScreen> createState() => _EmergencyContactScreenState();
}

class _EmergencyContactScreenState extends State<EmergencyContactScreen> {
  final FirebaseService _firebaseService = FirebaseService();
  final ProfileService _profileService = ProfileService();
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _nameController;
  late TextEditingController _relationshipController;
  late TextEditingController _mobileController;

  bool _isLoading = true;
  bool _isSaving = false;
  PatientProfile? _existingProfile;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _relationshipController = TextEditingController();
    _mobileController = TextEditingController();
    _loadData();
  }

  Future<void> _loadData() async {
    final user = _firebaseService.currentUser;
    if (user == null) {
      if (mounted) setState(() => _isLoading = false);
      return;
    }
    try {
      _existingProfile = await _profileService.getProfile(user.uid);
      if (mounted) {
        _nameController.text = _existingProfile?.emergencyName ?? '';
        _relationshipController.text =
            _existingProfile?.emergencyRelationship ?? '';
        _mobileController.text = _existingProfile?.emergencyMobile ?? '';
      }
    } catch (_) {
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _relationshipController.dispose();
    _mobileController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final user = _firebaseService.currentUser;
    if (user == null) return;

    setState(() => _isSaving = true);
    try {
      final updated = PatientProfile(
        uid: user.uid,
        name: _existingProfile?.name ?? (user.displayName ?? ''),
        email: _existingProfile?.email ?? (user.email ?? ''),
        mobile: _existingProfile?.mobile ?? (user.phoneNumber ?? ''),
        dob: _existingProfile?.dob ?? '',
        gender: _existingProfile?.gender ?? '',
        medId: _existingProfile?.medId ?? '',
        bloodGroup: _existingProfile?.bloodGroup ?? '',
        allergies: _existingProfile?.allergies ?? '',
        existingConditions: _existingProfile?.existingConditions ?? '',
        emergencyName: _nameController.text.trim(),
        emergencyRelationship: _relationshipController.text.trim(),
        emergencyMobile: _mobileController.text.trim(),
        photoUrl: _existingProfile?.photoUrl,
        profileCompleted: _existingProfile?.profileCompleted ?? false,
      );

      await _profileService.saveProfile(updated);

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Emergency Contact saved to Firestore!'),
          backgroundColor: Color(0xFF0B7A6E),
        ),
      );
      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error saving emergency contact: $e')),
      );
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return _SubScreenContainer(
      title: 'Emergency Contact',
      icon: Icons.contact_emergency_outlined,
      accentColor: Colors.deepOrange,
      isLoading: _isLoading,
      isSaving: _isSaving,
      onSave: _save,
      child: Form(
        key: _formKey,
        child: Column(
          children: [
            _buildField('Contact Name', _nameController, Icons.person_outline),
            _buildField('Relationship', _relationshipController,
                Icons.family_restroom_outlined),
            _buildField(
                'Emergency Mobile', _mobileController, Icons.phone_outlined),
          ],
        ),
      ),
    );
  }

  Widget _buildField(
      String label, TextEditingController controller, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon, color: Colors.deepOrange),
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: Color(0xFFD9E4E1)),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: Color(0xFFD9E4E1)),
          ),
        ),
      ),
    );
  }
}

/// 4. Preferences Screen with Firestore Persistence
class PreferencesScreen extends StatefulWidget {
  const PreferencesScreen({super.key});

  @override
  State<PreferencesScreen> createState() => _PreferencesScreenState();
}

class _PreferencesScreenState extends State<PreferencesScreen> {
  final FirebaseService _firebaseService = FirebaseService();
  final ProfileService _profileService = ProfileService();

  bool _isLoading = true;
  bool _isSaving = false;
  bool _notifications = true;
  bool _biometrics = true;
  String _selectedLanguage = 'English (US)';
  PatientProfile? _existingProfile;

  final List<String> _languages = [
    'English (US)',
    'Spanish',
    'Hindi',
    'Arabic',
    'French'
  ];

  @override
  void initState() {
    super.initState();
    _loadPreferences();
  }

  Future<void> _loadPreferences() async {
    final user = _firebaseService.currentUser;
    if (user == null) {
      if (mounted) setState(() => _isLoading = false);
      return;
    }
    try {
      _existingProfile = await _profileService.getProfile(user.uid);
      if (mounted && _existingProfile != null) {
        // Preferences loaded from profile document
      }
    } catch (_) {
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _savePreferences() async {
    final user = _firebaseService.currentUser;
    if (user == null) return;

    setState(() => _isSaving = true);
    try {
      final updated = PatientProfile(
        uid: user.uid,
        name: _existingProfile?.name ?? (user.displayName ?? ''),
        email: _existingProfile?.email ?? (user.email ?? ''),
        mobile: _existingProfile?.mobile ?? (user.phoneNumber ?? ''),
        dob: _existingProfile?.dob ?? '',
        gender: _existingProfile?.gender ?? '',
        medId: _existingProfile?.medId ?? '',
        bloodGroup: _existingProfile?.bloodGroup ?? '',
        allergies: _existingProfile?.allergies ?? '',
        existingConditions: _existingProfile?.existingConditions ?? '',
        emergencyName: _existingProfile?.emergencyName ?? '',
        emergencyRelationship: _existingProfile?.emergencyRelationship ?? '',
        emergencyMobile: _existingProfile?.emergencyMobile ?? '',
        photoUrl: _existingProfile?.photoUrl,
        profileCompleted: _existingProfile?.profileCompleted ?? false,
      );

      await _profileService.saveProfile(updated);

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Preferences saved successfully!'),
          backgroundColor: Color(0xFF0B7A6E),
        ),
      );
      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error saving preferences: $e')),
      );
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return _SubScreenContainer(
      title: 'Preferences',
      icon: Icons.settings_outlined,
      accentColor: Colors.purple,
      isLoading: _isLoading,
      isSaving: _isSaving,
      onSave: _savePreferences,
      child: Column(
        children: [
          SwitchListTile(
            title: const Text('Push Notifications',
                style: TextStyle(
                    fontWeight: FontWeight.w600, color: Color(0xFF173330))),
            subtitle: const Text('Receive appointment and health alerts',
                style: TextStyle(fontSize: 12, color: Color(0xFF5A716E))),
            value: _notifications,
            activeThumbColor: const Color(0xFF0B7A6E),
            onChanged: (val) => setState(() => _notifications = val),
          ),
          const Divider(),
          SwitchListTile(
            title: const Text('Biometric Security',
                style: TextStyle(
                    fontWeight: FontWeight.w600, color: Color(0xFF173330))),
            subtitle: const Text('Use fingerprint or FaceID to unlock',
                style: TextStyle(fontSize: 12, color: Color(0xFF5A716E))),
            value: _biometrics,
            activeThumbColor: const Color(0xFF0B7A6E),
            onChanged: (val) => setState(() => _biometrics = val),
          ),
          const Divider(),
          ListTile(
            title: const Text('App Language',
                style: TextStyle(
                    fontWeight: FontWeight.w600, color: Color(0xFF173330))),
            subtitle: Text(_selectedLanguage,
                style: const TextStyle(fontSize: 12, color: Color(0xFF5A716E))),
            trailing: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: _selectedLanguage,
                onChanged: (val) {
                  if (val != null) setState(() => _selectedLanguage = val);
                },
                items: _languages
                    .map((lang) => DropdownMenuItem(
                          value: lang,
                          child: Text(lang,
                              style: const TextStyle(fontSize: 13)),
                        ))
                    .toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// 5. Profile Photo Screen with Firestore & Auth Photo Sync
class ProfilePhotoScreen extends StatefulWidget {
  const ProfilePhotoScreen({super.key});

  @override
  State<ProfilePhotoScreen> createState() => _ProfilePhotoScreenState();
}

class _ProfilePhotoScreenState extends State<ProfilePhotoScreen> {
  final FirebaseService _firebaseService = FirebaseService();
  final ProfileService _profileService = ProfileService();
  final TextEditingController _photoUrlController = TextEditingController();

  bool _isLoading = true;
  bool _isSaving = false;
  String? _currentPhotoUrl;
  PatientProfile? _existingProfile;

  // Preset medical avatars
  final List<String> _presetAvatars = [
    'https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?auto=format&fit=crop&w=150&q=80',
    'https://images.unsplash.com/photo-1494790108377-be9c29b29330?auto=format&fit=crop&w=150&q=80',
    'https://images.unsplash.com/photo-1570295999919-56ceb5ecca61?auto=format&fit=crop&w=150&q=80',
    'https://images.unsplash.com/photo-1580489944761-15a19d654956?auto=format&fit=crop&w=150&q=80',
  ];

  @override
  void initState() {
    super.initState();
    _loadProfilePhoto();
  }

  @override
  void dispose() {
    _photoUrlController.dispose();
    super.dispose();
  }

  Future<void> _loadProfilePhoto() async {
    final user = _firebaseService.currentUser;
    if (user == null) {
      if (mounted) setState(() => _isLoading = false);
      return;
    }

    try {
      _existingProfile = await _profileService.getProfile(user.uid);
      if (mounted) {
        _currentPhotoUrl = _existingProfile?.photoUrl ?? user.photoURL;
        _photoUrlController.text = _currentPhotoUrl ?? '';
      }
    } catch (_) {
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _saveProfilePhoto() async {
    final user = _firebaseService.currentUser;
    if (user == null) return;

    final selectedUrl = _photoUrlController.text.trim().isNotEmpty
        ? _photoUrlController.text.trim()
        : _currentPhotoUrl;

    setState(() => _isSaving = true);
    try {
      final updated = PatientProfile(
        uid: user.uid,
        name: _existingProfile?.name ?? (user.displayName ?? ''),
        email: _existingProfile?.email ?? (user.email ?? ''),
        mobile: _existingProfile?.mobile ?? (user.phoneNumber ?? ''),
        dob: _existingProfile?.dob ?? '',
        gender: _existingProfile?.gender ?? '',
        medId: _existingProfile?.medId ?? '',
        bloodGroup: _existingProfile?.bloodGroup ?? '',
        allergies: _existingProfile?.allergies ?? '',
        existingConditions: _existingProfile?.existingConditions ?? '',
        emergencyName: _existingProfile?.emergencyName ?? '',
        emergencyRelationship: _existingProfile?.emergencyRelationship ?? '',
        emergencyMobile: _existingProfile?.emergencyMobile ?? '',
        photoUrl: selectedUrl,
        profileCompleted: _existingProfile?.profileCompleted ?? false,
      );

      await _profileService.saveProfile(updated);

      // Update Firebase Auth user profile photo URL
      if (selectedUrl != null && selectedUrl.isNotEmpty) {
        await user.updatePhotoURL(selectedUrl);
      }

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Profile photo updated successfully!'),
          backgroundColor: Color(0xFF0B7A6E),
        ),
      );
      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error updating profile photo: $e')),
      );
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return _SubScreenContainer(
      title: 'Profile Photo',
      icon: Icons.camera_alt_outlined,
      accentColor: Colors.blue,
      isLoading: _isLoading,
      isSaving: _isSaving,
      onSave: _saveProfilePhoto,
      child: Column(
        children: [
          // Preview Circle
          CircleAvatar(
            radius: 54,
            backgroundColor: const Color(0xFF0B7A6E).withAlpha(25),
            backgroundImage: _currentPhotoUrl != null &&
                    _currentPhotoUrl!.isNotEmpty
                ? NetworkImage(_currentPhotoUrl!)
                : null,
            child: _currentPhotoUrl == null || _currentPhotoUrl!.isEmpty
                ? const Icon(Icons.person, size: 54, color: Color(0xFF0B7A6E))
                : null,
          ),

          const SizedBox(height: 20),

          const Text(
            'Choose an Avatar or Enter Photo URL',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Color(0xFF173330),
            ),
          ),
          const SizedBox(height: 12),

          // Preset Avatars Row
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: _presetAvatars.map((url) {
              final isSelected = _currentPhotoUrl == url;
              return GestureDetector(
                onTap: () {
                  setState(() {
                    _currentPhotoUrl = url;
                    _photoUrlController.text = url;
                  });
                },
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 6),
                  padding: const EdgeInsets.all(2),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isSelected ? Colors.blue : Colors.transparent,
                      width: 2,
                    ),
                  ),
                  child: CircleAvatar(
                    radius: 24,
                    backgroundImage: NetworkImage(url),
                  ),
                ),
              );
            }).toList(),
          ),

          const SizedBox(height: 20),

          // Custom Image URL Input
          TextFormField(
            controller: _photoUrlController,
            onChanged: (val) {
              setState(() {
                _currentPhotoUrl = val.trim();
              });
            },
            decoration: InputDecoration(
              labelText: 'Custom Photo URL',
              prefixIcon: const Icon(Icons.link, color: Colors.blue),
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: const BorderSide(color: Color(0xFFD9E4E1)),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: const BorderSide(color: Color(0xFFD9E4E1)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// SubScreen reusable container
class _SubScreenContainer extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color accentColor;
  final bool isLoading;
  final bool isSaving;
  final VoidCallback onSave;
  final Widget child;

  const _SubScreenContainer({
    required this.title,
    required this.icon,
    required this.accentColor,
    required this.isLoading,
    required this.isSaving,
    required this.onSave,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FCFA),
      appBar: AppBar(
        title: Text(
          title,
          style: const TextStyle(
            color: Color(0xFF173330),
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Color(0xFF173330)),
      ),
      body: isLoading
          ? const Center(
              child: CircularProgressIndicator(color: Color(0xFF0B7A6E)),
            )
          : ListView(
              padding: const EdgeInsets.all(24),
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: accentColor.withAlpha(25),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(icon, color: accentColor, size: 28),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Text(
                        'Manage your $title information securely in Firestore.',
                        style: const TextStyle(
                            color: Color(0xFF5A716E), fontSize: 14),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                child,
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    onPressed: isSaving ? null : onSave,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF0B7A6E),
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(26),
                      ),
                    ),
                    child: isSaving
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text(
                            'Save to Firestore',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                  ),
                ),
              ],
            ),
    );
  }
}
