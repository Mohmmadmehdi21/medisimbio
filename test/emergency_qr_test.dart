import 'package:flutter_test/flutter_test.dart';
import 'package:medisimbio_ui/models/emergency_qr_record.dart';

void main() {
  group('Phase 1L — Emergency QR Model & Policy Unit Tests', () {
    test('EmergencyQrRecord constructor and payload reference integrity', () {
      final now = DateTime.now();
      final record = EmergencyQrRecord(
        emergencyQrId: 'EMGQR-881299-1001',
        patientId: 'user_123',
        medId: 'MD-8812-9901',
        status: EmergencyQrStatus.active,
        createdAt: now,
        expiresAt: now.add(const Duration(days: 90)),
        qrPayload: 'medisimbio://emergency/qr/EMGQR-881299-1001',
      );

      expect(record.emergencyQrId, equals('EMGQR-881299-1001'));
      expect(record.patientId, equals('user_123'));
      expect(record.medId, equals('MD-8812-9901'));
      expect(record.version, equals('1.0'));
      expect(record.status, equals(EmergencyQrStatus.active));
      expect(record.effectiveStatus, equals(EmergencyQrStatus.active));
      expect(record.isActive, isTrue);

      // Verify QR payload is a secure reference token, NOT raw patient medical data
      expect(record.qrPayload, startsWith('medisimbio://emergency/qr/'));
      expect(record.qrPayload, isNot(contains('prescriptions')));
      expect(record.qrPayload, isNot(contains('labReports')));
      expect(record.qrPayload, isNot(contains('medicalHistory')));
    });

    test('Timestamp expiration correctly evaluates effectiveStatus', () {
      final pastExpiration = DateTime.now().subtract(const Duration(days: 1));
      final record = EmergencyQrRecord(
        emergencyQrId: 'EMGQR-EXPIRED-01',
        patientId: 'user_123',
        medId: 'MD-8812-9901',
        status: EmergencyQrStatus.active,
        createdAt: DateTime.now().subtract(const Duration(days: 91)),
        expiresAt: pastExpiration,
        qrPayload: 'medisimbio://emergency/qr/EMGQR-EXPIRED-01',
      );

      expect(record.status, equals(EmergencyQrStatus.active));
      expect(record.effectiveStatus, equals(EmergencyQrStatus.expired));
      expect(record.isActive, isFalse);
    });

    test('Disabled QR status evaluates isActive = false', () {
      final record = EmergencyQrRecord(
        emergencyQrId: 'EMGQR-DISABLED-01',
        patientId: 'user_123',
        medId: 'MD-8812-9901',
        status: EmergencyQrStatus.disabled,
        createdAt: DateTime.now(),
        qrPayload: 'medisimbio://emergency/qr/EMGQR-DISABLED-01',
      );

      expect(record.effectiveStatus, equals(EmergencyQrStatus.disabled));
      expect(record.isActive, isFalse);
    });

    test('LimitedEmergencyInfo maps policy-filtered minimal fields', () {
      final info = LimitedEmergencyInfo(
        patientId: 'user_123',
        medId: 'MD-8812-9901',
        patientName: 'John Doe',
        bloodGroup: 'O+',
        allergies: 'Penicillin',
        existingConditions: 'Asthma',
        emergencyName: 'Jane Doe',
        emergencyRelationship: 'Spouse',
        emergencyMobile: '+19876543210',
        authorizedAt: DateTime(2026, 10, 5, 12, 0),
        policyName: 'EMERGENCY_MINIMUM_NECESSARY_V1',
      );

      expect(info.patientId, equals('user_123'));
      expect(info.medId, equals('MD-8812-9901'));
      expect(info.bloodGroup, equals('O+'));
      expect(info.allergies, equals('Penicillin'));
      expect(info.existingConditions, equals('Asthma'));
      expect(info.emergencyName, equals('Jane Doe'));
      expect(info.policyName, equals('EMERGENCY_MINIMUM_NECESSARY_V1'));

      final map = info.toMap();
      expect(map['patientId'], equals('user_123'));
      expect(map['medId'], equals('MD-8812-9901'));
      expect(map['bloodGroup'], equals('O+'));
    });

    test('fromFirestoreDoc and toFirestoreMap round-trip serialization', () {
      final now = DateTime.now();
      final original = EmergencyQrRecord(
        emergencyQrId: 'EMGQR-SERIAL-99',
        patientId: 'user_456',
        medId: 'MD-1122-3344',
        version: '1.0',
        status: EmergencyQrStatus.active,
        createdAt: now,
        expiresAt: now.add(const Duration(days: 30)),
        qrPayload: 'medisimbio://emergency/qr/EMGQR-SERIAL-99',
      );

      final map = original.toFirestoreMap();
      final restored = EmergencyQrRecord.fromMap(map, 'EMGQR-SERIAL-99');

      expect(restored.emergencyQrId, equals('EMGQR-SERIAL-99'));
      expect(restored.patientId, equals('user_456'));
      expect(restored.medId, equals('MD-1122-3344'));
      expect(restored.status, equals(EmergencyQrStatus.active));
      expect(restored.qrPayload, equals('medisimbio://emergency/qr/EMGQR-SERIAL-99'));
    });
  });
}
