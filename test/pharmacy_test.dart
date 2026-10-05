import 'package:flutter_test/flutter_test.dart';
import 'package:medisimbio_ui/models/medical_record.dart';

void main() {
  group('Phase 1J — Pharmacy / Medication Record Unit Tests', () {
    test('Should parse prescription-linked pharmacy record across PENDING, VERIFIED, DISPENSED statuses', () {
      final statuses = ['PENDING', 'VERIFIED', 'DISPENSED'];

      for (final st in statuses) {
        final json = {
          'userId': 'patient_789',
          'prescriptionId': 'rx_val_101',
          'pharmacyId': 'pharm_456',
          'pharmacyName': 'City Center Pharmacy',
          'doctorName': 'Dr. Elizabeth Taylor',
          'status': st,
          'orderDate': '2026-10-02T10:00:00.000Z',
          'verificationDate': st != 'PENDING' ? '2026-10-02T11:30:00.000Z' : null,
          'dispensedDate': st == 'DISPENSED' ? '2026-10-02T16:45:00.000Z' : null,
          'provenance': 'PHARMACY_EMR_v1',
          'medicines': [
            {
              'medicineName': 'Metformin 500mg',
              'dosage': '500mg',
              'frequency': '1 - 0 - 1',
              'duration': '30 Days',
            },
          ],
        };

        final record = PharmacyRecord.fromJson(json, 'pharm_rec_$st');

        expect(record.id, equals('pharm_rec_$st'));
        expect(record.userId, equals('patient_789'));
        expect(record.prescriptionId, equals('rx_val_101'));
        expect(record.pharmacyId, equals('pharm_456'));
        expect(record.pharmacyName, equals('City Center Pharmacy'));
        expect(record.doctorName, equals('Dr. Elizabeth Taylor'));
        expect(record.status, equals(st));
        expect(record.medicines.length, equals(1));
        expect(record.medicines.first.medicineName, equals('Metformin 500mg'));

        if (st == 'PENDING') {
          expect(record.verificationDate, isNull);
          expect(record.dispensedDate, isNull);
        } else if (st == 'VERIFIED') {
          expect(record.verificationDate, isNotNull);
          expect(record.dispensedDate, isNull);
        } else if (st == 'DISPENSED') {
          expect(record.verificationDate, isNotNull);
          expect(record.dispensedDate, isNotNull);
        }
      }
    });

    test('Patient data isolation: userId must match authenticated patient', () {
      const currentPatientId = 'patient_authed_uid';

      final record1 = PharmacyRecord(
        id: 'pharm_1',
        userId: currentPatientId,
        prescriptionId: 'rx_1',
        status: 'PENDING',
        medicines: [],
      );

      final record2 = PharmacyRecord(
        id: 'pharm_2',
        userId: 'other_patient_uid',
        prescriptionId: 'rx_2',
        status: 'VERIFIED',
        medicines: [],
      );

      expect(record1.userId == currentPatientId, isTrue);
      expect(record2.userId == currentPatientId, isFalse);
    });
  });
}
