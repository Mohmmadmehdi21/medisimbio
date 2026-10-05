import 'package:cloud_firestore/cloud_firestore.dart';

/// Status values for data access consent requests.
class ConsentStatus {
  static const String pending = 'PENDING';
  static const String granted = 'GRANTED';
  static const String denied = 'DENIED';
  static const String revoked = 'REVOKED';
  static const String expired = 'EXPIRED';
}

/// Data categories (scopes) for granular healthcare access control.
class ConsentScope {
  static const String medicalHistory = 'MEDICAL_HISTORY';
  static const String prescriptions = 'PRESCRIPTIONS';
  static const String labReports = 'LAB_REPORTS';
  static const String doctorConsultations = 'DOCTOR_CONSULTATIONS';
  static const String clinicalNotes = 'CLINICAL_NOTES';
  static const String documents = 'DOCUMENTS';
  static const String medicationRecords = 'MEDICATION_RECORDS';
  static const String appointments = 'APPOINTMENTS';

  /// Converts a scope identifier to a human-readable title.
  static String getLabel(String scope) {
    switch (scope.toUpperCase()) {
      case medicalHistory:
        return 'Medical History';
      case prescriptions:
        return 'Prescriptions';
      case labReports:
        return 'Lab Reports';
      case doctorConsultations:
        return 'Doctor Consultations';
      case clinicalNotes:
        return 'Clinical Notes';
      case documents:
        return 'Documents';
      case medicationRecords:
        return 'Medication Records';
      case appointments:
        return 'Appointments';
      default:
        return scope.replaceAll('_', ' ');
    }
  }
}

/// Persistent model representing a data access consent request/grant.
class ConsentRecord {
  final String accessRequestId;
  final String patientId;
  final String requesterId;
  final String requesterType;
  final String requesterName;
  final String? organizationId;
  final String? organizationName;
  final List<String> requestedScopes;
  final List<String> grantedScopes;
  final DateTime requestedAt;
  final int? durationHours;
  final DateTime? expiresAt;
  final String status; // PENDING, GRANTED, DENIED, REVOKED, EXPIRED
  final DateTime? grantedAt;
  final DateTime? deniedAt;
  final DateTime? revokedAt;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final String? reason;

  const ConsentRecord({
    required this.accessRequestId,
    required this.patientId,
    required this.requesterId,
    required this.requesterType,
    required this.requesterName,
    this.organizationId,
    this.organizationName,
    required this.requestedScopes,
    this.grantedScopes = const [],
    required this.requestedAt,
    this.durationHours,
    this.expiresAt,
    required this.status,
    this.grantedAt,
    this.deniedAt,
    this.revokedAt,
    this.createdAt,
    this.updatedAt,
    this.reason,
  });

  /// Computes effective status accounting for timestamp-based expiration.
  String get effectiveStatus {
    if (status == ConsentStatus.granted) {
      if (expiresAt != null && DateTime.now().isAfter(expiresAt!)) {
        return ConsentStatus.expired;
      }
    }
    return status;
  }

  /// Whether access is currently active and valid.
  bool get isActive {
    return effectiveStatus == ConsentStatus.granted;
  }

  /// Whether access has passed its expiration time.
  bool get isExpired {
    return effectiveStatus == ConsentStatus.expired;
  }

  /// Creates a ConsentRecord from a Firestore document snapshot or map.
  factory ConsentRecord.fromFirestoreDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? {};
    return ConsentRecord.fromMap(data, doc.id);
  }

  /// Creates a ConsentRecord from a map object.
  factory ConsentRecord.fromMap(Map<String, dynamic> data, String id) {
    return ConsentRecord(
      accessRequestId: id,
      patientId: data['patientId'] ?? '',
      requesterId: data['requesterId'] ?? '',
      requesterType: data['requesterType'] ?? 'PROVIDER',
      requesterName: data['requesterName'] ?? 'Healthcare Provider',
      organizationId: data['organizationId'],
      organizationName: data['organizationName'],
      requestedScopes: List<String>.from(data['requestedScopes'] ?? []),
      grantedScopes: List<String>.from(data['grantedScopes'] ?? []),
      requestedAt: _parseDateTime(data['requestedAt']) ?? DateTime.now(),
      durationHours: data['durationHours'] as int?,
      expiresAt: _parseDateTime(data['expiresAt']),
      status: data['status'] ?? ConsentStatus.pending,
      grantedAt: _parseDateTime(data['grantedAt']),
      deniedAt: _parseDateTime(data['deniedAt']),
      revokedAt: _parseDateTime(data['revokedAt']),
      createdAt: _parseDateTime(data['createdAt']),
      updatedAt: _parseDateTime(data['updatedAt']),
      reason: data['reason'] as String?,
    );
  }

  /// Converts this record to a Map for Firestore persistence.
  Map<String, dynamic> toFirestoreMap() {
    return {
      'accessRequestId': accessRequestId,
      'patientId': patientId,
      'requesterId': requesterId,
      'requesterType': requesterType,
      'requesterName': requesterName,
      'organizationId': organizationId,
      'organizationName': organizationName,
      'requestedScopes': requestedScopes,
      'grantedScopes': grantedScopes,
      'requestedAt': Timestamp.fromDate(requestedAt),
      'durationHours': durationHours,
      'expiresAt': expiresAt != null ? Timestamp.fromDate(expiresAt!) : null,
      'status': status,
      'grantedAt': grantedAt != null ? Timestamp.fromDate(grantedAt!) : null,
      'deniedAt': deniedAt != null ? Timestamp.fromDate(deniedAt!) : null,
      'revokedAt': revokedAt != null ? Timestamp.fromDate(revokedAt!) : null,
      'createdAt': createdAt != null ? Timestamp.fromDate(createdAt!) : FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
      'reason': reason,
    };
  }

  static DateTime? _parseDateTime(dynamic value) {
    if (value == null) return null;
    if (value is Timestamp) return value.toDate();
    if (value is DateTime) return value;
    if (value is String) return DateTime.tryParse(value);
    return null;
  }
}
