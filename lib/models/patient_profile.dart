class PatientProfile {
  final String uid;
  final String name;
  final String email;
  final String mobile;
  final String dob;
  final String gender;
  final String medId;
  final String bloodGroup;
  final String allergies;
  final String existingConditions;
  final String emergencyName;
  final String emergencyRelationship;
  final String emergencyMobile;
  final String? photoUrl;
  final bool profileCompleted;

  PatientProfile({
    required this.uid,
    required this.name,
    required this.email,
    required this.mobile,
    required this.dob,
    required this.gender,
    required this.medId,
    this.bloodGroup = '',
    this.allergies = '',
    this.existingConditions = '',
    this.emergencyName = '',
    this.emergencyRelationship = '',
    this.emergencyMobile = '',
    this.photoUrl,
    this.profileCompleted = false,
  });

  Map<String, dynamic> toJson() {
    return {
      'uid': uid,
      'name': name,
      'email': email,
      'mobile': mobile,
      'dob': dob,
      'gender': gender,
      'medId': medId,
      'bloodGroup': bloodGroup,
      'allergies': allergies,
      'existingConditions': existingConditions,
      'emergencyName': emergencyName,
      'emergencyRelationship': emergencyRelationship,
      'emergencyMobile': emergencyMobile,
      'photoUrl': photoUrl,
      'profileCompleted': profileCompleted,
    };
  }

  factory PatientProfile.fromJson(Map<String, dynamic> json) {
    return PatientProfile(
      uid: json['uid'] ?? '',
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      mobile: json['mobile'] ?? '',
      dob: json['dob'] ?? '',
      gender: json['gender'] ?? '',
      medId: json['medId'] ?? '',
      bloodGroup: json['bloodGroup'] ?? '',
      allergies: json['allergies'] ?? '',
      existingConditions: json['existingConditions'] ?? '',
      emergencyName: json['emergencyName'] ?? '',
      emergencyRelationship: json['emergencyRelationship'] ?? '',
      emergencyMobile: json['emergencyMobile'] ?? '',
      photoUrl: json['photoUrl'],
      profileCompleted: json['profileCompleted'] ?? false,
    );
  }
}
