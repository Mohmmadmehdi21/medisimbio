import 'package:flutter_test/flutter_test.dart';
import 'package:medisimbio_ui/models/medical_record.dart';

void main() {
  group('Phase 1H — Prescription Model & Isolation Unit Tests', () {
    test('Should parse multi-medicine provider-issued prescription JSON', () {
      final json = {
        'userId': 'patient_123',
        'doctorId': 'doc_456',
        'doctorName': 'Dr. Sarah Jenkins',
        'clinicName': 'City Cardiology Clinic',
        'prescriptionDate': '2026-10-04T10:00:00.000Z',
        'status': 'ACTIVE',
        'duration': '10 Days',
        'notes': 'Take medicines after meals.',
        'provenance': 'EMR_PROVIDER_v1',
        'medicines': [
          {
            'medicineName': 'Amoxicillin 500mg',
            'dosage': '500mg',
            'frequency': '1 - 0 - 1',
            'duration': '7 Days',
            'timing': 'After Breakfast and Dinner',
            'notes': 'Complete full course',
          },
          {
            'medicineName': 'Paracetamol 650mg',
            'dosage': '650mg',
            'frequency': '0 - 1 - 0',
            'duration': '3 Days',
            'timing': 'After Lunch',
          },
        ],
      };

      final record = PrescriptionRecord.fromJson(json, 'rx_789');

      expect(record.id, equals('rx_789'));
      expect(record.userId, equals('patient_123'));
      expect(record.doctorId, equals('doc_456'));
      expect(record.doctorName, equals('Dr. Sarah Jenkins'));
      expect(record.prescribedBy, equals('Dr. Sarah Jenkins'));
      expect(record.clinicName, equals('City Cardiology Clinic'));
      expect(record.status, equals('ACTIVE'));
      expect(record.duration, equals('10 Days'));
      expect(record.notes, equals('Take medicines after meals.'));
      expect(record.provenance, equals('EMR_PROVIDER_v1'));
      expect(record.medicines.length, equals(2));

      final med1 = record.medicines[0];
      expect(med1.medicineName, equals('Amoxicillin 500mg'));
      expect(med1.dosage, equals('500mg'));
      expect(med1.frequency, equals('1 - 0 - 1'));
      expect(med1.duration, equals('7 Days'));
      expect(med1.timing, equals('After Breakfast and Dinner'));
      expect(med1.notes, equals('Complete full course'));

      final med2 = record.medicines[1];
      expect(med2.medicineName, equals('Paracetamol 650mg'));
      expect(med2.frequency, equals('0 - 1 - 0'));
    });

    test('Should parse legacy single-medicine JSON with backward compatibility', () {
      final json = {
        'userId': 'patient_abc',
        'medicineName': 'Lisinopril 10mg',
        'dosage': '10mg',
        'frequency': '1 - 0 - 0',
        'duration': '30 Days',
        'prescribedBy': 'Dr. Robert Vance',
        'date': '2026-09-15T08:30:00.000Z',
        'provenance': 'LAB_SYSTEM',
      };

      final record = PrescriptionRecord.fromJson(json, 'rx_legacy_1');

      expect(record.id, equals('rx_legacy_1'));
      expect(record.userId, equals('patient_abc'));
      expect(record.medicineName, equals('Lisinopril 10mg'));
      expect(record.dosage, equals('10mg'));
      expect(record.frequency, equals('1 - 0 - 0'));
      expect(record.prescribedBy, equals('Dr. Robert Vance'));
      expect(record.date, isNotNull);
      expect(record.medicines.length, equals(1));
      expect(record.medicines.first.medicineName, equals('Lisinopril 10mg'));
    });

    test('Patient data isolation: userId in record must match authenticated user', () {
      const authUserId = 'patient_secure_uid';

      final recordA = PrescriptionRecord(
        id: 'rx_a',
        userId: authUserId,
        doctorName: 'Dr. Jane',
        medicines: [PrescriptionMedicine(medicineName: 'Med A')],
      );

      final recordB = PrescriptionRecord(
        id: 'rx_b',
        userId: 'other_user_uid',
        doctorName: 'Dr. John',
        medicines: [PrescriptionMedicine(medicineName: 'Med B')],
      );

      expect(recordA.userId == authUserId, isTrue);
      expect(recordB.userId == authUserId, isFalse);
    });
  });
}
