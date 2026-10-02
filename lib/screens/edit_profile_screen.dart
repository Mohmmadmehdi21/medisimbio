import 'package:flutter/material.dart';
import 'package:medisimbio_ui/models/patient_profile.dart';
import 'package:medisimbio_ui/services/firebase_service.dart';
import 'package:medisimbio_ui/services/profile_service.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final FirebaseService _firebaseService = FirebaseService();
  final ProfileService _profileService = ProfileService();
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _nameController;
  late TextEditingController _mobileController;
  late TextEditingController _emailController;
  late TextEditingController _dobController;
  late TextEditingController _genderController;
  late TextEditingController _bloodGroupController;
  late TextEditingController _allergiesController;
  late TextEditingController _conditionsController;
  late TextEditingController _emergencyNameController;
  late TextEditingController _emergencyRelationController;
  late TextEditingController _emergencyMobileController;

  bool _isLoading = true;
  bool _isSaving = false;
  String _medId = '';

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _mobileController = TextEditingController();
    _emailController = TextEditingController();
    _dobController = TextEditingController();
    _genderController = TextEditingController();
    _bloodGroupController = TextEditingController();
    _allergiesController = TextEditingController();
    _conditionsController = TextEditingController();
    _emergencyNameController = TextEditingController();
    _emergencyRelationController = TextEditingController();
    _emergencyMobileController = TextEditingController();

    _loadExistingProfile();
  }

  Future<void> _loadExistingProfile() async {
    final user = _firebaseService.currentUser;
    if (user == null) {
      if (mounted) setState(() => _isLoading = false);
      return;
    }

    try {
      final profile = await _profileService.getProfile(user.uid);
      if (profile != null && mounted) {
        setState(() {
          _medId = profile.medId;
          _nameController.text =
              profile.name.isNotEmpty ? profile.name : (user.displayName ?? '');
          _mobileController.text = profile.mobile.isNotEmpty
              ? profile.mobile
              : (user.phoneNumber ?? '');
          _emailController.text =
              profile.email.isNotEmpty ? profile.email : (user.email ?? '');
          _dobController.text = profile.dob;
          _genderController.text = profile.gender;
          _bloodGroupController.text = profile.bloodGroup;
          _allergiesController.text = profile.allergies;
          _conditionsController.text = profile.existingConditions;
          _emergencyNameController.text = profile.emergencyName;
          _emergencyRelationController.text = profile.emergencyRelationship;
          _emergencyMobileController.text = profile.emergencyMobile;
        });
      }
    } catch (_) {
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _mobileController.dispose();
    _emailController.dispose();
    _dobController.dispose();
    _genderController.dispose();
    _bloodGroupController.dispose();
    _allergiesController.dispose();
    _conditionsController.dispose();
    _emergencyNameController.dispose();
    _emergencyRelationController.dispose();
    _emergencyMobileController.dispose();
    super.dispose();
  }

  Future<void> _saveChanges() async {
    if (!_formKey.currentState!.validate()) return;

    final user = _firebaseService.currentUser;
    if (user == null) return;

    setState(() => _isSaving = true);
    try {
      final updatedProfile = PatientProfile(
        uid: user.uid,
        name: _nameController.text.trim(),
        email: _emailController.text.trim(),
        mobile: _mobileController.text.trim(),
        dob: _dobController.text.trim(),
        gender: _genderController.text.trim(),
        medId: _medId,
        bloodGroup: _bloodGroupController.text.trim(),
        allergies: _allergiesController.text.trim(),
        existingConditions: _conditionsController.text.trim(),
        emergencyName: _emergencyNameController.text.trim(),
        emergencyRelationship: _emergencyRelationController.text.trim(),
        emergencyMobile: _emergencyMobileController.text.trim(),
        profileCompleted: true,
      );

      await _profileService.saveProfile(updatedProfile);

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Profile updated successfully!'),
          backgroundColor: Color(0xFF0B7A6E),
        ),
      );
      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error updating profile: $e')),
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
          'Edit Profile',
          style:
              TextStyle(color: Color(0xFF173330), fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Color(0xFF173330)),
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: Color(0xFF0B7A6E)),
            )
          : Form(
              key: _formKey,
              child: ListView(
                padding: const EdgeInsets.all(24),
                children: [
                  // Profile Photo Section
                  Center(
                    child: Column(
                      children: [
                        Stack(
                          children: [
                            const CircleAvatar(
                              radius: 50,
                              backgroundColor: Color(0xFF0B7A6E),
                              child: Icon(Icons.person,
                                  size: 50, color: Colors.white),
                            ),
                            Positioned(
                              bottom: 0,
                              right: 0,
                              child: Container(
                                padding: const EdgeInsets.all(6),
                                decoration: const BoxDecoration(
                                  color: Color(0xFF0B7A6E),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(Icons.camera_alt,
                                    size: 16, color: Colors.white),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        TextButton(
                          onPressed: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                  content: Text('Photo picker selected')),
                            );
                          },
                          child: const Text(
                            'Change Photo',
                            style: TextStyle(
                              color: Color(0xFF0B7A6E),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),
                  const Text(
                    'Personal Information',
                    style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF173330)),
                  ),
                  const SizedBox(height: 12),

                  _buildField(
                      'Full Name', _nameController, Icons.person_outline),
                  _buildField(
                      'Mobile Number', _mobileController, Icons.phone_outlined),
                  _buildField(
                      'Email Address', _emailController, Icons.email_outlined),
                  _buildField(
                      'Date of Birth', _dobController, Icons.cake_outlined),
                  _buildField('Gender', _genderController, Icons.wc_outlined),

                  const SizedBox(height: 24),
                  const Text(
                    'Health Information',
                    style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF173330)),
                  ),
                  const SizedBox(height: 12),

                  _buildField('Blood Group', _bloodGroupController,
                      Icons.bloodtype_outlined,
                      required: false),
                  _buildField('Allergies', _allergiesController,
                      Icons.warning_amber_outlined,
                      required: false),
                  _buildField('Existing Conditions', _conditionsController,
                      Icons.healing_outlined,
                      required: false),

                  const SizedBox(height: 24),
                  const Text(
                    'Emergency Contact',
                    style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF173330)),
                  ),
                  const SizedBox(height: 12),

                  _buildField('Contact Name', _emergencyNameController,
                      Icons.person_outline,
                      required: false),
                  _buildField('Relationship', _emergencyRelationController,
                      Icons.family_restroom_outlined,
                      required: false),
                  _buildField('Emergency Mobile', _emergencyMobileController,
                      Icons.phone_outlined,
                      required: false),

                  const SizedBox(height: 32),

                  // Save Changes Button
                  SizedBox(
                    width: double.infinity,
                    height: 54,
                    child: ElevatedButton(
                      onPressed: _isSaving ? null : _saveChanges,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF0B7A6E),
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(27),
                        ),
                      ),
                      child: _isSaving
                          ? const CircularProgressIndicator(color: Colors.white)
                          : const Text(
                              'Save Changes',
                              style: TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.w600),
                            ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildField(
      String label, TextEditingController controller, IconData icon,
      {bool required = true}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        controller: controller,
        validator: required
            ? (val) => val == null || val.isEmpty ? 'Please enter $label' : null
            : null,
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
