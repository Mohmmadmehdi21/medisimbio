import 'package:cloud_firestore/cloud_firestore.dart';

/// Status constants for Emergency QR references.
class EmergencyQrStatus {
  static const String active = 'ACTIVE';
  static const String disabled = 'DISABLED';
  static const String expired = 'EXPIRED';
}

/// Secure model representing an Emergency QR reference identity.
/// The QR payload only encodes a non-sensitive reference URL/token,
/// NEVER raw medical records, credentials, or sensitive history.
class EmergencyQrRecord {
  final String emergencyQrId;
  final String patientId;
  final String medId;
  final String version;
  final String status; // ACTIVE, DISABLED, EXPIRED
  final DateTime createdAt;
  final DateTime? expiresAt;
  final DateTime? updatedAt;
  final String qrPayload;

  const EmergencyQrRecord({
    required this.emergencyQrId,
    required this.patientId,
    required this.medId,
    this.version = '1.0',
    required this.status,
    required this.createdAt,
    this.expiresAt,
    this.updatedAt,
    required this.qrPayload,
  });

  /// Computes effective status considering timestamp expiration.
  String get effectiveStatus {
    if (status == EmergencyQrStatus.active) {
      if (expiresAt != null && DateTime.now().isAfter(expiresAt!)) {
        return EmergencyQrStatus.expired;
      }
    }
    return status;
  }

  /// Whether this Emergency QR reference is currently active and valid.
  bool get isActive {
    return effectiveStatus == EmergencyQrStatus.active;
  }

  /// Factory constructing record from Firestore document snapshot.
  factory EmergencyQrRecord.fromFirestoreDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? {};
    return EmergencyQrRecord.fromMap(data, doc.id);
  }

  /// Factory constructing record from Map.
  factory EmergencyQrRecord.fromMap(Map<String, dynamic> data, String id) {
    return EmergencyQrRecord(
      emergencyQrId: id,
      patientId: data['patientId'] ?? '',
      medId: data['medId'] ?? 'MD-UNKNOWN',
      version: data['version'] ?? '1.0',
      status: data['status'] ?? EmergencyQrStatus.active,
      createdAt: _parseDateTime(data['createdAt']) ?? DateTime.now(),
      expiresAt: _parseDateTime(data['expiresAt']),
      updatedAt: _parseDateTime(data['updatedAt']),
      qrPayload: data['qrPayload'] ?? 'medisimbio://emergency/qr/$id',
    );
  }

  /// Converts record to Firestore Map.
  Map<String, dynamic> toFirestoreMap() {
    return {
      'emergencyQrId': emergencyQrId,
      'patientId': patientId,
      'medId': medId,
      'version': version,
      'status': status,
      'createdAt': Timestamp.fromDate(createdAt),
      'expiresAt': expiresAt != null ? Timestamp.fromDate(expiresAt!) : null,
      'updatedAt': FieldValue.serverTimestamp(),
      'qrPayload': qrPayload,
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

/// Policy-controlled minimal emergency information payload returned to
/// an authorized scanner upon resolving an Emergency QR reference.
class LimitedEmergencyInfo {
  final String patientId;
  final String medId;
  final String patientName;
  final String? bloodGroup;
  final String? allergies;
  final String? existingConditions;
  final String? emergencyName;
  final String? emergencyRelationship;
  final String? emergencyMobile;
  final DateTime authorizedAt;
  final String policyName;

  const LimitedEmergencyInfo({
    required this.patientId,
    required this.medId,
    required this.patientName,
    this.bloodGroup,
    this.allergies,
    this.existingConditions,
    this.emergencyName,
    this.emergencyRelationship,
    this.emergencyMobile,
    required this.authorizedAt,
    this.policyName = 'DEFAULT_EMERGENCY_POLICY_V1',
  });

  /// Factory creating info from Map.
  factory LimitedEmergencyInfo.fromMap(Map<String, dynamic> data) {
    return LimitedEmergencyInfo(
      patientId: data['patientId'] ?? '',
      medId: data['medId'] ?? 'MD-UNKNOWN',
      patientName: data['patientName'] ?? 'Patient',
      bloodGroup: data['bloodGroup'] as String?,
      allergies: data['allergies'] as String?,
      existingConditions: data['existingConditions'] as String?,
      emergencyName: data['emergencyName'] as String?,
      emergencyRelationship: data['emergencyRelationship'] as String?,
      emergencyMobile: data['emergencyMobile'] as String?,
      authorizedAt: DateTime.tryParse(data['authorizedAt'] ?? '') ?? DateTime.now(),
      policyName: data['policyName'] ?? 'DEFAULT_EMERGENCY_POLICY_V1',
    );
  }

  /// Converts model to Map.
  Map<String, dynamic> toMap() {
    return {
      'patientId': patientId,
      'medId': medId,
      'patientName': patientName,
      'bloodGroup': bloodGroup,
      'allergies': allergies,
      'existingConditions': existingConditions,
      'emergencyName': emergencyName,
      'emergencyRelationship': emergencyRelationship,
      'emergencyMobile': emergencyMobile,
      'authorizedAt': authorizedAt.toIso8601String(),
      'policyName': policyName,
    };
  }
}
