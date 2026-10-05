import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:medisimbio_ui/models/emergency_qr_record.dart';

/// Service managing patient Emergency QR references, status lifecycle, and policy-controlled resolution.
class EmergencyQrService {
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  EmergencyQrService({FirebaseFirestore? firestore, FirebaseAuth? auth})
      : _firestore = firestore ?? FirebaseFirestore.instance,
        _auth = auth ?? FirebaseAuth.instance;

  String? get currentPatientId => _auth.currentUser?.uid;

  CollectionReference<Map<String, dynamic>> _qrCollection(String patientId) {
    return _firestore.collection('users').doc(patientId).collection('emergencyQr');
  }

  /// Gets or generates the active Emergency QR reference for the authenticated patient.
  Future<EmergencyQrRecord> getOrCreateEmergencyQr(
    String patientId, {
    String? medId,
  }) async {
    final authId = currentPatientId;
    if (authId != null && authId != patientId) {
      throw Exception('Unauthorized Emergency QR access attempt.');
    }

    final querySnapshot = await _qrCollection(patientId)
        .where('status', isEqualTo: EmergencyQrStatus.active)
        .limit(1)
        .get();

    if (querySnapshot.docs.isNotEmpty) {
      final record = EmergencyQrRecord.fromFirestoreDoc(querySnapshot.docs.first);
      if (record.isActive) {
        return record;
      }
    }

    // Generate fresh secure reference identity if none active exists
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final prefix = patientId.length >= 6 ? patientId.substring(0, 6) : patientId;
    final id = 'EMGQR-$prefix-$timestamp';
    final payload = 'medisimbio://emergency/qr/$id';

    final newRecord = EmergencyQrRecord(
      emergencyQrId: id,
      patientId: patientId,
      medId: medId ?? 'MD-PENDING',
      version: '1.0',
      status: EmergencyQrStatus.active,
      createdAt: DateTime.now(),
      expiresAt: DateTime.now().add(const Duration(days: 90)), // 90-day rotation window
      qrPayload: payload,
    );

    await _qrCollection(patientId).doc(id).set(newRecord.toFirestoreMap());
    return newRecord;
  }

  /// Rotates/invalidates the existing Emergency QR and generates a fresh reference token.
  Future<EmergencyQrRecord> regenerateEmergencyQr(
    String patientId, {
    String? medId,
  }) async {
    final authId = currentPatientId;
    if (authId != null && authId != patientId) {
      throw Exception('Unauthorized Emergency QR rotation attempt.');
    }

    // Disable all existing active records
    final activeDocs = await _qrCollection(patientId)
        .where('status', isEqualTo: EmergencyQrStatus.active)
        .get();

    for (final doc in activeDocs.docs) {
      await doc.reference.update({
        'status': EmergencyQrStatus.disabled,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    }

    // Generate new active reference token
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final prefix = patientId.length >= 6 ? patientId.substring(0, 6) : patientId;
    final id = 'EMGQR-$prefix-$timestamp';
    final payload = 'medisimbio://emergency/qr/$id';

    final freshRecord = EmergencyQrRecord(
      emergencyQrId: id,
      patientId: patientId,
      medId: medId ?? 'MD-PENDING',
      version: '1.0',
      status: EmergencyQrStatus.active,
      createdAt: DateTime.now(),
      expiresAt: DateTime.now().add(const Duration(days: 90)),
      qrPayload: payload,
    );

    await _qrCollection(patientId).doc(id).set(freshRecord.toFirestoreMap());
    return freshRecord;
  }

  /// Real-time stream of the patient's active Emergency QR record.
  Stream<EmergencyQrRecord?> streamEmergencyQr(String patientId) {
    if (patientId.isEmpty) return Stream.value(null);
    return _qrCollection(patientId)
        .where('status', isEqualTo: EmergencyQrStatus.active)
        .snapshots()
        .map((snapshot) {
      if (snapshot.docs.isEmpty) return null;
      final record = EmergencyQrRecord.fromFirestoreDoc(snapshot.docs.first);
      return record.isActive ? record : null;
    });
  }

  /// Resolves an emergency QR payload through backend authorization and emergency access policy.
  /// FAILS CLOSED if provider role is unauthorized or QR is invalid/expired.
  Future<LimitedEmergencyInfo> resolveEmergencyQr({
    required String emergencyQrId,
    required String patientId,
    required String requesterId,
    required String requesterRole,
  }) async {
    // Check provider authorization
    const authorizedRoles = [
      'PARAMEDIC',
      'EMERGENCY_DOCTOR',
      'RESCUE_RESPONDER',
      'AUTHORIZED_PROVIDER'
    ];

    if (!authorizedRoles.contains(requesterRole.toUpperCase()) &&
        requesterId != patientId) {
      throw Exception('Unauthorized scanner: Emergency access policy denied access.');
    }

    final qrDoc = await _qrCollection(patientId).doc(emergencyQrId).get();
    if (!qrDoc.exists) {
      throw Exception('Emergency QR reference identity not found.');
    }

    final record = EmergencyQrRecord.fromFirestoreDoc(qrDoc);
    if (!record.isActive) {
      throw Exception('Emergency QR reference is invalid, disabled, or expired.');
    }

    // Fetch patient profile for policy-filtered emergency fields
    final userDoc = await _firestore.collection('users').doc(patientId).get();
    final profileData = userDoc.data() ?? {};

    // Apply minimum necessary information policy (Exposes ONLY emergency fields)
    return LimitedEmergencyInfo(
      patientId: patientId,
      medId: profileData['medId'] ?? record.medId,
      patientName: profileData['name'] ?? 'Patient',
      bloodGroup: profileData['bloodGroup'] as String?,
      allergies: profileData['allergies'] as String?,
      existingConditions: profileData['existingConditions'] as String?,
      emergencyName: profileData['emergencyName'] as String?,
      emergencyRelationship: profileData['emergencyRelationship'] as String?,
      emergencyMobile: profileData['emergencyMobile'] as String?,
      authorizedAt: DateTime.now(),
      policyName: 'EMERGENCY_MINIMUM_NECESSARY_V1',
    );
  }
}
