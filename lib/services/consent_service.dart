import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:medisimbio_ui/models/consent_record.dart';

/// Service managing patient data access consent lifecycle and persistence in Firestore.
class ConsentService {
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  ConsentService({FirebaseFirestore? firestore, FirebaseAuth? auth})
      : _firestore = firestore ?? FirebaseFirestore.instance,
        _auth = auth ?? FirebaseAuth.instance;

  /// Gets authenticated patient UID.
  String? get currentPatientId => _auth.currentUser?.uid;

  /// Helper to get subcollection reference for patient's consent records.
  CollectionReference<Map<String, dynamic>> _consentCollection(String patientId) {
    return _firestore.collection('users').doc(patientId).collection('consentRecords');
  }

  /// Streams pending access requests for the authenticated patient.
  Stream<List<ConsentRecord>> streamPendingRequests(String patientId) {
    if (patientId.isEmpty) return Stream.value([]);
    return _consentCollection(patientId)
        .where('status', isEqualTo: ConsentStatus.pending)
        .snapshots()
        .map((snapshot) {
      final records = snapshot.docs
          .map((doc) => ConsentRecord.fromFirestoreDoc(doc))
          .toList();
      records.sort((a, b) => b.requestedAt.compareTo(a.requestedAt));
      return records;
    });
  }

  /// Streams active consent grants for the authenticated patient.
  Stream<List<ConsentRecord>> streamActiveConsents(String patientId) {
    if (patientId.isEmpty) return Stream.value([]);
    return _consentCollection(patientId)
        .where('status', isEqualTo: ConsentStatus.granted)
        .snapshots()
        .map((snapshot) {
      final records = snapshot.docs
          .map((doc) => ConsentRecord.fromFirestoreDoc(doc))
          .where((rec) => rec.isActive) // Filter out timestamp-expired records
          .toList();
      records.sort((a, b) => b.requestedAt.compareTo(a.requestedAt));
      return records;
    });
  }

  /// Streams expired consent grants for the authenticated patient.
  Stream<List<ConsentRecord>> streamExpiredConsents(String patientId) {
    if (patientId.isEmpty) return Stream.value([]);
    return _consentCollection(patientId).snapshots().map((snapshot) {
      final records = snapshot.docs
          .map((doc) => ConsentRecord.fromFirestoreDoc(doc))
          .where((rec) => rec.isExpired)
          .toList();
      records.sort((a, b) => b.requestedAt.compareTo(a.requestedAt));
      return records;
    });
  }

  /// Streams all access history records for the authenticated patient.
  Stream<List<ConsentRecord>> streamConsentHistory(String patientId) {
    if (patientId.isEmpty) return Stream.value([]);
    return _consentCollection(patientId).snapshots().map((snapshot) {
      final records = snapshot.docs
          .map((doc) => ConsentRecord.fromFirestoreDoc(doc))
          .toList();
      records.sort((a, b) => b.requestedAt.compareTo(a.requestedAt));
      return records;
    });
  }

  /// Grants consent for a pending request.
  Future<void> allowConsent({
    required String patientId,
    required String accessRequestId,
    List<String>? selectedScopes,
  }) async {
    final authenticatedId = currentPatientId;
    if (authenticatedId != null && authenticatedId != patientId) {
      throw Exception('Unauthorized consent modification attempt.');
    }

    final docRef = _consentCollection(patientId).doc(accessRequestId);
    final docSnapshot = await docRef.get();

    if (!docSnapshot.exists) {
      throw Exception('Access request not found.');
    }

    final record = ConsentRecord.fromFirestoreDoc(docSnapshot);
    final now = DateTime.now();

    // Determine granted scopes (subset or full requested scopes)
    final finalGrantedScopes = selectedScopes ?? record.requestedScopes;

    // Calculate expiry date if duration is specified
    DateTime? expiresAt;
    if (record.durationHours != null && record.durationHours! > 0) {
      expiresAt = now.add(Duration(hours: record.durationHours!));
    } else if (record.expiresAt != null) {
      expiresAt = record.expiresAt;
    }

    await docRef.update({
      'status': ConsentStatus.granted,
      'grantedScopes': finalGrantedScopes,
      'grantedAt': Timestamp.fromDate(now),
      'expiresAt': expiresAt != null ? Timestamp.fromDate(expiresAt) : null,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  /// Denies consent for a pending request.
  Future<void> denyConsent({
    required String patientId,
    required String accessRequestId,
    String? reason,
  }) async {
    final authenticatedId = currentPatientId;
    if (authenticatedId != null && authenticatedId != patientId) {
      throw Exception('Unauthorized consent modification attempt.');
    }

    final docRef = _consentCollection(patientId).doc(accessRequestId);
    final now = DateTime.now();

    await docRef.update({
      'status': ConsentStatus.denied,
      'grantedScopes': [],
      'deniedAt': Timestamp.fromDate(now),
      'reason': reason,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  /// Revokes an active consent grant.
  Future<void> revokeConsent({
    required String patientId,
    required String accessRequestId,
    String? reason,
  }) async {
    final authenticatedId = currentPatientId;
    if (authenticatedId != null && authenticatedId != patientId) {
      throw Exception('Unauthorized consent modification attempt.');
    }

    final docRef = _consentCollection(patientId).doc(accessRequestId);
    final now = DateTime.now();

    await docRef.update({
      'status': ConsentStatus.revoked,
      'revokedAt': Timestamp.fromDate(now),
      'reason': reason,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }
}
