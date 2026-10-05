import 'package:flutter_test/flutter_test.dart';
import 'package:medisimbio_ui/models/consent_record.dart';

void main() {
  group('ConsentRecord Model Tests', () {
    test('ConsentRecord parsing from Map works correctly', () {
      final now = DateTime.now();
      final map = {
        'accessRequestId': 'req_123',
        'patientId': 'patient_abc',
        'requesterId': 'doctor_456',
        'requesterType': 'CLINIC',
        'requesterName': 'Metro Care Clinic',
        'organizationId': 'org_789',
        'organizationName': 'Metro Health System',
        'requestedScopes': ['MEDICAL_HISTORY', 'PRESCRIPTIONS', 'LAB_REPORTS'],
        'grantedScopes': ['MEDICAL_HISTORY', 'PRESCRIPTIONS'],
        'requestedAt': now.toIso8601String(),
        'durationHours': 24,
        'status': ConsentStatus.pending,
      };

      final record = ConsentRecord.fromMap(map, 'req_123');

      expect(record.accessRequestId, equals('req_123'));
      expect(record.patientId, equals('patient_abc'));
      expect(record.requesterName, equals('Metro Care Clinic'));
      expect(record.organizationName, equals('Metro Health System'));
      expect(record.requestedScopes.length, equals(3));
      expect(record.grantedScopes.length, equals(2));
      expect(record.status, equals(ConsentStatus.pending));
      expect(record.effectiveStatus, equals(ConsentStatus.pending));
      expect(record.isActive, isFalse);
      expect(record.isExpired, isFalse);
    });

    test('Timestamp-based expiration correctly calculates effectiveStatus', () {
      final pastExpiration = DateTime.now().subtract(const Duration(hours: 2));
      final record = ConsentRecord(
        accessRequestId: 'req_expired',
        patientId: 'patient_abc',
        requesterId: 'doc_1',
        requesterType: 'CLINIC',
        requesterName: 'City Clinic',
        requestedScopes: ['MEDICAL_HISTORY'],
        grantedScopes: ['MEDICAL_HISTORY'],
        requestedAt: DateTime.now().subtract(const Duration(hours: 26)),
        expiresAt: pastExpiration,
        status: ConsentStatus.granted,
      );

      expect(record.status, equals(ConsentStatus.granted));
      expect(record.effectiveStatus, equals(ConsentStatus.expired));
      expect(record.isExpired, isTrue);
      expect(record.isActive, isFalse);
    });

    test('Active non-expired grant evaluates isActive = true', () {
      final futureExpiration = DateTime.now().add(const Duration(hours: 12));
      final record = ConsentRecord(
        accessRequestId: 'req_active',
        patientId: 'patient_abc',
        requesterId: 'doc_1',
        requesterType: 'CLINIC',
        requesterName: 'City Clinic',
        requestedScopes: ['PRESCRIPTIONS'],
        grantedScopes: ['PRESCRIPTIONS'],
        requestedAt: DateTime.now(),
        expiresAt: futureExpiration,
        status: ConsentStatus.granted,
      );

      expect(record.effectiveStatus, equals(ConsentStatus.granted));
      expect(record.isActive, isTrue);
      expect(record.isExpired, isFalse);
    });

    test('Denied and Revoked statuses prevent access', () {
      final deniedRecord = ConsentRecord(
        accessRequestId: 'req_denied',
        patientId: 'patient_abc',
        requesterId: 'doc_1',
        requesterType: 'DOCTOR',
        requesterName: 'Dr. Smith',
        requestedScopes: ['LAB_REPORTS'],
        requestedAt: DateTime.now(),
        status: ConsentStatus.denied,
      );

      expect(deniedRecord.effectiveStatus, equals(ConsentStatus.denied));
      expect(deniedRecord.isActive, isFalse);

      final revokedRecord = ConsentRecord(
        accessRequestId: 'req_revoked',
        patientId: 'patient_abc',
        requesterId: 'doc_1',
        requesterType: 'DOCTOR',
        requesterName: 'Dr. Smith',
        requestedScopes: ['LAB_REPORTS'],
        requestedAt: DateTime.now(),
        status: ConsentStatus.revoked,
      );

      expect(revokedRecord.effectiveStatus, equals(ConsentStatus.revoked));
      expect(revokedRecord.isActive, isFalse);
    });

    test('ConsentScope label formatting helper works', () {
      expect(ConsentScope.getLabel(ConsentScope.medicalHistory), equals('Medical History'));
      expect(ConsentScope.getLabel(ConsentScope.prescriptions), equals('Prescriptions'));
      expect(ConsentScope.getLabel(ConsentScope.labReports), equals('Lab Reports'));
      expect(ConsentScope.getLabel(ConsentScope.doctorConsultations), equals('Doctor Consultations'));
      expect(ConsentScope.getLabel(ConsentScope.clinicalNotes), equals('Clinical Notes'));
      expect(ConsentScope.getLabel(ConsentScope.documents), equals('Documents'));
      expect(ConsentScope.getLabel(ConsentScope.medicationRecords), equals('Medication Records'));
      expect(ConsentScope.getLabel(ConsentScope.appointments), equals('Appointments'));
    });

    test('toFirestoreMap serialization preserves all required fields', () {
      final record = ConsentRecord(
        accessRequestId: 'req_map_test',
        patientId: 'patient_xyz',
        requesterId: 'req_456',
        requesterType: 'HOSPITAL',
        requesterName: 'General Hospital',
        requestedScopes: ['MEDICAL_HISTORY', 'LAB_REPORTS'],
        durationHours: 48,
        requestedAt: DateTime(2026, 10, 5, 10, 0),
        status: ConsentStatus.pending,
      );

      final map = record.toFirestoreMap();

      expect(map['accessRequestId'], equals('req_map_test'));
      expect(map['patientId'], equals('patient_xyz'));
      expect(map['requesterType'], equals('HOSPITAL'));
      expect(map['requesterName'], equals('General Hospital'));
      expect(map['requestedScopes'], equals(['MEDICAL_HISTORY', 'LAB_REPORTS']));
      expect(map['durationHours'], equals(48));
      expect(map['status'], equals(ConsentStatus.pending));
    });
  });
}
