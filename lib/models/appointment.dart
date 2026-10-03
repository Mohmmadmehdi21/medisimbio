class Appointment {
  final String id;
  final String uid;
  final String doctorId;
  final String doctorName;
  final String specialty;
  final String hospitalName;
  final String dateTime;
  final String consultationType; // 'In-Person', 'Video Consultation'
  final String status; // 'Upcoming', 'Completed', 'Cancelled'
  final bool isLiveTrackingActive;
  final DateTime? createdAt;

  Appointment({
    required this.id,
    required this.uid,
    required this.doctorId,
    required this.doctorName,
    required this.specialty,
    required this.hospitalName,
    required this.dateTime,
    required this.status,
    this.consultationType = 'In-Person',
    this.isLiveTrackingActive = false,
    this.createdAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'uid': uid,
      'doctorId': doctorId,
      'doctorName': doctorName,
      'specialty': specialty,
      'hospitalName': hospitalName,
      'dateTime': dateTime,
      'consultationType': consultationType,
      'status': status,
      'isLiveTrackingActive': isLiveTrackingActive,
      'createdAt': (createdAt ?? DateTime.now()).toIso8601String(),
    };
  }

  factory Appointment.fromJson(Map<String, dynamic> json) {
    return Appointment(
      id: json['id'] ?? '',
      uid: json['uid'] ?? '',
      doctorId: json['doctorId'] ?? '',
      doctorName: json['doctorName'] ?? '',
      specialty: json['specialty'] ?? '',
      hospitalName: json['hospitalName'] ?? '',
      dateTime: json['dateTime'] ?? '',
      consultationType: json['consultationType'] ?? 'In-Person',
      status: json['status'] ?? 'Upcoming',
      isLiveTrackingActive: json['isLiveTrackingActive'] ?? false,
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'])
          : null,
    );
  }
}
