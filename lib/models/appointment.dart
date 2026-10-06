class AppointmentStatus {
  static const String pending = 'PENDING';
  static const String confirmed = 'CONFIRMED';
  static const String upcoming = 'Upcoming';
  static const String rescheduled = 'RESCHEDULED';
  static const String cancelled = 'CANCELLED';
  static const String completed = 'COMPLETED';
  static const String checkedIn = 'CHECKED_IN';
  static const String waiting = 'WAITING';
  static const String inConsultation = 'IN_CONSULTATION';
}

class Appointment {
  final String id;
  final String uid;
  final String doctorId;
  final String doctorName;
  final String specialty;
  final String hospitalName;
  final String dateTime;
  final String consultationType; // 'In-Person', 'Video Consultation'
  final String status; // 'CONFIRMED', 'Upcoming', 'PENDING', 'CANCELLED', 'COMPLETED'
  final double consultationFee;
  final bool isLiveTrackingActive;
  final String? tokenNumber;
  final String? currentServingToken;
  final int? queuePosition;
  final int? estimatedWaitMinutes;
  final DateTime? trackingLastUpdated;
  final String? hospitalAddress;
  final double? latitude;
  final double? longitude;
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
    this.consultationFee = 0.0,
    this.isLiveTrackingActive = false,
    this.tokenNumber,
    this.currentServingToken,
    this.queuePosition,
    this.estimatedWaitMinutes,
    this.trackingLastUpdated,
    this.hospitalAddress,
    this.latitude,
    this.longitude,
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
      'consultationFee': consultationFee,
      'isLiveTrackingActive': isLiveTrackingActive,
      'tokenNumber': tokenNumber,
      'currentServingToken': currentServingToken,
      'queuePosition': queuePosition,
      'estimatedWaitMinutes': estimatedWaitMinutes,
      'trackingLastUpdated': trackingLastUpdated?.toIso8601String(),
      'hospitalAddress': hospitalAddress,
      'latitude': latitude,
      'longitude': longitude,
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
      status: json['status'] ?? 'CONFIRMED',
      consultationFee: (json['consultationFee'] as num?)?.toDouble() ?? 0.0,
      isLiveTrackingActive: json['isLiveTrackingActive'] ?? false,
      tokenNumber: json['tokenNumber']?.toString(),
      currentServingToken: json['currentServingToken']?.toString(),
      queuePosition: json['queuePosition'] as int?,
      estimatedWaitMinutes: json['estimatedWaitMinutes'] as int?,
      trackingLastUpdated: json['trackingLastUpdated'] != null
          ? DateTime.tryParse(json['trackingLastUpdated'])
          : null,
      hospitalAddress: json['hospitalAddress']?.toString(),
      latitude: (json['latitude'] as num?)?.toDouble(),
      longitude: (json['longitude'] as num?)?.toDouble(),
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'])
          : null,
    );
  }

  Appointment copyWith({
    String? id,
    String? uid,
    String? doctorId,
    String? doctorName,
    String? specialty,
    String? hospitalName,
    String? dateTime,
    String? consultationType,
    String? status,
    double? consultationFee,
    bool? isLiveTrackingActive,
    String? tokenNumber,
    String? currentServingToken,
    int? queuePosition,
    int? estimatedWaitMinutes,
    DateTime? trackingLastUpdated,
    String? hospitalAddress,
    double? latitude,
    double? longitude,
    DateTime? createdAt,
  }) {
    return Appointment(
      id: id ?? this.id,
      uid: uid ?? this.uid,
      doctorId: doctorId ?? this.doctorId,
      doctorName: doctorName ?? this.doctorName,
      specialty: specialty ?? this.specialty,
      hospitalName: hospitalName ?? this.hospitalName,
      dateTime: dateTime ?? this.dateTime,
      consultationType: consultationType ?? this.consultationType,
      status: status ?? this.status,
      consultationFee: consultationFee ?? this.consultationFee,
      isLiveTrackingActive: isLiveTrackingActive ?? this.isLiveTrackingActive,
      tokenNumber: tokenNumber ?? this.tokenNumber,
      currentServingToken: currentServingToken ?? this.currentServingToken,
      queuePosition: queuePosition ?? this.queuePosition,
      estimatedWaitMinutes: estimatedWaitMinutes ?? this.estimatedWaitMinutes,
      trackingLastUpdated: trackingLastUpdated ?? this.trackingLastUpdated,
      hospitalAddress: hospitalAddress ?? this.hospitalAddress,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
