import 'package:flutter/material.dart';

class PersonalInformationScreen extends StatelessWidget {
  const PersonalInformationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return _SubScreenTemplate(
      title: 'Personal Information',
      icon: Icons.person,
      accentColor: const Color(0xFF0B7A6E),
      children: [
        _buildTextField('Full Name', 'Sarah Jenkins', Icons.person_outline),
        _buildTextField(
            'Email Address', 'sarah.jenkins@example.com', Icons.email_outlined),
        _buildTextField(
            'Mobile Number', '+1 (555) 234-5678', Icons.phone_outlined),
        _buildTextField('Date of Birth', '15/06/1992', Icons.cake_outlined),
        _buildTextField('Gender', 'Female', Icons.wc_outlined),
      ],
    );
  }

  Widget _buildTextField(String label, String value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        initialValue: value,
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

class HealthInformationScreen extends StatelessWidget {
  const HealthInformationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return _SubScreenTemplate(
      title: 'Health Information',
      icon: Icons.medical_services_outlined,
      accentColor: Colors.amber.shade800,
      children: [
        _buildTextField('Blood Group', 'O+', Icons.bloodtype_outlined),
        _buildTextField(
            'Allergies', 'Penicillin, Peanuts', Icons.warning_amber_outlined),
        _buildTextField(
            'Existing Conditions', 'None Reported', Icons.healing_outlined),
      ],
    );
  }

  Widget _buildTextField(String label, String value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        initialValue: value,
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

class EmergencyContactScreen extends StatelessWidget {
  const EmergencyContactScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return _SubScreenTemplate(
      title: 'Emergency Contact',
      icon: Icons.contact_emergency_outlined,
      accentColor: Colors.deepOrange,
      children: [
        _buildTextField(
            'Contact Name', 'Michael Jenkins', Icons.person_outline),
        _buildTextField(
            'Relationship', 'Spouse', Icons.family_restroom_outlined),
        _buildTextField(
            'Mobile Number', '+1 (555) 987-6543', Icons.phone_outlined),
      ],
    );
  }

  Widget _buildTextField(String label, String value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        initialValue: value,
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

class PreferencesScreen extends StatefulWidget {
  const PreferencesScreen({super.key});

  @override
  State<PreferencesScreen> createState() => _PreferencesScreenState();
}

class _PreferencesScreenState extends State<PreferencesScreen> {
  bool _notifications = true;
  bool _biometrics = true;
  final String _language = 'English (US)';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FCFA),
      appBar: AppBar(
        title: const Text('Preferences',
            style: TextStyle(
                color: Color(0xFF173330), fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Color(0xFF173330)),
      ),
      body: ListView(
        padding: const EdgeInsets.all(24),
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
            subtitle: Text(_language,
                style: const TextStyle(fontSize: 12, color: Color(0xFF5A716E))),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                    content: Text('Language settings updated successfully')),
              );
            },
          ),
        ],
      ),
    );
  }
}

class ProfilePhotoScreen extends StatelessWidget {
  const ProfilePhotoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FCFA),
      appBar: AppBar(
        title: const Text('Profile Photo',
            style: TextStyle(
                color: Color(0xFF173330), fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Color(0xFF173330)),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const CircleAvatar(
                radius: 64,
                backgroundColor: Color(0xFF0B7A6E),
                child: Icon(Icons.person, size: 64, color: Colors.white),
              ),
              const SizedBox(height: 24),
              const Text(
                'Upload Profile Picture',
                style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF173330)),
              ),
              const SizedBox(height: 8),
              const Text(
                'Choose a clear photo of yourself for your healthcare providers.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Color(0xFF5A716E)),
              ),
              const SizedBox(height: 32),
              ElevatedButton.icon(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text('Profile photo updated successfully!')),
                  );
                  Navigator.pop(context);
                },
                icon: const Icon(Icons.camera_alt),
                label: const Text('Take Photo / Choose from Gallery'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0B7A6E),
                  foregroundColor: Colors.white,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SubScreenTemplate extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color accentColor;
  final List<Widget> children;

  const _SubScreenTemplate({
    required this.title,
    required this.icon,
    required this.accentColor,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FCFA),
      appBar: AppBar(
        title: Text(title,
            style: const TextStyle(
                color: Color(0xFF173330), fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Color(0xFF173330)),
      ),
      body: ListView(
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
                  'Manage your $title information securely.',
                  style:
                      const TextStyle(color: Color(0xFF5A716E), fontSize: 14),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          ...children,
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('$title saved successfully!')),
              );
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF0B7A6E),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24)),
            ),
            child: const Text('Save Changes',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }
}
