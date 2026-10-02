class Appointment {
  final String id;
  final String doctorName;
  final String specialty;
  final String hospitalName;
  final String dateTime;
  final String status;
  final bool isLiveTrackingActive;

  Appointment({
    required this.id,
    required this.doctorName,
    required this.specialty,
    required this.hospitalName,
    required this.dateTime,
    required this.status,
    this.isLiveTrackingActive = false,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'doctorName': doctorName,
      'specialty': specialty,
      'hospitalName': hospitalName,
      'dateTime': dateTime,
      'status': status,
      'isLiveTrackingActive': isLiveTrackingActive,
    };
  }

  factory Appointment.fromJson(Map<String, dynamic> json) {
    return Appointment(
      id: json['id'] ?? '',
      doctorName: json['doctorName'] ?? '',
      specialty: json['specialty'] ?? '',
      hospitalName: json['hospitalName'] ?? '',
      dateTime: json['dateTime'] ?? '',
      status: json['status'] ?? '',
      isLiveTrackingActive: json['isLiveTrackingActive'] ?? false,
    );
  }
}
